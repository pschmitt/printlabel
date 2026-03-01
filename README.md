# printlabel

Print text, images, and QR codes to a Brother P-Touch Cube from Linux.

## Sources

- <https://gist.github.com/Ircama/bd53c77c98ecd3d7db340c0398b22d8a>
- <https://gist.github.com/64ae743825e42f2bb8ec79cea7ad2057.git>

## Install

```sh
nix run .#printlabel -- --help
```

For development:

```sh
nix develop
```

## Pair Once

```sh
bluetoothctl
scan on
pair XX:XX:XX:XX:XX:XX
trust XX:XX:XX:XX:XX:XX
```

## Usage

Text:

```sh
./printlabel 'HELLO'
```

Image:

```sh
./printlabel --image label.png
```

QR code:

```sh
./printlabel --qr 'https://example.com'
```

Invert:

```sh
./printlabel --invert 'HELLO'
./printlabel --image label.png --invert
./printlabel --qr 'https://example.com' --invert
```

The printer MAC is optional. If omitted, `printlabel` tries to auto-discover a paired Brother printer.

## Environment

- `PRINTLABEL_PRINTER`: preferred printer MAC address
- `PRINTLABEL_PREVIEW=1`: preview generated output before printing
- `PRINTLABEL_QR_SIZE=64`: QR size in pixels before padding

## Notes

- `64px` is the safe QR default for 12 mm tape.
- The wrapper can wake a sleeping printer, but not a powered-off one.
