#!/bin/bash

##
## Commit configuration files.
##
if [ ! -d /etc/.git ]; then
	cd /etc
	git init
fi
git --work-tree=/etc --git-dir=/etc/.git add . >/dev/null 2>&1
git --work-tree=/etc --git-dir=/etc/.git commit -a -m "Logout commit `date +%c`" >/dev/null 2>&1
