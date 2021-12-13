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
        echo "failed to execute $*" >&2
        exit 1
    fi
}

if [[ -n $(echo $SHELL | grep "zsh") ]] ; then
    SHELLRC=~/.zshrc
elif [[ -n $(echo $SHELL | grep "bash") ]] ; then
    SHELLRC=~/.bashrc
else
    echo "unidentified shell $SHELL"
    exit
fi

if [[ ! -d "misc" ]]; then
    mkdir misc
fi

# if nvidia drivers are installed
if which nvidia-smi > /dev/null; then
    spatialPrint "nvidia drivers succesfully installed!"
    read -p "proceed to install developement libraries? y(yes) / s(skip): " tempvar
    tempvar=${tempvar:-s}

    if [ "$tempvar" = "y" ]; then
        if [[ ! $(command -v nvcc -V) ]]; then
            spatialPrint "installing CUDA"
            read -p "archive link (https://developer.nvidia.com/cuda-toolkit-archive) [default - https://developer.nvidia.com/cuda-10.1-download-archive-update2]: " cuda_link
            cuda_link=${cuda_link:-"https://developer.nvidia.com/cuda-10.1-download-archive-update2"}

            cuda_instr_block=$(wget -q -O - $cuda_link | grep wget | head -n 1)
            cuda_download_command=$(echo ${cuda_instr_block} | sed 's#\(.*\)"cudaBash">.*#\1#' | sed 's#.*"cudaBash">\([^<]*\).*#\1#' )
            if [ ! -f ./misc/cuda.run ]; then
                $cuda_download_command -O ./misc/cuda.run
            fi
            execute sudo sh ./misc/cuda.run --silent --toolkit --run-nvidia-xconfig
        fi

        if [[ (! -n $(echo $PATH | grep 'cuda')) && ( -d "/usr/local/cuda" ) ]]; then
            echo "# cuda" >> $SHELLRC
            echo "export PATH=/usr/local/cuda/bin:\$PATH" >> $SHELLRC
            echo "export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64:\$LD_LIBRARY_PATH" >> $SHELLRC
            echo "export CUDA_HOME=/usr/local/cuda" >> $SHELLRC
        fi

        if [ ! -f "/usr/local/cuda/include/cudnn.h" ]; then
            spatialPrint "setting up CUDNN"
            read -p "download before proceeding (https://developer.nvidia.com/rdp/cudnn-download). Downloaded version [default: 7.6.5]: " version
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

    spatialPrint "install pytorch"
    PIP="pip3 install --user"
    read -p "(https://pytorch.org/get-started/locally/) d(default) / c(custom) / s(skip): " tempvar
    tempvar=${tempvar:-s}
    if [ "$tempvar" = "d" ]; then
        execute $PIP torch torchvision torchaudio
    elif [ "$tempvar" = "c" ]; then
        read -p "pip3 install --user (fill rest)" tempvar
        execute $PIP $tempvar
    fi
    spatialPrint "check pytorch installation"
    python3 ./test_torch.py

    spatialPrint "script finished!"
else
    spatialPrint "nvidia drivers NOT installed, install before running this script!"
fi

