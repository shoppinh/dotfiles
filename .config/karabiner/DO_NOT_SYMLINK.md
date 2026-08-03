# Do not symlink this folder to ~/.config/karabiner

Karabiner-Elements (Core Service) fails to persist `virtual_hid_keyboard.keyboard_type_v2`
when the config directory is a symlink into Documents / iCloud / Dropbox. That causes the
"Please select the keyboard type you'd like to use" dialog on every launch.

`bootstrap.sh` copies this directory instead of linking it.
