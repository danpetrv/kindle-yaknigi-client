#!/bin/sh
# What the launcher does to KOReader's own launcher before it starts it.
RUN=$(CDPATH='' cd "$(dirname "$0")/../../kual/yaknigi-ko" && pwd)/run.sh
BASE=$(mktemp -d)
trap 'rm -rf "$BASE"' EXIT
failed=0

check() {
    if [ "$2" = "$3" ]; then
        echo "ok   $1"
    else
        echo "FAIL $1: got '$2', want '$3'"
        failed=1
    fi
}

# A launcher dir with no update waiting and the seed already in place, so only koreader.sh matters.
setup() {
    DIR=$BASE/$1
    mkdir -p "$DIR/koreader" "$DIR/home"
    : > "$DIR/apply-update.sh"
    echo 'return {}' > "$DIR/settings.reader.lua"
    cp "$DIR/settings.reader.lua" "$DIR/home/settings.seed"
    # KOReader's line as it is in platform/kindle/koreader.sh; the stand-in says what it would stop.
    {
        echo '#!/bin/sh'
        echo "TOGGLED_SERVICES=\"$2\""
        echo 'echo "$TOGGLED_SERVICES"'
    } > "$DIR/koreader/koreader.sh"
    chmod +x "$DIR/koreader/koreader.sh"
}
start() { YAKNIGI_DIR=$DIR sh "$RUN"; }

KO_LIST="stored webreader kfxreader kfxview todo tmd rcm archive scanner otav3 otaupd"
KEPT="stored webreader kfxreader kfxview todo rcm archive scanner otav3 otaupd"

setup middle "$KO_LIST"
check "tmd is not stopped" "$(start)" "$KEPT"
check "and stays so at the next start" "$(start)" "$KEPT"

setup first "tmd todo rcm"
check "tmd first in the list" "$(start)" "todo rcm"

setup last "todo rcm tmd"
check "tmd last in the list" "$(start)" "todo rcm"

setup none "todo rcm"
check "a list without tmd stays as it is" "$(start)" "todo rcm"

setup lookalike "todo tmdx xtmd rcm tmd"
check "only tmd itself goes" "$(start)" "todo tmdx xtmd rcm"

exit $failed
