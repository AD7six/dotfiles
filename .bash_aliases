alias texclean='rm -f *.toc *.aux *.log *.cp *.fn *.tp *.vr *.pg *.ky'
alias clean='echo -n "Really clean this directory?";
	read yorn;
	if test "$yorn" = "y"; then
		find . -type f -iregex "\(.*~~\|.*~\|.*\.tmp\|.*\.bak\|.*\.swo\|.*\.swp\|.*svn-commit\..*\|.*core\|.*.temporaryFile\)" -not -iregex ".*\.svn\/.*" -exec rm {} -v \;
	   echo "Cleaned.";
	else
	   echo "Not cleaned.";
	fi'
# Function which adds an alias to the current shell and to
# the ~/.bash_aliases file.
addAlias ()
{
	local name=$1 value="$2"
	echo "" >>~/.bash_aliases
	echo alias $name=\'$value\' >>~/.bash_aliases
	eval alias $name=\'$value\'
	alias $name
}
alias h='history'
alias j="jobs -l"
alias l="ls -l "
alias lc='ls -CF'
alias ls="ls -F"
alias la='ls -A'
alias pu="pushd"
alias po="popd"
alias ss="ps -aux"
alias c="clear"
alias m="more"
alias up="svn up config/ controllers/ models/ libs/ plugins/ views/ vendors/ webroot/"
alias svnExportClean='find . -name ".svn" -exec rm -rf {} \;'
alias svnA='clean|svn st|grep ^?|sed s/?//|xargs svn add $1'
alias svnC='rm $( svn status | sed -e ''/^?/!d'' -e ''s/^?//'' )'
alias svnR='svn rm $( svn status | sed -e ''/^!/!d'' -e ''s/^!//'' )'
alias svnS='svn status --ignore-externals'
alias svnU='svn up --ignore-externals'
alias phpL='find . -type f -name "*.php" -exec php -l {} \; | grep -v "No syntax errors"'
alias ci='if [[ -d tmp ]]; then git checkout tmp; fi && git commit'
alias dcommit='touch .temporaryFile && git add -f .temporaryFile && git stash && git rebase -i git-svn && git svn dcommit --rmdir && git stash pop && git reset HEAD .temporaryFile && rm .temporaryFile'
alias restart='sudo /etc/init.d/lighttpd restart'
alias push='git checkout tmp && git checkout app/tmp && git stash && git push && git stash pop'
alias stashdiff='git show $(git stash list | cut -d":" -f 1)'
alias st="git status | sed '/ in what will be committed/,\$d'"
alias rmTmp="find -name ".temporaryFile" -exec rm -rf {} \;"
alias subStatus="here=`pwd` && cd ~/www/cakes/1.3.x.x && git submodule foreach git log origin..HEAD --oneline && cd $here"
