# CLI Workstation
This repo is used to help setup and maintain a unified cli workstation.

## How to use on Ubuntu (18.04)
For fresh installs on Ubuntu run the following command:

```
$ sudo apt install curl
$ curl -fsSL https://raw.githubusercontent.com/cloudfoundry/cli-workstation/master/install-ubuntu.sh | bash -
# Reboot to pick up new device drivers
$ sudo shutdown -r now
```

To keep the workstation up to date:

```
$ cd ~/workspace/cli-workstation
$ git pull -r
$ ./install-ubuntu.sh
```

### Other things to configure:
- Settings > Mouse & Touchpad > Natural Scrolling : On
- Tilix > Preferences > Profiles > Default > Color > Color Scheme : Monokai Dark

### Note:
The nvim setup installs a powerline font, which is optional, but recommended.
To finalize this setup, change the terminal font to DejaVuSansMono Nerd Font
Mono.
