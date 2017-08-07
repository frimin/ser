# ser

Easy & fast to login your hosts and tunnel manager by using SSH.

### INSTALL

	sudo curl -L https://frimin.com/update/ser/last/ser -o /usr/local/bin/ser
	sudo chmod a+rx /usr/local/bin/ser

## SSH LOGIN USAGE

### Show all hosts from your SSH configs

	$ ser

### SSH login

	$ ser <index|name|pattern> [command]
	
### Through SCP copy file to all hosts

	$ ser cp "file" "*:~/"
	
### Copy file from all hosts

	$ ser cp "*:~/file" "save/to/path/file-{name}"

### Get help

	$ ser help

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

## TUNNEL USAGE

### Create a forward to tunnel

	$ ser tunnel-add <tunnel_name> <host_name> local 80 80

It will be generate a SSH connect command when start tunnel:
	
	ssh -f -N <host_name> <other_options> -L 127.0.0.1:5000:127.0.0.1:80
	
You can create more:

	$ ser add <tunnel_name> <host_name> local 443 443
	$ ser add <tunnel_name> <host_name> remote 22 8000
	
To generate command:

	ssh -f -N <host_name> <other_options> -L 127.0.0.1:5000:127.0.0.1:80 -L 127.0.0.1:443:127.0.0.1:443 -R 127.0.0.1:22:127.0.0.1:8000

### Show all tunnels

	$ ser sl
	$ ser tunnel-list

### Start tunnels

Mark tunnel enabled and open tunnels (execute generated command).

Start all tunnels:
	
	$ ser start

Start one tunnel:
	
	$ ser start <tunnel_name>

Start tunnel with pattern:
	
	$ ser start '<tunnel_name>*'
	
### Stop tunnels

	$ ser stop
	$ ser stop <tunnel_name>
	$ ser stop '<tunnel_name>*'
	
## LICENSE

MIT