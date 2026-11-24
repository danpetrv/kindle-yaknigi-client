#!/bin/sh
# Starts KOReader with the Yandex plugin, with its own settings and books.
DIR=${YAKNIGI_DIR:-/mnt/us/extensions/yaknigi-ko}
export KO_HOME="$DIR/home"
export YAKNIGI_APP=1
export YAKNIGI_DIR="$DIR"
mkdir -p "$KO_HOME"
# A version that was downloaded goes in place here, or one that did not start goes back.
/bin/sh "$DIR/apply-update.sh"
# A new version of the seed brings into KOReader's settings what it changed, and no more: the
# reader's own choices stay. If that fails, the settings stay as they are and it goes again next time.
if ! cmp -s "$DIR/settings.reader.lua" "$KO_HOME/settings.seed"; then
    (cd "$DIR/koreader" && ./luajit "$DIR/seed.lua" "$DIR/settings.reader.lua" "$KO_HOME/settings.seed" "$KO_HOME/settings.reader.lua") \
        && cp "$DIR/settings.reader.lua" "$KO_HOME/settings.seed"
fi
# KOReader stops a few of Amazon's services to win back memory, the transfer service tmd among
# them. On a Kindle Basic 2024 (5.20.2) a busy tmd crashes as it stops, and the firmware puts a
# report of that crash among the books. These Kindles have the memory, so tmd keeps running.
# KOReader is not updated with the app, so its launcher is changed here, at each start, if needed.
KO_SH="$DIR/koreader/koreader.sh"
if grep -q '^TOGGLED_SERVICES=.*[" ]tmd[ "]' "$KO_SH" 2>/dev/null; then
    sed -i -e '/^TOGGLED_SERVICES=/{s/\([" ]\)tmd\([ "]\)/\1\2/;s/  */ /g;s/=" /="/;s/ "/"/}' "$KO_SH"
fi
# From KUAL there is nothing to say; a scriptlet says what suits it.
[ $# -gt 0 ] || set -- --kual
exec "$DIR/koreader/koreader.sh" "$@"
