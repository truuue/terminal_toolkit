# ⚡ ZSH Dev Environment – Spotlight-First Workflow

This repo contains my **custom ZSH setup**, built as a **real working tool** focused on **performance**, **readability**, and **durability**.

👉 Key idea:  
**Spotlight → Terminal → ZSH = decision center**

No prompt framework, no third-party launcher, no hidden magic.

---

## 🧠 Core Philosophy

- ✅ **Spotlight-first**: Spotlight is just the portal to open Terminal
- ✅ **Terminal-centric**: all the brains live in the shell
- ✅ **Unix-first**: simple, explicit functions that are easy to reread
- ✅ **Zero dependency**: no Oh-My-Zsh, no external plugins
- ✅ **Performance over gimmicks**

---

## 🚀 Goals of this setup

- **Fast** shell startup
- Clear visual context (SSH / Git / project)
- Instant project navigation
- **Per-project** history
- Standardized project creation
- Minimal cognitive load

---

## ⛓️ Prerequisites

To use this configuration as-is you need the following pieces already installed on the machine:

`Homebrew` (Apple Silicon build) for the PATH assumptions

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

`fnm` to manage Node versions on directory change

```
brew install fnm
```

`Bun` for project scaffolding and dependency installs

```
curl -fsSL https://bun.sh/install | bash
```

`Node.js` runtime exposed through `fnm` or your preferred manager

```
fnm install <version>
```

Once these are present, sourcing `.zshrc` works without additional tweaks.

---

## ⚙️ Performance & Core ZSH

- `compinit` optimized with cache (`.zcompdump`)
- Expensive or useless options disabled
- History stays lean and deduped
- Bun prioritized and instant

```zsh
compinit -d "$ZSH_COMPDUMP" -C
setopt NO_BEEP NO_FLOW_CONTROL HIST_FIND_NO_DUPS HIST_REDUCE_BLANKS
```

---

## 🛤 Toolchain & PATH curation

- Apple Silicon Homebrew pinned to the front of `PATH`
- `$HOME/bin` appended for personal scripts

Result: consistent binaries whether local, SSH, or CI.

---

## 🧩 Runtime management

#### Bun (primary)

- Loaded immediately
- Used for scaffolds and modern projects

#### Node (via FNM)

- `fnm env --use-on-cd` gives per-project Node versions
- Zero-cost shell startup

---

## ⚡ Quick aliases

- Package flow → `p` (pnpm), `b` (bun), `r` (run), `d` (dev), `brd` (`bun run dev`)
- Git hygiene → `gs`, `gl`, `gcm`, `gpush`
- Everyday shell → `ll`, `la`, `now`
- Network shortcut → `ifc` (`ifconfig`)

All aliases are terse, transparent, and only wrap commands I type 50x a day.

---

## 📁 Project organization

All long-living projects live in:

```zsh
~/dev
```

Central variable:

```zsh
export DEV="$HOME/dev"
```

---

## 🔍 Project navigation

`f` – jump to a project

```zsh
f my-project
```

- Intentionally limited to ~/dev
- Predictable and free of magic
- Built-in auto-completion

`pp` – jump back to the previous project

```zsh
pp
```

---

### 🧠 Per-project history

Each project keeps its **own ZSH history file**.

- `~/dev/project-a` → `.zsh_history_project-a`
- Outside projects → `.zsh_history_global`

Advantages:

- `↑` always relevant
- Zero cross-project pollution
- Fewer dangerous mistakes

---

## 🌐 Network helpers

- `myip` → local IPv4 (prefers `ip`, falls back to `ifconfig`)
- `pubip` → public address via `api.ipify.org`
- `ifc` alias still available when I need raw `ifconfig`

Result: situational awareness without memorizing curl one-liners.

---

## 🛠️ Domain commands (personal DSL)

`up` – **update a project**

```zsh
up
```

- `git pull --rebase`
- auto-install dependencies:
  - `bun`
  - `pnpm`
  - `npm`

`clean` – **controlled cleanup**

```zsh
clean
```

- Removes `node_modules`, builds, and caches
- Refuses to run outside a Node project

`reset` – **start fresh**

```zsh
reset
```

Equivalent to:

```zsh
clean && up
```

`ren` – rename a project (folder + matching history)

```zsh
ren old-name new-name
```

`rem` – **remove a project**

```zsh
rem my-project
```

- Hard-stops if the folder is outside `~/dev`
- Clears the matching history file
- Resets `LAST_PROJECT` so navigation stays clean

---

## 🏗️ Project creation (mkp)

Complete standardization for project creation.

**Central command**

```zsh
mkp <type> <name>
```

**Supported types**

- `vite` → React + SWC + TypeScript
- `next` → Next.js latest
- `elysia` → API Bun / Elysia

**Ergonomic aliases**

```zsh
mkpv <name>   # Vite
mkpn <name>   # Next.js
mkpe <name>   # Elysia
```

**Example**

```zsh
mkpn dashboard
```

Result:

- Created in `~/dev/dashboard`
- Official scaffold via `bun create`
- `git init`
- VS Code opened automatically

---

## 🎨 Smart & safe prompt

Features:

- 🔴 **Red on SSH**
- 🟦 **Cyan on local**
- 📦 Git branch shown only if repo
- Git cache to avoid excessive forks

Example:

```zsh
truuue@vps-prod ~/dev/api main ➜
```

---

## 🧑‍💻 Dev flow helper

`dev`

```zsh
dev
```

- Opens VS Code when available
- Emits a quick hint when a `package.json` is detected

---

## ✅ Why this config exists

- Replacement of GUI launchers
- Reduce human errors
- Make the terminal predictable
- Build a durable environment
- Keep full control

---

## 📌 Explicit non-goals

- ❌ Oh-My-Zsh
- ❌ Prompt framework
- ❌ Mandatory fuzzy finder
- ❌ Opaque automations

---

## 🧪 Tested platforms

- macOS (Apple Silicon)
- ZSH
- Bun ≥ 1.x
- Node via FNM
- SSH to VPS / prod

---

## 🧾 License

Personal configuration — free to reuse, adapt, and draw inspiration from.

---

## ✍️ Author

Configuration built and maintained by **truuue**  
Goal: **a terminal that helps you stay focused, not distracted.**
