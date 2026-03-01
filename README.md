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
./printlabel --printer 98:6E:E8:47:C9:A3 'HELLO'
```

Image:

```sh
./printlabel --image label.png
./printlabel --image label.png --preview
```

QR code:

```sh
./printlabel --qr 'https://example.com'
./printlabel --qr 'https://example.com' --qr-size 64
./printlabel --qr 'https://example.com' --black
./printlabel --netbox 123 --netbox-url https://netbox.example.com
```

Invert:

```sh
./printlabel --invert 'HELLO'
./printlabel --image label.png --invert
./printlabel --qr 'https://example.com' --invert --preview
```

The printer MAC is optional. If omitted, `printlabel` tries to auto-discover a paired Brother printer.
If `--preview` is set, printing proceeds only after `Print? (y|n)` is answered with `y`.

## Flags

- `--printer MAC`: use a specific printer
- `--preview`: preview in terminal when Kitty graphics are available, otherwise use a GUI window, then ask `Print? (y|n)`
- `--qr-size PX`: QR size in pixels before padding
- `--black`: invert QR codes for black tape; for NetBox labels only the QR block is inverted
- `--raw`: skip preprocessing for `--image`
- `--invert`: invert black and white
- `--netbox ID`: fetch a device from NetBox and print `QR | name / asset tag / serial`
- `--netbox-url URL`: NetBox base URL, overrides `NETBOX_URL`
- `--netbox-token TOKEN`: NetBox API token, overrides `NETBOX_API_TOKEN`

NetBox defaults:

- `NETBOX_URL`
- `NETBOX_API_TOKEN`

## Notes

- `64px` is the safe QR default for 12 mm tape.
- The wrapper can wake a sleeping printer, but not a powered-off one.
