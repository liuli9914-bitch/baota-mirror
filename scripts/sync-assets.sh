#!/usr/bin/env bash
set -euo pipefail

output_dir=${1:-dist}
public_url='https://io.bt.sb/install/public.sh'
panel_url='https://io.bt.sb/install/src/panel6_latest.zip'

mkdir -p "$output_dir"
tmp_dir=$(mktemp -d)
cleanup() {
    rm -rf "$tmp_dir"
}
trap cleanup EXIT

download() {
    local url=$1
    local target=$2
    curl --fail --location --silent --show-error \
        --retry 5 --retry-all-errors --retry-delay 3 \
        --connect-timeout 20 --max-time 900 \
        --output "$target" "$url"
}

download "$public_url" "$tmp_dir/public.sh"
download "$panel_url" "$tmp_dir/panel6_latest.zip"

public_size=$(stat -c '%s' "$tmp_dir/public.sh")
panel_size=$(stat -c '%s' "$tmp_dir/panel6_latest.zip")
[ "$public_size" -ge 1024 ] || { echo 'public.sh is unexpectedly small' >&2; exit 1; }
[ "$panel_size" -ge 10485760 ] || { echo 'panel6_latest.zip is unexpectedly small' >&2; exit 1; }

bash -n "$tmp_dir/public.sh"
python3 - "$tmp_dir/panel6_latest.zip" <<'PY'
import sys
import zipfile

with zipfile.ZipFile(sys.argv[1]) as archive:
    bad_file = archive.testzip()
    if bad_file is not None:
        raise SystemExit("corrupt ZIP member: {}".format(bad_file))
    if "panel/BT-Panel" not in archive.namelist():
        raise SystemExit("panel/BT-Panel is missing from the ZIP archive")
PY

mv "$tmp_dir/public.sh" "$output_dir/public.sh"
mv "$tmp_dir/panel6_latest.zip" "$output_dir/panel6_latest.zip"

(
    cd "$output_dir"
    sha256sum public.sh panel6_latest.zip > SHA256SUMS
)

public_sha=$(sha256sum "$output_dir/public.sh" | awk '{print $1}')
panel_sha=$(sha256sum "$output_dir/panel6_latest.zip" | awk '{print $1}')
cat > "$output_dir/metadata.json" <<EOF
{
  "fetched_at": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
  "assets": {
    "public.sh": {
      "source": "$public_url",
      "size": $public_size,
      "sha256": "$public_sha"
    },
    "panel6_latest.zip": {
      "source": "$panel_url",
      "size": $panel_size,
      "sha256": "$panel_sha"
    }
  }
}
EOF

echo "Validated assets in $output_dir"
