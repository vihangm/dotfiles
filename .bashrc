#
# ~/.bashrc
#
# This is the initialization file for bash, and is read each time an instance of
# your shell executes. A shell starts up, for example, when you open a new xterm
# window, remotely log on to another machine, or type 'bash' or 'sh' to start a
# new shell explicitly.
#
# Refer to bash(1) for more information.
#
# The shell treats lines beginning with # as comments.
#
# EDIT THIS FILE to customize *only* shell-specific options for bash (e.g.
# prompt). All other shell options go in ~/.environment.
#

# Set the shell to prevent programs from dumping core.
ulimit -c 0

# set history settings
export HISTCONTROL=erasedups
export HISTSIZE=1000000
export PROMPT_COMMAND='history -a'
shopt -s histappend

export ANDROID_SDK=/Users/$USER/adt-bundle-mac/sdk
export ANDROID_NDK=/Users/$USER/android-ndk-r8b
export EDITOR=`which vim`
export SVN_EDITOR=`which vim`
export GIT_EDITOR=`which vim`
export PAGER=`which less`
export LS_COLORS="no=00:\
fi=00:\
di=01;36:\
ln=01;36:\
pi=40;33:\
so=01;35:\
do=01;35:\
bd=40;33;01:\
cd=40;33;01:\
or=40;31;01:\
ex=01;32:\
*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:\
*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:\
*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:\
*.ogg=01;35:*.mp3=01;35:*.wav=01;35:\
";
export GREP_OPTIONS='--color=auto'

# Compatability options
# The BSD sed on mac uses -E, while the GNU one on linux uses -r
(echo '' | sed -r /GG/g &> /dev/null)
if [ $? -eq "0" ]; then
  export SED_EXT='-r'
else
  export SED_EXT='-E'
fi


# GNU vs BSD ls for color
(ls --color=tty &> /dev/null)
if [ $? -eq 0 ]; then
  export LS_COLOR='--color=tty'
else
  export LS_COLOR='-G'
fi;

# Alias
alias ls='ls -lh $LS_COLOR'
alias la='ls -lah $LS_COLOR'
alias ..='cl ..'
alias clr='clear'

# Auto completion
complete -cf sudo
complete -cf which

#### RANDOM FUNCTIONS #####
# awesome!  CD AND LA. I never use 'cd' anymore...
function cl(){ cd "$@" && la; }
# Two standard functions to change $PATH
add_path() { export PATH="$PATH:$1"; }
add_pre_path() { export PATH="$1:$PATH"; }

# Extract based upon file ext
function ex() {
     if [ -f $1 ] ; then
         case $1 in
             *.tar.bz2)   tar xvjf $1;;
             *.tar.gz)    tar xvzf $1;;
             *.bz2)       bunzip2 $1;;
             *.rar)       unrar x $1;;
             *.gz)        gunzip $1;;
             *.tar)       tar xvf $1;;
             *.tbz2)      tar xvjf $1;;
             *.tgz)       tar xvzf $1;;
             *.zip)       unzip $1;;
             *.Z)         uncompress $1;;
             *.7z)        7z x $1;;
             *)           echo "'$1' cannot be extracted via >extract<";;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

PROMPT_COMMAND='RET=$?; if [[ $RET -eq 0 ]]; then echo -ne "\033[0;32m$RET\033[0m"; else echo -ne "\033[0;31m$RET\033[0m"; fi; echo -n " "'
