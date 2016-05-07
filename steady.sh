#!/bin/bash
# =====================================================================================================
# Copyright (C) steady.sh v1.2 2016 iicc (@iicc1)
# =====================================================================================================
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# this program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
# =======================================================================================================
# It depends on Tmux https://github.com/tmux/tmux which is BSD-licensed
# and Screen https://www.gnu.org/software/screen GNU-licensed.
# =======================================================================================================
# This script is intended to control the state of a telegram-cli telegram bot running in background.
# The idea is to get the bot fully operative all the time without any supervision by the user.
# It should be able to recover the telegram bot in any case telegram-cli crashes, freezes or whatever.
# This script works by tracing ctxt swithes value in kernel procces at a $RELOADTIME 
# So it can detect any kind of kernel interruption with the procces and reload the bot.
#
#--------------------------------------------------
#--      ____  ____ _____                        --
#--     |    \|  _ )_   _|___ ____   __  __      --
#--     | |_  )  _ \ | |/ ·__|  _ \_|  \/  |     --
#--     |____/|____/ |_|\____/\_____|_/\/\_|     --
#--                                              --
#--------------------------------------------------
#--                                              --
#--       Developers: @Josepdal & @MaSkAoS       --
#--     Support: @Skneos,  @iicc1 & @serx666     --
#--                                              --
#--------------------------------------------------


# Some script variables
OK=0
BAD=0
NONVOLUNTARY=1
NONVOLUNTARYCHECK=0
VOLUNTARY=1
VOLUNTARYCHECK=0
I=1
BOT=NortTM  # You can put here other bots. Also you can change it to run more than one bot in the same server.
RELOADTIME=120  # Time between checking cpu calls of the cli process. Set the value high if your bot does not receive lots of messages.


function tmux_mode {

sleep 0.5
clear
# Space invaders thanks to github.com/windelicato
f=3 b=4
for j in f b; do
  for i in {0..7}; do
    printf -v $j$i %b "\e[${!j}${i}m"
  done
done
bld=$'\e[1m'
rst=$'\e[0m'

cat << EOF

 $f1  ▀▄   ▄▀     $f2 ▄▄▄████▄▄▄    $f3  ▄██▄     $f4  ▀▄   ▄▀     $f5 ▄▄▄████▄▄▄    $f6  ▄██▄  $rst
 $f1 ▄█▀███▀█▄    $f2███▀▀██▀▀███   $f3▄█▀██▀█▄   $f4 ▄█▀███▀█▄    $f5███▀▀██▀▀███   $f6▄█▀██▀█▄$rst
 $f1█▀███████▀█   $f2▀▀███▀▀███▀▀   $f3▀█▀██▀█▀   $f4█▀███████▀█   $f5▀▀███▀▀███▀▀   $f6▀█▀██▀█▀$rst
 $f1▀ ▀▄▄ ▄▄▀ ▀   $f2 ▀█▄ ▀▀ ▄█▀    $f3▀▄    ▄▀   $f4▀ ▀▄▄ ▄▄▀ ▀   $f5 ▀█▄ ▀▀ ▄█▀    $f6▀▄    ▄▀$rst
 
EOF
echo -e "                \e[100m                Steady script           \e[00;37;40m"
echo -e "               \e[01;34m                    by iicc                \e[00;37;40m"
echo ""
cat << EOF
 $bld$f1▄ ▀▄   ▄▀ ▄   $f2 ▄▄▄████▄▄▄    $f3  ▄██▄     $f4▄ ▀▄   ▄▀ ▄   $f5 ▄▄▄████▄▄▄    $f6  ▄██▄  $rst
 $bld$f1█▄█▀███▀█▄█   $f2███▀▀██▀▀███   $f3▄█▀██▀█▄   $f4█▄█▀███▀█▄█   $f5███▀▀██▀▀███   $f6▄█▀██▀█▄$rst
 $bld$f1▀█████████▀   $f2▀▀▀██▀▀██▀▀▀   $f3▀▀█▀▀█▀▀   $f4▀█████████▀   $f5▀▀▀██▀▀██▀▀▀   $f6▀▀█▀▀█▀▀$rst
 $bld$f1 ▄▀     ▀▄    $f2▄▄▀▀ ▀▀ ▀▀▄▄   $f3▄▀▄▀▀▄▀▄   $f4 ▄▀     ▀▄    $f5▄▄▀▀ ▀▀ ▀▀▄▄   $f6▄▀▄▀▀▄▀▄$rst

EOF

sleep 1.2

# Checking if the bot folder is in HOME
echo -e "$bld$f4 CHECKING INSTALLED BOT...$rst"
sleep 0.5
ls ../ | grep $BOT 2>/dev/null >/dev/null
if [ $? != 0 ]; then
  echo -e "$f1 ERROR: BOT: $BOT NOT FOUND IN YOUR HOME DIRECTORY$rst"
  sleep 4
  exit 1
fi
echo -e "$f2 $BOT FOUND IN YOUR HOME DIRECTORY$rst"
sleep 0.5


echo ""
echo -e "\033[38;5;208m      ____  ____ _____                        \033[0;00m"
echo -e "\033[38;5;208m     |    \|  _ )_   _|___ ____   __  __      \033[0;00m"
echo -e "\033[38;5;208m     | |_  )  _ \ | |/ .__|  _ \_|  \/  |     \033[0;00m"
echo -e "\033[38;5;208m     |____/|____/ |_|\____/\_____|_/\/\_|     \033[0;00m"
echo -e "\033[38;5;208m                                              \033[0;00m"
echo =e "\033[38;5;208m   NortTeam Steady.sh Powered by DBTEAM bot.  \033[0;00m"

sleep 1.5
echo -e "$bld$f4 CHECKING PROCESSES...$rst"
sleep 0.7

# Looks for the number of screen/telegram-cli processes
CLINUM=`ps -e | grep -c telegram-cli`
echo "$f2 RUNNING $CLINUM TELEGRAM-CLI PROCESS$rst"
sleep 0.9

# =====Setup ends===== #

# Opening new tmux in a daemon
echo -e "$bld$f4 ATTACHING TMUX AS DAEMON...$rst"
# It is recommended to clear cli status always before starting the bot
rm ../.telegram-cli/state 2>/dev/null
# Nested TMUX sessions trick 
TMUX= tmux new-session -d -s $BOT "./launch.sh"
sleep 1.3

CLIPID=`ps -e | grep telegram-cli | head -1 | sed 's/^[[:space:]]*//' | cut -f 1 -d" "`
echo -e "$f2 NEW TELEGRAM-CLI PROCESS: $CLIPID$rst"
echo ""
echo ""

# Locating telegram-cli status
cat /proc/$CLIPID/task/$CLIPID/status > STATUS
NONVOLUNTARY=`grep nonvoluntary STATUS | cut -f 2 -d":" | sed 's/^[[:space:]]*//'`

sleep 3

# :::::::::::::::::::::::::
# ::::::: MAIN LOOP :::::::
# :::::::::::::::::::::::::

while true; do
  
	echo -e "$f2 TIMES CHECKED AND RUNNING:$f5 $OK $rst"
	echo -e "$f2 TIMES FAILED AND RECOVERED:$f5 $BAD $rst"
	echo ""
	
	cat /proc/$CLIPID/task/$CLIPID/status > CHECK
	if [ $? != 0 ]; then
		I=$(( $I + 1 ))
		if [ $I -ge 3 ]; then
			kill $CLIPID
			tmux kill-session -t $BOT
			rm ../.telegram-cli/state 2>/dev/null
			NONVOLUNTARY=0
			NONVOLUNTARYCHECK=0
			VOLUNTARY=0
			VOLUNTARYCHECK=0
		fi
	else
		I=1
	fi
	VOLUNTARYCHECK=`grep voluntary CHECK | head -1 | cut -f 2 -d":" | sed 's/^[[:space:]]*//'`
	NONVOLUNTARYCHECK=`grep nonvoluntary CHECK | cut -f 2 -d":" | sed 's/^[[:space:]]*//'`
	
	if [ $NONVOLUNTARY != $NONVOLUNTARYCHECK ] || [ $VOLUNTARY != $VOLUNTARYCHECK ]; then
		echo -e "$f5 BOT RUNNING!$rst"
		OK=$(( $OK + 1 ))

	else
		echo -e "$f5 BOT NOT RUNING, TRYING TO RELOAD IT...$rst"
		BAD=$(( $BAD + 1 ))
		sleep 1
		
		rm ../.telegram-cli/state 2>/dev/null 

		kill $CLIPID
		tmux kill-session -t $BOT
	
		TMUX= tmux new-session -d -s $BOT "./launch.sh"
		sleep 1
		
		CLIPID=`ps -e | grep telegram-cli | head -1 | sed 's/^[[:space:]]*//' | cut -f 1 -d" "`
		
		if [ -z "${CLIPID}" ]; then
			echo -e "$f1 ERROR: TELEGRAM-CLI PROCESS NOT RUNNING$rst"
			echo -e "$f1 FAILED TO RECOVER BOT$rst"
			sleep 3
			exit 1
		fi

	fi
	
	# Clear cache after 10h
	if [ "$OK" == 2400 ]; then
		sync
		sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
	fi
	
	VOLUNTARY=`echo $VOLUNTARYCHECK`
	NONVOLUNTARY=`echo $NONVOLUNTARYCHECK`
	sleep $RELOADTIME
	rm CHECK
	
done

}


function screen_mode {

clear
sleep 0.5

# Space invaders thanks to github.com/windelicato
f=3 b=4
for j in f b; do
  for i in {0..7}; do
    printf -v $j$i %b "\e[${!j}${i}m"
  done
done
bld=$'\e[1m'
rst=$'\e[0m'

cat << EOF

 $f1  ▀▄   ▄▀     $f2 ▄▄▄████▄▄▄    $f3  ▄██▄     $f4  ▀▄   ▄▀     $f5 ▄▄▄████▄▄▄    $f6  ▄██▄  $rst
 $f1 ▄█▀███▀█▄    $f2███▀▀██▀▀███   $f3▄█▀██▀█▄   $f4 ▄█▀███▀█▄    $f5███▀▀██▀▀███   $f6▄█▀██▀█▄$rst
 $f1█▀███████▀█   $f2▀▀███▀▀███▀▀   $f3▀█▀██▀█▀   $f4█▀███████▀█   $f5▀▀███▀▀███▀▀   $f6▀█▀██▀█▀$rst
 $f1▀ ▀▄▄ ▄▄▀ ▀   $f2 ▀█▄ ▀▀ ▄█▀    $f3▀▄    ▄▀   $f4▀ ▀▄▄ ▄▄▀ ▀   $f5 ▀█▄ ▀▀ ▄█▀    $f6▀▄    ▄▀$rst
 
EOF
echo -e "                \e[100m                Steady script           \e[00;37;40m"
echo -e "               \e[01;34m                    by iicc                \e[00;37;40m"
echo ""
cat << EOF
 $bld$f1▄ ▀▄   ▄▀ ▄   $f2 ▄▄▄████▄▄▄    $f3  ▄██▄     $f4▄ ▀▄   ▄▀ ▄   $f5 ▄▄▄████▄▄▄    $f6  ▄██▄  $rst
 $bld$f1█▄█▀███▀█▄█   $f2███▀▀██▀▀███   $f3▄█▀██▀█▄   $f4█▄█▀███▀█▄█   $f5███▀▀██▀▀███   $f6▄█▀██▀█▄$rst
 $bld$f1▀█████████▀   $f2▀▀▀██▀▀██▀▀▀   $f3▀▀█▀▀█▀▀   $f4▀█████████▀   $f5▀▀▀██▀▀██▀▀▀   $f6▀▀█▀▀█▀▀$rst
 $bld$f1 ▄▀     ▀▄    $f2▄▄▀▀ ▀▀ ▀▀▄▄   $f3▄▀▄▀▀▄▀▄   $f4 ▄▀     ▀▄    $f5▄▄▀▀ ▀▀ ▀▀▄▄   $f6▄▀▄▀▀▄▀▄$rst

EOF

sleep 1.3

# Checking if the bot folder is in HOME
echo -e "$bld$f4 CHECKING INSTALLED BOT...$rst"
sleep 0.5
ls ../ | grep $BOT 2>/dev/null >/dev/null
if [ $? != 0 ]; then
  echo -e "$f1 ERROR: BOT: $BOT NOT FOUND IN YOUR HOME DIRECTORY$rst"
  sleep 4
  exit 1
fi
echo -e "$f2 $BOT FOUND IN YOUR HOME DIRECTORY$rst"
sleep 0.5


echo ""
echo -e "\033[38;5;208m      ____  ____ _____                        \033[0;00m"
echo -e "\033[38;5;208m     |    \|  _ )_   _|___ ____   __  __      \033[0;00m"
echo -e "\033[38;5;208m     | |_  )  _ \ | |/ .__|  _ \_|  \/  |     \033[0;00m"
echo -e "\033[38;5;208m     |____/|____/ |_|\____/\_____|_/\/\_|     \033[0;00m"
echo -e "\033[38;5;208m                                              \033[0;00m"

# Starting preliminar setup
sleep 1.5
echo -e "$bld$f4 CHECKING PROCESSES...$rst"
sleep 0.7

# Looks for the number of screen/telegram-cli processes
SCREENNUM=`ps -e | grep -c screen`
CLINUM=`ps -e | grep -c telegram-cli`

if [ $SCREENNUM -ge 3 ]; then
  echo -e "$f1 ERROR: MORE THAN 2 PROCESS OF SCREEN RUNNING.$rst"
  echo -e "$f1 THESE PROCESSES HAVE BE KILLED. THEN RESTART THE SCRIPT$rst"
  echo -e '$f1 RUN: "killall screen" $rst'
  if [ $CLINUM -ge 2 ]; then
    echo -e "$f1 ERROR: MORE THAN 1 PROCESS OF TELEGRAM-CLI RUNNING.$rst"
    echo -e "$f1 THESE PROCESSES WILL BE KILLED. THEN RESTART THE SCRIPT$rst"
	echo -e "$f1 RUN: killall telegram-cli $rst"
  fi
  sleep 4
  exit 1
fi
echo "$f2 SCREEN NUMBER AND CLI NUMBER UNDER THE SUPPORTED LIMIT"
sleep 0.7
echo "$f2 RUNNING $SCREENNUM SCREEN PROCESS$rst"
echo "$f2 RUNNING $CLINUM TELEGRAM-CLI PROCESS$rst"
sleep 0.9

# Getting screen pid's
ps -e | grep screen | sed 's/^[[:space:]]*//' | cut -f 1 -d" " | while read -r line ; do
  sleep 0.5
  echo -e "$f2 SCREEN NUMBER $I PID: $line$rst"
  if [ $I -eq 1 ]; then
    echo $line > SC1
  else
    echo $line > SC2
  fi
  I=$(( $I + 1 ))
done

# I had some weird errors, so I had to do this silly fix:
SCREENPID1=`cat SC1`
SCREENPID2=`cat SC2`
rm SC1 SC2 2>/dev/null

sleep 0.7
CLIPID=`ps -e | grep telegram-cli | sed 's/^[[:space:]]*//' | cut -f 1 -d" "`
if [ $CLINUM -eq 1 ]; then
  echo -e "$f2 RUNNING ONE PROCESS OF TELEGRAM-CLI: $CLIPID1$rst"
  echo -e "$bld$f4 KILLING TELEGRAM-CLI PROCESS. NOT NEEDED NOW$rst"
  kill $CLIPID1
else
  echo -e "$f2 RUNNING ZERO PROCESS OF TELEGRAM-CLI$rst"
fi
sleep 0.7


CLINUM=`ps -e | grep -c telegram-cli`
if [ $CLINUM -eq 1 ]; then
  echo -e "$f1 ERROR: TELEGRAM-CLI PID COULDN'T BE KILLED. IGNORE.$rst"
fi
sleep 1


# =====Setup ends===== #

# Opening new screen in a daemon
echo -e "$bld$f4 ATTACHING SCREEN AS DAEMON...$rst"
# Better to clear cli status before
rm ../.telegram-cli/state 2>/dev/null
screen -d -m bash launch.sh

sleep 1.3

SCREENNUM=`ps -e | grep -c screen`
if [ $SCREENNUM != 3 ]; then
  echo -e "$f1 ERROR: SCREEN RUNNING: $SCREENNUM \n SCREEN ESPECTED: 3$rst"
  exit 1
fi

# Getting screen info
sleep 0.7
echo -e "$bld$f4 RELOADING SCREEN INFO...$rst"
sleep 1
echo -e "$f2 NUMBER OF SCREEN ATTACHED: $SCREENNUM$rst"
echo -e "$f2 SECONDARY SCREEN: $SCREENPID1 AND $SCREENPID2$rst"
SCREEN=`ps -e | grep -v $SCREENPID1 | grep -v $SCREENPID2 | grep screen | sed 's/^[[:space:]]*//' | cut -f 1 -d" "`

sleep 0.5
echo -e "$f2 PRIMARY SCREEN: $SCREEN$rst"

sleep 0.7
echo -e "$bld$f4 RELOADING TELEGRAM-CLI INFO...$rst"
sleep 0.7

# Getting new telegram-cli PID
CLIPID=`ps -e | grep telegram-cli | sed 's/^[[:space:]]*//' |cut -f 1 -d" "`
echo -e "$f2 NEW TELEGRAM-CLI PID: $CLIPID$rst"
if [ -z "${CLIPID}" ]; then
  echo -e "$f1 ERROR: TELEGRAM-CLI PROCESS NOT RUNNING$rst"
  sleep 3
  exit 1
fi


# Locating telegram-cli status
cat /proc/$CLIPID/task/$CLIPID/status > STATUS
NONVOLUNTARY=`grep nonvoluntary STATUS | cut -f 2 -d":" | sed 's/^[[:space:]]*//'`


sleep 5

# :::::::::::::::::::::::::
# ::::::: MAIN LOOP :::::::
# :::::::::::::::::::::::::

  while true; do
  
	echo -e "$f2 TIMES CHECKED AND RUNNING:$f5 $OK $rst"
	echo -e "$f2 TIMES FAILED AND RECOVERED:$f5 $BAD $rst"
	echo ""
	
	cat /proc/$CLIPID/task/$CLIPID/status > CHECK
	if [ $? != 0 ]; then
		I=$(( $I + 1 ))
		if [ $I -ge 3 ]; then
			rm ../.telegram-cli/state 2>/dev/null
			NONVOLUNTARY=0
			NONVOLUNTARYCHECK=0
			VOLUNTARY=0
			VOLUNTARYCHECK=0
		fi
	else
		I=1
	fi
	VOLUNTARYCHECK=`grep voluntary CHECK | head -1 | cut -f 2 -d":" | sed 's/^[[:space:]]*//'`
	NONVOLUNTARYCHECK=`grep nonvoluntary CHECK | cut -f 2 -d":" | sed 's/^[[:space:]]*//'`

	if [ $NONVOLUNTARY != $NONVOLUNTARYCHECK ] || [ $VOLUNTARY != $VOLUNTARYCHECK ]; then
		echo -e "$f5 BOT RUNNING!$rst"
		OK=$(( $OK + 1 ))

	else
		echo -e "$f5 BOT NOT RUNING, TRYING TO RELOAD IT...$rst"
		BAD=$(( $BAD + 1 ))
		sleep 1
		
		rm ../.telegram-cli/state 2>/dev/null

		kill $CLIPID
		kill $SCREEN
		
		screen -d -m bash launch.sh
		sleep 1
		
		CLIPID=`ps -e | grep telegram-cli | sed 's/^[[:space:]]*//' | cut -f 1 -d" "`
		
		if [ -z "${CLIPID}" ]; then
			echo -e "$f1 ERROR: TELEGRAM-CLI PROCESS NOT RUNNING$rst"
			echo -e "$f1 FAILED TO RECOVER BOT$rst"
			sleep 1
		fi
		
		SCREENNUM=`ps -e | grep -c screen`
		if [ $SCREENNUM != 3 ]; then
			echo -e "$f1 ERROR: SCREEN RUNNING: $SCREENNUM \n SCREEN ESPECTED: 3$rst"
			echo -e "$f1 FAILED TO RECOVER BOT$rst"
			exit 1
		fi

		SCREEN=`ps -e | grep -v $SCREENPID1 | grep -v $SCREENPID2 | grep screen | sed 's/^[[:space:]]*//' | cut -f 1 -d" "`
		echo -e "$f5 BOT HAS BEEN SUCCESFULLY RELOADED!$rst"
		echo -e "$f2 TELEGRAM-CLI NEW PID: $CLIPID$rst"
		echo -e "$f2 SCREEN NEW PID: $SCREEN$rst"
		sleep 3
		
	fi
	
	# Clear cache after 10h
	if [ "$OK" == 2400 ]; then
		sync
		sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
	fi
	
	VOLUNTARY=`echo $VOLUNTARYCHECK`
	NONVOLUNTARY=`echo $NONVOLUNTARYCHECK`
	sleep $RELOADTIME
	rm CHECK
	
  done

}

