#!/usr/bin/env bash

set -Eeuf -o pipefail
shopt -s inherit_errexit
set -x

main() {
  sudo -v
  nix build

  local img=./result/iso/rescue.iso
  local outfile=/dev/disk/by-id/usb-Kingston_DataTraveler_3.0_60A44C4138F0B050D98B0070-0:0

  local args=(
    of="${outfile}"
    bs=4M
    status=progress
    conv=fsync
  )

  if [[ -f "${img}.zst" ]]; then
    zstd --decompress --keep --stdout "${img}.zst" | sudo dd "${args[@]}"
  else
    sudo dd if="${img}" "${args[@]}"
  fi
}
main "$@"
