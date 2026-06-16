# dapp — A Docker Compose Wrapper for the Lazy

<p align="center">
  <img src="assets/logo.svg" alt="dapp logo" width="600"/>
</p>

> _While unwittingly eating cornflakes with a fork and finger tapping a keyboard, I yearned to somehow speed up my `docker compose` flow; then actually using a spoon inspired `dapp`. For me, this is the way._

[![CI](https://github.com/neutralvibes/dapp/actions/workflows/ci.yml/badge.svg)](https://github.com/neutralvibes/dapp/actions/workflows/ci.yml)
---


## Why dapp?

Because this gets old fast:

```bash
# The old way — navigate, type, repeat
cd /opt/dapps/nginx && docker compose logs -f
cd /opt/dapps/grafana && docker compose up -d
cd /opt/dapps/frigate && docker compose restart
```

When you could just do this — **from anywhere:**

```bash
dapp nginx lf
dapp grafana u
dapp frigate r
```

A taste of what else it can do:

```bash
dapp pihole pullup                      # pull && up -d in one cmd
dapp @status                            # Status of every app at a glance
dapp immich lf                          # Stream logs for any app
dapp postgresql exec db psql -U postgres # Exec into a container
dapp @list=nginx,caddy,grafana u        # Start a group of apps at once
dapp nextcloud d                        # Bring nextcloud down
dapp @status-save stopped ~/stopped.txt # Save a list of stopped apps
dapp nginx                              # ps of nginx app
dapp ports-check 1984                   # Find container using port 1984, if any
dcd nginx                               # cd straight into the nginx folder
```

---

## Table of Contents

- [Overview](#overview)
- [How It Works](#how-it-works)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Quick Reference](#quick-reference)
  - [Command Shortcuts](#command-shortcuts)
  - [Local Mode](#local-mode)
  - [Global Mode](#global-mode)
  - [List Operations](#list-operations)
  - [Tab Completion](#tab-completion)
  - [dcd Helper](#dcd-helper)
- [Advanced Usage](#advanced-usage)
- [Self-Update](#self-update)
- [Environment Variables](#environment-variables)
- [Troubleshooting](#troubleshooting)
- [Requirements](#requirements)
- [Disclaimer](#disclaimer)

---

## Overview

`dapp` is a bash script that wraps `docker compose` (v2) or `docker-compose` (v1.x) to make managing one or multiple Docker applications faster and less repetitive. It provides command shortcuts, tab completion, multi-app operations, and works from any directory.

_This works for me, but there are advanced ways of working with docker that this may not suit. For this reason it is important to test this utility to see if it meets your requirements._

**Key features:**

- Run compose commands against any app without `cd`-ing into its folder
- Short aliases for common commands (`u` → `up -d`, `d` → `down`, etc.)
- View the status of all apps at a glance
- Run a command across multiple apps at once
- Save lists of running/stopped apps for batch operations

A companion utility, [`dcd`](#dcd-helper), enables quick directory-switching into app folders with tab completion.

> Docker and Docker Compose must be installed before using `dapp`.

---

## How It Works

`dapp` expects your Docker applications to live as sub-folders under a single parent directory (default: `/opt/dapps`). Each sub-folder is considered an **app** if it contains a valid compose file.

**Supported compose filenames:**

- `compose.yml` / `compose.yaml`
- `docker-compose.yml` / `docker-compose.yaml`

### Example Folder Structure

```
/opt/dapps/          ← parent folder (DAPP_DIR)
├── nginx/
│   ├── compose.yml
│   └── app_files/
├── frigate/
│   └── docker-compose.yaml
├── grafana/
│   └── docker-compose.yml
└── immich/
    └── compose.yaml
```

> **Tip:** Avoid spaces in app folder names. Underscores and dashes are fine.

An **app name** in `dapp` is just the sub-folder name (e.g. `nginx`, `grafana`) — not a full path.

---

## Installation

### 1. Download

```bash
curl -L https://github.com/neutralvibes/dapp/archive/refs/heads/main.tar.gz \
    | sudo tar -xz -C /opt
```

### 2. Install

```bash
sudo /opt/dapp_cmd/dapp_cmd --install
```

### 3. Install `dcd` _(optional)_

Run this for each user who needs the `dcd` directory-switching helper:

```bash
dapp --install-dcd
```

To give `root` access too:

```bash
sudo dapp --install-dcd
```

### Removal

```bash
sudo dapp --uninstall
```

---

## Configuration

The config file lives at `/opt/dapps_cmd/.config`. Edit it with:

```bash
sudo -e /opt/dapp_cmd/.config
```

| Variable       | Default      | Description                             |
|----------------|--------------|------------------------------------------|
| `DAPP_DIR`     | `/opt/dapps` | Parent directory for Docker app folders |
| `DAPP_EDITOR`  | `nano`       | Editor used by `dapp APP edit`          |
| `DAPP_LIST_SAFE` | see config | Whitelisted commands for list operations |

### List Command Whitelist

The `@list-all`, `@list=`, and `@list-file=` operations only run commands in the `DAPP_LIST_SAFE` whitelist (to prevent accidentally looping blocking or destructive commands over every app).


| Whitelist entry              |                                      |
|------------------------------|--------------------------------------|
| COMMAND                      | Permit COMMAND with any ARGS          |
| noflag:(-f\|--follow):COMMAND| Ban COMMAND ARGS '-f' and '--follow'. Allows any other ARGS. |
| strict:COMMAND               | Permit COMMAND but without any ARGS       |
| flag:(-d\|--hi\|-p):COMMAND  | Permit COMMAND ARGS '-d', '--hi' and '-p' only|

Whitelist entries must be separated by a semi-colon.


```text
# Example whitelist
DAPP_LIST_SAFE="ps; up -d; start; stop; down; restart; noflag:(-f|--follow):logs"
```

If `DAPP_LIST_SAFE` is unset, `dapp` falls back to an internal default list.

---

## Usage

### Quick Reference

```bash
dapp @ls                         # List all Docker compose apps
dapp @status                     # Show status of all apps
dapp APP                         # Run 'docker compose ps' for APP
dapp APP edit                    # Edit APP's compose file
dapp APP [compose command...]    # Run compose command for APP
```

### Command Shortcuts

These shortcuts expand to their full `docker compose` equivalents and work in all modes (global, local, and list):

| Shortcut | Expands To        |
|----------|-------------------|
| `d`      | `down`            |
| `l`      | `logs`            |
| `lf`     | `logs -f`         |
| `pullup` | `pull && up -d`   |
| `u`      | `up -d`           |
| `ulf`    | `up -d && logs -f`|
| `r`      | `restart`         |

_Expansions containg  `&&` insert docker compose in the right places_

```bash
dapp traefik u       # up -d
dapp nginx d         # down
dapp frigate l       # logs
dapp grafana lf      # logs -f
dapp immich r        # restart
```

Run `dapp -h` to see all available options.

### Local Mode

When run from inside an app folder (one containing a compose file), you can omit the app name:

```bash
cd /opt/dapps/nginx   # or: dcd nginx

dapp ps
dapp logs -f
dapp up -d
dapp u                # shortcut for up -d
dapp lf               # shortcut for logs -f
```

### Global Mode

Run compose commands for any app from anywhere:

```bash
dapp nginx ps
dapp grafana up
dapp immich down
dapp frigate logs -f
dapp caddy restart
dapp postgresql exec db psql -U postgres
```

### List Operations

Run a whitelisted command across multiple apps using `@list-all`, `@list=`, or `@list-file=`.

```bash
# All apps
dapp @list-all ps

# Selected apps (comma-separated)
dapp @list=frigate,caddy,immich stop

# Apps listed in a file (one name per line)
dapp @list-file=~/dlists/app-list.lst down
```

> **Caution:** Using `@list-all` targets every detected app. It's recommended to use named lists for routine batch operations.

#### Saving Status Lists

Generate app name lists (one per line) that can be fed back into `@list-file=`:

```bash
dapp @status-save stopped /path/to/file    # List all stopped apps
dapp @status-save running /path/to/file    # List all running apps
```

### Tab Completion

After installation, tab completion is available for app names and some compose commands:

```bash
dapp <TAB>           # Shows all available app names
dapp n<TAB>          # Completes to 'nginx'
dapp nginx <TAB>     # Shows available compose commands
dapp nginx pu<TAB>    # Completes to 'pull'
```

### dcd Helper

`dcd` is an optional shell function that lets you `cd` directly into an app folder from anywhere, with tab completion:

```bash
dcd nginx             # cd /opt/dapps/nginx
dcd frigate           # cd /opt/dapps/frigate
dcd ng<TAB>           # Completes to 'nginx'
```

`dcd` respects the `DAPP_DIR` environment variable. If the helper was just installed, reload your shell first:

```bash
source ~/.bashrc
```

---

## Advanced Usage

### Overriding `DAPP_DIR` at Runtime

Set `DAPP_DIR` in your shell to point at a different app root without changing the config file:

```bash
export DAPP_DIR=/home/apps/dapps
dapp ls     # Lists apps under /home/apps/dapps
```

Environment variables take precedence over `.config`.

### Wrapping `dapp` for Multiple Stacks

You can create wrapper scripts to manage separate Docker stacks:

```bash
#!/bin/bash
# Script: stackb
export DAPP_DIR=/stack_b/apps
dapp "$@"
```

```bash
stackb nextcloud u       # up -d in /stack_b/apps/nextcloud
stackb emby l            # logs for /stack_b/apps/emby
stackb nzbget build
```

### Common Workflows

```bash
# Check all app statuses. (! running=stopped)
dapp @status

# Start a service and follow its logs
dapp nginx u
dapp nginx lf

# View an app's compose config
dapp postgresql edit

# Run a one-off command in a container
dapp postgresql exec db psql -U postgres

# Rebuild and restart
dapp nginx d
dapp nginx build
dapp nginx u

# Check what if anything is using a port
dapp ports-check 8080

```

---

## Self-Update

```bash
dapp --self-update
```

Checks the remote version and updates only if a newer version is available. No update is performed if the installed version is current.

---

## Environment Variables

Environment variables always override the `.config` file.

| Variable        | Default      | Description                             |
|-----------------|-------------|------------------------------------------|
| `DAPP_DIR`      | `/opt/dapps` | Parent directory for Docker app folders |
| `DAPP_EDITOR`   | `nano`       | Editor used by `dapp APP edit`          |
| `DAPP_LIST_SAFE`| _see config_ | Whitelist for list commands             |

---

## Troubleshooting

### `"Docker App 'APP' not found"`

The app sub-folder doesn't exist under `$DAPP_DIR`:

```bash
dapp @ls             # List detected apps
ls "$DAPP_DIR"/      # Check the raw directory
```

### `"No compose file found"`

The app folder exists but contains no recognised compose file. Ensure one of these is present:

- `compose.yml` / `compose.yaml`
- `docker-compose.yml` / `docker-compose.yaml`

### `"Docker Compose not found"`

Neither `docker compose` nor `docker-compose` is installed. Install Docker Desktop or Docker Engine with the Compose plugin.

### Permission denied errors

```bash
sudo dapp APP up     # Use sudo for privileged operations
```

Or add your user to the `docker` group:

```bash
sudo usermod -aG docker $USER
```

---

## Requirements

- **Bash** 4.0+
- **Docker Engine** with Docker Compose (v1.x or v2+)
- **Root/sudo access** for installation only — not needed for daily use

---

## Related

See `dapps_function` for an alternative, limited version of `dapp` designed to be inserted directly into `.bash_aliases`.

---

## Disclaimer

**Non-Affiliation:** This project is neither affiliated with nor endorsed by Docker, Inc. "Docker" and the Docker logo are trademarks or registered trademarks of Docker, Inc.

**Warranty Disclaimer:** This script is provided "AS IS" without warranties of any kind, express or implied. The author assumes no liability for data loss, system damage, or any other consequences arising from its use.
