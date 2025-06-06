# ██████  ██████  ███████ ███████ ████████ ██   ██    ██████   ██████
# ██   ██ ██   ██ ██      ██         ██    ██   ██    ██   ██ ██
# ██████  ██████  █████   █████      ██    ███████    ██████  ██
# ██      ██   ██ ██      ██         ██    ██   ██    ██   ██ ██
# ██      ██   ██ ███████ ███████    ██    ██   ██ ██ ██   ██  ██████


export HISTCONTROL=ignoredups:erasedups            # no duplicate entries

# Source global definitions
if [ -f /etc/zshrc ]; then
	. /etc/zshrc
fi

# User specific environment
# Had to install an updated version of clang to work with C++20
# Prepend to PATH to supercede system version
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="/opt/homebrew/opt/llvm/bin:$PATH"
fi

# Add Brew, Go, and Rust tools/libraries to PATH.
export GNUGREPBIN=$(brew --prefix grep)/libexec/gnubin
export BINUTILSBIN=$(brew --prefix binutils)/libexec/gnubin
export GNUTARBIN=$(brew --prefix gnu-tar)/libexec/gnubin
export GOPATH=~/go
export GOBIN=~/go/bin
export CARGOBIN=$HOME/.cargo/bin

export PATH=$GNUGREPBIN:$CARGOBIN:$GOBIN:$PATH

### COMMANDS ###

# Cleans Mac...
macpurge() {
	sudo rm -rf ~/Library/Caches/*
	sudo rm -rf /var/log
	sudo rm -rf ~/Library/Logs
	brew autoremove
	sudo rm -rf ~/Application Support/MobileSync/Backups
	sudo rm -f ~/Messages/*
}

# shortcut to make file/dir readonly
ro ()
{
	chmod 0444 $1
}

# explicit soft link cmd
sln ()
{
	ln -s $1 $2
}

# mkdir and cd at same time
mcd ()
{
    mkdir -p -- "$1" && cd -P -- "$1"
}

# view any Unicode codepoint for current font,
# where $1 is the hex form of the codepoint
ucp ()
{
	printf "$(printf '\\U%08x' $1)\n"	
}

# shorthand for running a python file
pyf ()
{
	local filename=$1
	shift
	python3 $filename.py $@
}

# navigate to my CODE directory which has all my projects
# no arg goes to dir root, otherwise cd to CODE/$1 if $1 
# is name of a project dir
cdcd ()
{
	[[ $# -eq 0 ]] && cd $HOME/CODE
	[[ $# -eq 1 && -d $HOME/CODE/$1 ]] && cd $HOME/CODE/$1 && return 0
	[[ $# -eq 1 && -d /Volumes/BACKUP/CODE/$1 ]] && cd /Volumes/BACKUP/CODE/$1
}

cdl ()
{
	cd $1 && ls
}

### AWS RELATED DEFINITIONS ###
export AWS_PROFILE=dev-profile

alias s3="aws s3"
alias dydb="aws dynamodb"
alias dyls="dydb list-tables"

# Request credentials from AWS for IAM Identity Center users. This is
# needed to run AWS CLI commands. If you have an IAM user account and
# have already ran aws configure, feel free to delete this function
#
# I only have one sso-session and one profile setup in my ~/.aws/config, 
# so I never need to specify the session to the --sso-session option or
# the --profile option
alias ssli="aws sso login"
alias sslo="aws sso logout"

# For deleting a file in a CodeCommit repository from your local machine
#
# The --profile flag is because I access AWS through the IAM Identity Center
# If you have an IAM user account, you can delete that part. If not, make sure
# the AWS_DEV_PROFILE variable above has the name of the SSO profile that gives
# you permission to access to CodeCommit
#
# USAGE: accd [BRANCH] [FILEPATH] [FULL_COMMIT_ID] (FILEPATH must start with repo name)
accd ()
{
	local FILEPATH=$2 
	aws codecommit delete-file --branch-name $1 \
	--repository-name ${FILEPATH%%/*} \
	--file-path ${FILEPATH#*/} \
	--parent-commit-id $3 
}

dybw ()
{
	dydb batch-write-item --request-items file://$1
}

### GENERAL ALIASES ###
alias B:="cd /Volumes/BACKUP"
alias dld="cd $HOME/Downloads"
alias docs="cd $HOME/Documents"
alias t3="cd $HOME/Documents/digitalt3"
alias rc="hx $HOME/Documents/bashrc/.bashrc"
alias py="python3"
alias pip="pip3"
alias pup="pip3 install --upgrade pip"
alias brin="brew install"
alias brun="brew uninstall"
alias bren="brew reinstall"
alias brup="brew upgrade && brew upgrade --greedy"
alias zzz="pmset sleepnow"
alias bye="sudo shutdown -s now"
alias brb="sudo shutdown -r now"

