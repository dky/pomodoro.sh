# Pomodoro timer in Shell

This script was hacked together to better quantify how much time I'll be spending on practicing Algorithms and other things...
It's in the terminal so win!

## Usage

Script accepts 3 arguments:

```bash
./pomodoro.sh your-task 25 5
```

- The task you want to work on.
- How much time you want to spend on the task (Pomodoro duration in minutes)
- Break duration (minutes)

## Features

Outputs to a `pomodoro.log` in the current directory so you can see what you've done for today.

## Underlying principles
## There are six steps in the original technique:

1. Decide on the task to be done.
2. Set the pomodoro timer (traditionally to 25 minutes).
3. Work on the task.
4. End work when the timer rings and put a checkmark on a piece of paper.
5. If you have fewer than four checkmarks, take a short break (3–5 minutes), then go to step 2.
6. After four pomodoros, take a longer break (15–30 minutes), reset your checkmark count to zero, then go to step 1.

## OS support

This is only supported on MacOS for the time being, although porting it to Linux should be a breeze...

## MacOS directions

This script was coded on a MacOS machine. However we did not use the native system date command because it was a bit fussy...

Instead install `coreutils` to leverage `gdate` with

```bash
brew install coreutils
```
