# ser

Easy to use your ssh config (**/etc/ssh/ssh_config**, **~/.ssh/config**).

Based **ssh**, **scp** (etc...).

## INSTALL

	git clone https://github.com/frimin/ser ~/.ser
	echo 'PATH=$HOME/.ser:$PATH; export PATH' >> ~/.bash_profile

## USAGE

### Show all hosts

	ser
	
![](imgs/list.gif)

### SSH login

	ser <number or name> [command]

![](imgs/connect.gif)
	
### Copy file to all hosts

	ser cp "file" "*:~/"

![](imgs/cp.gif)
	
### Copy file from all hosts

	ser cp "*:~/file" "save/to/path/file-{name}"
	
### Get help

	ser help
	
### SSH config limited support
	
The **ser** script need to read these option from each host config:
	
* Host
* User
* HostName
* Port
	
So, config file should be like:
	
	Host host1
	HostName host1.abcd.com
	User username
	[Port 22]
	[Other options ...]
	
	Host host2
	HostName host2.abcd.com
	User username
	[Port 22]
	[Other options ...]
	
	# ...
	
## TODO
* [ ] LocalForward / RemoteForward connect on background and auto reconnect
* [ ] support ssh config patterns
* [ ] support Match options