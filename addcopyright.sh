#!/bin/bash

declare -A applyRE
declare -A addpre
declare -A addpost

addpre[c]='/*'
applyRE[c]='s/^/ * /'
addpost[c]=' */'

applyRE[shell]='s/^/# /'
applyRE[matlab]='s/^/% /'
applyRE[lua]='s/^/-- /'

if [[ x$1 == x ]]; then
    echo 'No style given, applying default "c"' >&2
    STYLE="c"
elif [[ -v "applyRE[$1]" ]] ; then
    STYLE=$1
else
    echo "Unknown style"
    exit 1
fi

tmpcopyright=$(mktemp /tmp/addcopyright.XXXXXX)

if [[ -v "addpre[$STYLE]" ]] ; then echo "${addpre[$STYLE]}" > $tmpcopyright ; fi
sed "${applyRE[$STYLE]}" < copyright.txt >> $tmpcopyright
if [[ -v "addpost[$STYLE]" ]] ; then echo "${addpost[$STYLE]}" >> $tmpcopyright; fi
COPYRIGHTLEN=$(wc -l $tmpcopyright)

## Solution found as part of this stackoverflow discussion: https://stackoverflow.com/questions/151677/tool-for-adding-license-headers-to-source-files
tmpsrcfile=$(mktemp /tmp/addcopyright.XXXXXX)
for x in *; do
    echo "doing $x"
    head -$COPYRIGHTLEN $x | diff copyright.txt - || ( (cat $tmpcopyright; echo; cat $x) > $tmpsrcfile; mv $tmpsrcfile $x )
done

rm -f $tmpcopyright $tmpsrcfile

exit 0
