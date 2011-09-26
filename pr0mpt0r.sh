# prompt0r

# default prompt
export MY_P=":s"

function parse_git_branch {
	git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function parse_svn_revision {
	svn info 2> /dev/null | grep Revision: | sed -e 's/^Revision: \(\d*\)/r\1/'
}

function get_prompt_info {
  case $1 in
    :d )
      date_prompt
      ;;
    :re )
      rails_env_prompt
      ;;
    :s )
      scm_prompt
      ;;
    * )
      echo $prompt
      ;;
  esac
}

function get_full_prompt_info {
  if [[ $# == 0 ]]; then
    get_full_prompt_info $MY_P && return
  fi
  
  local PROMPT_INFO=`get_prompt_info $1`;shift
  for prompt in $*; do
    local P=`get_prompt_info $prompt`
    if [[ ! -z "$P" ]]; then
      PROMPT_INFO="${PROMPT_INFO} | `get_prompt_info $prompt`"
    fi
  done
  
  if [[ ! -z "$PROMPT_INFO" ]]; then
    echo " ($PROMPT_INFO)"
  fi
  
}

function date_prompt {
  date
}

function rails_env_prompt {
  if [[ ! -z "$RAILS_ENV" ]]; then
    echo $RAILS_ENV
  else
    echo development
  fi
}

function scm_prompt {
	git_branch=$(parse_git_branch)
	svn_revision=$(parse_svn_revision)

	if [[ "$git_branch" != '' ]]; then
		echo "$git_branch"
	elif [[ "$svn_revision" != '' ]]; then
		echo "$svn_revision"
	fi
}

function pr0mpt0r {
	local color_red=`tput setaf 1`
	local color_green=`tput setaf 2`
	local reset_color=`tput sgr0`

	# need to wrap non-printable characters in \[ and \] 
	# so PS1 knows not to count them when determining the length of the prompt
	color_red=\\\[${color_red}\\\]
	color_green=\\\[${color_green}\\\]
	reset_color=\\\[${reset_color}\\\]

	export PS1="\h:\W${color_red}\$(get_full_prompt_info)${color_green} \u${reset_color}\$ "
	PS2='> '
	PS4='+ '
}
