#!/bin/bash
#
# A Pomodoro timer - Because productivity...

notify() {
	notification=$1

	if [ "$notification"  == "pomodoro_complete" ]; then
		notification_message="25 minutes done, Time to take a quick break!"
		osascript -e 'display notification "Time to take a quick break" with title "Work"';
		say -v kyoko "Time to take a break!"
	elif [ "$notification" == "short_break_complete" ]; then
		notification_message="5 minute break done!"
		osascript -e 'display notification "Time to get back to work" with title "Work"';
	else {
		notification_message="15 minute break done!"
	}
	fi

	echo $notification_message
}

count_down() {
	seconds=$1
	#echo "seconds_to_count: $seconds, epoc_now: $(date +%s), Now - Seconds = $(expr $seconds - $(date +%s))"
	echo -ne "$(date -u -j -f %s $(($seconds - $(date +%s))) +%H:%M:%S)\r";
}

log_work() {
	task="$1"
	duration=$2

	work_log=./pomodoro.log
	work_date=`date +%m-%d-%y-%H:%M:%S`
	echo "$work_date,$duration,$task" >> $work_log

}

wseconds=${1:-25}*60;
pseconds=${2:-wseconds/300}*60;
task="${3:-codebreakers}"

main () {

	while true; do
		wseconds_epoch=$((`date +%s` + $wseconds));
		pomodoro_duration=$((wseconds / 60))

		while [ "$wseconds_epoch" -ge `date +%s` ]; do
			echo -ne "$(date -u -j -f %s $(($wseconds_epoch - `date +%s`)) +%H:%M:%S)\r";
		done

		notify pomodoro_complete
		read -n1 -rsp $'Press any key to take a break or Ctrl+C to exit...\n';
		log_work $task $pomodoro_duration

		pseconds_epoch=$((`date +%s` + $pseconds));
		break_duration=$((pseconds / 60))

		while [ "$pseconds_epoch" -gt `date +%s` ]; do
			echo -ne "$(date -u -j -f %s $(($pseconds_epoch - `date +%s`)) +%H:%M:%S)\r";
		done

		notify short_break_complete
		read -n1 -rsp $'Press any key to get another Pomodoro in or Ctrl+C to exit...\n';
		log_work "short-break" $break_duration
	done

}

main
