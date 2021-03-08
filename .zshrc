# forget older history
setopt HIST_IGNORE_ALL_DUPS
bindkey -e

# remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  # Update static initialization script if it does not exist or it's outdated, before sourcing it
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
source ${ZIM_HOME}/init.zsh

# up-down for searching history
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

zmodload -F zsh/terminfo +p:terminfo
if [[ -n ${terminfo[kcuu1]} && -n ${terminfo[kcud1]} ]]; then
  bindkey ${terminfo[kcuu1]} history-substring-search-up
  bindkey ${terminfo[kcud1]} history-substring-search-down
fi

bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# source aliases
if [ -f ~/.bash_aliases ]; then
  source ~/.bash_aliases
fi

# switching to 256-bit colour by default so that zsh-autosuggestion's suggestions are not suggested in white, but in grey instead
export TERM=xterm-256color

# extract archives
function extract() {

    if [[ "$#" -lt 1 ]]; then
        echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
        return 1 #not enough args
    fi

    if [[ ! -e "$1" ]]; then
      echo -e "File does not exist!"
      return 2 # File not found
    fi

    DESTDIR="."

    filename=`basename "$1"`

    case "${filename##*.}" in
      tar)
        echo -e "Extracting $1 to $DESTDIR: (uncompressed tar)"
        tar xvf "$1" -C "$DESTDIR"
        ;;
      gz)
        echo -e "Extracting $1 to $DESTDIR: (gip compressed tar)"
        tar xvfz "$1" -C "$DESTDIR"
        ;;
      tgz)
        echo -e "Extracting $1 to $DESTDIR: (gip compressed tar)"
        tar xvfz "$1" -C "$DESTDIR"
        ;;
      xz)
        echo -e "Extracting  $1 to $DESTDIR: (gip compressed tar)"
        tar xvf -J "$1" -C "$DESTDIR"
        ;;
      bz2)
        echo -e "Extracting $1 to $DESTDIR: (bzip compressed tar)"
        tar xvfj "$1" -C "$DESTDIR"
        ;;
      tbz2)
        echo -e "Extracting $1 to $DESTDIR: (tbz2 compressed tar)"
        tar xvjf "$1" -C "$DESTDIR"
        ;;
      zip)
        echo -e "Extracting $1 to $DESTDIR: (zipp compressed file)"
        unzip "$1" -d "$DESTDIR"
        ;;
      lzma)
        echo -e "Extracting $1 : (lzma compressed file)"
        unlzma "$1"
        ;;
      rar)
        echo -e "Extracting $1 to $DESTDIR: (rar compressed file)"
        unrar x "$1" "$DESTDIR"
        ;;
      7z)
        echo -e  "Extracting $1 to $DESTDIR: (7zip compressed file)"
        7za e "$1" -o "$DESTDIR"
        ;;
      xz)
        echo -e  "Extracting $1 : (xz compressed file)"
        unxz  "$1"
        ;;
      exe)
        cabextract "$1"
        ;;
      *)
        echo -e "Unknown archive format!"
        return
        ;;
    esac
}

# cuda
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH
export CUDA_HOME=/usr/local/cuda

# data directory
export DATA=/data/
