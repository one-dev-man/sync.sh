# sync.sh

`sync.sh` is a bash tool to synchronize a project between its source (dev) and its destination (maybe deploy, test server, ...)

## Install

First, be sure to use a linux distribution such as Ubuntu (quite obvious but important).

Then clone this repository where you want to store the installation on your computer and launch the `install.sh` script.

Now you should be able to use `sync.sh` in any shell.

## Usage

The main usage is describe when you call `sync.sh`.

There's 4 main commands :
 - `init` -  initialize a new `sync.sh` project configuration (see [config section](#configuration))
 - `sync` - launch an `rsync` synchronization from the specified source/project directory and the remote destination directory.
 - `remote` - allows you to send a remote command through `ssh`. The command will be executed in the specified source/project directory.
 - `shell` - allows you to open a remote shell through `ssh` (also the basic usage of `ssh` by the way).

 After, depending of your project configuration, you could execute some other commands called `tasks`.

## Configuration

<details>
    <summary>Required configuration keys</summary>

There's three required configuration key :

| key         | type     | description                                                                |
| ----------- | -------- | -------------------------------------------------------------------------- |
| SOURCE      | `string` | Path of the project directory / any directory to use as source.            |
| DESTINATION | `string` | Path of the remote project destination directory.                          |
| SSH_KEY     | `string` | Path to the ssh key to use when synchronizing and execute remote commands. |

</details>

<br>

<details>
    <summary>Optional configuration keys</summary>

There's two optional configuration key :

| key        | type     | description                                 |
| ---------- | -------- | ------------------------------------------- |
| RSYNC_ARGS | `string` | Some additionnal `rsync` command arguments. |
| SSH_ARGS   | `string` | Some additionnal `ssh` command arguments.   |

</details>

<br>

<details>
    <summary>Tasks</summary>

Also you can define custom tasks (like `npm` scripts) :

| key             | type     | description |
| --------------- | -------- | ----------- |
| TASK_`<taskname>` | `string` | Command to execute when task called. You can use the `remote` native function to execute a command into the specified destination directory. |

By example :
```bash
...

TASK_BUILD="echo build task ; remote \"mvn package\""

...
```
You can call this task with `sync.sh build` and it will first print `build task` in terminal and then execute `mvn package` into the destination directory.

</details>

## Contributors

List of contributors :

<div style="float:left;margin:0 10px 10px 0">
    <img align="left" src="https://contrib.rocks/image?repo=one-dev-man/4th" width="24px">
    <a href="https://github.com/one-dev-man/">
        onedevman
    </a>
</div>