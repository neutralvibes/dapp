# dapp - Docker compose wrapper

[![CI](https://github.com/neutralvibes/dapp/actions/workflows/ci.yml/badge.svg)](https://github.com/neutralvibes/dapp/actions/workflows/ci.yml)

A `BASH` command line utility that wraps `docker compose` for managing multiple Docker applications, along with some short-cuts and full Docker Compose support,regardless of the actual folder you are in at the time.

## Overview

While in a galaxy far far away with a keyboard, I yearned to speed up my docker compose flow; then the force inspired `dapp`. For me, this is the way.

### dapp

`dapp` is a wrapper around `docker compose` for command line warriors. It lets you easily manage multiple Docker applications located under a central parent folder; providing short-cuts, app auto-completion and a convenient speedy CLI for most Docker Compose operations.

#### How it works

`dapp` scans the sub-folders under the parent to ensure they contain a `docker-compose.yml`, `compose.yml` or the variants that end in `.yaml`. If a compose file is found, `dapp` considers that sub-folder an application folder and will perform `docker compose` actions on that application, irrespective of the folder you are actually in.

#### Example folder Structure

For `dapp` to actually be useful you need to be using/create a similar structure to the one below, although the name of the parent folder can differ.

```text
/opt/dapps/   # Parent folder (DAPP_DIR)
│
├── nginx/
│   ├── compose.yml
│   ├── app_files/
│   └── ...
├── frigate/
│   ├── docker-compose.yaml
│   └── ...
├── grafana/
│   ├── docker-compose.yml
│   └── ...
└── immich/
    └── compose.yaml

etc....

```

##### Warning

_It is best to remove any spaces in APP sub-folder names._

### dcd

`dcd` is an optional complimentary utility which does a quick `cd` to a docker application folder via `dcd APPNAME`, along with sub-folder name completion.

```text
# Example  `cd` via dcd

dcd frigate        # Switches to sub-folder called frigate
dcd ng[TAB]        # Completes 'nginx' sub-folder name
```

---
These utilities have saved me huge amounts of time and perhaps you may find them useful too.

## Usage

_`APP` below represents just the name of the application sub-folder the compose files are located in. As in `'nginx'`_

### Quick  Global Commands

```bash
dapp ls                    # List all Docker apps
dapp status                # Show status of all apps
dapp APP                   # APP's docker compose ps
dapp APP edit              # Edit APP's compose file
dapp APP [any docker compose commands]
```

### Run Docker Compose Commands

From anywhere via `dapp` execute `docker compose` commands against applications located in the `/opt/dapps/APP` folder, or whichever parent folder you configure for use.

```bash
# From anywhere - use APP as sub-folder name

dapp nginx ps              # List containers
dapp grafana up            # Start services
dapp immich down           # Stop services
dapp frigate logs -f       # Stream logs
dapp caddy restart         # Restart services

# While in an APP folder (local mode)

cd /opt/dapps/sonarr
# Tip: installed `dcd`?
# type `dcd sonarr`
dapp ps
dapp logs -f
dapp up -d
```

### Command Shortcuts

These shortcuts work globally and in local mode:

| Shortcut | Expands To               |
|----------|--------------------------|
| `u`      | `up -d` (start detached) |
| `d`      | `down` (stop)            |
| `l`      | `logs` (logs)            |
| `lf`     | `logs -f` (stream logs)  |
| `r`      | `restart`                |

See more available via `dapp -h`

**Examples:**

```bash
# From anywhere

dapp traefik u               # Start services detached
dapp nginx d                 # Stop services
dapp frigate l               # Show logs
dapp grafana lf              # Stream logs
dapp immich r                # Restart services

# Local Mode - compose file in current folder

dapp u                       # 'up -d'
dapp lf                      # 'logs -f'
```

## Installation

### Get the script

```bash
curl -L https://github.com/neutralvibes/dapp/archive/refs/heads/main.tar.gz \
    | sudo tar -xz -C /opt
```

### Install dapp

```bash
sudo /opt/dapp_cmd/dapp_cmd --install
```

### Removal

```bash
sudo dapp --uninstall
```

### Install 'dcd' - _optional_

_Provides quick `cd` to application folders_

From each user requiring the functionality.

```text
dapp --install-dcd
```

If you want `root` to access `dcd` as well, run with `sudo`.

## Configuration

| `/opt/dapps_cmd/.config`

This file has the basic `dapp` settings.

```text
# Parent of docker app folders
DAPP_DIR=/opt/dapps

# Default editor to use for `dapp APP edit`
DAPP_EDITOR="nano"
```

By default, `dapp` looks for Docker apps under `/opt/dapps`. Modify this via the `DAPP_DIR` variable in the config file.

```bash
sudo -e /opt/dapp_cmd/.config
```

## Environment variables

You can also change the sub-folders location via the `DAPP_DIR` environment variable in other ways. For example:

```bash
export DAPP_DIR=/home/apps/dapps
dapp ls    # Shows any docker apps under /home/apps/dapps, without modifying the default location
```

Environment variables take precedence over the `.config` file, so `DAPP_DIR` set in your shell will override the file.

### Advanced use

This could allow a wrapper to modify the parent folder location if for some reason there is also another sub-folder stack elsewhere.

```bash
# Example dapp wrapper: script file called `stackb`
----------------------------------

#!/bin/bash
export DAPP_DIR=/stack_b/apps
dapp $@
# -- end file --

# Usage
stackb nextcloud u      # Nextcloud up -d
stackb emby l           # emby logs
stackb nzbget build     # build container

```

## Self Update

`dapp --self-update` checks the remote script version and updates the installed `dapp` only if a newer version is available.

You must configure `DAPP_SELF_UPDATE_URL` to point to the raw GitHub script URL:

```bash
export DAPP_SELF_UPDATE_URL=https://raw.githubusercontent.com/<owner>/<repo>/main/dapp_cmd
```

Then run:

```bash
dapp --self-update
```

If the remote version is the same or older, no update is performed.

**Supported compose file names:**

- `compose.yml`
- `compose.yaml`
- `docker-compose.yml`
- `docker-compose.yaml`

## Features

### Auto-Detection

- Automatically detects `docker compose` (v2) or `docker-compose` (v1.x)
- Finds compose files with multiple naming conventions
- Supports both local mode (current directory) and global app mode

### Local Mode

When a compose file is found in the current directory, commands work without specifying an app name:

```bash
cd /opt/dapps/nginx
dapp ps                    # Works - uses ./compose.yml
dapp logs -f
```

### Global Mode

Specify the app name from anywhere:

```bash
dapp nginx ps              # Works from anywhere
dapp nginx logs -f
```

### Tab Completion

After installation, tab completion works for:

- App names: `dapp <TAB>` shows available apps
- Commands: `dapp APP <TAB>` shows available docker compose commands

Example:

```bash
dapp n<TAB>                # Completes to 'nginx'
dapp nginx p<TAB>          # Completes to 'ps'
```

### Helper Function - `dcd`

The optional `dcd` shell helper is installed when you run `sudo ./dapp_cmd --install` and use Bash. It lets you jump directly into app directories under `DAPP_DIR`:

```bash
dcd nginx                  # Changes to /opt/dapps/nginx
dcd postgresql             # Changes to /opt/dapps/postgresql
```

If the helper is installed but not active, reload your shell or source your bash profile:

```bash
source ~/.bashrc
```

The helper respects `DAPP_DIR`, so if you use a custom app root it still works:

```bash
export DAPP_DIR=/home/apps/dapps
dcd myapp
```

## Examples

### Start a web service

```bash
dapp nginx u -d
dapp nginx logs -f
```

### Check status of all apps

```bash
dapp status
```

### View an app's compose configuration

```bash
dapp postgresql edit       # Opens in $EDITOR (nano by default)
```

### Run a one-off command in a container

```bash
dapp postgresql exec db psql -U postgres
```

### Rebuild and restart

```bash
dapp nginx down
dapp nginx build
dapp nginx u
```

## Environment Variables

The `.config` file located in `/opt/dapp_cmd` provides the settings below.

**Environment variables override the local config file.**

| Variable      | Default      | Description                    |
|---------------|--------------|--------------------------------|
| `DAPP_DIR`    | `/opt/dapps` | Root directory for Docker apps |
| `DAPP_EDITOR` | `nano`       | Editor used for `dapp APP edit`|

**Example:**

```bash
DAPP_DIR=/home/apps/dapps
```

## Troubleshooting

### "Docker App 'APP' not found"

The app directory doesn't exist in `$DAPP_DIR`. Check:

```bash
dapp ls                    # List available apps
ls "$DAPP_DIR"/          # List raw directory
```

### "No compose file found"

The app directory doesn't contain a valid compose file. Ensure one of these exists:

- `compose.yml`
- `compose.yaml`
- `docker-compose.yml`
- `docker-compose.yaml`

### "Docker Compose not found"

Neither `docker compose` nor `docker-compose` is installed. Install Docker Desktop or Docker Engine with Docker Compose.

### Permission denied errors

If you see permission errors on compose files:

```bash
sudo dapp APP up           # Use sudo for privileged operations
```

or add user to docker group

## Requirements

- **Bash** 4.0+
- **Docker Engine** with Docker Compose (v1.x or v2+)
- **Root/sudo access** for installation only (not for daily use)

## Related

See `dapps_function` for alternative (limited) version of dapp for Docker app management utilities, to be inserted in .bash_aliases.
