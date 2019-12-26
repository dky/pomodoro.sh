#!/bin/bash
#
# A Pomodoro timer - Because productivity...

DATE_CMD=gdate

notify() {
	notification=$1
	duration=$2

	if [ "$notification"  == "pomodoro_complete" ]; then
		notification_message="$duration minute Pomodoro done, Time to take a quick break!"
		osascript -e 'display notification "Time to take a quick break" with title "Pomodoro Complete"';
		say -v kyoko "休憩時間"
	elif [ "$notification" == "short_break_complete" ]; then
		notification_message="$duration minute break done!"
		osascript -e 'display notification "Time to get back to work" with title "Lets do another one!"';
	else {
		notification_message="15 minute break done!"
	}
	fi

	echo $notification_message
}

count_down() {
	seconds=$1
	#echo "seconds_to_count: $seconds, epoc_now: $($DATE_CMD +%s), Now - Seconds = $(expr $seconds - $($DATE_CMD +%s))"
	echo -ne "$($DATE_CMD -u -j -f %s $(($seconds - $($DATE_CMD +%s))) +%H:%M:%S)\r";
}

log_work() {
	task="$1"
	duration=$2
	work_log=./pomodoro.log
	work_date=`$DATE_CMD +%Y-%m-%dT%H:%M:%SZ`

	if [[ ! -e $work_log ]]; then
		touch $work_log
	fi

	echo "date=$work_date,duration=$duration,task=$task" >> $work_log

}

main () {
	task="${1:-codebreakers}";
	wseconds=${2:-25}*60; # work seconds, default is 25 mins.
	pseconds=${3:-wseconds/300}*60; # pause/break seconds, default is 5 mins

	while true; do
		wseconds_epoch=$((`$DATE_CMD +%s` + $wseconds));
		pomodoro_duration=$((wseconds / 60));

		echo "This is the task we are working on: $task"

		while [ "$wseconds_epoch" -ge `$DATE_CMD +%s` ]; do
			echo -ne "$($DATE_CMD -u --date @$(($wseconds_epoch - `$DATE_CMD +%s` )) +%H:%M:%S)\r";
		done

		notify pomodoro_complete $pomodoro_duration;
		read -n1 -rsp $'Press any key to take a break or Ctrl+C to exit...\n';
		log_work $task $pomodoro_duration;

		pseconds_epoch=$((`$DATE_CMD +%s` + $pseconds));
		break_duration=$((pseconds / 60));

		while [ "$pseconds_epoch" -gt `$DATE_CMD +%s` ]; do
			echo -ne "$($DATE_CMD -u --date @$(($pseconds_epoch - `$DATE_CMD +%s` )) +%H:%M:%S)\r";
		done

		notify short_break_complete $break_duration;
		read -n1 -rsp $'Press any key to start another Pomodoro or Ctrl+C to exit...\n';
		log_work "short-break" $break_duration;
	done

}

main $1 $2 $3
