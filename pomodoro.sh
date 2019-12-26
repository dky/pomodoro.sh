#!/bin/bash
#
# A Pomodoro timer - Because productivity...

DATE_CMD=gdate

notify() {
	notification=$1
	duration=$2

	if [ "$notification"  == "pomodoro_complete" ]; then
		notification_message="$duration minute Pomodoro done! Time to take a quick break and log progress."
		osascript -e 'display notification "Time to take a quick break" with title "Pomodoro Complete"';
		say -v kyoko "やった"
	elif [ "$notification" == "short_break_complete" ]; then
		notification_message="$duration minute break done! Let's get ready to crush another one!"
		osascript -e 'display notification "Time to get back to work" with title "Lets do another one!"';
	else {
		notification_message="15 minute break done!"
	}
	fi

	printf "$notification_message\n\n"
}

count_down() {
	seconds=$1
	#echo "seconds_to_count: $seconds, epoc_now: $($DATE_CMD +%s), Now - Seconds = $(expr $seconds - $($DATE_CMD +%s))"
	echo -ne "$($DATE_CMD -u -j -f %s $(($seconds - $($DATE_CMD +%s))) +%H:%M:%S)\r";
}

log_work() {
	work_log=./pomodoro.log

	work_date=`$DATE_CMD +%Y-%m-%dT%H:%M:%SZ`
	task="$1"
	duration=$2
	count=$3

	if [[ ! -e $work_log ]]; then
		touch $work_log
	fi

	echo "$work_date,$task,$duration,$count" >> $work_log

}


main () {
	pomodoro_name="${1:-codebreakers}";
	#wseconds=${2:-25}*60; # work seconds, default is 25 mins.
	wseconds=3
	#pseconds=${3:-wseconds/300}*60; # pause/break seconds, default is 5 mins
	pseconds=3

	# Log the break type as long or short, useful for log analysis
	break_type=short
	# How many Pomodoro's done this session, resets to zero at 4.
	pomodoro_count=0

	while true; do
		wseconds_epoch=$((`$DATE_CMD +%s` + $wseconds));
		pomodoro_duration=$((wseconds / 60));

		printf "Pomodoro we are currently working on: $pomodoro_name, Pomodoros completed for $pomodoro_name: $pomodoro_count this session\n\n"

		while [ "$wseconds_epoch" -ge `$DATE_CMD +%s` ]; do
			echo -ne "Time left in this Pomodoro: $($DATE_CMD -u --date @$(($wseconds_epoch - `$DATE_CMD +%s` )) +%H:%M:%S)\r";
		done

		pomodoro_count=$((pomodoro_count+1))

		if [ $pomodoro_count -eq 4 ];then
			printf "Awesome Job! You just completed: 4 pomodoros for $pomodoro_name, time for a well deserved long break!\n"
			printf "Whatever you do, don't stare at the screen for 30 mins!\n"
			pseconds=10

			printf "Resetting Pomodoro counts for $pomodoro_name, let's do another 4!\n"
			pomodoro_count=0
			break_type=long
		fi

		notify pomodoro_complete $pomodoro_duration;
		read -n1 -rsp $'Press any key to take a break or Ctrl+C to exit...\n';
		log_work $pomodoro_name $pomodoro_duration $pomodoro_count;

		pseconds_epoch=$((`$DATE_CMD +%s` + $pseconds));
		break_duration=$((pseconds / 60));

		while [ "$pseconds_epoch" -gt `$DATE_CMD +%s` ]; do
			echo -ne "Break remaining: $($DATE_CMD -u --date @$(($pseconds_epoch - `$DATE_CMD +%s` )) +%H:%M:%S)\r";
		done

		notify short_break_complete $break_duration;
		read -n1 -rsp $'Press any key to start another Pomodoro or Ctrl+C to exit...\n';
		log_work $break_type $break_duration 1;
	done
}

main $1 $2 $3