# count files in directory
alias cntf="ls -l . | egrep -c ‘^-’"

# Colorize grep output (good for log files)
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"

# confirm before overwriting something - credit to DistroTube for these
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"
alias rmd="rm -d"

# GIT
alias gti="git"
alias push="git push origin main"
alias pull="git pull origin main"
alias clone="git clone"
alias merge="git merge"
alias stash="git stash"
alias unstash="git stash pop"
alias squash="git squash"
alias gstat="git status"
alias glog="git log"

# git function to remove a remote origin and change it to the provided 
# argument URL instead, then switch to master and push our repo
#
# gno stands for "git new origin"
gno ()
{
	git remote remove origin
	git remote add origin $1
	git branch -M main
	git push -u origin main
}

# function to push any of my bashrc changes to the github repo 
# this includes committing the latest changes.
grc ()
{
	cd ~/CODE/bashrc
	git add .zshrc
	git commit -m "${1}"
	git stage .zshrc
	git push origin main
	echo "Updated .zshrc on Github"
}

# C/C++
alias hmake="cmake .. && make"	# stands for "hard make"

# opens CMakeLists.txt regardless of whether it's in current dir or parent dir which can be
# useful if we are currently in the /build dir of the project
# you can swap "code" with editor of your choice (vim, nano, emacs, etc)
cmt ()
{	# only one of these can be true at a time
	# the [[ ]] syntax only works in bash and zsh and korn shells,
	# so you may have to use [ ] if this isn't working for you
	[[ -f CMakeLists.txt ]] && hx CMakeLists.txt
	[[ -f ../CMakeLists.txt ]] && hx ../CMakeLists.txt
}

# if CMakeLists.txt in cwd, build and run project. grep CMakeLists to get first executable name
# only works if the executable gets outputted to the build directory
cbrun ()
{
	[[ -f CMakeLists.txt ]] && {
		local prog=$(grep -oP "(?<=add_executable\()\w+" CMakeLists.txt)
		mcd build
		cmake .. && make
		./"$prog"
	}
}

# For running make from any directory within a C project, where the project root folder
# is in my workspace. It checks if the prefix of the current path contains one of
# these folders, and then runs make if so. It assumes that there will be a Makefile 
rmake ()
{
	local curr=$PWD
	cdcd $1
	make
	cd $curr
}

cproj ()
{
	cdcd
	mkdir $1
	cd $1
	touch Makefile
	touch README.md
	touch build.sh
	chmod +x build.sh
	mkdir include
	mkdir src
	printf "Project %s created successfully" $1
}

# RUST
alias ca="cargo"
alias cah="cargo help"
alias cav="cargo version"
alias cai="cargo init"
alias cain="cargo install"
alias caun="cargo uninstall"
alias cach="cargo check"
alias cbd="cargo build"
alias cbr="cargo build --release"
alias cc="cargo run"
alias cal="cargo clippy"
alias cas="cargo search"
alias cate="cargo test"
alias catr="cargo tree"
alias cab="cargo bench"
alias cac="cargo clean"
alias caa="cargo add"
alias carm="cargo rm"
alias caf="cargo fix"
alias cado="cargo rustdoc"

# show verbose version info
alias cvv="cargo -Vv"

# run all tests regardless of failure
alias catea="cargo test --no-fail-fast"

# opens Cargo.toml file in a Rust project if it exists for quick viewing/editing
alias ctom="[ -f ./Cargo.toml ] && micro ./Cargo.toml"

# build and suppress warnings
alias caw="cargo rustc -- -Awarnings"

# apply lint fixes as compiler would
alias calf="cargo clippy --fix"

# fails on warnings
alias calw="cargo clippy -- -D warnings"

# check tests and non default features too
alias cala="cargo clippy --all-targets --all-features -- -D warnings"

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

# docker and orb stuff
alias ostop="orb stop"
alias orbrs="orb restart docker"
alias orbcfg="orb config"
alias orbls="orb list"
alias orbh="orb --help"
alias orbctlh="orbctl --help"
alias fedora="orb start fedora; orb"

# bun completions
[ -s "/Users/preeth/.bun/_bun" ] && source "/Users/preeth/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

neofetch
