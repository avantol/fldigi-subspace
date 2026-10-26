#!/bin/bash
# build-deb.sh <version>  -- e.g. 4.2.13-subspace1
# Packages the fldigi built in this tree as fldigi-subspace: /usr/bin/fldigi-subspace,
# its data and translations in /usr/share/fldigi-subspace, its own menu entry and
# icon, beside any stock fldigi. The tree must be built for that data folder:
#   ./configure --prefix=/usr
#   make pkgdatadir=/usr/share/fldigi-subspace localedir=/usr/share/fldigi-subspace/locale
# Writes the .deb to $OUT (default: this tree).
set -euo pipefail
VER=${1:?usage: build-deb.sh <version>}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
ST=$ROOT/pkg-staging
INST=$ROOT/pkg-install
DATA=/usr/share/fldigi-subspace
BIN=$ROOT/src/fldigi
[ -x "$BIN" ] || { echo "no $BIN -- build first (see the top of this script)"; exit 1; }
grep -q "$DATA/locale" "$BIN" || { echo "$BIN was not built for $DATA -- see the top of this script"; exit 1; }

rm -rf "$INST" "$ST"
make -C "$ROOT" install DESTDIR="$INST" pkgdatadir="$DATA" localedir="$DATA/locale" > /dev/null

mkdir -p "$ST/DEBIAN" "$ST/usr/bin" "$ST/usr/share/applications" \
         "$ST/usr/share/pixmaps" "$ST/usr/share/doc/fldigi-subspace"
install -m 755 -s "$INST/usr/bin/fldigi" "$ST/usr/bin/fldigi-subspace"
cp -a "$INST$DATA" "$ST$DATA"
install -m 644 "$ROOT/packaging/deb/fldigi-subspace.desktop" "$ST/usr/share/applications/"
install -m 644 "$ROOT/data/fldigi.xpm" "$ST/usr/share/pixmaps/fldigi-subspace.xpm"
install -m 644 "$ROOT/COPYING" "$ST/usr/share/doc/fldigi-subspace/copyright"
sed "s/@VERSION@/$VER/" "$ROOT/packaging/deb/control.in" > "$ST/DEBIAN/control"
find "$ST" -type d -exec chmod 755 {} +   # never group-writable in a .deb
find "$ST/usr/share" -type f -exec chmod 644 {} +
chmod 644 "$ST/DEBIAN/control"
rm -rf "$INST"

OUT=${OUT:-$ROOT}/fldigi-subspace_${VER}_amd64.deb
dpkg-deb --build --root-owner-group "$ST" "$OUT"
echo "$OUT"
