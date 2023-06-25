#!/bin/sh
set -e

# export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
export NVM_DIR="$HOME/.nvm"

# variables
NVM_SOURCE=https://github.com/nvm-sh/nvm.git

nvm_try_profile() {
  if [ -z "${1-}" ] || [ ! -f "${1}" ]; then
    return 1
  fi
  echo "${1}"
}

#
# Detect profile file if not specified as environment variable
# (eg: PROFILE=~/.myprofile)
# The echo'ed path is guaranteed to be an existing file
# Otherwise, an empty string is returned
#
nvm_detect_profile() {
  if [ "${PROFILE-}" = '/dev/null' ]; then
    # the user has specifically requested NOT to have nvm touch their profile
    return
  fi

  if [ -n "${PROFILE}" ] && [ -f "${PROFILE}" ]; then
    echo "${PROFILE}"
    return
  fi

  local DETECTED_PROFILE
  DETECTED_PROFILE=''

  if [ "${SHELL#*bash}" != "$SHELL" ]; then
    if [ -f "$HOME/.bashrc" ]; then
      DETECTED_PROFILE="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
      DETECTED_PROFILE="$HOME/.bash_profile"
    fi
  elif [ "${SHELL#*zsh}" != "$SHELL" ]; then
    if [ -f "$HOME/.zshrc" ]; then
      DETECTED_PROFILE="$HOME/.zshrc"
    elif [ -f "$HOME/.zprofile" ]; then
      DETECTED_PROFILE="$HOME/.zprofile"
    fi
  fi

  if [ -z "$DETECTED_PROFILE" ]; then
    for EACH_PROFILE in ".profile" ".bashrc" ".bash_profile" ".zprofile" ".zshrc"
    do
      if DETECTED_PROFILE="$(nvm_try_profile "${HOME}/${EACH_PROFILE}")"; then
        break
      fi
    done
  fi

  if [ -n "$DETECTED_PROFILE" ]; then
    echo "$DETECTED_PROFILE"
  fi
}


if [ ! -d $NVM_DIR ] ; then
  echo "=> Downloading nvm from git to '$NVM_DIR'"
  command git clone "$NVM_SOURCE" --depth=1 "${NVM_DIR}" || {
    echo >&2 'Failed to clone nvm repo. Please report this!'
    exit 2
  }
  cd $NVM_DIR
  git fetch --tags --quiet
  LATEST_TAG=$(git describe --tags $(git rev-list --tags --max-count=1) --abbrev=0)
  echo $LATEST_TAG
  git checkout $LATEST_TAG --quiet

  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

  SOURCE_STR="\\nexport NVM_DIR=\"${NVM_DIR}\"\\n[ -s \"\$NVM_DIR/nvm.sh\" ] && \\. \"\$NVM_DIR/nvm.sh\"  # This loads nvm\\n"
  COMPLETION_STR='[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion\n' 
  NVM_PROFILE="$(nvm_detect_profile)"

  # install node.js
  nvm install --lts

  if ! command grep -qc '/nvm.sh' "$NVM_PROFILE"; then
    echo "=> Appending nvm source string to $NVM_PROFILE"
    command printf "${SOURCE_STR}" >> "$NVM_PROFILE"
  else
    echo "=> nvm source string already in ${NVM_PROFILE}"
  fi
  
  if ! command grep -qc '$NVM_DIR/bash_completion' "$NVM_PROFILE"; then
    echo "=> Appending bash_completion source string to $NVM_PROFILE"
    command printf "$COMPLETION_STR" >> "$NVM_PROFILE"
  else
    echo "=> bash_completion source string already in ${NVM_PROFILE}"
  fi

fi
