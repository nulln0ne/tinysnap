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

- <kbd>Option ⌥</kbd> + <kbd>Shift ⇧</kbd> + <kbd>H</kbd> — snap left  
- <kbd>Option ⌥</kbd> + <kbd>Shift ⇧</kbd> + <kbd>L</kbd> — snap right  
- <kbd>Option ⌥</kbd> + <kbd>C</kbd>                     — center  
- <kbd>Option ⌥</kbd> + <kbd>Shift ⇧</kbd> + <kbd>C</kbd> — center & resize  
- <kbd>Option ⌥</kbd> + <kbd>Shift ⇧</kbd> + <kbd>F</kbd> — maximize  

You can customize this in `config.def.h`.