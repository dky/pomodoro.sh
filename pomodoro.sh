#!/bin/bash
#
# A Pomodoro timer - Because productivity...

# Use coreutils gdate on OSX, go away BSD date...
DATE_CMD=gdate

RED='\033[0;31m'
GREEN='\033[1;32m'
YELLOW='\033[01;33m'
CYAN='\033[01;36m'

NC='\033[0m' # No Color

notify() {
	notification=$1
	duration=$2
	osa_script=/usr/bin/osascript
	afplay_script=/usr/bin/afplay

	if [ "$notification"  == "pomodoro_complete" ]; then
		notification_message="${YELLOW}$duration${NC} minute 🍅 ${RED}Pomodoro${NC} done! 👍 Time to take a quick ${YELLOW}5${NC} min break and log progress.";
		$osa_script -e 'display notification "Time to take a quick break" with title "🍅 Pomodoro Complete"';
		$afplay_script media/train-alert-on.mp3
	elif [ "$notification" == "short_break_complete" ]; then
		notification_message="${YELLOW}$duration${NC} minute 🛌 break done! Ready for another one?";
		$osa_script -e 'display notification "Time to get back to work" with title "Lets complete another Pomodoro!"';
		$afplay_script media/train-alert-off.mp3
	else {
		notification_message="15 minute break done!";
	}
	fi

	printf "$notification_message\n\n";
}

count_down() {
	seconds=$1
	#echo "seconds_to_count: $seconds, epoc_now: $($DATE_CMD +%s), Now - Seconds = $(expr $seconds - $($DATE_CMD +%s))"
	echo -ne "$($DATE_CMD -u -j -f %s $(($seconds - $($DATE_CMD +%s))) +%H:%M:%S)\r";
}

log_work() {
	work_date=`$DATE_CMD +%Y-%m-%dT%H:%M:%SZ`
	task="$1"
	duration=$2
	count=$3

	# Individual Log date
	daily_log_date=`$DATE_CMD -I`
	# Where to store daily logs
	log_dir=./log
	work_log=./$log_dir/$daily_log_date-pomodoro.log

	# Check if there's a log dir
	if [ ! -d "$log_dir" ]; then
		mkdir -p $log_dir
	fi
	# Check if there's a daily log file
	if [[ ! -e $work_log ]]; then
		touch $work_log
	fi

	# Log it
	echo "$work_date,$task,$duration,$count" >> $work_log;
}


main () {
	pomodoro_name="${1:-codebreakers}";
	pomodoro_seconds=${2:-25}*60; # work seconds, default is 25 mins.
	#pomodoro_seconds=3 # 3 seconds for testing.
	break_seconds=${3:-pomodoro_seconds/300}*60; # pause/break seconds, default is 5 mins
	#break_seconds=3 # 3 seconds for testing.
	# Log the break type as long or short, useful for log analysis
	break_type=short-break
	# How many pomodoros done this session, resets to zero at 4.
	pomodoro_count=0

	while true; do
		pomodoro_seconds_epoch=$((`$DATE_CMD +%s` + $pomodoro_seconds));
		pomodoro_duration=$((pomodoro_seconds / 60));

		printf "Currently working on: ${CYAN}$pomodoro_name${NC}. ${RED}Pomodoros${NC} completed for ${CYAN}$pomodoro_name${NC}: ${YELLOW}$pomodoro_count${NC} 🍅 this session\n\n"

		count_down() {
			count_seconds=$1
			count_message=$2
			date_count_down=$($DATE_CMD -u --date @$(($count_seconds - `$DATE_CMD +%s` )) +%H:%M:%S)

			if [ "$count_message"  == "pomodoro" ]; then
				echo -ne "Time left in 🍅 ${RED}Pomodoro${NC}: ${GREEN}$date_count_down\r${NC}"
			elif [ "$count_message" == "break" ]; then
				echo -ne "Time left in Break 🛌: ${GREEN}$date_count_down\r${NC}";
			fi

		}

	while [ "$pomodoro_seconds_epoch" -ge `$DATE_CMD +%s` ]; do
		count_down $pomodoro_seconds_epoch pomodoro &
		afplay -v 0.1 media/tick.mp3
		sleep 0.3
	done

	pomodoro_count=$((pomodoro_count+1))

	if [ $pomodoro_count -eq 4 ];then
		break_seconds=1800 # 30 mins
		#break_seconds=10 # 10 seconds for testing...
		pomodoro_count=0
		break_type=long-break

		printf "🚀🚀🚀 Awesome Job! 🚀🚀🚀 You just completed: 🍅 ${YELLOW}4${NC} ${RED}pomodoros${NC} for ${CYAN}$pomodoro_name${NC}\n";
		printf "Time for a well deserved ${YELLOW}30${NC} min break!\n";
		printf "Whatever you do, don't 👀 stare at the screen for ${YELLOW}30${NC} mins!\n";
		printf "Resetting 🍅 ${RED}Pomodoro${NC} counts for ${CYAN}$pomodoro_name${NC}, let's do another ${YELLOW}4${NC} 🍅 after this break!\n";
	else
		notify pomodoro_complete $pomodoro_duration;
	fi

	read -n1 -rsp $'Press \e[36many key\e[0m to take a \e[35mbreak 🛌\e[0m or \e[36mCtrl+C\e[0m to exit...\n\n';
	log_work $pomodoro_name $pomodoro_duration $pomodoro_count;

	break_seconds_epoch=$((`$DATE_CMD +%s` + $break_seconds));
	break_duration=$((break_seconds / 60));

	while [ "$break_seconds_epoch" -ge `$DATE_CMD +%s` ]; do
		count_down $break_seconds_epoch break
		sleep 1
	done

	notify short_break_complete $break_duration;
	read -n1 -rsp $'Press \e[36many key\e[0m to \e[35mstart another\e[0m 🍅 \e[31mPomodoro\e[0m or \e[36mCtrl+C\e[0m to exit...\n\n';
	log_work $break_type $break_duration 1;
done
}

main $1 $2 $3
