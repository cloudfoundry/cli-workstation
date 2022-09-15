# CLI Workstation
This repo is used to help setup and maintain a unified cli workstation.

## How to use on Ubuntu (18.04)
For fresh installs on Ubuntu run the following command:
(Note the bottom section for workarounds on a fresh workstation)

```
$ sudo apt install curl
$ curl -fsSL https://raw.githubusercontent.com/cloudfoundry/cli-workstation/main/install-ubuntu.sh | bash -
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
- Tilix > Preferences > Profiles > Default > General > Custom font : DejaVuSansMono Nerd Font Mono 12

### Things missing from our workstation setup:
- run git-init in repos to update git-duet hook

### Notes from 1/16/19 Fresh Ocean Installation
- Ran once, failed => Needed to load an ssh key to load github repos
- Ran a second time, failed => needed to closed terminal and reopen to get `$GOPATH` variable
- Ran a third time, success
