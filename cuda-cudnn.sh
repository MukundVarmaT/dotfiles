#!/bin/bash
set -e

# echo in style
spatialPrint() {
    echo ""
    echo ""
    echo "$1"
    echo "================================"
}

# NOTE: the execute() function doesn't handle pipes well
execute () {
    echo "$ $*"
    OUTPUT=$($@ 2>&1)
    if [ $? -ne 0 ]; then
        echo "$OUTPUT"
        echo ""
        echo "Failed to Execute $*" >&2
        exit 1
    fi
}

# if nvidia drivers are installed
if which nvidia-smi > /dev/null; then
    spatialPrint "nvidia drivers succesfully installed!"
    read -p "proceed to install developement libraries? y(yes) / s(skip): " tempvar
    tempvar=${tempvar:-s}

    if [ "$tempvar" = "y" ]; then
        if [[ ! $(command -v nvcc -V) ]]; then
            read -p "cuda link (https://developer.nvidia.com/cuda-toolkit-archive): " cuda_link
            cuda_link=${cuda_link:-"https://developer.nvidia.com/cuda-10.1-download-archive-update2"}

            cuda_instr_block=$(wget -q -O - $cuda_link | grep wget | head -n 1)
            cuda_download_command=$(echo ${cuda_instr_block} | sed 's#\(.*\)"cudaBash">.*#\1#' | sed 's#.*"cudaBash">\([^<]*\).*#\1#' )
            if [ ! -f ./misc/cuda.run ]; then
                $cuda_download_command -O ./misc/cuda.run
            fi
            execute sudo sh ./misc/cuda.run --silent --toolkit --run-nvidia-xconfig
        fi

        if [[ (! -n $(echo $PATH | grep 'cuda')) && ( -d "/usr/local/cuda" ) ]]; then
            echo "# cuda" >> ~/.zshrc
            echo "export PATH=/usr/local/cuda/bin:\$PATH" >> ~/.zshrc
            echo "export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64:\$LD_LIBRARY_PATH" >> ~/.zshrc
            echo "export CUDA_HOME=/usr/local/cuda" >> ~/.zshrc
        fi

        if [ ! -f "/usr/local/cuda/include/cudnn.h" ]; then
            spatialPrint "cudnn"
            read -p "version (https://developer.nvidia.com/rdp/cudnn-download): " version
            version=${version:-"7.6.5"}
            v=$(printf %.1s "$version")
            if [ ! -f ./misc/cudnn.tgz ]; then
                mv ~/Downloads/cudnn*.tgz ./misc/cudnn.tgz
            fi
            execute tar -zxf ./misc/cudnn.tgz
            execute sudo cp ./cuda/include/cudnn*.h /usr/local/cuda/include
            execute sudo cp -P ./cuda/lib64/libcudnn* /usr/local/cuda/lib64
            execute sudo chmod a+r /usr/local/cuda/include/cudnn*.h /usr/local/cuda/lib64/libcudnn*

            execute sudo ln -sf /usr/local/cuda/lib64/libcudnn.so.$version /usr/local/cuda/lib64/libcudnn.so.$v
            execute sudo ln -sf /usr/local/cuda/lib64/libcudnn.so.$v /usr/local/cuda/lib64/libcudnn.so
            rm -rf ./cuda/
        fi
    fi

    if [[ ! $(command -v nvtop) ]]; then
        spatialPrint "nvtop"
        execute sudo apt-get install cmake libncurses5-dev git -y
        if [[ ! -d "nvtop" ]]; then
            execute git clone --quiet https://github.com/Syllo/nvtop.git
        else
        (
            cd nvtop || exit
            execute git pull origin master
        )
        fi
        execute mkdir -p nvtop/build
        cd nvtop/build
        execute cmake -DCMAKE_BUILD_TYPE=Optimized -DNVML_RETRIEVE_HEADER_ONLINE=True ..
        execute make
        execute sudo make install
        cd ../../
        rm -rf ./nvtop/
    fi
    spatialPrint "nvidia-docker"
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
    execute sudo apt-get update
    execute sudo apt-get install -y nvidia-container-toolkit
    execute sudo systemctl restart docker
fi

spatialPrint "pytorch install"
PIP="pip3 install --user"
read -p "(https://pytorch.org/get-started/locally/) d(default) / c(custom) / s(skip): " tempvar
tempvar=${tempvar:-s}
if [ "$tempvar" = "d" ]; then
    execute $PIP torch torchvision torchaudio
elif [ "$tempvar" = "c" ]; then
    read -p "pip3 install --user " tempvar
    execute $PIP $tempvar
fi

spatialPrint "script finished!"
