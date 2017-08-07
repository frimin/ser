# ser

使用 Bash Shell 编写的终端下的 SSH 登录辅助工具，以及隧道管理工具。

### 安装

	sudo curl -L https://frimin.com/update/ser/last/ser -o /usr/local/bin/ser
	sudo chmod a+rx /usr/local/bin/ser
	
## SSH 登录功能

### 显示 SSH 配置中的所有主机名

	$ ser
	
### SSH 登入

	$ ser <index|name|pattern> [command]
	
当然也可以添加一段命令在所有主机上执行:

	$ ser '*' 'ls -alh'
	
### 通过 SCP 拷贝文件到所有主机

	$ ser cp "file" "*:~/"

### 拷贝文件从所有主机到本机

	$ ser cp "*:~/file" "save/to/path/file-{name}"
	
## 有限的 SSH 配置格式支持

SSH 配置支持基于匹配模式的主机名和 **match** 字段，一个主机最终的配置实际上可以配置在多个 **host** 配置下，例如:
	
	Host *host
	User user
	HostName myhost.com
	
	Host myhost
	Port 1234

然后可以通过 **SSH** 登入:

	$ ssh myhost

等价于:

	$ ssh user@myhost.com -p 1234

但是 **ser** 目前只能识别对于单个配置下的完整配置，所以配置应该是如下形式:

	Host host1
	HostName host1.abcd.com
	User username
	[Port 22]
	[其它配置 ...]
	
	Host host2
	HostName host2.abcd.com
	User username
	[Port 22]
	[其它配置 ...]
	
	# ...
	
**ser** 会读取主机配置下的下列字段，其它字段会被忽略:

* **Host**
* **User**
* **HostName**
* **Port** [可选]

另外对于全局生效的配置 `Host *` 作了忽略处理，因为它是存在于 ssh_config 中的默认配置。

## 隧道管理

**ser** 中集成了 SSH 中的 **本地**/**远端** (LocalForward/RemoteForward) 转发功能，配置完成后可以便捷地停止/启动转发隧道。

### 创建一个转发隧道

	$ ser tunnel-add <隧道名> <主机名> local 80 80
	
创建完成后启动隧道相当于生成了一条如下的指令来启动 SSH 隧道:

	ssh -f -N <主机名> <其它选项> -L 127.0.0.1:5000:127.0.0.1:80
	
当然你也可以在同一个隧道中创建多个转发:

	$ ser tunnel-add <隧道名> <主机名> local 443 443
	$ ser tunnel-add <隧道名> <主机名> remote 22 8000
	
则会生成如下的隧道启动指令:

	ssh -f -N <隧道名> <其它选项> \
	-L 127.0.0.1:5000:127.0.0.1:80 \
	-L 127.0.0.1:443:127.0.0.1:443 \
	-R 127.0.0.1:22:127.0.0.1:8000

### 移除转发

	$ ser tunnel-remove <隧道名> <转发索引>

### 启动隧道

标记隧道为启用状态同时打开隧道连接。

启动所有隧道:

	$ ser start

启动某个隧道:

	$ ser start <隧道名>
	$ ser tunnel-start <隧道名>
	
以模式匹配隧道名来启动隧道:

	$ ser tunnel-start <文本模式>
	
启动后每个 SSH 隧道会通过 `-f` 选项运行在后台。
	
当启动失败时，会打印 SSH 进程的结束代码，可以通过 `ser info` 命令来看到隧道的最后一个打印的错误。大部分情况只会保留这一个错误，因为启动隧道时会刷新错误流所重定向的文件。
	
### 停止隧道

	$ ser stop
	$ ser tunnel-stop
	$ ser tunnel-stop <隧道名>
	$ ser tunnel-stop <文本模式>
	
### 重启隧道

	$ ser restart
	$ ser tunnel-restart
	$ ser tunnel-restart <隧道名>
	$ ser tunnel-restart <文本模式>
	
等价于 `ser stop [host]; ser start [host]`
	
### 列出所有隧道

	$ ser tl
	$ ser tunnel-list
	
上述指令只会列出隧道名，是否已启用以及是否已连接的信息，例如:

	host - [enabled] [connected]
	
要获取更多的详细信息，请使用 `ser info`:

	 # tunnel: my-forward
	 - host: host
	 - enable: yes
	 - connect: yes
	 - pid: 30103
	 - out file: ~/.ser/tunnels/frimin.out
	 - error file: ~/.ser/tunnels/frimin.err
	 - forward #1: (local) 127.0.0.1:80 <= (remote) 127.0.0.1:80

### 检查隧道状态

检查已启用但未连接的隧道并启动它们。

	$ ser check
	$ ser tunnel-check
	
可以将这个命令加入到 crontab 实现断开的连接进行自动重连:

	crontab <<< '0-59 * * * * bash '/path/to/ser' tunnel-check-step

上列命令可以通过 `ser help tunnel-check-step` 列出。
	 
## 其它帮助内容

	$ ser help
	 
## LICENSE

MIT