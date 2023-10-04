#!/bin/bash
# based on a function found in bashtstyle-ng 5.0b1
# Original author Christopher Roy Bratusek (http://www.nanolx.org)
# Last arranged by ayoli (http://ayozone.org) 2008-02-04 17:16:43 +0100 CET

#export TERM=xterm-color
#export TERM=cygwin
#export TERM=xterm-new

function parse_git_dirty {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working tree clean" ]] && echo "*"
}
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/[\1$(parse_git_dirty)]/"
}
#export PS1='\[\e[33m\]\u@\h \[\e[32m\]\w\[\e[31m\]$(parse_git_branch)\[\e[0m\] $

function pre_prompt {
newPWD="${PWD}"
user="whoami"
host=$(echo -n $HOSTNAME | sed -e "s/[\.].*//")
datenow=$(date "+%a, %d %b %y")
let promptsize=$(echo -n "-----($user@$host ddd., DD mmm YY)$(parse_git_branch)(${PWD})-" \
                 | wc -c | tr -d " ")
let fillsize=${COLUMNS}-${promptsize}
fill=""
while [ "$fillsize" -gt "0" ]
do
    fill="${fill}-"
	let fillsize=${fillsize}-1
done
if [ "$fillsize" -lt "0" ]
then
    let cutt=3-${fillsize}
    newPWD="...$(echo -n $PWD | sed -e "s/\(^.\{$cutt\}\)\(.*\)/\2/")"
fi

}

PROMPT_COMMAND=pre_prompt

# Colors from http://wiki.archlinux.org/index.php/Color_Bash_Prompt

txtblk='\033[0;30m' # Black - Regular
txtred='\033[0;31m' # Red
txtgrn='\033[0;32m' # Green
txtylw='\033[0;33m' # Yellow
txtblu='\033[0;34m' # Blue
txtpur='\033[0;35m' # Purple
txtcyn='\033[0;36m' # Cyan
txtwht='\033[0;37m' # White
txtora='\033[0;38m' # Orange
bldblk='\033[1;30m' # Black - Bold
bldred='\033[1;31m' # Red
bldgrn='\033[1;32m' # Green
bldylw='\033[1;33m' # Yellow
bldblu='\033[1;34m' # Blue
bldpur='\033[1;35m' # Purple
bldcyn='\033[1;36m' # Cyan
bldwht='\033[1;37m' # White
unkblk='\033[4;30m' # Black - Underline
undred='\033[4;31m' # Red
undgrn='\033[4;32m' # Green
undylw='\033[4;33m' # Yellow
undblu='\033[4;34m' # Blue
undpur='\033[4;35m' # Purple
undcyn='\033[4;36m' # Cyan
undwht='\033[4;37m' # White
bakblk='\033[40m'   # Black - Background
bakred='\033[41m'   # Red
badgrn='\033[42m'   # Green
bakylw='\033[43m'   # Yellow
bakblu='\033[44m'   # Blue
bakpur='\033[45m'   # Purple
bakcyn='\033[46m'   # Cyan
bakwht='\033[47m'   # White
txtrst='\033[0m'    # Text Reset

export black="\[\033[0;38;5;0m\]"
export red="\[\033[0;38;5;1m\]"
export orange="\[\033[0;38;5;130m\]"
export green="\[\033[0;38;5;2m\]"
export yellow="\[\033[0;38;5;3m\]"
export blue="\[\033[0;38;5;4m\]"
export bblue="\[\033[0;38;5;12m\]"
export magenta="\[\033[0;38;5;55m\]"
export cyan="\[\033[0;38;5;6m\]"
export white="\[\033[0;38;5;7m\]"
export coldblue="\[\033[0;38;5;33m\]"
export smoothblue="\[\033[0;38;5;111m\]"
export iceblue="\[\033[0;38;5;45m\]"
export turqoise="\[\033[0;38;5;50m\]"
export smoothgreen="\[\033[0;38;5;42m\]"

case "$TERM" in
cygwin*)
    PS1="\n\[${bldblu}\]--(\[${txtgrn}\]\u@\h \$(date \"+%a, %d %b %y\")\[${bldblu}\])-\${fill}-\$(parse_git_branch)(\[${txtylw}\]\$newPWD\
\[${bldblu}\])--\n\[${bldblu}\]--(\[${txtora}\]\$(date \"+%H:%M\") \$\[${bldblu}\])->\[${txtrst}\] "
    ;;
xterm*)
    PS1="\n\[${bldblu}\]--(\[${txtgrn}\]\u@\h \$(date \"+%a, %d %b %y\")\[${bldblu}\])-\${fill}-\$(parse_git_branch)(\[${txtylw}\]\$newPWD\
\[${bldblu}\])--\n\[${bldblu}\]--(\[${txtora}\]\$(date \"+%H:%M\") \$\[${bldblu}\])->\[${txtrst}\] "
    ;;
screen)
    PS1="$bblue┌─($orange\u@\h \$(date \"+%a, %d %b %y\")$bblue)─\${fill}─\$(parse_git_branch)($orange\$newPWD\
$bblue)─┐\n$bblue└─($orange\$(date \"+%H:%M\") \$$bblue)─>$white "
    ;;
    *)
    PS1="┌─(\u@\h \$(date \"+%a, %d %b %y\"))─\${fill}─\$(parse_git_branch)(\$newPWD\
)─┐\n└─(\$(date \"+%H:%M\") \$)─> "
    ;;
esac

# bash_history settings: size and no duplicates and no lines w/ lead spaces
export HISTCONTROL="ignoreboth"
export HISTSIZE=1024
