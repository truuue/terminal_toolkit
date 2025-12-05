##########
# ZSH CORE
##########

# Performance & sécurité
export ZSH_DISABLE_COMPFIX=true
ZSH_COMPDUMP="$HOME/.zcompdump"
autoload -Uz compinit
compinit -d "$ZSH_COMPDUMP" -C
setopt NO_BEEP
setopt NO_FLOW_CONTROL
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS

# Éditeur par défaut
export EDITOR="code"
export VISUAL="code"


########
# PATHS
########

# Homebrew (Apple Silicon)
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# Bin user
export PATH="$HOME/bin:$PATH"


##########
# FNM
##########

eval "$(fnm env --use-on-cd)"


#######
# BUN
#######

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"


##########
# ALIASES
##########

# Package managers
alias p="pnpm"
alias b="bun"
alias r="run"
alias d="dev"
alias brd="bun run dev"

# Git
alias gs='git status'
alias gl='git log --oneline --graph --decorate'
alias gcm='git commit -m'
alias gpush='git push'

# Shell
alias ll='ls -lh'
alias la='ls -A'
alias now='date "+%Y-%m-%d %H:%M"'

# Network
alias ifc='ifconfig'


#################
# NETWORK / IP
#################

# IP locale (priorité à ip, sinon ifconfig)
myip() {
  if command -v ip >/dev/null 2>&1; then
    ip addr show | awk '/inet / && !/127.0.0.1/ {print $2}'
  else
    ifconfig | awk '/inet / && $2 != "127.0.0.1" {print $2}'
  fi
}

# IP publique
pubip() {
  curl -s https://api.ipify.org && echo
}


##########
# PROJECTS
##########

# Racine de tous tes projets
export DEV="$HOME/dev"

# Dernier projet visité
export LAST_PROJECT=""

# Aller dans un projet instantanément (scopé à ~/dev)
f() {
  [ -z "$1" ] && ls "$DEV" && return

  if [ ! -d "$DEV/$1" ]; then
    echo "Projet introuvable : $1"
    return
  fi

  export LAST_PROJECT="$1"
  cd "$DEV/$1" || return
  ls
}

# Revenir au dernier projet visité
pp() {
  [ -n "$LAST_PROJECT" ] && f "$LAST_PROJECT"
}

# Completion pour f()
_f_complete() {
  local projects
  projects=$(cd "$DEV" && find . -mindepth 1 -maxdepth 2 -type d | sed 's|^\./||')
  compadd -- ${=projects}
}
compdef _f_complete f

# Rename project
ren() {
  if [[ $# -ne 2 ]]; then
    echo "Usage: ren <old_name> <new_name>"
    return 1
  fi

  local old="$1"
  local new="$2"

  local old_dir="$DEV/$old"
  local new_dir="$DEV/$new"

  local old_hist="$HOME/.zsh_history_$old"
  local new_hist="$HOME/.zsh_history_$new"

  # Vérifier que l'ancien projet existe
  if [[ ! -d "$old_dir" ]]; then
    echo "Projet introuvable : $old"
    return 1
  fi

  # Vérifier que le nouveau nom n'existe pas déjà
  if [[ -d "$new_dir" ]]; then
    echo "Un projet existe déjà sous le nom : $new"
    return 1
  fi

  # Renommage du dossier
  mv "$old_dir" "$new_dir"

  # Renommage du fichier d'historique (si présent)
  if [[ -f "$old_hist" ]]; then
    mv "$old_hist" "$new_hist"
  fi

  # Mettre à jour LAST_PROJECT si nécessaire
  if [[ "$LAST_PROJECT" == "$old" ]]; then
    export LAST_PROJECT="$new"
  fi

  echo "Renommage terminé."
}


##########
# PROJECT INIT (mkp)
##########

mkp() {
  if [ $# -lt 2 ]; then
    echo "Usage: mkp <vite|next|elysia> <name>"
    return
  fi

  local type="$1"
  local name="$2"

  # Crée ~/dev si absent
  if [ ! -d "$DEV" ]; then
    echo "Creating projects directory: $DEV"
    mkdir -p "$DEV" || return
  fi

  cd "$DEV" || return

  if [ -d "$name" ]; then
    echo "Projet déjà existant : $name"
    return
  fi

  case "$type" in
    vite)
      echo "⚡ Creating Vite project ($name)"
      bun create vite "$name" --template react-swc-ts
      ;;
    next)
      echo "▲ Creating Next.js project ($name)"
      bun create next-app@latest "$name" --yes
      ;;
    elysia)
      echo "√ Creating Elysia project ($name)"
      bun create elysia "$name"
      ;;
    *)
      echo "Type inconnu : $type"
      echo "Types disponibles : vite | next | elysia"
      return
      ;;
  esac

  cd "$name" || return

  # Init git seulement si absent
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git init
  fi

  # Ouvre VS Code seulement si disponible
  command -v code >/dev/null && code .

  echo "Projet '$name' prêt"
}

