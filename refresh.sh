#!/bin/bash

dots=(".zshrc" ".config/nvim/init.vim" ".bash_aliases")
for dot in "${dots[@]}"; do
    echo "restoring $HOME/${dot}.."
    cp $HOME/${dot} ./${dot}
done
