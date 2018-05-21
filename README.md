# CLI Workstation
This repo is used to help setup and maintain a unified cli workstation.

## How to use on Ubuntu (17.10)
For fresh installs on Ubuntu run the following command:

```
curl -fsSL https://raw.githubusercontent.com/cloudfoundry/cli-workstation/master/install-ubuntu.sh | bash -
```

To keep the workstation up to date:

```
cd ~/workspace/cli-workstation
git pull -r
./install-ubuntu.sh
```

### Note:
The nvim setup installs a powerline font, which is optional, but recommended.
To finalize this setup, change the terminal font to DejaVuSansMono Nerd Font
Mono.