# Alias ergonomiques
alias mkpv='mkp vite'
alias mkpn='mkp next'
alias mkpe='mkp elysia'


##########################
# REMOVE PROJECT (rem)
##########################

rem() {
  if [[ -z "$1" ]]; then
    echo "Usage: rem <project_name>"
    return 1
  fi

  local project="$1"
  local project_dir="$DEV/$project"
  local hist_file="$HOME/.zsh_history_$project"

  # Vérification : On ne supprime que dans ~/dev
  if [[ ! -d "$project_dir" ]]; then
    echo "Projet introuvable : $project"
    return 1
  fi

  # Supprime le dossier du projet
  rm -rf "$project_dir"

  # Supprime l’historique associé
  if [[ -f "$hist_file" ]]; then
    rm -f "$hist_file"
  fi

  # Reset LAST_PROJECT si nécessaire
  [[ "$LAST_PROJECT" == "$project" ]] && export LAST_PROJECT=""

  echo "Suppression terminée."
}


##########
# DEV TOOLS
##########

# Nettoyage projet Node
clean() {
  [[ -f package.json || -f bun.lockb || -f pnpm-lock.yaml ]] || {
    echo "Not a Node project"
    return
  }

  rm -rf node_modules dist build .turbo .next .cache
}

# Mise à jour projet
up() {
  # 1. Git (si repo)
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Git pull"
    git pull --rebase
  fi

  # 2. Dépendances Node / Bun
  if [ -f "bun.lockb" ]; then
    echo "Installing dependencies"
    bun install
  elif [ -f "pnpm-lock.yaml" ]; then
    echo "Installing dependencies"
    pnpm install
  elif [ -f "package-lock.json" ]; then
    echo "Installing dependencies"
    npm install
  fi
}

# Reset projet
reset() {
  clean
  up
}


############
# DEV FLOW
############

# Lancer un contexte dev propre
dev() {
  command -v code >/dev/null && code .
  [ -f "package.json" ] && echo "Project detected"
}


#############
# HISTORIQUE
#############

HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt sharehistory
setopt hist_ignore_all_dups

autoload -Uz add-zsh-hook

_project_history() {
  local new_histfile

  if [[ "$PWD" == "$DEV/"* ]]; then
    local project
    project=$(echo "$PWD" | sed "s|$DEV/||" | cut -d/ -f1)
    new_histfile="$HOME/.zsh_history_$project"
  else
    new_histfile="$HOME/.zsh_history_global"
  fi

  # Appliquer le nouveau fichier d'historique
  export HISTFILE="$new_histfile"

  # Recharger l'historique depuis ce fichier
  [[ -f "$HISTFILE" ]] || touch "$HISTFILE"
  fc -p "$HISTFILE"
  fc -R "$HISTFILE"
}

add-zsh-hook chpwd _project_history


############
# QUALITY
############

# Activer les substitutions dans le prompt
setopt PROMPT_SUBST

# Couleur différente si SSH
host_color() {
  [[ -n "$SSH_CONNECTION" ]] && echo '%F{red}' || echo '%F{cyan}'
}

# Branche git (avec cache)
_git_branch_cached=""
_git_pwd_cached=""

git_branch() {
  if [[ "$PWD" != "$_git_pwd_cached" ]]; then
    _git_pwd_cached="$PWD"
    _git_branch_cached=$(git symbolic-ref --short HEAD 2>/dev/null)
  fi

  [[ -n "$_git_branch_cached" ]] && echo " %F{magenta}$_git_branch_cached%f"
}

# Prompt custom
PROMPT='$(host_color)%n@%m%f %F{green}%1~%f$(git_branch) %F{green}➜%f '

# Init historique au lancement
_project_history