function tmux_detached {
clear
TMUX= tmux new-session -d -s script_detach "bash steady.sh -t"
echo -e "\e[1m"
echo -e ""
echo "Bot running in the backgroud with TMUX"
echo ""
echo -e "\e[0m"
sleep 3
tmux kill-session script 2>/dev/null
exit 1
}

function screen_detached {
clear
screen -d -m bash launch.sh
echo -e "\e[1m"
echo -e ""
echo "Bot running in the backgroud with SCREEN"
echo ""
echo -e "\e[0m"
sleep 3
quit
exit 1
}



if [ $# -eq 0 ]
then
	echo -e "\e[1m"
	echo -e ""
	echo "Missing options!"
	echo "Run: bash steady.sh -h  for help!"
	echo ""
	echo -e "\e[0m"
    sleep 1
	exit 1
fi

while getopts ":tsTSih" opt; do
  case $opt in
    t)
	echo -e "\e[1m"
	echo -e ""
	echo "TMUX multiplexer option has been triggered." >&2
	echo "Starting script..."
	sleep 1.5
	echo -e "\e[0m"
	tmux_mode
	exit 1
      ;;
	s)
	echo -e "\e[1m"
	echo -e ""
	echo "SCREEN multiplexer option has been triggered." >&2
	echo "Starting script..."
	sleep 1.5
	echo -e "\e[0m"
	screen_mode
	exit 1
      ;;
    T)
	echo -e "\e[1m"
	echo -e ""
	echo "TMUX multiplexer option has been triggered." >&2
	echo "Starting script..."
	sleep 1.5
	echo -e "\e[0m"
	tmux_detached
	exit 1
      ;;
	S)
	echo -e "\e[1m"
	echo -e ""
	echo "SCREEN multiplexer option has been triggered." >&2
	echo "Starting script..."
	sleep 1.5
	echo -e "\e[0m"
	screen_detached
	exit 1
      ;;
	i)
	echo -e "\e[1m"
	echo -e ""
	echo "steady.sh bash script v1.2 iicc 2016 DBTeam" >&2
	echo ""
	echo -e "\e[0m"
