### Add colors to terminal
export CLICOLOR=1

### Aliases
alias l="ls -CF"
alias la="ls -A"
alias ll="ls -alF"
alias code="open -a Visual\ Studio\ Code"

### Use nano as the default editor (instead of vim)
export EDITOR=nano
export VISUAL="$EDITOR"

# Add Homebrew to PATH
eval "$(/opt/homebrew/bin/brew shellenv)" # echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile

# Add Node.js v16 to PATH
export PATH="/opt/homebrew/opt/node@16/bin:$PATH"

# Print terminal color spectrum with codes
function colorswatch() {
  for i in {0..255};
  do
    print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'};
  done
}

# Print text with normal and bright colors
function colorswatchfg() {
  echo -e "\033[0;39mNC (No color)"
  echo -e "\033[0;30mBLACK   \t \033[1;90mBRIGHT_BLACK"
  echo -e "\033[0;31mRED     \t \033[1;91mBRIGHT_RED"
  echo -e "\033[0;32mGREEN   \t \033[1;92mBRIGHT_GREEN"
  echo -e "\033[0;33mYELLOW  \t \033[1;93mBRIGHT_YELLOW"
  echo -e "\033[0;34mBLUE    \t \033[1;94mBRIGHT_BLUE"
  echo -e "\033[0;35mMAGENTA \t \033[1;95mBRIGHT_MAGENTA"
  echo -e "\033[0;36mCYAN    \t \033[1;96mBRIGHT_CYAN"
  echo -e "\033[0;37mWHITE   \t \033[1;97mBRIGHT_WHITE"
  # normal background colors are in the 40's range, and bright background colors in the 100's range
}

############################
### PROMPT CONFIGURATION ###
############################

# Enable substitution in the prompt
setopt PROMPT_SUBST

# Enable git autocomplete
autoload -Uz compinit && compinit

# Load version control information
autoload -Uz vcs_info

# Configure styles for vcs_info
# https://arjanvandergaag.nl/blog/customize-zsh-prompt-with-vcs-info.html
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' formats '(%b) %m%u%c'
zstyle ':vcs_info:*' actionformats '(%b) %a %m%u%c'

# Initialize vsc_info in precmd function
precmd () { vcs_info }

# Add a new line between the prompt and the command's output
preexec () { echo }

# Prompt codes:
# %B / %F{n} / %K{n}: begin bold / color / background color
# %b / %f / %k: end bold / color / background color
# %n~: display n latest directories of current directory
# %#: display a '%' (or '#' when root)
# %(..): conditional expression (see docs)
# %?: exit code of last process
# %n@%m: user@host
# \UE0B0 = solid right arrow
# \UE0B1 = empty right arrow
# \UE0B2 = solid left arrow
# \UE0B3 = empty left arrow
# █▓▒░ = fade

# Default prompt
# PROMPT="%n@%m %1~ %# "

# Lean custom prompt
# PROMPT='%B%F{red}%n%b@%m:%B%F{yellow}%~%f%b %F{099}${vcs_info_msg_0_}%f%# '

# Function to configure a multiline full rainbow prompt
setprompt () {
  local top_left top_right top_left_length top_right_length vcs_info_length filler filler_length max_length

  # Evaluate the expressions without colors and formatting to get the actual length of text that will be printed
  top_left_length=${#${(%):---  > %n@%m > %2~ > >}}
  top_right_length=${#${(%):-< %D{%H:%M:%S} --}}
  vcs_info_length=${#${(%):-${vcs_info_msg_0_}}}
  
  # Calculate the space between the left-side content and the right-side content of the prompt
  filler_length=$(($COLUMNS - top_left_length - top_right_length - 1))

  # Create filler using the space calculated above, and calculate the max length to truncate the VCS and working directory information if needed
  if [[ $vcs_info_length -lt $filler_length ]]; then
    max_length=0
    filler_length=$((filler_length - vcs_info_length))
  else
    max_length=$(((${#${(%):-%2~}} + filler_length) / 2))
    filler_length=$(((${#${(%):-%2~}} + filler_length) % 2))
  fi
  filler="$PR_SHIFT_IN${(r:$filler_length::$PR_HBAR:)}$PR_SHIFT_OUT"
  filler="$PR_SHIFT_IN\${(l.(($filler_length))..${PR_HBAR}.)}$PR_SHIFT_OUT"

  # On the left side of the prompt: usename@host | Working directory | VCS
  top_left=$'\n$PR_SHIFT_IN$PR_ULCORNER$PR_HBAR$PR_SHIFT_OUT%K{black}%F{white}  %K{049}%F{black}\UE0B0 %F{237}%B%n%b@%m %F{049}%K{075}\UE0B0 %F{231}%K{075}'
  top_left+="%$max_length<...<%2~%<<"
  top_left+=$' %K{099}%F{075}\UE0B0 %F{231}'
  top_left+="%$max_length<...<$vcs_info_msg_0_%<<"
  top_left+=$'%k%F{099}\UE0B0%f'
  # On the right side of the prompt: Datetime
  top_right=$'%F{black}\UE0B2%K{black} %F{249}%D{%H:%M:%S}%f %k$PR_SHIFT_IN$PR_HBAR$PR_URCORNER$PR_SHIFT_OUT'

  # Set the multiline prompt
  PROMPT=$top_left$filler$top_right
  PROMPT+=$'\n$PR_SHIFT_IN$PR_LLCORNER$PR_HBAR$PR_SHIFT_OUT%K{black} %(?.%F{049}.%F{204})❯ %k%F{black}\UE0B0%f '

  # Set the right prompt
  RPROMPT=$'%F{black}\UE0B2%K{black} %F{249}%D{%a %b %d} %f%k$PR_SHIFT_IN$PR_HBAR$PR_LRCORNER$PR_SHIFT_OUT'

  # http://aperiodic.net/phil/prompt/
  typeset -A altchar
  set -A altchar ${(s..)terminfo[acsc]}
  PR_SET_CHARSET="%{$terminfo[enacs]%}"
  PR_SHIFT_IN="%{$terminfo[smacs]%}"
  PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
  PR_DOT=${altchar[~]:-:}
	PR_HBAR=${altchar[q]:--}
	PR_VBAR=${altchar[x]:-|}
	PR_LVBAR=${altchar[u]:-|}
	PR_RVBAR=${altchar[t]:-|}
	PR_LRVBAR=${altchar[n]:-|}
	PR_ULCORNER=${altchar[l]:--}
	PR_LLCORNER=${altchar[m]:--}
	PR_LRCORNER=${altchar[j]:--}
	PR_URCORNER=${altchar[k]:--}
}

# Add setprompt to the list of functions that'll be executed before each prompt
precmd_functions+=(setprompt)
