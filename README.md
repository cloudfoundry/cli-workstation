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

## How to use on macOS (no longer maintained)
For fresh installs on macOS run the following command:

```
curl -fsSL https://raw.githubusercontent.com/cloudfoundry/cli-workstation/master/install-osx.sh | bash -
```

To keep the workstation up to date:

```
cd ~/workspace/cli-workstation
git pull -r
./install-osx.sh
```
