
BASHCHONFIG_TC_RESET=$'\x1B[0m'
BASHCHONFIG_TC_BG_FAIL=$'\x1B[48;5;1m'
BASHCHONFIG_TC_BG_SUCC=$'\x1B[48;5;243m'
BASHCHONFIG_TC_TEXT=$'\x1B[38;5;15m'
BASHCHONFIG_CLREOL=$'\x1B[K'
BASHCHONFIG_INIT=0
BASHCHONFIG_TIMEISSET=0

function after_command() {
  if [ "$BASHCHONFIG_TIMEISSET" -ne "1" ] ;then
    BASHCHONFIG_TIME=$(gdate +%s%3N)
    BASHCHONFIG_TIMEISSET=1
  fi
}

calc() { awk "BEGIN{print $*}"; }

trap 'after_command' DEBUG

function prompt_command() {
  BASHCHONFIG_VAR=$?
  BASHCHONFIG_HIST="$(history 1 | cut -c 8-)"
  BASHCHONFIG_CMD="$(echo $BASHCHONFIG_HIST | cut -d ' ' -f 1)"
  BASHCHONFIG_PWD=$(pwd)
  BASHCHONFIG_TITLE=""
  BASHCHONFIG_TIMEPASSED="$(calc $(($(gdate +%s%3N)-BASHCHONFIG_TIME))/1000)"

  BASHCHONFIG_TIME="$(gdate +%s%3N)"
  BASHCHONFIG_TIMEISSET=0
  BASHCONFIG_GIT_BRANCH=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')

  BASHCONFIG_OUT="[$BASHCHONFIG_HIST] - ${BASHCHONFIG_TIMEPASSED}s"

  if [[ "$BASHCONFIG_GIT_BRANCH" != "" ]] ;then
    BASHCONFIG_OUT="$BASHCONFIG_OUT - $BASHCONFIG_GIT_BRANCH"
  fi

  if [ -e "$VIRTUAL_ENV" ]; then
    BASHCHONFIG_TITLE="${VIRTUAL_ENV#$WORKON_HOME/} - "
  fi

  if [[ "$(pwd)" == $HOME* ]] ;then
    BASHCHONFIG_TITLE="$BASHCHONFIG_TITLE~${BASHCHONFIG_PWD#$HOME}"
  fi

  if [ "$BASHCHONFIG_INIT" -ne "0" ] ;then
    echo -n "${BASHCHONFIG_TC_TEXT}"
    if [ "$BASHCHONFIG_VAR" -eq "0" ] ;then
      echo -n "${BASHCHONFIG_TC_BG_SUCC} ✓ "
      BASHCHONFIG_TITLE="$BASHCHONFIG_TITLE - $BASHCHONFIG_CMD"
    else
      echo -n "${BASHCHONFIG_TC_BG_FAIL} x "
      BASHCHONFIG_TITLE="$BASHCHONFIG_TITLE - Failed"
    fi
    echo -n "$BASHCONFIG_OUT"
    echo "${BASHCHONFIG_CLREOL}${BASHCHONFIG_TC_RESET}"
  fi


  echo -n -e "\033]0;$BASHCHONFIG_TITLE\007"

  BASHCHONFIG_INIT=1
}
export PROMPT_COMMAND="prompt_command; $PROMPT_COMMAND"
