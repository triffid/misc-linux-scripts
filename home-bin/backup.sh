#!/bin/bash

REMOTEHOST=haxnas
PREFIX=Backup/daily.

export PATH="$HOME/bin:/bin:/usr/bin:/usr/local/bin"

. "$HOME/.ssh/agent"

LINKDEST=$(echo "$PREFIX" | perl -pe 's![^/]+!..!g;'; echo /../; )

ssh "$REMOTEHOST" 'for I in {13..0}; do while [ -e "'$PREFIX'"$(( $I + 1 )) ]; do echo rm -rf '"$PREFIX"'$(( $I + 1 )) && chmod u+w -R '"$PREFIX"'$(( $I + 1 )) && rm -rf '"$PREFIX"'$(( $I + 1 )) || exit 1; done; echo mv '"$PREFIX"'$I '"$PREFIX"'$(( $I + 1 )) && mv '"$PREFIX"'$I '"$PREFIX"'$(( $I + 1 )) || exit 1; done; echo mkdir '"$PREFIX"'0 && mkdir '"$PREFIX"'0;'

cd ~/.backup
for F in *
do
    termtitle "Rsyncing $F"
    echo "*** $F ***"
    rsync -avhszP --delete --link-dest="../../${PREFIX##*/}1/$F" "$F/" "${REMOTEHOST}:${PREFIX}0/$F"
done
