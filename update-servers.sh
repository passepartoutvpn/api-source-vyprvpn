#!/bin/bash
URL="https://support.vyprvpn.com/hc/en-us/articles/360037728912-What-are-the-VyprVPN-server-addresses-"
TPL="template"
SERVERS_SRC="$TPL/servers.html"
SERVERS_DST="$TPL/servers.csv"

mkdir -p $TPL
if ! curl -L $URL >$SERVERS_SRC.tmp; then
    exit
fi
mv $SERVERS_SRC.tmp $SERVERS_SRC
sed -nE "s/^.*width: 263\.15px;\">.+ - ([^,]+).*<\/td>$/\1/p" $SERVERS_SRC >names.out
sed -nE "s/^.*;\">([^0-9]+)([0-9]*)\.vpn\.goldenfrog\.com<.*$/\1\2,\1/p" $SERVERS_SRC >ids.out
paste -d ',' ids.out names.out >$SERVERS_DST
rm *.out

# fix codes inconsistencies
sed -i"" -E "s/,uk,/,gb,/" $SERVERS_DST

sort $SERVERS_DST >$SERVERS_DST.tmp
mv $SERVERS_DST.tmp $SERVERS_DST
