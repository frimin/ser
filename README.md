# ser

Easy to use hosts from ssh config (**/etc/ssh/ssh_config**, **~/.ssh/config**):

## Usage

### show all hosts

	ser
	
### ssh connect

	ser <number or name> [command]
	
### copy file to all hosts

	ser cp "file" "*:~/"
	
### copy file from all hosts

	ser cp "*:~/file" "save/to/path/file-{name}"
	
### get help

	ser help