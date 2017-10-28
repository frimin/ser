# SSH 配置文件支持

SSH 配置支持基于匹配模式的主机名和 **match** 字段，一个主机最终的配置实际上可以配置在多个 **host** 配置下，例如:
	
	Host *host
	User user
	HostName myhost1.com
	
	Host myhost1
	Port 1234

然后可以通过 **SSH** 登入:

	$ ssh myhost1

等价于:

	$ ssh user@myhost1.com -p 1234

由于脚本由 Bash Shell 编写，所以仅能支持简单的 SSH Config 的格式。目前只能识别对于单个配置下的完整配置，所以配置应该是如下形式:

	Host myhost1
	HostName myhost1.com
	User user
	[Port 22]
	[其它配置 ...]
	
	Host myhost2
	HostName myhost2.com
	User user
	[Port 22]
	[其它配置 ...]
	
	# ...
	
**ser** 会读取主机配置下的下列字段，其它字段会被忽略:

* **Host**
* **User**
* **HostName**
* **Port** [可选]

另外对于全局生效的配置 `Host *` 作了忽略处理，因为它是存在于 ssh_config 中的默认配置。