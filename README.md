# Cage: a Wayland kiosk

<img src="https://www.hjdskes.nl/img/projects/cage/cage.svg" alt="Cage's logo" width="150px" align="right">

This is Cage, a Wayland kiosk. A kiosk runs a single, maximized
application.

This README is only relevant for development resources and instructions. For a
description of Cage and installation instructions for end-users, please see
[its project page](https://www.hjdskes.nl/projects/cage) and [the
Wiki](https://github.com/cage-kiosk/cage/wiki/).
See [the man page](./cage.1.scd) for a list of possible environment variables and run options.

## Release signatures

Releases up to version 0.1.4 are signed with [6EBC43B1](http://keys.gnupg.net/pks/lookup?op=vindex&fingerprint=on&search=0x37C445296EBC43B1). Releases from 0.1.5 onwards are signed with
[E88F5E48](https://keys.openpgp.org/search?q=34FF9526CFEF0E97A340E2E40FDE7BE0E88F5E48)
All releases are published on [GitHub](https://github.com/cage-kiosk/cage/releases).

## Building and running Cage

You can build Cage with the [meson](https://mesonbuild.com/) build system. It
requires wayland, wlroots, and xkbcommon to be installed. Optionally, install
scdoc for manual pages. Cage is currently based on branch 0.18 of wlroots.

Simply execute the following steps to build Cage:

```
$ meson setup build
$ meson compile -C build
```

By default, this builds a debug build. To build a release build, use `meson
setup build --buildtype=release`.

Cage comes with compile-time support for XWayland. To enable this, make sure
that your version of wlroots is compiled with this option. Note that you'll
need to have the XWayland binary installed on your system for this to work.

You can run Cage by running `./build/cage APPLICATION`. If you run it from
within an existing X11 or Wayland session, it will open in a virtual output as
a window in your existing session. If you run it at a TTY, it'll run with the
KMS+DRM backend. In debug mode (default build type with Meson), press
<kbd>Alt</kbd>+<kbd>Esc</kbd> to quit. For more configuration options, see
[Configuration](https://github.com/cage-kiosk/cage/wiki/Configuration).

Cage is based on the annotated source of tinywl and rootston.

## Nix / NixOS (Flake)

This repository provides a Nix Flake that packages the pre-built binary release (`cage-waydroid-helper`) with `autoPatchelfHook` and `xwayland` runtime integration. The binary and package are named `cage-waydroid-helper` to avoid collisions with standard upstream `cage`.

### Run or Shell

Run directly without installing:
```bash
# Run cage-waydroid-helper
nix run github:j-a-sunny/cage -- --help

# Or locally from the repo directory
nix run .#cage-waydroid-helper -- --help
```

Or launch an ephemeral shell:
```bash
nix shell github:j-a-sunny/cage
cage-waydroid-helper --help
```

### Install in NixOS (`flake.nix`)

Add `cage-waydroid-helper` as a flake input in your NixOS configuration:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    cage-waydroid-helper.url = "github:j-a-sunny/cage";
  };

  outputs = { self, nixpkgs, cage-waydroid-helper, ... }: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; # or "aarch64-linux"
      modules = [
        ./configuration.nix

        # Option A: Add to systemPackages directly
        ({ pkgs, ... }: {
          environment.systemPackages = [
            cage-waydroid-helper.packages.${pkgs.system}.default
          ];
        })

        # Option B: Use the provided NixOS module
        # cage-waydroid-helper.nixosModules.default
        # {
        #   programs.cage-waydroid-helper.enable = true;
        # }
      ];
    };
  };
}
```

### Traditional Nix (`nix-build`)

You can also build the package using `default.nix`:
```bash
nix-build
./result/bin/cage-waydroid-helper --help
```

## Bugs

For any bug, please [create an
issue](https://github.com/cage-kiosk/cage/issues/new) on
[GitHub](https://github.com/cage-kiosk/cage).

## License

Please see
[LICENSE](https://github.com/cage-kiosk/cage/blob/master/LICENSE) on
[GitHub](https://github.com/cage-kiosk/cage).

Copyright © 2018-2020 Jente Hidskes <dev@hjdskes.nl>
