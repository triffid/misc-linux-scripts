#!/bin/bash

REMOTEHOST=haxnas
PREFIX=Backup/daily.

export PATH="$HOME/bin:/bin:/usr/bin:/usr/local/bin"

. "$HOME/.ssh/agent"

if [ "$1" != "-n" ]
then
	ssh "$REMOTEHOST" 'if [ -e .old ]; then echo rm -rf .old && chmod -R u+w .old && rm -rf .old || exit 1; fi; if [ -e "'$PREFIX'"14 ]; then mv '"$PREFIX"'14 .old && setsid rm -rf .old &>/dev/null & echo -n; fi; for I in {13..0}; do J=$(( $I + 1 )); echo mv '"$PREFIX"'$I '"$PREFIX"'$J && mv '"$PREFIX"'$I '"$PREFIX"'$J || exit 1; done; echo mkdir '"$PREFIX"'0 && mkdir '"$PREFIX"'0;' || exit 1

	echo "Finished preparing"
fi

cd ~/.backup
for F in *
do
    termtitle "Rsyncing $F"
    echo "*** $F *** rsync -avhszP --delete --link-dest="../../${PREFIX##*/}1/$F" "$F/" "${REMOTEHOST}:${PREFIX}0/$F""
    rsync -ahvsP --delete --link-dest="../../${PREFIX##*/}1/$F" "$F/" "${REMOTEHOST}:${PREFIX}0/$F" || exit 1
done

ssh "$REMOTEHOST" "touch ${PREFIX}0"
