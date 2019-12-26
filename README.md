# Pomodoro timer in Shell

This script was hacked together to better quantify how much time I'll be spending on practicing Algorithms with [codebreakers.io](https://codebreakers.io).

## Usage

Script accepts 3 arguments:

```bash
./pomodoro.sh your-task 25 5
```

- The task you want to work on. (**Note** The task needs to be separated with `-` for now if it contains spaces, otherwise it will break the output in the log)
- How much time you want to spend on the task (Pomodoro duration in minutes)
- Break duration (minutes)

If you just invoke it by default with:
```bash
./pomodoro.sh
```

It will just start a `25` minute Pomodoro with a default break of `5` minutes. The task will be named `codebreakers` in the pomodoro.log.

## Features

- Outputs to a `pomodoro.log` in the current directory so you can see what you've done for today.
- After 4 short Pomodoros you'll get prompted for a long break automatically without breaking your work flow on a task.

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

There's an external dependency on `gdate` for the `date` command because the BSD date was giving us a nightmare of a time...

Install `coreutils` to leverage `gdate` with

```bash
brew install coreutils
```
