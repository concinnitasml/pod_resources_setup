#!/bin/bash

# Ensure aria2 is installed for downloads
if ! command -v aria2c &> /dev/null; then
    apt-get update && apt-get install -y aria2
fi

# --- Helper Functions ---
dl_model() {
    local url="$1"
    local full_dest="$2"
    local auth="$3"
    
    local dest_dir=$(dirname "$full_dest")
    local dest_file=$(basename "$full_dest")

    mkdir -p "$dest_dir"

    if [ ! -f "$full_dest" ]; then
        echo "Downloading $dest_file..."
        if [ "$auth" == "auth" ]; then
            aria2c -x 16 -s 16 -k 1M --console-log-level=error --summary-interval=10 \
            --header="Authorization: Bearer $HF_TOKEN" \
            -d "$dest_dir" -o "$dest_file" "$url"
        else
            aria2c -x 16 -s 16 -k 1M --console-log-level=error --summary-interval=10 \
            -d "$dest_dir" -o "$dest_file" "$url"
        fi
    else
        echo "Skipping $dest_file (already exists)"
    fi
}

install_node() {
    local node_dir="/workspace/ComfyUI/custom_nodes/$1"
    local repo_url="$2"
    
    if [ ! -d "$node_dir" ]; then
        echo "Installing custom node: $1"
        git clone "$repo_url" "$node_dir"
        if [ -f "$node_dir/requirements.txt" ]; then
            $V_PIP install -r "$node_dir/requirements.txt"
        fi
    else
        echo "Node $1 already installed."
    fi
}

# --- Directory Setup ---
mkdir -p /workspace/ComfyUI/models/ckpts
mkdir -p /workspace/ComfyUI/models/diffusion_models
mkdir -p /workspace/ComfyUI/models/unet
mkdir -p /workspace/ComfyUI/models/text_encoders
mkdir -p /workspace/ComfyUI/models/vae
mkdir -p /workspace/ComfyUI/models/loras
mkdir -p /workspace/output
mkdir -p /workspace/input

# --- Create Extra Paths YAML ---
cat > /workspace/ComfyUI/extra_model_paths.yaml <<YAML
comfyui:
    base_path: /workspace/ComfyUI
    is_default: true
    checkpoints: models/ckpts/
    diffusion_models: |
         models/diffusion_models
         models/unet
    input: /workspace/input
    output: /workspace/output
YAML

# --- Model Downloads ---
# dl_model "https://huggingface.co/black-forest-labs/FLUX.2-klein-base-9B/resolve/main/flux-2-klein-base-9b.safetensors" "/workspace/ComfyUI/models/diffusion_models/flux-2-klein-base-9b.safetensors" "auth"
# dl_model "https://huggingface.co/black-forest-labs/FLUX.2-klein-base-9b-fp8/resolve/main/flux-2-klein-base-9b-fp8.safetensors" "/workspace/ComfyUI/models/diffusion_models/flux-2-klein-base-9b-fp8.safetensors" "auth"

# dl_model "https://huggingface.co/black-forest-labs/FLUX.2-klein-9B/resolve/main/flux-2-klein-9b.safetensors" "/workspace/ComfyUI/models/diffusion_models/flux-2-klein-9b.safetensors" "auth"
dl_model "https://huggingface.co/black-forest-labs/FLUX.2-klein-9b-fp8/resolve/main/flux-2-klein-9b-fp8.safetensors" "/workspace/ComfyUI/models/diffusion_models/flux-2-klein-9b-fp8.safetensors" "auth"

# dl_model "https://huggingface.co/Comfy-Org/flux2-klein-9B/resolve/main/split_files/text_encoders/qwen_3_8b.safetensors" "/workspace/ComfyUI/models/text_encoders/qwen_3_8b.safetensors"
dl_model "https://huggingface.co/Comfy-Org/flux2-klein-9B/resolve/main/split_files/text_encoders/qwen_3_8b_fp8mixed.safetensors" "/workspace/ComfyUI/models/text_encoders/qwen_3_8b_fp8mixed.safetensors"

# dl_model "https://huggingface.co/black-forest-labs/FLUX.2-klein-base-4B/resolve/main/flux-2-klein-base-4b.safetensors" "/workspace/ComfyUI/models/diffusion_models/flux-2-klein-base-4b.safetensors" "auth"
# dl_model "https://huggingface.co/black-forest-labs/FLUX.2-klein-base-4b-fp8/resolve/main/flux-2-klein-base-4b-fp8.safetensors" "/workspace/ComfyUI/models/diffusion_models/flux-2-klein-base-4b-fp8.safetensors" "auth"

# dl_model "https://huggingface.co/black-forest-labs/FLUX.2-klein-4B/resolve/main/flux-2-klein-4b.safetensors" "/workspace/ComfyUI/models/diffusion_models/flux-2-klein-4b.safetensors" "auth"
# dl_model "https://huggingface.co/black-forest-labs/FLUX.2-klein-4b-fp8/resolve/main/flux-2-klein-4b-fp8.safetensors" "/workspace/ComfyUI/models/diffusion_models/flux-2-klein-4b-fp8.safetensors" "auth"

# dl_model "https://huggingface.co/Comfy-Org/flux2-klein-4B/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors" "/workspace/ComfyUI/models/text_encoders/qwen_3_4b.safetensors"
# dl_model "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b_fp8_mixed.safetensors" "/workspace/ComfyUI/models/text_encoders/qwen_3_4b_fp8mixed.safetensors"

dl_model "https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors" "/workspace/ComfyUI/models/vae/flux2-vae.safetensors"

# --- Custom Node Installs ---
install_node "ComfyUI-Manager" "https://github.com/ltdrdata/ComfyUI-Manager.git"
install_node "ComfyMath" "https://github.com/evanspearman/ComfyMath.git"
# install_node "rgthree-comfy" "https://github.com/rgthree/rgthree-comfy"
# install_node "ComfyUI_tinyterraNodes" "https://github.com/TinyTerra/ComfyUI_tinyterraNodes"
# install_node "ComfyUI-Custom-Scripts" "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"

# Clean cache to save space
rm -rf /workspace/.cache
