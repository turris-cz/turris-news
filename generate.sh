#!/bin/sh
# This script generates format as is expected by turris-news
# Result is placed in 'out' directory.
set -e

# This is list of all channels
# !! Tis variable is used as is, unquoted, as argument to for loop!!
CHANNELS="news updates rc maintain security"

OUT="$(readlink -f "${1-out}")"
cd "$(dirname "$(readlink -f -- "$0")")"

sha256() {
	sha256sum "$1" |  cut -d " " -f 1
}

# Generate result for given channel that is specified as first argument
gen_channel() {
	mkdir -p "$OUT/$1"
	(
	INDX="$OUT/$1.index"
	touch "$INDX"
	cd "$1"
	for FILE in *.md; do
		[ -f "$FILE" ] || continue # just to protect against no match
		echo "$FILE" | grep -qv '\...\.md$' || continue # Skip translations
		BASE="${FILE%.md}"
		DATE="$(echo "$BASE" | cut -c -6)"
		TITLE="$(echo "$BASE" | cut -c 8-)"
		date -d "$DATE" > /dev/null || {
			echo "Invalid date: '$DATE'" >&2
			return 1
		}
		[ -n "$TITLE" ] || {
			echo "Message title for date $DATE is empty" >&2
			return 1
		}
		# English version
		FILE_OUT="$OUT/$1/$DATE-$TITLE.md.gz"
		gzip --to-stdout "$FILE" > "$FILE_OUT"
		echo "$DATE:$TITLE:md:$(sha256 "$FILE_OUT")" >> "$INDX"
		# Translations
		for TFILE in "$BASE".*.md; do
			[ -f "$TFILE" ] || continue
			LNG="$(echo "$TFILE" | cut -d "." -f 2)"
			TFILE_OUT="$OUT/$1/$DATE-$TITLE.$LNG.md.gz"
			gzip --to-stdout "$TFILE" > "$TFILE_OUT"
			echo ":$TITLE:$LNG:$(sha256 "$TFILE_OUT")" >> "$INDX"
		done
	done
	gzip "$INDX"
	)
}

##########
[ ! -e "$OUT" ] || rm -r "$OUT"
mkdir -p "$OUT"

CHANNEL_INDEX="$OUT/index"
echo 1 > "$CHANNEL_INDEX"

for CHANNEL in $CHANNELS; do
	gen_channel "$CHANNEL"
	HASH="$(sha256 "$OUT/$CHANNEL.index.gz")"
	DESCRIPTION="$(head -1 "$CHANNEL/DESCRIPTION")"
	echo "$CHANNEL:$HASH:$DESCRIPTION"
	tail -n +2 "$CHANNEL/DESCRIPTION" | while read LINE; do
		echo ":$CHANNEL:$LINE"
	done
done >> "$CHANNEL_INDEX"
gzip "$CHANNEL_INDEX"

# TODO sign CHINDX
