#!/bin/bash
#
# A Pomodoro timer - Because productivity...
# Underlying principles
# There are six steps in the original technique:
# 1. Decide on the task to be done.
# 2. Set the pomodoro timer (traditionally to 25 minutes).
# 3. Work on the task.
# 4. End work when the timer rings and put a checkmark on a piece of paper.[6]
# 5. If you have fewer than four checkmarks, take a short break (3–5 minutes), then go to step 2.
# 6. After four pomodoros, take a longer break (15–30 minutes), reset your checkmark count to zero, then go to step 1.

work_seconds=${1:-25}*60; # 1500 seconds
break_seconds=${2:-work_seconds/300}*60; # 300 seconds
notify() {
	voice="kyoko"
	notification=$1

	if [ "$notification"  == "pomodoro_done" ]; then
		notification_message="25 minutes done, Time to take a quick break!"
		osascript -e 'display notification "Time to take a quick break" with title "Work"';
	elif [ "$notification" == "short_break" ]; then
		notification_message="5 minute break done!"
		osascript -e 'display notification "Time to get back to work" with title "Work"';
	else {
		notification_message="15 minute break done!"
	}
	fi

	echo $notification_message
	say -v $voice "$notification_message"
}

get_response() {
	read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n';
}

count_down() {
	seconds=$1
	echo -ne "$(date -u -j -f %s $(($seconds - `date +%s`)) +%H:%M:%S)\r";
}

main() {
	while true; do

		work_duration=$((`date +%s` + $work_seconds));
		break_duration=$((`date +%s` + $break_seconds));

		while [ "$work_duration" -ge `date +%s` ]; do
			count_down $work_duration
		done

		notify pomodoro_done
		get_response

		while [ "break_duration" -gt `date +%s` ]; do
			count_down $break_duration
		done

		notify short_break
		get_response
	done
}

main
