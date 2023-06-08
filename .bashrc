# ██████  ██████  ███████ ███████ ████████ ██   ██    ██████   ██████
# ██   ██ ██   ██ ██      ██         ██    ██   ██    ██   ██ ██
# ██████  ██████  █████   █████      ██    ███████    ██████  ██
# ██      ██   ██ ██      ██         ██    ██   ██    ██   ██ ██
# ██      ██   ██ ███████ ███████    ██    ██   ██ ██ ██   ██  ██████

### EXPORT ###
export XTERM="truecolor"                           # getting proper colors
export HISTCONTROL=ignoredups:erasedups           # no duplicate entries
export ANDROID_HOME=$HOME/Android/Sdk

export AWS_DEV_PROFILE=dev-profile

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH=$ANDROID_HOME/platform-tools:$HOME/preethv/.cargo/bin:$PATH

### COMMANDS ###

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

# install a font system wide, set permissions, and update font cache per
# https://docs.fedoraproject.org/en-US/quick-docs/fonts/#system-fonts
fin ()
{
	local path = "/usr/local/share/fonts"/"$1"
	sudo mkdir -p path
	sudo cp ./"$1"/*.ttf path
	sudo chown -R root: path
	sudo chmod 644 path/*
	sudo restorecon -RF path
	sudo fc-cache -v
	echo Installed font "$1"
}

# opens CMakeLists.txt regardless of whether it's in current dir or parent dir which can be
# useful if we are currently in the /build dir of the project
cmt ()
{	# only one of these can be true at a time
	# the [[ ]] syntax only works in bash and zsh and korn shells,
	# so you may have to use [ ] if this isn't working for you
	[[ -f CMakeLists.txt ]] && nano CMakeLists.txt
	[[ -f ../CMakeLists.txt ]] && nano ../CMakeLists.txt
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

# git function to remove a remote origin and change it to the provided argument URL instead, then switch to master and push our repo
# gno stands for "git new origin"
gno ()
{
	git remote remove origin
	git remote add origin $1
	git branch -M main
	git push -u origin main
}

# function to push any of my bashrc changes to the github repo 
grc ()
{
	cd ~/Documents/bashrc
	git pull https://github.com/pre-eth/.bashrc.git main
	git stage .bashrc
	git push https://github.com/pre-eth/.bashrc.git main
	echo "Updated .bashrc on Github"
}

### AWS RELATED DEFINITIONS ###
export AWS_DEV_PROFILE=dev-profile
export AWS_S3_PROFILE=s3-profile
export AWS_DB_PROFILE=db-profile

alias sslo="aws sso logout"
alias s3="aws s3"
alias dyndb="aws dynamodb"

# Request credentials from AWS for IAM Identity Center users. This is
# needed to run AWS CLI commands. If you have an IAM user account and
# have already ran aws configure, feel free to delete this function
#
# I only have one sso-session setup in my ~/.aws/config, so I never
# really need to specify the session to the --sso-session option
ssli ()
{
  # If your sso profiles don't end with the word "profile", replace
  # "$1-profile" with $1 and provide your full profile name
  aws sso login --profile "$1-profile"
}

# For deleting a file in a CodeCommit repository from your local machine
#
# The --profile flag is because I access AWS through the IAM Identity Center
# If you have an IAM user account, you can delete that part. If not, make sure
# the AWS_DEV_PROFILE variable above has the name of the SSO profile that gives
# you access to CodeCommit
#
# USAGE: accd [BRANCH] [FILEPATH] [COMMIT_ID] (FILEPATH must start with repo name)
accd ()
{
	local FILEPATH=$2 
	aws codecommit delete-file --branch-name $1 \
	--repository-name ${FILEPATH%%/*} \
	--file-path ${FILEPATH#*/} \
	--parent-commit-id $3 \
	--profile $AWS_DEV_PROFILE
}

### ALIASES ###
alias dld="cd ~/Downloads"
alias docs="cd ~/Documents"
alias usrbin="cd /usr/local/bin/"
alias nv="neovide"
alias vim="nvim"
alias rc="nano ~/Documents/bashrc/.bashrc"
alias nc="nano ~/.nanorc"
alias t3="cd ~/Documents/digitalt3"
alias gti="git"
alias virt="virt-manager"

# count files in directory
alias cntf="ls -l . | egrep -c ‘^-’"

# C/C++
alias cppd="cd ~/Documents/C++"
alias hmake="cmake .. && make"	# stands for "hard make"

# RUST
alias rud="cd ~/Documents/Rust"
alias ca="cargo"
alias cah="cargo help"
alias cav="cargo version"
alias cai="cargo init"
alias cain="cargo install"
alias caun="cargo uninstall"
alias cach="cargo check"
alias cad="cargo build"
alias cadd="cargo build --release"
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
alias ctom="[ -f ./Cargo.toml ] && nano ./Cargo.toml"

# build and suppress warnings
alias caw="cargo rustc -- -Awarnings"

# apply lint fixes as compiler would
alias calf="cargo clippy --fix"

# fails on warnings
alias calw="cargo clippy -- -D warnings"

# check tests and non default features too
alias cala="cargo clippy --all-targets --all-features -- -D warnings"

# Colorize grep output (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# confirm before overwriting something - credit to DistroTube for these
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'
alias rmd="rm -d"

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

unset rc
