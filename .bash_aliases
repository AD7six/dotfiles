# Function which adds an alias to the current shell and to
# the ~/.bash_aliases file.
addAlias () {
	local name=$1 value="$2"
	echo "" >>~/.bash_aliases
	echo alias $name=\'$value\' >>~/.bash_aliases
	eval alias $name=\'$value\'
	alias $name
}

# Upload a file to my public dump folder
7up () {
	scp $@ ad7six:ad7six.com/dump/;
	url="http://ad7six.com/dump/${1#*\/}";
	chromium $url;
	echo $url;
}

# ls shortcuts, taken from http://hayne.net/MacDev/Bash/aliases.bash
ll () { ls -l "$@"; }
lt () { ls -lt "$@"; }

# create or decompress a file/folder
btar () {
	archive=`basename $(readlink -f $@)`;
	tar cjf "$archive".tar.bz2 "$archive";
}
gtar () {
	archive=`basename $(`readlink -f $@`)`;
	tar czf "$archive".tar.gz "$archive";
}
unbtar () { tar xvjf "$@"; }
ungtar () { tar xvzf "$@"; }

# find shortcuts, taken from http://hayne.net/MacDev/Bash/aliases.bash
# ff:  to find a file under the current directory
ff () { find . -name "$@" ; }
# ffs: to find a file whose name starts with a given string
ffs () { find . -name "$@"'*' ; }
# ffe: to find a file whose name ends with a given string
ffe () { find . -name '*'"$@" ; }
# find_larger: find files larger than a certain size (in bytes)
findLarger() { find . -type f -size +${1}c ; }

# Clean up symlinks
findBrokenLinks() { find -L "$@" -type l; }
deleteBrokenLinks() { find -L "$@" -type l -print0 | xargs -0 rm; }

# text shortcuts, taken from http://hayne.net/MacDev/Bash/aliases.bash
# fixlines: edit files in place to ensure Unix line-endings
fixlines () { perl -pi~ -e 's/\r\n?/\n/g' "$@" ; }

# networking shortcuts, taken from http://hayne.net/MacDev/Bash/aliases.bash
# httpHeaders: get just the HTTP headers from a web page (and its redirects)
httpHeaders () { curl -I -L $@ ; }

# delete crap from a directory
alias clean='echo -n "Really clean this directory?";
	read yorn;
	if test "$yorn" = "y"; then
		find . -type f -iregex "\(.*~~\|.*~\|.*\.tmp\|.*\.bak\|.*\.swo\|.*\.swp\|.*svn-commit\..*\|.*core\|.*.temporaryFile\)" -not -iregex ".*\.svn\/.*" -exec rm {} -v \;
	   echo "Cleaned.";
	else
	   echo "Not cleaned.";
	fi'

# what's the status of the current repository. gets rid of un committed files from git reports
alias st="if [[ -d .svn ]];
then
	svn status -q;
else
	git status | sed '/ in what will be committed/,\$d'
fi"

# from https://github.com/leek/dotfiles/blob/master/profile
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias c="clear"
alias m="more"
alias phpL='find . -type f -name "*.php" -exec php -l {} \; | grep -v "No syntax errors"'
alias restart='sudo /etc/rc.d/nginx restart'
alias fixPerms="sudo find . -type d -exec chmod 0755 {} \; -or -type f -exec chmod 0644 {} \;"
alias tether="sudo ifconfig eth0 down; sudo ifconfig usb0 up; sudo dhcpcd usb0"
alias fether="sudo ifconfig eth0 up; sudo ifconfig usb0 down; sudo dhcpcd eth0"
alias gh='cd `git rev-parse --show-toplevel`'
alias git="git-achievements"
