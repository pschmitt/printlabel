# printlabel

Print text, images, QR codes, and NetBox device labels to a Brother P-Touch Cube from Linux.

## Install

```sh
nix run github:pschmitt/printlabel -- --help
```

Consume as a flake input:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    printlabel.url = "github:pschmitt/printlabel";
  };

  outputs = { self, nixpkgs, flake-utils, printlabel, ... }:
    flake-utils.lib.eachDefaultSystem (system: {
      packages.default = printlabel.packages.${system}.printlabel;
    });
}
```

## Setup

Pair the printer once:

```sh
bluetoothctl
scan on
pair XX:XX:XX:XX:XX:XX
trust XX:XX:XX:XX:XX:XX
```

Optional NetBox environment:

```sh
export NETBOX_URL='https://netbox.example.com'
export NETBOX_API_TOKEN='...'
```

## Usage

```sh
./printlabel 'HELLO'
./printlabel --printer 98:6E:E8:47:C9:A3 'HELLO'
./printlabel --count 3 'HELLO'
./printlabel --image label.png
./printlabel --qr 'https://example.com'
./printlabel --qr 'https://example.com' test1234
./printlabel --qr 'https://example.com' --qr-size 64
./printlabel --invert 'HELLO'
./printlabel --preview 'HELLO'
```

NetBox labels:

```sh
./printlabel --netbox 123
./printlabel --netbox Schmutzi
./printlabel --netbox '#LGE-0001'
./printlabel --netbox '109PNEB0E740'
./printlabel --netbox
./printlabel --netbox Schmutzi --preview
./printlabel --netbox Schmutzi --simple
./printlabel --netbox 123 --netbox-url https://netbox.example.com
```

## NetBox

`printlabel` uses [`nbx`](https://github.com/pschmitt/nbx) for device, rack, module, and inventory item lookup instead of talking to the NetBox API directly.

- `--netbox [QUERY]` accepts an id, name, serial, or asset tag.
- `--netbox` with no argument opens `fzf` over all devices, racks, modules, and inventory items.
- `--simple` in NetBox mode prints only the QR code and asset tag.
- Exact matches are resolved first; broader NetBox search is used as fallback.
- If multiple objects match, `fzf` is used for selection.
- Before previewing or printing, the selected NetBox object details are shown on stdout.

## Flags

- `--printer MAC`: use a specific printer
- `--count N`: print the same label `N` times
- Positional arguments are treated as label text (for text mode, or as right-side text in `--qr` mode).
- `--preview`: preview first, then ask before printing
- `--qr-size PX`: QR size in pixels before padding
- `--black`: invert QR codes for black tape; in NetBox mode only the QR block is inverted
- `--raw`: skip preprocessing for `--image`
- `--invert`: invert black and white
- `--netbox [QUERY]`: print a NetBox device, rack, module, or inventory item label
- `--simple`: in NetBox mode, print only the QR code and asset tag
- `--netbox-url URL`: override `NETBOX_URL`
- `--netbox-token TOKEN`: override `NETBOX_API_TOKEN`

## Notes

- The printer MAC is optional; `printlabel` tries to auto-discover a paired printer.
- `64px` is the safe QR default for 12 mm tape.
- The wrapper can wake a sleeping printer, but not a powered-off one.

## Sources

- <https://gist.github.com/Ircama/bd53c77c98ecd3d7db340c0398b22d8a>
- <https://gist.github.com/64ae743825e42f2bb8ec79cea7ad2057.git>
