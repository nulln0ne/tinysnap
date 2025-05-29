tinysnap
========

tinysnap is a tiny macOS tiling helper written in Objective-C.  
It lets you snap windows left, right, center, or maximize them via hotkeys.

Requirements
------------

- macOS
- Accessibility permissions (System Settings → Privacy & Security → Accessibility)

Installation
------------

Edit `config.def.h` to configure keybindings.  
Then run:

```sh
make
sudo make install
```

To create a macOS `.app` bundle:

```sh
make app
```

To enable autostart via LaunchAgents:

```sh
make autostart
```

Files
-----

- `main.m`         core logic
- `config.def.h`   default keybindings
- `Makefile`       build rules

Usage
-----

By default:

- ⌥⇧H — snap left
- ⌥⇧L — snap right
- ⌥C   — center
- ⌥⇧C — center & resize
- ⌥⇧F — maximize

You can customize this in `config.def.h`.