echo -e "\033[38;5;208m      ____  ____ _____                        \033[0;00m"
echo -e "\033[38;5;208m     |    \|  _ )_   _|___ ____   __  __      \033[0;00m"
echo -e "\033[38;5;208m     | |_  )  _ \ | |/ .__|  _ \_|  \/  |     \033[0;00m"
echo -e "\033[38;5;208m     |____/|____/ |_|\____/\_____|_/\/\_|     \033[0;00m"
echo -e "\033[38;5;208m                                              \033[0;00m"	
echo ""
	exit 1
      ;;
	h)
	echo -e "\e[1m"
	echo -e ""
	echo "Usage:"
	echo -e ""
	echo "steady.sh -t"
	echo "steady.sh -s"
	echo "steady.sh -T"
	echo "steady.sh -S"
	echo "steady.sh -h"
	echo "steady.sh -i"
    echo ""
	echo "Options:"
	echo ""
    echo "   -t     select TMUX terminal multiplexer"
	echo "   -s     select SCREEN terminal multiplexer"
	echo "   -T     select TMUX and detach session after start"
	echo "   -S     select SCREEN and detach session after start"
	echo "   -h     script options help page"
	echo "   -i     information about the script"
	echo -e "\e[0m"
	exit 1
	;;
	  
    \?)
	echo -e "\e[1m"
	echo -e ""
    echo "Invalid option: -$OPTARG" >&2
	echo "Run bash $0 -h for help"
	echo -e "\e[0m"
	exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

      </tr>
      <tr>
        <td id="L88" class="blob-num js-line-number" data-line-number="88"></td>
        <td id="LC88" class="blob-code blob-code-inner js-file-line"><span class="pl-k">if</span> [ <span class="pl-smi">$?</span> <span class="pl-k">!=</span> 0 ]<span class="pl-k">;</span> <span class="pl-k">then</span></td>
      </tr>
      <tr>
        <td id="L89" class="blob-num js-line-number" data-line-number="89"></td>
        <td id="LC89" class="blob-code blob-code-inner js-file-line">  <span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f1</span> ERROR: BOT: <span class="pl-smi">$BOT</span> NOT FOUND IN YOUR HOME DIRECTORY<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L90" class="blob-num js-line-number" data-line-number="90"></td>
        <td id="LC90" class="blob-code blob-code-inner js-file-line">  sleep 4</td>
      </tr>
      <tr>
        <td id="L91" class="blob-num js-line-number" data-line-number="91"></td>
        <td id="LC91" class="blob-code blob-code-inner js-file-line">  <span class="pl-c1">exit</span> 1</td>
      </tr>
      <tr>
        <td id="L92" class="blob-num js-line-number" data-line-number="92"></td>
        <td id="LC92" class="blob-code blob-code-inner js-file-line"><span class="pl-k">fi</span></td>
      </tr>
      <tr>
        <td id="L93" class="blob-num js-line-number" data-line-number="93"></td>
        <td id="LC93" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f2</span> <span class="pl-smi">$BOT</span> FOUND IN YOUR HOME DIRECTORY<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L94" class="blob-num js-line-number" data-line-number="94"></td>
        <td id="LC94" class="blob-code blob-code-inner js-file-line">sleep 0.5</td>
      </tr>
      <tr>
        <td id="L95" class="blob-num js-line-number" data-line-number="95"></td>
        <td id="LC95" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L96" class="blob-num js-line-number" data-line-number="96"></td>
        <td id="LC96" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L97" class="blob-num js-line-number" data-line-number="97"></td>
        <td id="LC97" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L98" class="blob-num js-line-number" data-line-number="98"></td>
        <td id="LC98" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\033[38;5;208m      ____  ____ _____                        \033[0;00m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L99" class="blob-num js-line-number" data-line-number="99"></td>
        <td id="LC99" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\033[38;5;208m     |    \|  _ )_   _|___ ____   __  __      \033[0;00m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L100" class="blob-num js-line-number" data-line-number="100"></td>
        <td id="LC100" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\033[38;5;208m     | |_  )  _ \ | |/ .__|  _ \_|  \/  |     \033[0;00m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L101" class="blob-num js-line-number" data-line-number="101"></td>
        <td id="LC101" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\033[38;5;208m     |____/|____/ |_|\____/\_____|_/\/\_|     \033[0;00m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L102" class="blob-num js-line-number" data-line-number="102"></td>
        <td id="LC102" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\033[38;5;208m                                              \033[0;00m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L103" class="blob-num js-line-number" data-line-number="103"></td>
        <td id="LC103" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L104" class="blob-num js-line-number" data-line-number="104"></td>
        <td id="LC104" class="blob-code blob-code-inner js-file-line">sleep 1.5</td>
      </tr>
      <tr>
        <td id="L105" class="blob-num js-line-number" data-line-number="105"></td>
        <td id="LC105" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$bld$f4</span> CHECKING PROCESSES...<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L106" class="blob-num js-line-number" data-line-number="106"></td>
        <td id="LC106" class="blob-code blob-code-inner js-file-line">sleep 0.7</td>
      </tr>
      <tr>
        <td id="L107" class="blob-num js-line-number" data-line-number="107"></td>
        <td id="LC107" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L108" class="blob-num js-line-number" data-line-number="108"></td>
        <td id="LC108" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># Looks for the number of screen/telegram-cli processes</span></td>
      </tr>
      <tr>
        <td id="L109" class="blob-num js-line-number" data-line-number="109"></td>
        <td id="LC109" class="blob-code blob-code-inner js-file-line">CLINUM=<span class="pl-s"><span class="pl-pds">`</span>ps -e <span class="pl-k">|</span> grep -c telegram-cli<span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L110" class="blob-num js-line-number" data-line-number="110"></td>
        <td id="LC110" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f2</span> RUNNING <span class="pl-smi">$CLINUM</span> TELEGRAM-CLI PROCESS<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L111" class="blob-num js-line-number" data-line-number="111"></td>
        <td id="LC111" class="blob-code blob-code-inner js-file-line">sleep 0.9</td>
      </tr>
      <tr>
        <td id="L112" class="blob-num js-line-number" data-line-number="112"></td>
        <td id="LC112" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L113" class="blob-num js-line-number" data-line-number="113"></td>
        <td id="LC113" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># =====Setup ends===== #</span></td>
      </tr>
      <tr>
        <td id="L114" class="blob-num js-line-number" data-line-number="114"></td>
        <td id="LC114" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L115" class="blob-num js-line-number" data-line-number="115"></td>
        <td id="LC115" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># Opening new tmux in a daemon</span></td>
      </tr>
      <tr>
        <td id="L116" class="blob-num js-line-number" data-line-number="116"></td>
        <td id="LC116" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$bld$f4</span> ATTACHING TMUX AS DAEMON...<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L117" class="blob-num js-line-number" data-line-number="117"></td>
        <td id="LC117" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># It is recommended to clear cli status always before starting the bot</span></td>
      </tr>
      <tr>
        <td id="L118" class="blob-num js-line-number" data-line-number="118"></td>
        <td id="LC118" class="blob-code blob-code-inner js-file-line">rm ../.telegram-cli/state <span class="pl-k">2&gt;</span>/dev/null</td>
      </tr>
      <tr>
        <td id="L119" class="blob-num js-line-number" data-line-number="119"></td>
        <td id="LC119" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># Nested TMUX sessions trick </span></td>
      </tr>
      <tr>
        <td id="L120" class="blob-num js-line-number" data-line-number="120"></td>
        <td id="LC120" class="blob-code blob-code-inner js-file-line">TMUX= tmux new-session -d -s <span class="pl-smi">$BOT</span> <span class="pl-s"><span class="pl-pds">&quot;</span>./launch.sh<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L121" class="blob-num js-line-number" data-line-number="121"></td>
        <td id="LC121" class="blob-code blob-code-inner js-file-line">sleep 1.3</td>
      </tr>
      <tr>
        <td id="L122" class="blob-num js-line-number" data-line-number="122"></td>
        <td id="LC122" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L123" class="blob-num js-line-number" data-line-number="123"></td>
        <td id="LC123" class="blob-code blob-code-inner js-file-line">CLIPID=<span class="pl-s"><span class="pl-pds">`</span>ps -e <span class="pl-k">|</span> grep telegram-cli <span class="pl-k">|</span> head -1 <span class="pl-k">|</span> sed <span class="pl-s"><span class="pl-pds">&#39;</span>s/^[[:space:]]*//<span class="pl-pds">&#39;</span></span> <span class="pl-k">|</span> cut -f 1 -d<span class="pl-s"><span class="pl-pds">&quot;</span> <span class="pl-pds">&quot;</span></span><span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L124" class="blob-num js-line-number" data-line-number="124"></td>
        <td id="LC124" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f2</span> NEW TELEGRAM-CLI PROCESS: <span class="pl-smi">$CLIPID$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L125" class="blob-num js-line-number" data-line-number="125"></td>
        <td id="LC125" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L126" class="blob-num js-line-number" data-line-number="126"></td>
        <td id="LC126" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L127" class="blob-num js-line-number" data-line-number="127"></td>
        <td id="LC127" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L128" class="blob-num js-line-number" data-line-number="128"></td>
        <td id="LC128" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># Locating telegram-cli status</span></td>
      </tr>
      <tr>
        <td id="L129" class="blob-num js-line-number" data-line-number="129"></td>
        <td id="LC129" class="blob-code blob-code-inner js-file-line">cat /proc/<span class="pl-smi">$CLIPID</span>/task/<span class="pl-smi">$CLIPID</span>/status <span class="pl-k">&gt;</span> STATUS</td>
      </tr>
      <tr>
        <td id="L130" class="blob-num js-line-number" data-line-number="130"></td>
        <td id="LC130" class="blob-code blob-code-inner js-file-line">NONVOLUNTARY=<span class="pl-s"><span class="pl-pds">`</span>grep nonvoluntary STATUS <span class="pl-k">|</span> cut -f 2 -d<span class="pl-s"><span class="pl-pds">&quot;</span>:<span class="pl-pds">&quot;</span></span> <span class="pl-k">|</span> sed <span class="pl-s"><span class="pl-pds">&#39;</span>s/^[[:space:]]*//<span class="pl-pds">&#39;</span></span><span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L131" class="blob-num js-line-number" data-line-number="131"></td>
        <td id="LC131" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L132" class="blob-num js-line-number" data-line-number="132"></td>
        <td id="LC132" class="blob-code blob-code-inner js-file-line">sleep 3</td>
      </tr>
      <tr>
        <td id="L133" class="blob-num js-line-number" data-line-number="133"></td>
        <td id="LC133" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L134" class="blob-num js-line-number" data-line-number="134"></td>
        <td id="LC134" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># :::::::::::::::::::::::::</span></td>
      </tr>
      <tr>
        <td id="L135" class="blob-num js-line-number" data-line-number="135"></td>
        <td id="LC135" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># ::::::: MAIN LOOP :::::::</span></td>
      </tr>
      <tr>
        <td id="L136" class="blob-num js-line-number" data-line-number="136"></td>
        <td id="LC136" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># :::::::::::::::::::::::::</span></td>
      </tr>
      <tr>
        <td id="L137" class="blob-num js-line-number" data-line-number="137"></td>
        <td id="LC137" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L138" class="blob-num js-line-number" data-line-number="138"></td>
        <td id="LC138" class="blob-code blob-code-inner js-file-line"><span class="pl-k">while</span> <span class="pl-c1">true</span><span class="pl-k">;</span> <span class="pl-k">do</span></td>
      </tr>
      <tr>
        <td id="L139" class="blob-num js-line-number" data-line-number="139"></td>
        <td id="LC139" class="blob-code blob-code-inner js-file-line">  </td>
      </tr>
      <tr>
        <td id="L140" class="blob-num js-line-number" data-line-number="140"></td>
        <td id="LC140" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f2</span> TIMES CHECKED AND RUNNING:<span class="pl-smi">$f5</span> <span class="pl-smi">$OK</span> <span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L141" class="blob-num js-line-number" data-line-number="141"></td>
        <td id="LC141" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f2</span> TIMES FAILED AND RECOVERED:<span class="pl-smi">$f5</span> <span class="pl-smi">$BAD</span> <span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L142" class="blob-num js-line-number" data-line-number="142"></td>
        <td id="LC142" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L143" class="blob-num js-line-number" data-line-number="143"></td>
        <td id="LC143" class="blob-code blob-code-inner js-file-line">	</td>
      </tr>
      <tr>
        <td id="L144" class="blob-num js-line-number" data-line-number="144"></td>
        <td id="LC144" class="blob-code blob-code-inner js-file-line">	cat /proc/<span class="pl-smi">$CLIPID</span>/task/<span class="pl-smi">$CLIPID</span>/status <span class="pl-k">&gt;</span> CHECK</td>
      </tr>
      <tr>
        <td id="L145" class="blob-num js-line-number" data-line-number="145"></td>
        <td id="LC145" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">if</span> [ <span class="pl-smi">$?</span> <span class="pl-k">!=</span> 0 ]<span class="pl-k">;</span> <span class="pl-k">then</span></td>
      </tr>
      <tr>
        <td id="L146" class="blob-num js-line-number" data-line-number="146"></td>
        <td id="LC146" class="blob-code blob-code-inner js-file-line">		I=<span class="pl-s"><span class="pl-pds">$((</span> <span class="pl-smi">$I</span> <span class="pl-k">+</span> <span class="pl-c1">1</span> <span class="pl-pds">))</span></span></td>
      </tr>
      <tr>
        <td id="L147" class="blob-num js-line-number" data-line-number="147"></td>
        <td id="LC147" class="blob-code blob-code-inner js-file-line">		<span class="pl-k">if</span> [ <span class="pl-smi">$I</span> <span class="pl-k">-ge</span> 3 ]<span class="pl-k">;</span> <span class="pl-k">then</span></td>
      </tr>
      <tr>
        <td id="L148" class="blob-num js-line-number" data-line-number="148"></td>
        <td id="LC148" class="blob-code blob-code-inner js-file-line">			<span class="pl-c1">kill</span> <span class="pl-smi">$CLIPID</span></td>
      </tr>
      <tr>
        <td id="L149" class="blob-num js-line-number" data-line-number="149"></td>
        <td id="LC149" class="blob-code blob-code-inner js-file-line">			tmux kill-session -t <span class="pl-smi">$BOT</span></td>
      </tr>
      <tr>
        <td id="L150" class="blob-num js-line-number" data-line-number="150"></td>
        <td id="LC150" class="blob-code blob-code-inner js-file-line">			rm ../.telegram-cli/state <span class="pl-k">2&gt;</span>/dev/null</td>
      </tr>
      <tr>
        <td id="L151" class="blob-num js-line-number" data-line-number="151"></td>
        <td id="LC151" class="blob-code blob-code-inner js-file-line">			NONVOLUNTARY=0</td>
      </tr>
      <tr>
        <td id="L152" class="blob-num js-line-number" data-line-number="152"></td>
        <td id="LC152" class="blob-code blob-code-inner js-file-line">			NONVOLUNTARYCHECK=0</td>
      </tr>
      <tr>
        <td id="L153" class="blob-num js-line-number" data-line-number="153"></td>
        <td id="LC153" class="blob-code blob-code-inner js-file-line">			VOLUNTARY=0</td>
      </tr>
      <tr>
        <td id="L154" class="blob-num js-line-number" data-line-number="154"></td>
        <td id="LC154" class="blob-code blob-code-inner js-file-line">			VOLUNTARYCHECK=0</td>
      </tr>
      <tr>
        <td id="L155" class="blob-num js-line-number" data-line-number="155"></td>
        <td id="LC155" class="blob-code blob-code-inner js-file-line">		<span class="pl-k">fi</span></td>
      </tr>
      <tr>
        <td id="L156" class="blob-num js-line-number" data-line-number="156"></td>
        <td id="LC156" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">else</span></td>
      </tr>
      <tr>
        <td id="L157" class="blob-num js-line-number" data-line-number="157"></td>
        <td id="LC157" class="blob-code blob-code-inner js-file-line">		I=1</td>
      </tr>
      <tr>
        <td id="L158" class="blob-num js-line-number" data-line-number="158"></td>
        <td id="LC158" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">fi</span></td>
      </tr>
      <tr>
        <td id="L159" class="blob-num js-line-number" data-line-number="159"></td>
        <td id="LC159" class="blob-code blob-code-inner js-file-line">	VOLUNTARYCHECK=<span class="pl-s"><span class="pl-pds">`</span>grep voluntary CHECK <span class="pl-k">|</span> head -1 <span class="pl-k">|</span> cut -f 2 -d<span class="pl-s"><span class="pl-pds">&quot;</span>:<span class="pl-pds">&quot;</span></span> <span class="pl-k">|</span> sed <span class="pl-s"><span class="pl-pds">&#39;</span>s/^[[:space:]]*//<span class="pl-pds">&#39;</span></span><span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L160" class="blob-num js-line-number" data-line-number="160"></td>
        <td id="LC160" class="blob-code blob-code-inner js-file-line">	NONVOLUNTARYCHECK=<span class="pl-s"><span class="pl-pds">`</span>grep nonvoluntary CHECK <span class="pl-k">|</span> cut -f 2 -d<span class="pl-s"><span class="pl-pds">&quot;</span>:<span class="pl-pds">&quot;</span></span> <span class="pl-k">|</span> sed <span class="pl-s"><span class="pl-pds">&#39;</span>s/^[[:space:]]*//<span class="pl-pds">&#39;</span></span><span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L161" class="blob-num js-line-number" data-line-number="161"></td>
        <td id="LC161" class="blob-code blob-code-inner js-file-line">	</td>
      </tr>
      <tr>
        <td id="L162" class="blob-num js-line-number" data-line-number="162"></td>
        <td id="LC162" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">if</span> [ <span class="pl-smi">$NONVOLUNTARY</span> <span class="pl-k">!=</span> <span class="pl-smi">$NONVOLUNTARYCHECK</span> ] <span class="pl-k">||</span> [ <span class="pl-smi">$VOLUNTARY</span> <span class="pl-k">!=</span> <span class="pl-smi">$VOLUNTARYCHECK</span> ]<span class="pl-k">;</span> <span class="pl-k">then</span></td>
      </tr>
      <tr>
        <td id="L163" class="blob-num js-line-number" data-line-number="163"></td>
        <td id="LC163" class="blob-code blob-code-inner js-file-line">		<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f5</span> BOT RUNNING!<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L164" class="blob-num js-line-number" data-line-number="164"></td>
        <td id="LC164" class="blob-code blob-code-inner js-file-line">		OK=<span class="pl-s"><span class="pl-pds">$((</span> <span class="pl-smi">$OK</span> <span class="pl-k">+</span> <span class="pl-c1">1</span> <span class="pl-pds">))</span></span></td>
      </tr>
      <tr>
        <td id="L165" class="blob-num js-line-number" data-line-number="165"></td>
        <td id="LC165" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L166" class="blob-num js-line-number" data-line-number="166"></td>
        <td id="LC166" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">else</span></td>
      </tr>
      <tr>
        <td id="L167" class="blob-num js-line-number" data-line-number="167"></td>
        <td id="LC167" class="blob-code blob-code-inner js-file-line">		<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f5</span> BOT NOT RUNING, TRYING TO RELOAD IT...<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L168" class="blob-num js-line-number" data-line-number="168"></td>
        <td id="LC168" class="blob-code blob-code-inner js-file-line">		BAD=<span class="pl-s"><span class="pl-pds">$((</span> <span class="pl-smi">$BAD</span> <span class="pl-k">+</span> <span class="pl-c1">1</span> <span class="pl-pds">))</span></span></td>
      </tr>
      <tr>
        <td id="L169" class="blob-num js-line-number" data-line-number="169"></td>
        <td id="LC169" class="blob-code blob-code-inner js-file-line">		sleep 1</td>
      </tr>
      <tr>
        <td id="L170" class="blob-num js-line-number" data-line-number="170"></td>
        <td id="LC170" class="blob-code blob-code-inner js-file-line">		</td>
      </tr>
      <tr>
        <td id="L171" class="blob-num js-line-number" data-line-number="171"></td>
        <td id="LC171" class="blob-code blob-code-inner js-file-line">		rm ../.telegram-cli/state <span class="pl-k">2&gt;</span>/dev/null </td>
      </tr>
      <tr>
        <td id="L172" class="blob-num js-line-number" data-line-number="172"></td>
        <td id="LC172" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L173" class="blob-num js-line-number" data-line-number="173"></td>
        <td id="LC173" class="blob-code blob-code-inner js-file-line">		<span class="pl-c1">kill</span> <span class="pl-smi">$CLIPID</span></td>
      </tr>
      <tr>
        <td id="L174" class="blob-num js-line-number" data-line-number="174"></td>
        <td id="LC174" class="blob-code blob-code-inner js-file-line">		tmux kill-session -t <span class="pl-smi">$BOT</span></td>
      </tr>
      <tr>
        <td id="L175" class="blob-num js-line-number" data-line-number="175"></td>
        <td id="LC175" class="blob-code blob-code-inner js-file-line">	</td>
      </tr>
      <tr>
        <td id="L176" class="blob-num js-line-number" data-line-number="176"></td>
        <td id="LC176" class="blob-code blob-code-inner js-file-line">		TMUX= tmux new-session -d -s <span class="pl-smi">$BOT</span> <span class="pl-s"><span class="pl-pds">&quot;</span>./launch.sh<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L177" class="blob-num js-line-number" data-line-number="177"></td>
        <td id="LC177" class="blob-code blob-code-inner js-file-line">		sleep 1</td>
      </tr>
      <tr>
        <td id="L178" class="blob-num js-line-number" data-line-number="178"></td>
        <td id="LC178" class="blob-code blob-code-inner js-file-line">		</td>
      </tr>
      <tr>
        <td id="L179" class="blob-num js-line-number" data-line-number="179"></td>
        <td id="LC179" class="blob-code blob-code-inner js-file-line">		CLIPID=<span class="pl-s"><span class="pl-pds">`</span>ps -e <span class="pl-k">|</span> grep telegram-cli <span class="pl-k">|</span> head -1 <span class="pl-k">|</span> sed <span class="pl-s"><span class="pl-pds">&#39;</span>s/^[[:space:]]*//<span class="pl-pds">&#39;</span></span> <span class="pl-k">|</span> cut -f 1 -d<span class="pl-s"><span class="pl-pds">&quot;</span> <span class="pl-pds">&quot;</span></span><span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L180" class="blob-num js-line-number" data-line-number="180"></td>
        <td id="LC180" class="blob-code blob-code-inner js-file-line">		</td>
      </tr>
      <tr>
        <td id="L181" class="blob-num js-line-number" data-line-number="181"></td>
        <td id="LC181" class="blob-code blob-code-inner js-file-line">		<span class="pl-k">if</span> [ <span class="pl-k">-z</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">${CLIPID}</span><span class="pl-pds">&quot;</span></span> ]<span class="pl-k">;</span> <span class="pl-k">then</span></td>
      </tr>
      <tr>
        <td id="L182" class="blob-num js-line-number" data-line-number="182"></td>
        <td id="LC182" class="blob-code blob-code-inner js-file-line">			<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f1</span> ERROR: TELEGRAM-CLI PROCESS NOT RUNNING<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L183" class="blob-num js-line-number" data-line-number="183"></td>
        <td id="LC183" class="blob-code blob-code-inner js-file-line">			<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f1</span> FAILED TO RECOVER BOT<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L184" class="blob-num js-line-number" data-line-number="184"></td>
        <td id="LC184" class="blob-code blob-code-inner js-file-line">			sleep 3</td>
      </tr>
      <tr>
        <td id="L185" class="blob-num js-line-number" data-line-number="185"></td>
        <td id="LC185" class="blob-code blob-code-inner js-file-line">			<span class="pl-c1">exit</span> 1</td>
      </tr>
      <tr>
        <td id="L186" class="blob-num js-line-number" data-line-number="186"></td>
        <td id="LC186" class="blob-code blob-code-inner js-file-line">		<span class="pl-k">fi</span></td>
      </tr>
      <tr>
        <td id="L187" class="blob-num js-line-number" data-line-number="187"></td>
        <td id="LC187" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L188" class="blob-num js-line-number" data-line-number="188"></td>
        <td id="LC188" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">fi</span></td>
      </tr>
      <tr>
        <td id="L189" class="blob-num js-line-number" data-line-number="189"></td>
        <td id="LC189" class="blob-code blob-code-inner js-file-line">	</td>
      </tr>
      <tr>
        <td id="L190" class="blob-num js-line-number" data-line-number="190"></td>
        <td id="LC190" class="blob-code blob-code-inner js-file-line">	<span class="pl-c"># Clear cache after 10h</span></td>
      </tr>
      <tr>
        <td id="L191" class="blob-num js-line-number" data-line-number="191"></td>
        <td id="LC191" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">if</span> [ <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$OK</span><span class="pl-pds">&quot;</span></span> <span class="pl-k">==</span> 2400 ]<span class="pl-k">;</span> <span class="pl-k">then</span></td>
      </tr>
      <tr>
        <td id="L192" class="blob-num js-line-number" data-line-number="192"></td>
        <td id="LC192" class="blob-code blob-code-inner js-file-line">		sync</td>
      </tr>
      <tr>
        <td id="L193" class="blob-num js-line-number" data-line-number="193"></td>
        <td id="LC193" class="blob-code blob-code-inner js-file-line">		sudo sh -c <span class="pl-s"><span class="pl-pds">&#39;</span>echo 3 &gt; /proc/sys/vm/drop_caches<span class="pl-pds">&#39;</span></span></td>
      </tr>
      <tr>
        <td id="L194" class="blob-num js-line-number" data-line-number="194"></td>
        <td id="LC194" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">fi</span></td>
      </tr>
      <tr>
        <td id="L195" class="blob-num js-line-number" data-line-number="195"></td>
        <td id="LC195" class="blob-code blob-code-inner js-file-line">	</td>
      </tr>
      <tr>
        <td id="L196" class="blob-num js-line-number" data-line-number="196"></td>
        <td id="LC196" class="blob-code blob-code-inner js-file-line">	VOLUNTARY=<span class="pl-s"><span class="pl-pds">`</span><span class="pl-c1">echo</span> <span class="pl-smi">$VOLUNTARYCHECK</span><span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L197" class="blob-num js-line-number" data-line-number="197"></td>
        <td id="LC197" class="blob-code blob-code-inner js-file-line">	NONVOLUNTARY=<span class="pl-s"><span class="pl-pds">`</span><span class="pl-c1">echo</span> <span class="pl-smi">$NONVOLUNTARYCHECK</span><span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L198" class="blob-num js-line-number" data-line-number="198"></td>
        <td id="LC198" class="blob-code blob-code-inner js-file-line">	sleep <span class="pl-smi">$RELOADTIME</span></td>
      </tr>
      <tr>
        <td id="L199" class="blob-num js-line-number" data-line-number="199"></td>
        <td id="LC199" class="blob-code blob-code-inner js-file-line">	rm CHECK</td>
      </tr>
      <tr>
        <td id="L200" class="blob-num js-line-number" data-line-number="200"></td>
        <td id="LC200" class="blob-code blob-code-inner js-file-line">	</td>
      </tr>
      <tr>
        <td id="L201" class="blob-num js-line-number" data-line-number="201"></td>
        <td id="LC201" class="blob-code blob-code-inner js-file-line"><span class="pl-k">done</span></td>
      </tr>
      <tr>
        <td id="L202" class="blob-num js-line-number" data-line-number="202"></td>
        <td id="LC202" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L203" class="blob-num js-line-number" data-line-number="203"></td>
        <td id="LC203" class="blob-code blob-code-inner js-file-line">}</td>
      </tr>
      <tr>
        <td id="L204" class="blob-num js-line-number" data-line-number="204"></td>
        <td id="LC204" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L205" class="blob-num js-line-number" data-line-number="205"></td>
        <td id="LC205" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L206" class="blob-num js-line-number" data-line-number="206"></td>
        <td id="LC206" class="blob-code blob-code-inner js-file-line"><span class="pl-k">function</span> <span class="pl-en">screen_mode</span> {</td>
      </tr>
      <tr>
        <td id="L207" class="blob-num js-line-number" data-line-number="207"></td>
        <td id="LC207" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L208" class="blob-num js-line-number" data-line-number="208"></td>
        <td id="LC208" class="blob-code blob-code-inner js-file-line">clear</td>
      </tr>
      <tr>
        <td id="L209" class="blob-num js-line-number" data-line-number="209"></td>
        <td id="LC209" class="blob-code blob-code-inner js-file-line">sleep 0.5</td>
      </tr>
      <tr>
        <td id="L210" class="blob-num js-line-number" data-line-number="210"></td>
        <td id="LC210" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L211" class="blob-num js-line-number" data-line-number="211"></td>
        <td id="LC211" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># Space invaders thanks to github.com/windelicato</span></td>
      </tr>
      <tr>
        <td id="L212" class="blob-num js-line-number" data-line-number="212"></td>
        <td id="LC212" class="blob-code blob-code-inner js-file-line">f=3 b=4</td>
      </tr>
      <tr>
        <td id="L213" class="blob-num js-line-number" data-line-number="213"></td>
        <td id="LC213" class="blob-code blob-code-inner js-file-line"><span class="pl-k">for</span> <span class="pl-smi">j</span> <span class="pl-k">in</span> f b<span class="pl-k">;</span> <span class="pl-k">do</span></td>
      </tr>
      <tr>
        <td id="L214" class="blob-num js-line-number" data-line-number="214"></td>
        <td id="LC214" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">for</span> <span class="pl-smi">i</span> <span class="pl-k">in</span> {0..7}<span class="pl-k">;</span> <span class="pl-k">do</span></td>
      </tr>
      <tr>
        <td id="L215" class="blob-num js-line-number" data-line-number="215"></td>
        <td id="LC215" class="blob-code blob-code-inner js-file-line">    <span class="pl-c1">printf</span> -v <span class="pl-smi">$j$i</span> %b <span class="pl-s"><span class="pl-pds">&quot;</span>\e[<span class="pl-smi">${<span class="pl-k">!</span>j}${i}</span>m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L216" class="blob-num js-line-number" data-line-number="216"></td>
        <td id="LC216" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">done</span></td>
      </tr>
      <tr>
        <td id="L217" class="blob-num js-line-number" data-line-number="217"></td>
        <td id="LC217" class="blob-code blob-code-inner js-file-line"><span class="pl-k">done</span></td>
      </tr>
      <tr>
        <td id="L218" class="blob-num js-line-number" data-line-number="218"></td>
        <td id="LC218" class="blob-code blob-code-inner js-file-line">bld=<span class="pl-s"><span class="pl-pds">$&#39;</span><span class="pl-cce">\e</span>[1m<span class="pl-pds">&#39;</span></span></td>
      </tr>
      <tr>
        <td id="L219" class="blob-num js-line-number" data-line-number="219"></td>
        <td id="LC219" class="blob-code blob-code-inner js-file-line">rst=<span class="pl-s"><span class="pl-pds">$&#39;</span><span class="pl-cce">\e</span>[0m<span class="pl-pds">&#39;</span></span></td>
      </tr>
      <tr>
        <td id="L220" class="blob-num js-line-number" data-line-number="220"></td>
        <td id="LC220" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L221" class="blob-num js-line-number" data-line-number="221"></td>
        <td id="LC221" class="blob-code blob-code-inner js-file-line">cat <span class="pl-k">&lt;&lt;</span> EOF</td>
      </tr>
      <tr>
        <td id="L222" class="blob-num js-line-number" data-line-number="222"></td>
        <td id="LC222" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L223" class="blob-num js-line-number" data-line-number="223"></td>
        <td id="LC223" class="blob-code blob-code-inner js-file-line"> <span class="pl-smi">$f1</span>  ▀▄   ▄▀     <span class="pl-smi">$f2</span> ▄▄▄████▄▄▄    <span class="pl-smi">$f3</span>  ▄██▄     <span class="pl-smi">$f4</span>  ▀▄   ▄▀     <span class="pl-smi">$f5</span> ▄▄▄████▄▄▄    <span class="pl-smi">$f6</span>  ▄██▄  <span class="pl-smi">$rst</span></td>
      </tr>
      <tr>
        <td id="L224" class="blob-num js-line-number" data-line-number="224"></td>
        <td id="LC224" class="blob-code blob-code-inner js-file-line"> <span class="pl-smi">$f1</span> ▄█▀███▀█▄    <span class="pl-smi">$f2</span>███▀▀██▀▀███   <span class="pl-smi">$f3</span>▄█▀██▀█▄   <span class="pl-smi">$f4</span> ▄█▀███▀█▄    <span class="pl-smi">$f5</span>███▀▀██▀▀███   <span class="pl-smi">$f6</span>▄█▀██▀█▄<span class="pl-smi">$rst</span></td>
      </tr>
      <tr>
        <td id="L225" class="blob-num js-line-number" data-line-number="225"></td>
        <td id="LC225" class="blob-code blob-code-inner js-file-line"> <span class="pl-smi">$f1</span>█▀███████▀█   <span class="pl-smi">$f2</span>▀▀███▀▀███▀▀   <span class="pl-smi">$f3</span>▀█▀██▀█▀   <span class="pl-smi">$f4</span>█▀███████▀█   <span class="pl-smi">$f5</span>▀▀███▀▀███▀▀   <span class="pl-smi">$f6</span>▀█▀██▀█▀<span class="pl-smi">$rst</span></td>
      </tr>
      <tr>
        <td id="L226" class="blob-num js-line-number" data-line-number="226"></td>
        <td id="LC226" class="blob-code blob-code-inner js-file-line"> <span class="pl-smi">$f1</span>▀ ▀▄▄ ▄▄▀ ▀   <span class="pl-smi">$f2</span> ▀█▄ ▀▀ ▄█▀    <span class="pl-smi">$f3</span>▀▄    ▄▀   <span class="pl-smi">$f4</span>▀ ▀▄▄ ▄▄▀ ▀   <span class="pl-smi">$f5</span> ▀█▄ ▀▀ ▄█▀    <span class="pl-smi">$f6</span>▀▄    ▄▀<span class="pl-smi">$rst</span></td>
      </tr>
      <tr>
        <td id="L227" class="blob-num js-line-number" data-line-number="227"></td>
        <td id="LC227" class="blob-code blob-code-inner js-file-line"> </td>
      </tr>
      <tr>
        <td id="L228" class="blob-num js-line-number" data-line-number="228"></td>
        <td id="LC228" class="blob-code blob-code-inner js-file-line">EOF</td>
      </tr>
      <tr>
        <td id="L229" class="blob-num js-line-number" data-line-number="229"></td>
        <td id="LC229" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>                \e[100m                Steady script           \e[00;37;40m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L230" class="blob-num js-line-number" data-line-number="230"></td>
        <td id="LC230" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>               \e[01;34m                    by iicc                \e[00;37;40m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L231" class="blob-num js-line-number" data-line-number="231"></td>
        <td id="LC231" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L232" class="blob-num js-line-number" data-line-number="232"></td>
        <td id="LC232" class="blob-code blob-code-inner js-file-line">cat <span class="pl-k">&lt;&lt;</span> EOF</td>
      </tr>
      <tr>
        <td id="L233" class="blob-num js-line-number" data-line-number="233"></td>
        <td id="LC233" class="blob-code blob-code-inner js-file-line"> <span class="pl-smi">$bld$f1</span>▄ ▀▄   ▄▀ ▄   <span class="pl-smi">$f2</span> ▄▄▄████▄▄▄    <span class="pl-smi">$f3</span>  ▄██▄     <span class="pl-smi">$f4</span>▄ ▀▄   ▄▀ ▄   <span class="pl-smi">$f5</span> ▄▄▄████▄▄▄    <span class="pl-smi">$f6</span>  ▄██▄  <span class="pl-smi">$rst</span></td>
      </tr>
      <tr>
        <td id="L234" class="blob-num js-line-number" data-line-number="234"></td>
        <td id="LC234" class="blob-code blob-code-inner js-file-line"> <span class="pl-smi">$bld$f1</span>█▄█▀███▀█▄█   <span class="pl-smi">$f2</span>███▀▀██▀▀███   <span class="pl-smi">$f3</span>▄█▀██▀█▄   <span class="pl-smi">$f4</span>█▄█▀███▀█▄█   <span class="pl-smi">$f5</span>███▀▀██▀▀███   <span class="pl-smi">$f6</span>▄█▀██▀█▄<span class="pl-smi">$rst</span></td>
      </tr>
      <tr>
        <td id="L235" class="blob-num js-line-number" data-line-number="235"></td>
        <td id="LC235" class="blob-code blob-code-inner js-file-line"> <span class="pl-smi">$bld$f1</span>▀█████████▀   <span class="pl-smi">$f2</span>▀▀▀██▀▀██▀▀▀   <span class="pl-smi">$f3</span>▀▀█▀▀█▀▀   <span class="pl-smi">$f4</span>▀█████████▀   <span class="pl-smi">$f5</span>▀▀▀██▀▀██▀▀▀   <span class="pl-smi">$f6</span>▀▀█▀▀█▀▀<span class="pl-smi">$rst</span></td>
      </tr>
      <tr>
        <td id="L236" class="blob-num js-line-number" data-line-number="236"></td>
        <td id="LC236" class="blob-code blob-code-inner js-file-line"> <span class="pl-smi">$bld$f1</span> ▄▀     ▀▄    <span class="pl-smi">$f2</span>▄▄▀▀ ▀▀ ▀▀▄▄   <span class="pl-smi">$f3</span>▄▀▄▀▀▄▀▄   <span class="pl-smi">$f4</span> ▄▀     ▀▄    <span class="pl-smi">$f5</span>▄▄▀▀ ▀▀ ▀▀▄▄   <span class="pl-smi">$f6</span>▄▀▄▀▀▄▀▄<span class="pl-smi">$rst</span></td>
      </tr>
      <tr>
        <td id="L237" class="blob-num js-line-number" data-line-number="237"></td>
        <td id="LC237" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L238" class="blob-num js-line-number" data-line-number="238"></td>
        <td id="LC238" class="blob-code blob-code-inner js-file-line">EOF</td>
      </tr>
      <tr>
        <td id="L239" class="blob-num js-line-number" data-line-number="239"></td>
        <td id="LC239" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L240" class="blob-num js-line-number" data-line-number="240"></td>
        <td id="LC240" class="blob-code blob-code-inner js-file-line">sleep 1.3</td>
      </tr>
      <tr>
        <td id="L241" class="blob-num js-line-number" data-line-number="241"></td>
        <td id="LC241" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L242" class="blob-num js-line-number" data-line-number="242"></td>
        <td id="LC242" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># Checking if the bot folder is in HOME</span></td>
      </tr>
      <tr>
        <td id="L243" class="blob-num js-line-number" data-line-number="243"></td>
        <td id="LC243" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$bld$f4</span> CHECKING INSTALLED BOT...<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L244" class="blob-num js-line-number" data-line-number="244"></td>
        <td id="LC244" class="blob-code blob-code-inner js-file-line">sleep 0.5</td>
      </tr>
      <tr>
        <td id="L245" class="blob-num js-line-number" data-line-number="245"></td>
        <td id="LC245" class="blob-code blob-code-inner js-file-line">ls ../ <span class="pl-k">|</span> grep <span class="pl-smi">$BOT</span> <span class="pl-k">2&gt;</span>/dev/null <span class="pl-k">&gt;</span>/dev/null</td>
      </tr>
      <tr>
        <td id="L246" class="blob-num js-line-number" data-line-number="246"></td>
        <td id="LC246" class="blob-code blob-code-inner js-file-line"><span class="pl-k">if</span> [ <span class="pl-smi">$?</span> <span class="pl-k">!=</span> 0 ]<span class="pl-k">;</span> <span class="pl-k">then</span></td>
      </tr>
      <tr>
        <td id="L247" class="blob-num js-line-number" data-line-number="247"></td>
        <td id="LC247" class="blob-code blob-code-inner js-file-line">  <span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f1</span> ERROR: BOT: <span class="pl-smi">$BOT</span> NOT FOUND IN YOUR HOME DIRECTORY<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L248" class="blob-num js-line-number" data-line-number="248"></td>
        <td id="LC248" class="blob-code blob-code-inner js-file-line">  sleep 4</td>
      </tr>
      <tr>
        <td id="L249" class="blob-num js-line-number" data-line-number="249"></td>
        <td id="LC249" class="blob-code blob-code-inner js-file-line">  <span class="pl-c1">exit</span> 1</td>
      </tr>
      <tr>
        <td id="L250" class="blob-num js-line-number" data-line-number="250"></td>
        <td id="LC250" class="blob-code blob-code-inner js-file-line"><span class="pl-k">fi</span></td>
      </tr>
      <tr>
        <td id="L251" class="blob-num js-line-number" data-line-number="251"></td>
        <td id="LC251" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f2</span> <span class="pl-smi">$BOT</span> FOUND IN YOUR HOME DIRECTORY<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L252" class="blob-num js-line-number" data-line-number="252"></td>
        <td id="LC252" class="blob-code blob-code-inner js-file-line">sleep 0.5</td>
      </tr>
      <tr>
        <td id="L253" class="blob-num js-line-number" data-line-number="253"></td>
        <td id="LC253" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L254" class="blob-num js-line-number" data-line-number="254"></td>
        <td id="LC254" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L255" class="blob-num js-line-number" data-line-number="255"></td>
        <td id="LC255" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L256" class="blob-num js-line-number" data-line-number="256"></td>
        <td id="LC256" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\033[38;5;208m      ____  ____ _____                        \033[0;00m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L257" class="blob-num js-line-number" data-line-number="257"></td>
        <td id="LC257" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\033[38;5;208m     |    \|  _ )_   _|___ ____   __  __      \033[0;00m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L258" class="blob-num js-line-number" data-line-number="258"></td>
        <td id="LC258" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\033[38;5;208m     | |_  )  _ \ | |/ .__|  _ \_|  \/  |     \033[0;00m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L259" class="blob-num js-line-number" data-line-number="259"></td>
        <td id="LC259" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\033[38;5;208m     |____/|____/ |_|\____/\_____|_/\/\_|     \033[0;00m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L260" class="blob-num js-line-number" data-line-number="260"></td>
        <td id="LC260" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\033[38;5;208m                                              \033[0;00m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L261" class="blob-num js-line-number" data-line-number="261"></td>
        <td id="LC261" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L262" class="blob-num js-line-number" data-line-number="262"></td>
        <td id="LC262" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># Starting preliminar setup</span></td>
      </tr>
      <tr>
        <td id="L263" class="blob-num js-line-number" data-line-number="263"></td>
        <td id="LC263" class="blob-code blob-code-inner js-file-line">sleep 1.5</td>
      </tr>
      <tr>
        <td id="L264" class="blob-num js-line-number" data-line-number="264"></td>
        <td id="LC264" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$bld$f4</span> CHECKING PROCESSES...<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L265" class="blob-num js-line-number" data-line-number="265"></td>
        <td id="LC265" class="blob-code blob-code-inner js-file-line">sleep 0.7</td>
      </tr>
      <tr>
        <td id="L266" class="blob-num js-line-number" data-line-number="266"></td>
        <td id="LC266" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L267" class="blob-num js-line-number" data-line-number="267"></td>
        <td id="LC267" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># Looks for the number of screen/telegram-cli processes</span></td>
      </tr>
      <tr>
        <td id="L268" class="blob-num js-line-number" data-line-number="268"></td>
        <td id="LC268" class="blob-code blob-code-inner js-file-line">SCREENNUM=<span class="pl-s"><span class="pl-pds">`</span>ps -e <span class="pl-k">|</span> grep -c screen<span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L269" class="blob-num js-line-number" data-line-number="269"></td>
        <td id="LC269" class="blob-code blob-code-inner js-file-line">CLINUM=<span class="pl-s"><span class="pl-pds">`</span>ps -e <span class="pl-k">|</span> grep -c telegram-cli<span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L270" class="blob-num js-line-number" data-line-number="270"></td>
        <td id="LC270" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L271" class="blob-num js-line-number" data-line-number="271"></td>
        <td id="LC271" class="blob-code blob-code-inner js-file-line"><span class="pl-k">if</span> [ <span class="pl-smi">$SCREENNUM</span> <span class="pl-k">-ge</span> 3 ]<span class="pl-k">;</span> <span class="pl-k">then</span></td>
      </tr>
      <tr>
        <td id="L272" class="blob-num js-line-number" data-line-number="272"></td>
        <td id="LC272" class="blob-code blob-code-inner js-file-line">  <span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f1</span> ERROR: MORE THAN 2 PROCESS OF SCREEN RUNNING.<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L273" class="blob-num js-line-number" data-line-number="273"></td>
        <td id="LC273" class="blob-code blob-code-inner js-file-line">  <span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f1</span> THESE PROCESSES HAVE BE KILLED. THEN RESTART THE SCRIPT<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L274" class="blob-num js-line-number" data-line-number="274"></td>
        <td id="LC274" class="blob-code blob-code-inner js-file-line">  <span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&#39;</span>$f1 RUN: &quot;killall screen&quot; $rst<span class="pl-pds">&#39;</span></span></td>
      </tr>
      <tr>
        <td id="L275" class="blob-num js-line-number" data-line-number="275"></td>
        <td id="LC275" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">if</span> [ <span class="pl-smi">$CLINUM</span> <span class="pl-k">-ge</span> 2 ]<span class="pl-k">;</span> <span class="pl-k">then</span></td>
      </tr>
      <tr>
        <td id="L276" class="blob-num js-line-number" data-line-number="276"></td>
        <td id="LC276" class="blob-code blob-code-inner js-file-line">    <span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f1</span> ERROR: MORE THAN 1 PROCESS OF TELEGRAM-CLI RUNNING.<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L277" class="blob-num js-line-number" data-line-number="277"></td>
        <td id="LC277" class="blob-code blob-code-inner js-file-line">    <span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f1</span> THESE PROCESSES WILL BE KILLED. THEN RESTART THE SCRIPT<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L278" class="blob-num js-line-number" data-line-number="278"></td>
        <td id="LC278" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f1</span> RUN: killall telegram-cli <span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L279" class="blob-num js-line-number" data-line-number="279"></td>
        <td id="LC279" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">fi</span></td>
      </tr>
      <tr>
        <td id="L280" class="blob-num js-line-number" data-line-number="280"></td>
        <td id="LC280" class="blob-code blob-code-inner js-file-line">  sleep 4</td>
      </tr>
      <tr>
        <td id="L281" class="blob-num js-line-number" data-line-number="281"></td>
        <td id="LC281" class="blob-code blob-code-inner js-file-line">  <span class="pl-c1">exit</span> 1</td>
      </tr>
      <tr>
        <td id="L282" class="blob-num js-line-number" data-line-number="282"></td>
        <td id="LC282" class="blob-code blob-code-inner js-file-line"><span class="pl-k">fi</span></td>
      </tr>
      <tr>
        <td id="L283" class="blob-num js-line-number" data-line-number="283"></td>
        <td id="LC283" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f2</span> SCREEN NUMBER AND CLI NUMBER UNDER THE SUPPORTED LIMIT<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L284" class="blob-num js-line-number" data-line-number="284"></td>
        <td id="LC284" class="blob-code blob-code-inner js-file-line">sleep 0.7</td>
      </tr>
      <tr>
        <td id="L285" class="blob-num js-line-number" data-line-number="285"></td>
        <td id="LC285" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f2</span> RUNNING <span class="pl-smi">$SCREENNUM</span> SCREEN PROCESS<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L286" class="blob-num js-line-number" data-line-number="286"></td>
        <td id="LC286" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f2</span> RUNNING <span class="pl-smi">$CLINUM</span> TELEGRAM-CLI PROCESS<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L287" class="blob-num js-line-number" data-line-number="287"></td>
        <td id="LC287" class="blob-code blob-code-inner js-file-line">sleep 0.9</td>
      </tr>
      <tr>
        <td id="L288" class="blob-num js-line-number" data-line-number="288"></td>
        <td id="LC288" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L289" class="blob-num js-line-number" data-line-number="289"></td>
        <td id="LC289" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># Getting screen pid&#39;s</span></td>
      </tr>
      <tr>
        <td id="L290" class="blob-num js-line-number" data-line-number="290"></td>
        <td id="LC290" class="blob-code blob-code-inner js-file-line">ps -e <span class="pl-k">|</span> grep screen <span class="pl-k">|</span> sed <span class="pl-s"><span class="pl-pds">&#39;</span>s/^[[:space:]]*//<span class="pl-pds">&#39;</span></span> <span class="pl-k">|</span> cut -f 1 -d<span class="pl-s"><span class="pl-pds">&quot;</span> <span class="pl-pds">&quot;</span></span> <span class="pl-k">|</span> <span class="pl-k">while</span> <span class="pl-c1">read</span> -r line <span class="pl-k">;</span> <span class="pl-k">do</span></td>
      </tr>
      <tr>
        <td id="L291" class="blob-num js-line-number" data-line-number="291"></td>
        <td id="LC291" class="blob-code blob-code-inner js-file-line">  sleep 0.5</td>
      </tr>
      <tr>
        <td id="L292" class="blob-num js-line-number" data-line-number="292"></td>
        <td id="LC292" class="blob-code blob-code-inner js-file-line">  <span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f2</span> SCREEN NUMBER <span class="pl-smi">$I</span> PID: <span class="pl-smi">$line$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L293" class="blob-num js-line-number" data-line-number="293"></td>
        <td id="LC293" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">if</span> [ <span class="pl-smi">$I</span> <span class="pl-k">-eq</span> 1 ]<span class="pl-k">;</span> <span class="pl-k">then</span></td>
      </tr>
      <tr>
        <td id="L294" class="blob-num js-line-number" data-line-number="294"></td>
        <td id="LC294" class="blob-code blob-code-inner js-file-line">    <span class="pl-c1">echo</span> <span class="pl-smi">$line</span> <span class="pl-k">&gt;</span> SC1</td>
      </tr>
      <tr>
        <td id="L295" class="blob-num js-line-number" data-line-number="295"></td>
        <td id="LC295" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">else</span></td>
      </tr>
      <tr>
        <td id="L296" class="blob-num js-line-number" data-line-number="296"></td>
        <td id="LC296" class="blob-code blob-code-inner js-file-line">    <span class="pl-c1">echo</span> <span class="pl-smi">$line</span> <span class="pl-k">&gt;</span> SC2</td>
      </tr>
      <tr>
        <td id="L297" class="blob-num js-line-number" data-line-number="297"></td>
        <td id="LC297" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">fi</span></td>
      </tr>
      <tr>
        <td id="L298" class="blob-num js-line-number" data-line-number="298"></td>
        <td id="LC298" class="blob-code blob-code-inner js-file-line">  I=<span class="pl-s"><span class="pl-pds">$((</span> <span class="pl-smi">$I</span> <span class="pl-k">+</span> <span class="pl-c1">1</span> <span class="pl-pds">))</span></span></td>
      </tr>
      <tr>
        <td id="L299" class="blob-num js-line-number" data-line-number="299"></td>
        <td id="LC299" class="blob-code blob-code-inner js-file-line"><span class="pl-k">done</span></td>
      </tr>
      <tr>
        <td id="L300" class="blob-num js-line-number" data-line-number="300"></td>
        <td id="LC300" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L301" class="blob-num js-line-number" data-line-number="301"></td>
        <td id="LC301" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># I had some weird errors, so I had to do this silly fix:</span></td>
      </tr>
      <tr>
        <td id="L302" class="blob-num js-line-number" data-line-number="302"></td>
        <td id="LC302" class="blob-code blob-code-inner js-file-line">SCREENPID1=<span class="pl-s"><span class="pl-pds">`</span>cat SC1<span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L303" class="blob-num js-line-number" data-line-number="303"></td>
        <td id="LC303" class="blob-code blob-code-inner js-file-line">SCREENPID2=<span class="pl-s"><span class="pl-pds">`</span>cat SC2<span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L304" class="blob-num js-line-number" data-line-number="304"></td>
        <td id="LC304" class="blob-code blob-code-inner js-file-line">rm SC1 SC2 <span class="pl-k">2&gt;</span>/dev/null</td>
      </tr>
      <tr>
        <td id="L305" class="blob-num js-line-number" data-line-number="305"></td>
        <td id="LC305" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L306" class="blob-num js-line-number" data-line-number="306"></td>
        <td id="LC306" class="blob-code blob-code-inner js-file-line">sleep 0.7</td>
      </tr>
      <tr>
        <td id="L307" class="blob-num js-line-number" data-line-number="307"></td>
        <td id="LC307" class="blob-code blob-code-inner js-file-line">CLIPID=<span class="pl-s"><span class="pl-pds">`</span>ps -e <span class="pl-k">|</span> grep telegram-cli <span class="pl-k">|</span> sed <span class="pl-s"><span class="pl-pds">&#39;</span>s/^[[:space:]]*//<span class="pl-pds">&#39;</span></span> <span class="pl-k">|</span> cut -f 1 -d<span class="pl-s"><span class="pl-pds">&quot;</span> <span class="pl-pds">&quot;</span></span><span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L308" class="blob-num js-line-number" data-line-number="308"></td>
        <td id="LC308" class="blob-code blob-code-inner js-file-line"><span class="pl-k">if</span> [ <span class="pl-smi">$CLINUM</span> <span class="pl-k">-eq</span> 1 ]<span class="pl-k">;</span> <span class="pl-k">then</span></td>
      </tr>
      <tr>
        <td id="L309" class="blob-num js-line-number" data-line-number="309"></td>
        <td id="LC309" class="blob-code blob-code-inner js-file-line">  <span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f2</span> RUNNING ONE PROCESS OF TELEGRAM-CLI: <span class="pl-smi">$CLIPID1$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L310" class="blob-num js-line-number" data-line-number="310"></td>
        <td id="LC310" class="blob-code blob-code-inner js-file-line">  <span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$bld$f4</span> KILLING TELEGRAM-CLI PROCESS. NOT NEEDED NOW<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L311" class="blob-num js-line-number" data-line-number="311"></td>
        <td id="LC311" class="blob-code blob-code-inner js-file-line">  <span class="pl-c1">kill</span> <span class="pl-smi">$CLIPID1</span></td>
      </tr>
      <tr>
        <td id="L312" class="blob-num js-line-number" data-line-number="312"></td>
        <td id="LC312" class="blob-code blob-code-inner js-file-line"><span class="pl-k">else</span></td>
      </tr>
      <tr>
        <td id="L313" class="blob-num js-line-number" data-line-number="313"></td>
        <td id="LC313" class="blob-code blob-code-inner js-file-line">  <span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f2</span> RUNNING ZERO PROCESS OF TELEGRAM-CLI<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L314" class="blob-num js-line-number" data-line-number="314"></td>
        <td id="LC314" class="blob-code blob-code-inner js-file-line"><span class="pl-k">fi</span></td>
      </tr>
      <tr>
        <td id="L315" class="blob-num js-line-number" data-line-number="315"></td>
        <td id="LC315" class="blob-code blob-code-inner js-file-line">sleep 0.7</td>
      </tr>
      <tr>
        <td id="L316" class="blob-num js-line-number" data-line-number="316"></td>
        <td id="LC316" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L317" class="blob-num js-line-number" data-line-number="317"></td>
        <td id="LC317" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L318" class="blob-num js-line-number" data-line-number="318"></td>
        <td id="LC318" class="blob-code blob-code-inner js-file-line">CLINUM=<span class="pl-s"><span class="pl-pds">`</span>ps -e <span class="pl-k">|</span> grep -c telegram-cli<span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L319" class="blob-num js-line-number" data-line-number="319"></td>
        <td id="LC319" class="blob-code blob-code-inner js-file-line"><span class="pl-k">if</span> [ <span class="pl-smi">$CLINUM</span> <span class="pl-k">-eq</span> 1 ]<span class="pl-k">;</span> <span class="pl-k">then</span></td>
      </tr>
      <tr>
        <td id="L320" class="blob-num js-line-number" data-line-number="320"></td>
        <td id="LC320" class="blob-code blob-code-inner js-file-line">  <span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f1</span> ERROR: TELEGRAM-CLI PID COULDN&#39;T BE KILLED. IGNORE.<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L321" class="blob-num js-line-number" data-line-number="321"></td>
        <td id="LC321" class="blob-code blob-code-inner js-file-line"><span class="pl-k">fi</span></td>
      </tr>
      <tr>
        <td id="L322" class="blob-num js-line-number" data-line-number="322"></td>
        <td id="LC322" class="blob-code blob-code-inner js-file-line">sleep 1</td>
      </tr>
      <tr>
        <td id="L323" class="blob-num js-line-number" data-line-number="323"></td>
        <td id="LC323" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L324" class="blob-num js-line-number" data-line-number="324"></td>
        <td id="LC324" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L325" class="blob-num js-line-number" data-line-number="325"></td>
        <td id="LC325" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># =====Setup ends===== #</span></td>
      </tr>
      <tr>
        <td id="L326" class="blob-num js-line-number" data-line-number="326"></td>
        <td id="LC326" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L327" class="blob-num js-line-number" data-line-number="327"></td>
        <td id="LC327" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># Opening new screen in a daemon</span></td>
      </tr>
      <tr>
        <td id="L328" class="blob-num js-line-number" data-line-number="328"></td>
        <td id="LC328" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$bld$f4</span> ATTACHING SCREEN AS DAEMON...<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L329" class="blob-num js-line-number" data-line-number="329"></td>
        <td id="LC329" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># Better to clear cli status before</span></td>
      </tr>
      <tr>
        <td id="L330" class="blob-num js-line-number" data-line-number="330"></td>
        <td id="LC330" class="blob-code blob-code-inner js-file-line">rm ../.telegram-cli/state <span class="pl-k">2&gt;</span>/dev/null</td>
      </tr>
      <tr>
        <td id="L331" class="blob-num js-line-number" data-line-number="331"></td>
        <td id="LC331" class="blob-code blob-code-inner js-file-line">screen -d -m bash launch.sh</td>
      </tr>
      <tr>
        <td id="L332" class="blob-num js-line-number" data-line-number="332"></td>
        <td id="LC332" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L333" class="blob-num js-line-number" data-line-number="333"></td>
        <td id="LC333" class="blob-code blob-code-inner js-file-line">sleep 1.3</td>
      </tr>
      <tr>
        <td id="L334" class="blob-num js-line-number" data-line-number="334"></td>
        <td id="LC334" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L335" class="blob-num js-line-number" data-line-number="335"></td>
        <td id="LC335" class="blob-code blob-code-inner js-file-line">SCREENNUM=<span class="pl-s"><span class="pl-pds">`</span>ps -e <span class="pl-k">|</span> grep -c screen<span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L336" class="blob-num js-line-number" data-line-number="336"></td>
        <td id="LC336" class="blob-code blob-code-inner js-file-line"><span class="pl-k">if</span> [ <span class="pl-smi">$SCREENNUM</span> <span class="pl-k">!=</span> 3 ]<span class="pl-k">;</span> <span class="pl-k">then</span></td>
      </tr>
      <tr>
        <td id="L337" class="blob-num js-line-number" data-line-number="337"></td>
        <td id="LC337" class="blob-code blob-code-inner js-file-line">  <span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f1</span> ERROR: SCREEN RUNNING: <span class="pl-smi">$SCREENNUM</span> \n SCREEN ESPECTED: 3<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L338" class="blob-num js-line-number" data-line-number="338"></td>
        <td id="LC338" class="blob-code blob-code-inner js-file-line">  <span class="pl-c1">exit</span> 1</td>
      </tr>
      <tr>
        <td id="L339" class="blob-num js-line-number" data-line-number="339"></td>
        <td id="LC339" class="blob-code blob-code-inner js-file-line"><span class="pl-k">fi</span></td>
      </tr>
      <tr>
        <td id="L340" class="blob-num js-line-number" data-line-number="340"></td>
        <td id="LC340" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L341" class="blob-num js-line-number" data-line-number="341"></td>
        <td id="LC341" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># Getting screen info</span></td>
      </tr>
      <tr>
        <td id="L342" class="blob-num js-line-number" data-line-number="342"></td>
        <td id="LC342" class="blob-code blob-code-inner js-file-line">sleep 0.7</td>
      </tr>
      <tr>
        <td id="L343" class="blob-num js-line-number" data-line-number="343"></td>
        <td id="LC343" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$bld$f4</span> RELOADING SCREEN INFO...<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L344" class="blob-num js-line-number" data-line-number="344"></td>
        <td id="LC344" class="blob-code blob-code-inner js-file-line">sleep 1</td>
      </tr>
      <tr>
        <td id="L345" class="blob-num js-line-number" data-line-number="345"></td>
        <td id="LC345" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f2</span> NUMBER OF SCREEN ATTACHED: <span class="pl-smi">$SCREENNUM$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L346" class="blob-num js-line-number" data-line-number="346"></td>
        <td id="LC346" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f2</span> SECONDARY SCREEN: <span class="pl-smi">$SCREENPID1</span> AND <span class="pl-smi">$SCREENPID2$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L347" class="blob-num js-line-number" data-line-number="347"></td>
        <td id="LC347" class="blob-code blob-code-inner js-file-line">SCREEN=<span class="pl-s"><span class="pl-pds">`</span>ps -e <span class="pl-k">|</span> grep -v <span class="pl-smi">$SCREENPID1</span> <span class="pl-k">|</span> grep -v <span class="pl-smi">$SCREENPID2</span> <span class="pl-k">|</span> grep screen <span class="pl-k">|</span> sed <span class="pl-s"><span class="pl-pds">&#39;</span>s/^[[:space:]]*//<span class="pl-pds">&#39;</span></span> <span class="pl-k">|</span> cut -f 1 -d<span class="pl-s"><span class="pl-pds">&quot;</span> <span class="pl-pds">&quot;</span></span><span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L348" class="blob-num js-line-number" data-line-number="348"></td>
        <td id="LC348" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L349" class="blob-num js-line-number" data-line-number="349"></td>
        <td id="LC349" class="blob-code blob-code-inner js-file-line">sleep 0.5</td>
      </tr>
      <tr>
        <td id="L350" class="blob-num js-line-number" data-line-number="350"></td>
        <td id="LC350" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f2</span> PRIMARY SCREEN: <span class="pl-smi">$SCREEN$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L351" class="blob-num js-line-number" data-line-number="351"></td>
        <td id="LC351" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L352" class="blob-num js-line-number" data-line-number="352"></td>
        <td id="LC352" class="blob-code blob-code-inner js-file-line">sleep 0.7</td>
      </tr>
      <tr>
        <td id="L353" class="blob-num js-line-number" data-line-number="353"></td>
        <td id="LC353" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$bld$f4</span> RELOADING TELEGRAM-CLI INFO...<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L354" class="blob-num js-line-number" data-line-number="354"></td>
        <td id="LC354" class="blob-code blob-code-inner js-file-line">sleep 0.7</td>
      </tr>
      <tr>
        <td id="L355" class="blob-num js-line-number" data-line-number="355"></td>
        <td id="LC355" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L356" class="blob-num js-line-number" data-line-number="356"></td>
        <td id="LC356" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># Getting new telegram-cli PID</span></td>
      </tr>
      <tr>
        <td id="L357" class="blob-num js-line-number" data-line-number="357"></td>
        <td id="LC357" class="blob-code blob-code-inner js-file-line">CLIPID=<span class="pl-s"><span class="pl-pds">`</span>ps -e <span class="pl-k">|</span> grep telegram-cli <span class="pl-k">|</span> sed <span class="pl-s"><span class="pl-pds">&#39;</span>s/^[[:space:]]*//<span class="pl-pds">&#39;</span></span> <span class="pl-k">|</span>cut -f 1 -d<span class="pl-s"><span class="pl-pds">&quot;</span> <span class="pl-pds">&quot;</span></span><span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L358" class="blob-num js-line-number" data-line-number="358"></td>
        <td id="LC358" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f2</span> NEW TELEGRAM-CLI PID: <span class="pl-smi">$CLIPID$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L359" class="blob-num js-line-number" data-line-number="359"></td>
        <td id="LC359" class="blob-code blob-code-inner js-file-line"><span class="pl-k">if</span> [ <span class="pl-k">-z</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">${CLIPID}</span><span class="pl-pds">&quot;</span></span> ]<span class="pl-k">;</span> <span class="pl-k">then</span></td>
      </tr>
      <tr>
        <td id="L360" class="blob-num js-line-number" data-line-number="360"></td>
        <td id="LC360" class="blob-code blob-code-inner js-file-line">  <span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f1</span> ERROR: TELEGRAM-CLI PROCESS NOT RUNNING<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L361" class="blob-num js-line-number" data-line-number="361"></td>
        <td id="LC361" class="blob-code blob-code-inner js-file-line">  sleep 3</td>
      </tr>
      <tr>
        <td id="L362" class="blob-num js-line-number" data-line-number="362"></td>
        <td id="LC362" class="blob-code blob-code-inner js-file-line">  <span class="pl-c1">exit</span> 1</td>
      </tr>
      <tr>
        <td id="L363" class="blob-num js-line-number" data-line-number="363"></td>
        <td id="LC363" class="blob-code blob-code-inner js-file-line"><span class="pl-k">fi</span></td>
      </tr>
      <tr>
        <td id="L364" class="blob-num js-line-number" data-line-number="364"></td>
        <td id="LC364" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L365" class="blob-num js-line-number" data-line-number="365"></td>
        <td id="LC365" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L366" class="blob-num js-line-number" data-line-number="366"></td>
        <td id="LC366" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># Locating telegram-cli status</span></td>
      </tr>
      <tr>
        <td id="L367" class="blob-num js-line-number" data-line-number="367"></td>
        <td id="LC367" class="blob-code blob-code-inner js-file-line">cat /proc/<span class="pl-smi">$CLIPID</span>/task/<span class="pl-smi">$CLIPID</span>/status <span class="pl-k">&gt;</span> STATUS</td>
      </tr>
      <tr>
        <td id="L368" class="blob-num js-line-number" data-line-number="368"></td>
        <td id="LC368" class="blob-code blob-code-inner js-file-line">NONVOLUNTARY=<span class="pl-s"><span class="pl-pds">`</span>grep nonvoluntary STATUS <span class="pl-k">|</span> cut -f 2 -d<span class="pl-s"><span class="pl-pds">&quot;</span>:<span class="pl-pds">&quot;</span></span> <span class="pl-k">|</span> sed <span class="pl-s"><span class="pl-pds">&#39;</span>s/^[[:space:]]*//<span class="pl-pds">&#39;</span></span><span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L369" class="blob-num js-line-number" data-line-number="369"></td>
        <td id="LC369" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L370" class="blob-num js-line-number" data-line-number="370"></td>
        <td id="LC370" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L371" class="blob-num js-line-number" data-line-number="371"></td>
        <td id="LC371" class="blob-code blob-code-inner js-file-line">sleep 5</td>
      </tr>
      <tr>
        <td id="L372" class="blob-num js-line-number" data-line-number="372"></td>
        <td id="LC372" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L373" class="blob-num js-line-number" data-line-number="373"></td>
        <td id="LC373" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># :::::::::::::::::::::::::</span></td>
      </tr>
      <tr>
        <td id="L374" class="blob-num js-line-number" data-line-number="374"></td>
        <td id="LC374" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># ::::::: MAIN LOOP :::::::</span></td>
      </tr>
      <tr>
        <td id="L375" class="blob-num js-line-number" data-line-number="375"></td>
        <td id="LC375" class="blob-code blob-code-inner js-file-line"><span class="pl-c"># :::::::::::::::::::::::::</span></td>
      </tr>
      <tr>
        <td id="L376" class="blob-num js-line-number" data-line-number="376"></td>
        <td id="LC376" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L377" class="blob-num js-line-number" data-line-number="377"></td>
        <td id="LC377" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">while</span> <span class="pl-c1">true</span><span class="pl-k">;</span> <span class="pl-k">do</span></td>
      </tr>
      <tr>
        <td id="L378" class="blob-num js-line-number" data-line-number="378"></td>
        <td id="LC378" class="blob-code blob-code-inner js-file-line">  </td>
      </tr>
      <tr>
        <td id="L379" class="blob-num js-line-number" data-line-number="379"></td>
        <td id="LC379" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f2</span> TIMES CHECKED AND RUNNING:<span class="pl-smi">$f5</span> <span class="pl-smi">$OK</span> <span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L380" class="blob-num js-line-number" data-line-number="380"></td>
        <td id="LC380" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f2</span> TIMES FAILED AND RECOVERED:<span class="pl-smi">$f5</span> <span class="pl-smi">$BAD</span> <span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L381" class="blob-num js-line-number" data-line-number="381"></td>
        <td id="LC381" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L382" class="blob-num js-line-number" data-line-number="382"></td>
        <td id="LC382" class="blob-code blob-code-inner js-file-line">	</td>
      </tr>
      <tr>
        <td id="L383" class="blob-num js-line-number" data-line-number="383"></td>
        <td id="LC383" class="blob-code blob-code-inner js-file-line">	cat /proc/<span class="pl-smi">$CLIPID</span>/task/<span class="pl-smi">$CLIPID</span>/status <span class="pl-k">&gt;</span> CHECK</td>
      </tr>
      <tr>
        <td id="L384" class="blob-num js-line-number" data-line-number="384"></td>
        <td id="LC384" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">if</span> [ <span class="pl-smi">$?</span> <span class="pl-k">!=</span> 0 ]<span class="pl-k">;</span> <span class="pl-k">then</span></td>
      </tr>
      <tr>
        <td id="L385" class="blob-num js-line-number" data-line-number="385"></td>
        <td id="LC385" class="blob-code blob-code-inner js-file-line">		I=<span class="pl-s"><span class="pl-pds">$((</span> <span class="pl-smi">$I</span> <span class="pl-k">+</span> <span class="pl-c1">1</span> <span class="pl-pds">))</span></span></td>
      </tr>
      <tr>
        <td id="L386" class="blob-num js-line-number" data-line-number="386"></td>
        <td id="LC386" class="blob-code blob-code-inner js-file-line">		<span class="pl-k">if</span> [ <span class="pl-smi">$I</span> <span class="pl-k">-ge</span> 3 ]<span class="pl-k">;</span> <span class="pl-k">then</span></td>
      </tr>
      <tr>
        <td id="L387" class="blob-num js-line-number" data-line-number="387"></td>
        <td id="LC387" class="blob-code blob-code-inner js-file-line">			rm ../.telegram-cli/state <span class="pl-k">2&gt;</span>/dev/null</td>
      </tr>
      <tr>
        <td id="L388" class="blob-num js-line-number" data-line-number="388"></td>
        <td id="LC388" class="blob-code blob-code-inner js-file-line">			NONVOLUNTARY=0</td>
      </tr>
      <tr>
        <td id="L389" class="blob-num js-line-number" data-line-number="389"></td>
        <td id="LC389" class="blob-code blob-code-inner js-file-line">			NONVOLUNTARYCHECK=0</td>
      </tr>
      <tr>
        <td id="L390" class="blob-num js-line-number" data-line-number="390"></td>
        <td id="LC390" class="blob-code blob-code-inner js-file-line">			VOLUNTARY=0</td>
      </tr>
      <tr>
        <td id="L391" class="blob-num js-line-number" data-line-number="391"></td>
        <td id="LC391" class="blob-code blob-code-inner js-file-line">			VOLUNTARYCHECK=0</td>
      </tr>
      <tr>
        <td id="L392" class="blob-num js-line-number" data-line-number="392"></td>
        <td id="LC392" class="blob-code blob-code-inner js-file-line">		<span class="pl-k">fi</span></td>
      </tr>
      <tr>
        <td id="L393" class="blob-num js-line-number" data-line-number="393"></td>
        <td id="LC393" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">else</span></td>
      </tr>
      <tr>
        <td id="L394" class="blob-num js-line-number" data-line-number="394"></td>
        <td id="LC394" class="blob-code blob-code-inner js-file-line">		I=1</td>
      </tr>
      <tr>
        <td id="L395" class="blob-num js-line-number" data-line-number="395"></td>
        <td id="LC395" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">fi</span></td>
      </tr>
      <tr>
        <td id="L396" class="blob-num js-line-number" data-line-number="396"></td>
        <td id="LC396" class="blob-code blob-code-inner js-file-line">	VOLUNTARYCHECK=<span class="pl-s"><span class="pl-pds">`</span>grep voluntary CHECK <span class="pl-k">|</span> head -1 <span class="pl-k">|</span> cut -f 2 -d<span class="pl-s"><span class="pl-pds">&quot;</span>:<span class="pl-pds">&quot;</span></span> <span class="pl-k">|</span> sed <span class="pl-s"><span class="pl-pds">&#39;</span>s/^[[:space:]]*//<span class="pl-pds">&#39;</span></span><span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L397" class="blob-num js-line-number" data-line-number="397"></td>
        <td id="LC397" class="blob-code blob-code-inner js-file-line">	NONVOLUNTARYCHECK=<span class="pl-s"><span class="pl-pds">`</span>grep nonvoluntary CHECK <span class="pl-k">|</span> cut -f 2 -d<span class="pl-s"><span class="pl-pds">&quot;</span>:<span class="pl-pds">&quot;</span></span> <span class="pl-k">|</span> sed <span class="pl-s"><span class="pl-pds">&#39;</span>s/^[[:space:]]*//<span class="pl-pds">&#39;</span></span><span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L398" class="blob-num js-line-number" data-line-number="398"></td>
        <td id="LC398" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L399" class="blob-num js-line-number" data-line-number="399"></td>
        <td id="LC399" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">if</span> [ <span class="pl-smi">$NONVOLUNTARY</span> <span class="pl-k">!=</span> <span class="pl-smi">$NONVOLUNTARYCHECK</span> ] <span class="pl-k">||</span> [ <span class="pl-smi">$VOLUNTARY</span> <span class="pl-k">!=</span> <span class="pl-smi">$VOLUNTARYCHECK</span> ]<span class="pl-k">;</span> <span class="pl-k">then</span></td>
      </tr>
      <tr>
        <td id="L400" class="blob-num js-line-number" data-line-number="400"></td>
        <td id="LC400" class="blob-code blob-code-inner js-file-line">		<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f5</span> BOT RUNNING!<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L401" class="blob-num js-line-number" data-line-number="401"></td>
        <td id="LC401" class="blob-code blob-code-inner js-file-line">		OK=<span class="pl-s"><span class="pl-pds">$((</span> <span class="pl-smi">$OK</span> <span class="pl-k">+</span> <span class="pl-c1">1</span> <span class="pl-pds">))</span></span></td>
      </tr>
      <tr>
        <td id="L402" class="blob-num js-line-number" data-line-number="402"></td>
        <td id="LC402" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L403" class="blob-num js-line-number" data-line-number="403"></td>
        <td id="LC403" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">else</span></td>
      </tr>
      <tr>
        <td id="L404" class="blob-num js-line-number" data-line-number="404"></td>
        <td id="LC404" class="blob-code blob-code-inner js-file-line">		<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f5</span> BOT NOT RUNING, TRYING TO RELOAD IT...<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L405" class="blob-num js-line-number" data-line-number="405"></td>
        <td id="LC405" class="blob-code blob-code-inner js-file-line">		BAD=<span class="pl-s"><span class="pl-pds">$((</span> <span class="pl-smi">$BAD</span> <span class="pl-k">+</span> <span class="pl-c1">1</span> <span class="pl-pds">))</span></span></td>
      </tr>
      <tr>
        <td id="L406" class="blob-num js-line-number" data-line-number="406"></td>
        <td id="LC406" class="blob-code blob-code-inner js-file-line">		sleep 1</td>
      </tr>
      <tr>
        <td id="L407" class="blob-num js-line-number" data-line-number="407"></td>
        <td id="LC407" class="blob-code blob-code-inner js-file-line">		</td>
      </tr>
      <tr>
        <td id="L408" class="blob-num js-line-number" data-line-number="408"></td>
        <td id="LC408" class="blob-code blob-code-inner js-file-line">		rm ../.telegram-cli/state <span class="pl-k">2&gt;</span>/dev/null</td>
      </tr>
      <tr>
        <td id="L409" class="blob-num js-line-number" data-line-number="409"></td>
        <td id="LC409" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L410" class="blob-num js-line-number" data-line-number="410"></td>
        <td id="LC410" class="blob-code blob-code-inner js-file-line">		<span class="pl-c1">kill</span> <span class="pl-smi">$CLIPID</span></td>
      </tr>
      <tr>
        <td id="L411" class="blob-num js-line-number" data-line-number="411"></td>
        <td id="LC411" class="blob-code blob-code-inner js-file-line">		<span class="pl-c1">kill</span> <span class="pl-smi">$SCREEN</span></td>
      </tr>
      <tr>
        <td id="L412" class="blob-num js-line-number" data-line-number="412"></td>
        <td id="LC412" class="blob-code blob-code-inner js-file-line">		</td>
      </tr>
      <tr>
        <td id="L413" class="blob-num js-line-number" data-line-number="413"></td>
        <td id="LC413" class="blob-code blob-code-inner js-file-line">		screen -d -m bash launch.sh</td>
      </tr>
      <tr>
        <td id="L414" class="blob-num js-line-number" data-line-number="414"></td>
        <td id="LC414" class="blob-code blob-code-inner js-file-line">		sleep 1</td>
      </tr>
      <tr>
        <td id="L415" class="blob-num js-line-number" data-line-number="415"></td>
        <td id="LC415" class="blob-code blob-code-inner js-file-line">		</td>
      </tr>
      <tr>
        <td id="L416" class="blob-num js-line-number" data-line-number="416"></td>
        <td id="LC416" class="blob-code blob-code-inner js-file-line">		CLIPID=<span class="pl-s"><span class="pl-pds">`</span>ps -e <span class="pl-k">|</span> grep telegram-cli <span class="pl-k">|</span> sed <span class="pl-s"><span class="pl-pds">&#39;</span>s/^[[:space:]]*//<span class="pl-pds">&#39;</span></span> <span class="pl-k">|</span> cut -f 1 -d<span class="pl-s"><span class="pl-pds">&quot;</span> <span class="pl-pds">&quot;</span></span><span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L417" class="blob-num js-line-number" data-line-number="417"></td>
        <td id="LC417" class="blob-code blob-code-inner js-file-line">		</td>
      </tr>
      <tr>
        <td id="L418" class="blob-num js-line-number" data-line-number="418"></td>
        <td id="LC418" class="blob-code blob-code-inner js-file-line">		<span class="pl-k">if</span> [ <span class="pl-k">-z</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">${CLIPID}</span><span class="pl-pds">&quot;</span></span> ]<span class="pl-k">;</span> <span class="pl-k">then</span></td>
      </tr>
      <tr>
        <td id="L419" class="blob-num js-line-number" data-line-number="419"></td>
        <td id="LC419" class="blob-code blob-code-inner js-file-line">			<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f1</span> ERROR: TELEGRAM-CLI PROCESS NOT RUNNING<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L420" class="blob-num js-line-number" data-line-number="420"></td>
        <td id="LC420" class="blob-code blob-code-inner js-file-line">			<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f1</span> FAILED TO RECOVER BOT<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L421" class="blob-num js-line-number" data-line-number="421"></td>
        <td id="LC421" class="blob-code blob-code-inner js-file-line">			sleep 1</td>
      </tr>
      <tr>
        <td id="L422" class="blob-num js-line-number" data-line-number="422"></td>
        <td id="LC422" class="blob-code blob-code-inner js-file-line">		<span class="pl-k">fi</span></td>
      </tr>
      <tr>
        <td id="L423" class="blob-num js-line-number" data-line-number="423"></td>
        <td id="LC423" class="blob-code blob-code-inner js-file-line">		</td>
      </tr>
      <tr>
        <td id="L424" class="blob-num js-line-number" data-line-number="424"></td>
        <td id="LC424" class="blob-code blob-code-inner js-file-line">		SCREENNUM=<span class="pl-s"><span class="pl-pds">`</span>ps -e <span class="pl-k">|</span> grep -c screen<span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L425" class="blob-num js-line-number" data-line-number="425"></td>
        <td id="LC425" class="blob-code blob-code-inner js-file-line">		<span class="pl-k">if</span> [ <span class="pl-smi">$SCREENNUM</span> <span class="pl-k">!=</span> 3 ]<span class="pl-k">;</span> <span class="pl-k">then</span></td>
      </tr>
      <tr>
        <td id="L426" class="blob-num js-line-number" data-line-number="426"></td>
        <td id="LC426" class="blob-code blob-code-inner js-file-line">			<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f1</span> ERROR: SCREEN RUNNING: <span class="pl-smi">$SCREENNUM</span> \n SCREEN ESPECTED: 3<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L427" class="blob-num js-line-number" data-line-number="427"></td>
        <td id="LC427" class="blob-code blob-code-inner js-file-line">			<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f1</span> FAILED TO RECOVER BOT<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L428" class="blob-num js-line-number" data-line-number="428"></td>
        <td id="LC428" class="blob-code blob-code-inner js-file-line">			<span class="pl-c1">exit</span> 1</td>
      </tr>
      <tr>
        <td id="L429" class="blob-num js-line-number" data-line-number="429"></td>
        <td id="LC429" class="blob-code blob-code-inner js-file-line">		<span class="pl-k">fi</span></td>
      </tr>
      <tr>
        <td id="L430" class="blob-num js-line-number" data-line-number="430"></td>
        <td id="LC430" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L431" class="blob-num js-line-number" data-line-number="431"></td>
        <td id="LC431" class="blob-code blob-code-inner js-file-line">		SCREEN=<span class="pl-s"><span class="pl-pds">`</span>ps -e <span class="pl-k">|</span> grep -v <span class="pl-smi">$SCREENPID1</span> <span class="pl-k">|</span> grep -v <span class="pl-smi">$SCREENPID2</span> <span class="pl-k">|</span> grep screen <span class="pl-k">|</span> sed <span class="pl-s"><span class="pl-pds">&#39;</span>s/^[[:space:]]*//<span class="pl-pds">&#39;</span></span> <span class="pl-k">|</span> cut -f 1 -d<span class="pl-s"><span class="pl-pds">&quot;</span> <span class="pl-pds">&quot;</span></span><span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L432" class="blob-num js-line-number" data-line-number="432"></td>
        <td id="LC432" class="blob-code blob-code-inner js-file-line">		<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f5</span> BOT HAS BEEN SUCCESFULLY RELOADED!<span class="pl-smi">$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L433" class="blob-num js-line-number" data-line-number="433"></td>
        <td id="LC433" class="blob-code blob-code-inner js-file-line">		<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f2</span> TELEGRAM-CLI NEW PID: <span class="pl-smi">$CLIPID$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L434" class="blob-num js-line-number" data-line-number="434"></td>
        <td id="LC434" class="blob-code blob-code-inner js-file-line">		<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$f2</span> SCREEN NEW PID: <span class="pl-smi">$SCREEN$rst</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L435" class="blob-num js-line-number" data-line-number="435"></td>
        <td id="LC435" class="blob-code blob-code-inner js-file-line">		sleep 3</td>
      </tr>
      <tr>
        <td id="L436" class="blob-num js-line-number" data-line-number="436"></td>
        <td id="LC436" class="blob-code blob-code-inner js-file-line">		</td>
      </tr>
      <tr>
        <td id="L437" class="blob-num js-line-number" data-line-number="437"></td>
        <td id="LC437" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">fi</span></td>
      </tr>
      <tr>
        <td id="L438" class="blob-num js-line-number" data-line-number="438"></td>
        <td id="LC438" class="blob-code blob-code-inner js-file-line">	</td>
      </tr>
      <tr>
        <td id="L439" class="blob-num js-line-number" data-line-number="439"></td>
        <td id="LC439" class="blob-code blob-code-inner js-file-line">	<span class="pl-c"># Clear cache after 10h</span></td>
      </tr>
      <tr>
        <td id="L440" class="blob-num js-line-number" data-line-number="440"></td>
        <td id="LC440" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">if</span> [ <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-smi">$OK</span><span class="pl-pds">&quot;</span></span> <span class="pl-k">==</span> 2400 ]<span class="pl-k">;</span> <span class="pl-k">then</span></td>
      </tr>
      <tr>
        <td id="L441" class="blob-num js-line-number" data-line-number="441"></td>
        <td id="LC441" class="blob-code blob-code-inner js-file-line">		sync</td>
      </tr>
      <tr>
        <td id="L442" class="blob-num js-line-number" data-line-number="442"></td>
        <td id="LC442" class="blob-code blob-code-inner js-file-line">		sudo sh -c <span class="pl-s"><span class="pl-pds">&#39;</span>echo 3 &gt; /proc/sys/vm/drop_caches<span class="pl-pds">&#39;</span></span></td>
      </tr>
      <tr>
        <td id="L443" class="blob-num js-line-number" data-line-number="443"></td>
        <td id="LC443" class="blob-code blob-code-inner js-file-line">	<span class="pl-k">fi</span></td>
      </tr>
      <tr>
        <td id="L444" class="blob-num js-line-number" data-line-number="444"></td>
        <td id="LC444" class="blob-code blob-code-inner js-file-line">	</td>
      </tr>
      <tr>
        <td id="L445" class="blob-num js-line-number" data-line-number="445"></td>
        <td id="LC445" class="blob-code blob-code-inner js-file-line">	VOLUNTARY=<span class="pl-s"><span class="pl-pds">`</span><span class="pl-c1">echo</span> <span class="pl-smi">$VOLUNTARYCHECK</span><span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L446" class="blob-num js-line-number" data-line-number="446"></td>
        <td id="LC446" class="blob-code blob-code-inner js-file-line">	NONVOLUNTARY=<span class="pl-s"><span class="pl-pds">`</span><span class="pl-c1">echo</span> <span class="pl-smi">$NONVOLUNTARYCHECK</span><span class="pl-pds">`</span></span></td>
      </tr>
      <tr>
        <td id="L447" class="blob-num js-line-number" data-line-number="447"></td>
        <td id="LC447" class="blob-code blob-code-inner js-file-line">	sleep <span class="pl-smi">$RELOADTIME</span></td>
      </tr>
      <tr>
        <td id="L448" class="blob-num js-line-number" data-line-number="448"></td>
        <td id="LC448" class="blob-code blob-code-inner js-file-line">	rm CHECK</td>
      </tr>
      <tr>
        <td id="L449" class="blob-num js-line-number" data-line-number="449"></td>
        <td id="LC449" class="blob-code blob-code-inner js-file-line">	</td>
      </tr>
      <tr>
        <td id="L450" class="blob-num js-line-number" data-line-number="450"></td>
        <td id="LC450" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">done</span></td>
      </tr>
      <tr>
        <td id="L451" class="blob-num js-line-number" data-line-number="451"></td>
        <td id="LC451" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L452" class="blob-num js-line-number" data-line-number="452"></td>
        <td id="LC452" class="blob-code blob-code-inner js-file-line">}</td>
      </tr>
      <tr>
        <td id="L453" class="blob-num js-line-number" data-line-number="453"></td>
        <td id="LC453" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L454" class="blob-num js-line-number" data-line-number="454"></td>
        <td id="LC454" class="blob-code blob-code-inner js-file-line"><span class="pl-k">function</span> <span class="pl-en">tmux_detached</span> {</td>
      </tr>
      <tr>
        <td id="L455" class="blob-num js-line-number" data-line-number="455"></td>
        <td id="LC455" class="blob-code blob-code-inner js-file-line">clear</td>
      </tr>
      <tr>
        <td id="L456" class="blob-num js-line-number" data-line-number="456"></td>
        <td id="LC456" class="blob-code blob-code-inner js-file-line">TMUX= tmux new-session -d -s script_detach <span class="pl-s"><span class="pl-pds">&quot;</span>bash steady.sh -t<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L457" class="blob-num js-line-number" data-line-number="457"></td>
        <td id="LC457" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\e[1m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L458" class="blob-num js-line-number" data-line-number="458"></td>
        <td id="LC458" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L459" class="blob-num js-line-number" data-line-number="459"></td>
        <td id="LC459" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>Bot running in the backgroud with TMUX<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L460" class="blob-num js-line-number" data-line-number="460"></td>
        <td id="LC460" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L461" class="blob-num js-line-number" data-line-number="461"></td>
        <td id="LC461" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\e[0m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L462" class="blob-num js-line-number" data-line-number="462"></td>
        <td id="LC462" class="blob-code blob-code-inner js-file-line">sleep 3</td>
      </tr>
      <tr>
        <td id="L463" class="blob-num js-line-number" data-line-number="463"></td>
        <td id="LC463" class="blob-code blob-code-inner js-file-line">tmux kill-session script <span class="pl-k">2&gt;</span>/dev/null</td>
      </tr>
      <tr>
        <td id="L464" class="blob-num js-line-number" data-line-number="464"></td>
        <td id="LC464" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">exit</span> 1</td>
      </tr>
      <tr>
        <td id="L465" class="blob-num js-line-number" data-line-number="465"></td>
        <td id="LC465" class="blob-code blob-code-inner js-file-line">}</td>
      </tr>
      <tr>
        <td id="L466" class="blob-num js-line-number" data-line-number="466"></td>
        <td id="LC466" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L467" class="blob-num js-line-number" data-line-number="467"></td>
        <td id="LC467" class="blob-code blob-code-inner js-file-line"><span class="pl-k">function</span> <span class="pl-en">screen_detached</span> {</td>
      </tr>
      <tr>
        <td id="L468" class="blob-num js-line-number" data-line-number="468"></td>
        <td id="LC468" class="blob-code blob-code-inner js-file-line">clear</td>
      </tr>
      <tr>
        <td id="L469" class="blob-num js-line-number" data-line-number="469"></td>
        <td id="LC469" class="blob-code blob-code-inner js-file-line">screen -d -m bash launch.sh</td>
      </tr>
      <tr>
        <td id="L470" class="blob-num js-line-number" data-line-number="470"></td>
        <td id="LC470" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\e[1m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L471" class="blob-num js-line-number" data-line-number="471"></td>
        <td id="LC471" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L472" class="blob-num js-line-number" data-line-number="472"></td>
        <td id="LC472" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>Bot running in the backgroud with SCREEN<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L473" class="blob-num js-line-number" data-line-number="473"></td>
        <td id="LC473" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L474" class="blob-num js-line-number" data-line-number="474"></td>
        <td id="LC474" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\e[0m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L475" class="blob-num js-line-number" data-line-number="475"></td>
        <td id="LC475" class="blob-code blob-code-inner js-file-line">sleep 3</td>
      </tr>
      <tr>
        <td id="L476" class="blob-num js-line-number" data-line-number="476"></td>
        <td id="LC476" class="blob-code blob-code-inner js-file-line">quit</td>
      </tr>
      <tr>
        <td id="L477" class="blob-num js-line-number" data-line-number="477"></td>
        <td id="LC477" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">exit</span> 1</td>
      </tr>
      <tr>
        <td id="L478" class="blob-num js-line-number" data-line-number="478"></td>
        <td id="LC478" class="blob-code blob-code-inner js-file-line">}</td>
      </tr>
      <tr>
        <td id="L479" class="blob-num js-line-number" data-line-number="479"></td>
        <td id="LC479" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L480" class="blob-num js-line-number" data-line-number="480"></td>
        <td id="LC480" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L481" class="blob-num js-line-number" data-line-number="481"></td>
        <td id="LC481" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L482" class="blob-num js-line-number" data-line-number="482"></td>
        <td id="LC482" class="blob-code blob-code-inner js-file-line"><span class="pl-k">if</span> [ <span class="pl-smi">$#</span> <span class="pl-k">-eq</span> 0 ]</td>
      </tr>
      <tr>
        <td id="L483" class="blob-num js-line-number" data-line-number="483"></td>
        <td id="LC483" class="blob-code blob-code-inner js-file-line"><span class="pl-k">then</span></td>
      </tr>
      <tr>
        <td id="L484" class="blob-num js-line-number" data-line-number="484"></td>
        <td id="LC484" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\e[1m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L485" class="blob-num js-line-number" data-line-number="485"></td>
        <td id="LC485" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L486" class="blob-num js-line-number" data-line-number="486"></td>
        <td id="LC486" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>Missing options!<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L487" class="blob-num js-line-number" data-line-number="487"></td>
        <td id="LC487" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>Run: bash steady.sh -h  for help!<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L488" class="blob-num js-line-number" data-line-number="488"></td>
        <td id="LC488" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L489" class="blob-num js-line-number" data-line-number="489"></td>
        <td id="LC489" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\e[0m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L490" class="blob-num js-line-number" data-line-number="490"></td>
        <td id="LC490" class="blob-code blob-code-inner js-file-line">    sleep 1</td>
      </tr>
      <tr>
        <td id="L491" class="blob-num js-line-number" data-line-number="491"></td>
        <td id="LC491" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">exit</span> 1</td>
      </tr>
      <tr>
        <td id="L492" class="blob-num js-line-number" data-line-number="492"></td>
        <td id="LC492" class="blob-code blob-code-inner js-file-line"><span class="pl-k">fi</span></td>
      </tr>
      <tr>
        <td id="L493" class="blob-num js-line-number" data-line-number="493"></td>
        <td id="LC493" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L494" class="blob-num js-line-number" data-line-number="494"></td>
        <td id="LC494" class="blob-code blob-code-inner js-file-line"><span class="pl-k">while</span> <span class="pl-c1">getopts</span> <span class="pl-s"><span class="pl-pds">&quot;</span>:tsTSih<span class="pl-pds">&quot;</span></span> opt<span class="pl-k">;</span> <span class="pl-k">do</span></td>
      </tr>
      <tr>
        <td id="L495" class="blob-num js-line-number" data-line-number="495"></td>
        <td id="LC495" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">case</span> <span class="pl-smi">$opt</span> in</td>
      </tr>
      <tr>
        <td id="L496" class="blob-num js-line-number" data-line-number="496"></td>
        <td id="LC496" class="blob-code blob-code-inner js-file-line">    t)</td>
      </tr>
      <tr>
        <td id="L497" class="blob-num js-line-number" data-line-number="497"></td>
        <td id="LC497" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\e[1m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L498" class="blob-num js-line-number" data-line-number="498"></td>
        <td id="LC498" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L499" class="blob-num js-line-number" data-line-number="499"></td>
        <td id="LC499" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>TMUX multiplexer option has been triggered.<span class="pl-pds">&quot;</span></span> <span class="pl-k">&gt;&amp;2</span></td>
      </tr>
      <tr>
        <td id="L500" class="blob-num js-line-number" data-line-number="500"></td>
        <td id="LC500" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>Starting script...<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L501" class="blob-num js-line-number" data-line-number="501"></td>
        <td id="LC501" class="blob-code blob-code-inner js-file-line">	sleep 1.5</td>
      </tr>
      <tr>
        <td id="L502" class="blob-num js-line-number" data-line-number="502"></td>
        <td id="LC502" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\e[0m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L503" class="blob-num js-line-number" data-line-number="503"></td>
        <td id="LC503" class="blob-code blob-code-inner js-file-line">	tmux_mode</td>
      </tr>
      <tr>
        <td id="L504" class="blob-num js-line-number" data-line-number="504"></td>
        <td id="LC504" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">exit</span> 1</td>
      </tr>
      <tr>
        <td id="L505" class="blob-num js-line-number" data-line-number="505"></td>
        <td id="LC505" class="blob-code blob-code-inner js-file-line">      ;;</td>
      </tr>
      <tr>
        <td id="L506" class="blob-num js-line-number" data-line-number="506"></td>
        <td id="LC506" class="blob-code blob-code-inner js-file-line">	s)</td>
      </tr>
      <tr>
        <td id="L507" class="blob-num js-line-number" data-line-number="507"></td>
        <td id="LC507" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\e[1m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L508" class="blob-num js-line-number" data-line-number="508"></td>
        <td id="LC508" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L509" class="blob-num js-line-number" data-line-number="509"></td>
        <td id="LC509" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>SCREEN multiplexer option has been triggered.<span class="pl-pds">&quot;</span></span> <span class="pl-k">&gt;&amp;2</span></td>
      </tr>
      <tr>
        <td id="L510" class="blob-num js-line-number" data-line-number="510"></td>
        <td id="LC510" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>Starting script...<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L511" class="blob-num js-line-number" data-line-number="511"></td>
        <td id="LC511" class="blob-code blob-code-inner js-file-line">	sleep 1.5</td>
      </tr>
      <tr>
        <td id="L512" class="blob-num js-line-number" data-line-number="512"></td>
        <td id="LC512" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\e[0m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L513" class="blob-num js-line-number" data-line-number="513"></td>
        <td id="LC513" class="blob-code blob-code-inner js-file-line">	screen_mode</td>
      </tr>
      <tr>
        <td id="L514" class="blob-num js-line-number" data-line-number="514"></td>
        <td id="LC514" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">exit</span> 1</td>
      </tr>
      <tr>
        <td id="L515" class="blob-num js-line-number" data-line-number="515"></td>
        <td id="LC515" class="blob-code blob-code-inner js-file-line">      ;;</td>
      </tr>
      <tr>
        <td id="L516" class="blob-num js-line-number" data-line-number="516"></td>
        <td id="LC516" class="blob-code blob-code-inner js-file-line">    T)</td>
      </tr>
      <tr>
        <td id="L517" class="blob-num js-line-number" data-line-number="517"></td>
        <td id="LC517" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\e[1m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L518" class="blob-num js-line-number" data-line-number="518"></td>
        <td id="LC518" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L519" class="blob-num js-line-number" data-line-number="519"></td>
        <td id="LC519" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>TMUX multiplexer option has been triggered.<span class="pl-pds">&quot;</span></span> <span class="pl-k">&gt;&amp;2</span></td>
      </tr>
      <tr>
        <td id="L520" class="blob-num js-line-number" data-line-number="520"></td>
        <td id="LC520" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>Starting script...<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L521" class="blob-num js-line-number" data-line-number="521"></td>
        <td id="LC521" class="blob-code blob-code-inner js-file-line">	sleep 1.5</td>
      </tr>
      <tr>
        <td id="L522" class="blob-num js-line-number" data-line-number="522"></td>
        <td id="LC522" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\e[0m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L523" class="blob-num js-line-number" data-line-number="523"></td>
        <td id="LC523" class="blob-code blob-code-inner js-file-line">	tmux_detached</td>
      </tr>
      <tr>
        <td id="L524" class="blob-num js-line-number" data-line-number="524"></td>
        <td id="LC524" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">exit</span> 1</td>
      </tr>
      <tr>
        <td id="L525" class="blob-num js-line-number" data-line-number="525"></td>
        <td id="LC525" class="blob-code blob-code-inner js-file-line">      ;;</td>
      </tr>
      <tr>
        <td id="L526" class="blob-num js-line-number" data-line-number="526"></td>
        <td id="LC526" class="blob-code blob-code-inner js-file-line">	S)</td>
      </tr>
      <tr>
        <td id="L527" class="blob-num js-line-number" data-line-number="527"></td>
        <td id="LC527" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\e[1m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L528" class="blob-num js-line-number" data-line-number="528"></td>
        <td id="LC528" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L529" class="blob-num js-line-number" data-line-number="529"></td>
        <td id="LC529" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>SCREEN multiplexer option has been triggered.<span class="pl-pds">&quot;</span></span> <span class="pl-k">&gt;&amp;2</span></td>
      </tr>
      <tr>
        <td id="L530" class="blob-num js-line-number" data-line-number="530"></td>
        <td id="LC530" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>Starting script...<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L531" class="blob-num js-line-number" data-line-number="531"></td>
        <td id="LC531" class="blob-code blob-code-inner js-file-line">	sleep 1.5</td>
      </tr>
      <tr>
        <td id="L532" class="blob-num js-line-number" data-line-number="532"></td>
        <td id="LC532" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\e[0m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L533" class="blob-num js-line-number" data-line-number="533"></td>
        <td id="LC533" class="blob-code blob-code-inner js-file-line">	screen_detached</td>
      </tr>
      <tr>
        <td id="L534" class="blob-num js-line-number" data-line-number="534"></td>
        <td id="LC534" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">exit</span> 1</td>
      </tr>
      <tr>
        <td id="L535" class="blob-num js-line-number" data-line-number="535"></td>
        <td id="LC535" class="blob-code blob-code-inner js-file-line">      ;;</td>
      </tr>
      <tr>
        <td id="L536" class="blob-num js-line-number" data-line-number="536"></td>
        <td id="LC536" class="blob-code blob-code-inner js-file-line">	i)</td>
      </tr>
      <tr>
        <td id="L537" class="blob-num js-line-number" data-line-number="537"></td>
        <td id="LC537" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\e[1m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L538" class="blob-num js-line-number" data-line-number="538"></td>
        <td id="LC538" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L539" class="blob-num js-line-number" data-line-number="539"></td>
        <td id="LC539" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>steady.sh bash script v1.2 iicc 2016 DBTeam<span class="pl-pds">&quot;</span></span> <span class="pl-k">&gt;&amp;2</span></td>
      </tr>
      <tr>
        <td id="L540" class="blob-num js-line-number" data-line-number="540"></td>
        <td id="LC540" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L541" class="blob-num js-line-number" data-line-number="541"></td>
        <td id="LC541" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\e[0m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L542" class="blob-num js-line-number" data-line-number="542"></td>
        <td id="LC542" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\033[38;5;208m      ____  ____ _____                        \033[0;00m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L543" class="blob-num js-line-number" data-line-number="543"></td>
        <td id="LC543" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\033[38;5;208m     |    \|  _ )_   _|___ ____   __  __      \033[0;00m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L544" class="blob-num js-line-number" data-line-number="544"></td>
        <td id="LC544" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\033[38;5;208m     | |_  )  _ \ | |/ .__|  _ \_|  \/  |     \033[0;00m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L545" class="blob-num js-line-number" data-line-number="545"></td>
        <td id="LC545" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\033[38;5;208m     |____/|____/ |_|\____/\_____|_/\/\_|     \033[0;00m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L546" class="blob-num js-line-number" data-line-number="546"></td>
        <td id="LC546" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\033[38;5;208m                                              \033[0;00m<span class="pl-pds">&quot;</span></span>	</td>
      </tr>
      <tr>
        <td id="L547" class="blob-num js-line-number" data-line-number="547"></td>
        <td id="LC547" class="blob-code blob-code-inner js-file-line"><span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L548" class="blob-num js-line-number" data-line-number="548"></td>
        <td id="LC548" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">exit</span> 1</td>
      </tr>
      <tr>
        <td id="L549" class="blob-num js-line-number" data-line-number="549"></td>
        <td id="LC549" class="blob-code blob-code-inner js-file-line">      ;;</td>
      </tr>
      <tr>
        <td id="L550" class="blob-num js-line-number" data-line-number="550"></td>
        <td id="LC550" class="blob-code blob-code-inner js-file-line">	h)</td>
      </tr>
      <tr>
        <td id="L551" class="blob-num js-line-number" data-line-number="551"></td>
        <td id="LC551" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\e[1m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L552" class="blob-num js-line-number" data-line-number="552"></td>
        <td id="LC552" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L553" class="blob-num js-line-number" data-line-number="553"></td>
        <td id="LC553" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>Usage:<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L554" class="blob-num js-line-number" data-line-number="554"></td>
        <td id="LC554" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L555" class="blob-num js-line-number" data-line-number="555"></td>
        <td id="LC555" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>steady.sh -t<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L556" class="blob-num js-line-number" data-line-number="556"></td>
        <td id="LC556" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>steady.sh -s<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L557" class="blob-num js-line-number" data-line-number="557"></td>
        <td id="LC557" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>steady.sh -T<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L558" class="blob-num js-line-number" data-line-number="558"></td>
        <td id="LC558" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>steady.sh -S<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L559" class="blob-num js-line-number" data-line-number="559"></td>
        <td id="LC559" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>steady.sh -h<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L560" class="blob-num js-line-number" data-line-number="560"></td>
        <td id="LC560" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>steady.sh -i<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L561" class="blob-num js-line-number" data-line-number="561"></td>
        <td id="LC561" class="blob-code blob-code-inner js-file-line">    <span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L562" class="blob-num js-line-number" data-line-number="562"></td>
        <td id="LC562" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>Options:<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L563" class="blob-num js-line-number" data-line-number="563"></td>
        <td id="LC563" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L564" class="blob-num js-line-number" data-line-number="564"></td>
        <td id="LC564" class="blob-code blob-code-inner js-file-line">    <span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>   -t     select TMUX terminal multiplexer<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L565" class="blob-num js-line-number" data-line-number="565"></td>
        <td id="LC565" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>   -s     select SCREEN terminal multiplexer<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L566" class="blob-num js-line-number" data-line-number="566"></td>
        <td id="LC566" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>   -T     select TMUX and detach session after start<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L567" class="blob-num js-line-number" data-line-number="567"></td>
        <td id="LC567" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>   -S     select SCREEN and detach session after start<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L568" class="blob-num js-line-number" data-line-number="568"></td>
        <td id="LC568" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>   -h     script options help page<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L569" class="blob-num js-line-number" data-line-number="569"></td>
        <td id="LC569" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>   -i     information about the script<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L570" class="blob-num js-line-number" data-line-number="570"></td>
        <td id="LC570" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\e[0m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L571" class="blob-num js-line-number" data-line-number="571"></td>
        <td id="LC571" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">exit</span> 1</td>
      </tr>
      <tr>
        <td id="L572" class="blob-num js-line-number" data-line-number="572"></td>
        <td id="LC572" class="blob-code blob-code-inner js-file-line">	;;</td>
      </tr>
      <tr>
        <td id="L573" class="blob-num js-line-number" data-line-number="573"></td>
        <td id="LC573" class="blob-code blob-code-inner js-file-line">	  </td>
      </tr>
      <tr>
        <td id="L574" class="blob-num js-line-number" data-line-number="574"></td>
        <td id="LC574" class="blob-code blob-code-inner js-file-line">    <span class="pl-cce">\?</span>)</td>
      </tr>
      <tr>
        <td id="L575" class="blob-num js-line-number" data-line-number="575"></td>
        <td id="LC575" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\e[1m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L576" class="blob-num js-line-number" data-line-number="576"></td>
        <td id="LC576" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span><span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L577" class="blob-num js-line-number" data-line-number="577"></td>
        <td id="LC577" class="blob-code blob-code-inner js-file-line">    <span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>Invalid option: -<span class="pl-smi">$OPTARG</span><span class="pl-pds">&quot;</span></span> <span class="pl-k">&gt;&amp;2</span></td>
      </tr>
      <tr>
        <td id="L578" class="blob-num js-line-number" data-line-number="578"></td>
        <td id="LC578" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>Run bash <span class="pl-smi">$0</span> -h for help<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L579" class="blob-num js-line-number" data-line-number="579"></td>
        <td id="LC579" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">echo</span> -e <span class="pl-s"><span class="pl-pds">&quot;</span>\e[0m<span class="pl-pds">&quot;</span></span></td>
      </tr>
      <tr>
        <td id="L580" class="blob-num js-line-number" data-line-number="580"></td>
        <td id="LC580" class="blob-code blob-code-inner js-file-line">	<span class="pl-c1">exit</span> 1</td>
      </tr>
      <tr>
        <td id="L581" class="blob-num js-line-number" data-line-number="581"></td>
        <td id="LC581" class="blob-code blob-code-inner js-file-line">      ;;</td>
      </tr>
      <tr>
        <td id="L582" class="blob-num js-line-number" data-line-number="582"></td>
        <td id="LC582" class="blob-code blob-code-inner js-file-line">    :)</td>
      </tr>
      <tr>
        <td id="L583" class="blob-num js-line-number" data-line-number="583"></td>
        <td id="LC583" class="blob-code blob-code-inner js-file-line">      <span class="pl-c1">echo</span> <span class="pl-s"><span class="pl-pds">&quot;</span>Option -<span class="pl-smi">$OPTARG</span> requires an argument.<span class="pl-pds">&quot;</span></span> <span class="pl-k">&gt;&amp;2</span></td>
      </tr>
      <tr>
        <td id="L584" class="blob-num js-line-number" data-line-number="584"></td>
        <td id="LC584" class="blob-code blob-code-inner js-file-line">      <span class="pl-c1">exit</span> 1</td>
      </tr>
      <tr>
        <td id="L585" class="blob-num js-line-number" data-line-number="585"></td>
        <td id="LC585" class="blob-code blob-code-inner js-file-line">      ;;</td>
      </tr>
      <tr>
        <td id="L586" class="blob-num js-line-number" data-line-number="586"></td>
        <td id="LC586" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">esac</span></td>
      </tr>
      <tr>
        <td id="L587" class="blob-num js-line-number" data-line-number="587"></td>
        <td id="LC587" class="blob-code blob-code-inner js-file-line"><span class="pl-k">done</span></td>
      </tr>
</table>

  </div>

</div>

<button type="button" data-facebox="#jump-to-line" data-facebox-class="linejump" data-hotkey="l" class="hidden">Jump to Line</button>
<div id="jump-to-line" style="display:none">
  <!-- </textarea> --><!-- '"` --><form accept-charset="UTF-8" action="" class="js-jump-to-line-form" method="get"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div>
    <input class="form-control linejump-input js-jump-to-line-field" type="text" placeholder="Jump to line&hellip;" aria-label="Jump to line" autofocus>
    <button type="submit" class="btn">Go</button>
</form></div>

  </div>
  <div class="modal-backdrop"></div>
</div>


    </div>
  </div>

    </div>

        <div class="container site-footer-container">
  <div class="site-footer" role="contentinfo">
    <ul class="site-footer-links right">
        <li><a href="https://status.github.com/" data-ga-click="Footer, go to status, text:status">Status</a></li>
      <li><a href="https://developer.github.com" data-ga-click="Footer, go to api, text:api">API</a></li>
      <li><a href="https://training.github.com" data-ga-click="Footer, go to training, text:training">Training</a></li>
      <li><a href="https://shop.github.com" data-ga-click="Footer, go to shop, text:shop">Shop</a></li>
        <li><a href="https://github.com/blog" data-ga-click="Footer, go to blog, text:blog">Blog</a></li>
        <li><a href="https://github.com/about" data-ga-click="Footer, go to about, text:about">About</a></li>

    </ul>

    <a href="https://github.com" aria-label="Homepage" class="site-footer-mark" title="GitHub">
      <svg aria-hidden="true" class="octicon octicon-mark-github" height="24" version="1.1" viewBox="0 0 16 16" width="24"><path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59 0.4 0.07 0.55-0.17 0.55-0.38 0-0.19-0.01-0.82-0.01-1.49-2.01 0.37-2.53-0.49-2.69-0.94-0.09-0.23-0.48-0.94-0.82-1.13-0.28-0.15-0.68-0.52-0.01-0.53 0.63-0.01 1.08 0.58 1.23 0.82 0.72 1.21 1.87 0.87 2.33 0.66 0.07-0.52 0.28-0.87 0.51-1.07-1.78-0.2-3.64-0.89-3.64-3.95 0-0.87 0.31-1.59 0.82-2.15-0.08-0.2-0.36-1.02 0.08-2.12 0 0 0.67-0.21 2.2 0.82 0.64-0.18 1.32-0.27 2-0.27 0.68 0 1.36 0.09 2 0.27 1.53-1.04 2.2-0.82 2.2-0.82 0.44 1.1 0.16 1.92 0.08 2.12 0.51 0.56 0.82 1.27 0.82 2.15 0 3.07-1.87 3.75-3.65 3.95 0.29 0.25 0.54 0.73 0.54 1.48 0 1.07-0.01 1.93-0.01 2.2 0 0.21 0.15 0.46 0.55 0.38C13.71 14.53 16 11.53 16 8 16 3.58 12.42 0 8 0z"></path></svg>
</a>
    <ul class="site-footer-links">
      <li>&copy; 2016 <span title="0.07824s from github-fe118-cp1-prd.iad.github.net">GitHub</span>, Inc.</li>
        <li><a href="https://github.com/site/terms" data-ga-click="Footer, go to terms, text:terms">Terms</a></li>
        <li><a href="https://github.com/site/privacy" data-ga-click="Footer, go to privacy, text:privacy">Privacy</a></li>
        <li><a href="https://github.com/security" data-ga-click="Footer, go to security, text:security">Security</a></li>
        <li><a href="https://github.com/contact" data-ga-click="Footer, go to contact, text:contact">Contact</a></li>
        <li><a href="https://help.github.com" data-ga-click="Footer, go to help, text:help">Help</a></li>
    </ul>
  </div>
</div>



    
    

    <div id="ajax-error-message" class="ajax-error-message flash flash-error">
      <svg aria-hidden="true" class="octicon octicon-alert" height="16" version="1.1" viewBox="0 0 16 16" width="16"><path d="M15.72 12.5l-6.85-11.98C8.69 0.21 8.36 0.02 8 0.02s-0.69 0.19-0.87 0.5l-6.85 11.98c-0.18 0.31-0.18 0.69 0 1C0.47 13.81 0.8 14 1.15 14h13.7c0.36 0 0.69-0.19 0.86-0.5S15.89 12.81 15.72 12.5zM9 12H7V10h2V12zM9 9H7V5h2V9z"></path></svg>
      <button type="button" class="flash-close js-flash-close js-ajax-error-dismiss" aria-label="Dismiss error">
        <svg aria-hidden="true" class="octicon octicon-x" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path d="M7.48 8l3.75 3.75-1.48 1.48-3.75-3.75-3.75 3.75-1.48-1.48 3.75-3.75L0.77 4.25l1.48-1.48 3.75 3.75 3.75-3.75 1.48 1.48-3.75 3.75z"></path></svg>
      </button>
      Something went wrong with that request. Please try again.
    </div>


      <script crossorigin="anonymous" src="https://assets-cdn.github.com/assets/compat-7db58f8b7b91111107fac755dd8b178fe7db0f209ced51fc339c446ad3f8da2b.js"></script>
      <script crossorigin="anonymous" src="https://assets-cdn.github.com/assets/frameworks-e2eca2df0042931f550f59831b5d492c5c279682797c3131a99cd43c3f0917d3.js"></script>
      <script async="async" crossorigin="anonymous" src="https://assets-cdn.github.com/assets/github-2e43b33c8410732a627bbaf05757eb3584ec9cf7a8747f46ccd2336a28223f60.js"></script>
      
      
      
      
      
      
    <div class="js-stale-session-flash stale-session-flash flash flash-warn flash-banner hidden">
      <svg aria-hidden="true" class="octicon octicon-alert" height="16" version="1.1" viewBox="0 0 16 16" width="16"><path d="M15.72 12.5l-6.85-11.98C8.69 0.21 8.36 0.02 8 0.02s-0.69 0.19-0.87 0.5l-6.85 11.98c-0.18 0.31-0.18 0.69 0 1C0.47 13.81 0.8 14 1.15 14h13.7c0.36 0 0.69-0.19 0.86-0.5S15.89 12.81 15.72 12.5zM9 12H7V10h2V12zM9 9H7V5h2V9z"></path></svg>
      <span class="signed-in-tab-flash">You signed in with another tab or window. <a href="">Reload</a> to refresh your session.</span>
      <span class="signed-out-tab-flash">You signed out in another tab or window. <a href="">Reload</a> to refresh your session.</span>
    </div>
    <div class="facebox" id="facebox" style="display:none;">
  <div class="facebox-popup">
    <div class="facebox-content" role="dialog" aria-labelledby="facebox-header" aria-describedby="facebox-description">
    </div>
    <button type="button" class="facebox-close js-facebox-close" aria-label="Close modal">
      <svg aria-hidden="true" class="octicon octicon-x" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path d="M7.48 8l3.75 3.75-1.48 1.48-3.75-3.75-3.75 3.75-1.48-1.48 3.75-3.75L0.77 4.25l1.48-1.48 3.75 3.75 3.75-3.75 1.48 1.48-3.75 3.75z"></path></svg>
    </button>
  </div>
</div>

  </body>
</html>

