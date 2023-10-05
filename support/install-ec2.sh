#!/bin/bash

self=$(whoami)
echo "Setup starting as ${self} : ${0}"
if [ $UID -eq 0 ]; then
	user="ubuntu"
	cp ${0} /tmp/setup-sd.sh
	chmod a+x /tmp/setup-sd.sh
	chown ubuntu:ubuntu /tmp/setup-sd.sh
	echo "restarting in '$(pwd)': su ${user} -c /tmp/setup-sd.sh"
	su "$user" -c /tmp/setup-sd.sh
	rm -f /tmp/setup-sd.sh
	exit 0
fi

cd /home/ubuntu && pwd
export DEBIAN_FRONTEND=noninteractive

sudo apt -qq -o DPkg::lock::Timeout=-1 update && \
	sudo apt -qq -y -o DPkg::lock::Timeout=-1 upgrade && \
	sudo apt -qq -y -o=Dpkg::Use-Pty=0 -o DPkg::lock::Timeout=-1 install python3-venv jq libtcmalloc-minimal4 plocate nvtop && \
	sudo updatedb && \
	sudo apt clean

echo "installing yarn, node and nvm"
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt -qq update && sudo apt -yq -o=Dpkg::Use-Pty=0 install yarn
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | /usr/bin/bash
export NVM_DIR="/home/ubuntu/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

nvm install $(nvm list-remote | tail -n 1 | xargs)
node -v
echo "yarn, node and nvm installed"

echo "installing stable diffusion"

git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
pushd stable-diffusion-webui

# install the StableStudio ++ plugins

echo "installing extensions"
pushd extensions
git clone https://github.com/jtydhr88/sd-webui-StableStudio.git
git clone https://github.com/jtydhr88/sd-3dmodel-loader.git
git clone https://github.com/Mikubill/sd-webui-controlnet.git
git clone https://github.com/nonnonstop/sd-webui-3d-open-pose-editor
popd

echo "installing models"
pushd models
pushd Stable-diffusion
wget -q https://huggingface.co/CompVis/stable-diffusion-v-1-4-original/resolve/main/sd-v1-4.ckpt
popd
popd

wget -q https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.4.pth

# install controlnet models
echo "installing controlnet"

mkdir -p models/ControlNet
pushd models
pushd ControlNet

links=(
control_v11p_sd15_canny
control_v11p_sd15_mlsd
control_v11f1p_sd15_depth
control_v11p_sd15_normalbae
control_v11p_sd15_seg
control_v11p_sd15_inpaint
control_v11p_sd15_lineart
control_v11p_sd15s2_lineart_anime
control_v11p_sd15_openpose
control_v11p_sd15_scribble
control_v11p_sd15_softedge
control_v11e_sd15_shuffle
control_v11e_sd15_ip2p
control_v11f1e_sd15_tile
)

base="https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main"
for i in ${links[@]}; do
	final="${base}/${i}.pth"
	echo "downloading : $final"
    wget -q $final
	final="${base}/${i}.yaml"
	echo "downloading : $final"
	wget -q $final
done

popd
popd

echo "stable diffusion installed"

###### setup our options
echo "setting up custom Automatic 111 options"
echo "export IGNORE_CMD_ARGS_ERRORS=\"TRUE\"" >> webui-user.sh
echo "export 'PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512'" >> webui-user.sh
echo "export COMMANDLINE_ARGS=\"--skip-torch-cuda-test --no-half --no-tests --enable-insecure-extension-access --api --listen --port 7860\"" >> webui-user.sh

###### initial setup
echo "forcing an Automatic 111 setup"
export LAUNCH_SCRIPT="mysetup.py"
/usr/bin/bash -c 'cat > mysetup.py' <<EOF
import launch

if name == "main":
	launch.prepare_environment()

EOF
./webui.sh --no-half --skip-torch-cuda-test
rm -f ./mysetup.py
export LAUNCH_SCRIPT="launch.py"
echo "setup finished"

# create a service config
echo "creating and installing the service"

sudo /usr/bin/bash -c 'cat > /usr/lib/systemd/system/sd-web-ui.service' <<EOF 

[Unit]
Description=Stable Diffusion Web UI.

[Service]
ExecStartPre=/bin/sleep 30
Type=idle
User=ubuntu
Group=ubuntu
WorkingDirectory=/home/ubuntu/stable-diffusion-webui
ExecStart=/home/ubuntu/stable-diffusion-webui/webui.sh
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo chmod 644 /usr/lib/systemd/system/sd-web-ui.service
sudo cp /usr/lib/systemd/system/sd-web-ui.service /etc/systemd/system/
sudo systemctl enable sd-web-ui
echo "service installed and enabled"
popd

sudo reboot
