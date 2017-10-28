# ser

使用 Bash Shell 编写的终端下的 SSH 登录辅助脚本，以及隧道进程管理脚本。

### 安装 & 更新

	# install
	$ sudo curl -L https://frimin.com/update/ser/last/ser -o /usr/local/bin/ser
	$ sudo chmod a+rx /usr/local/bin/ser

	# update
	$ sudo ser update

### 准备工作

请参阅: [设置你的 SSH 客户端配置文件](docs/configure_ssh_client_options_chs.md)

## SSH 登录功能

### 显示 SSH 配置中的所有主机名

	$ ser
	
会以如下形式显示主机列表:

	1) myhost1 - user@myhost1.com:22
	2) myhost2 - user@myhost2.com:22
	3) myhost3 - user@myhost3.com:22
	...
		
### SSH 登入

	ser [o] <host|index> [command] [redirect_stdout_to_filename]

通过主机列表中显示的索引可以登入列表中的主机，下列指令等价 `ssh myhost1 `，其中子命令 `o` 是可选的，如果你的主机名和其它子命令名称相冲突，则必须使用子命令 `o`:

	$ ser 1
	$ ser o 1
	
通过主机名或者通配符，登入时使用通配符只会登入与之匹配的第一个主机:

	$ ser myhost1
	$ ser 'myh*'
	
当然也可以添加一段命令在主机上执行:

	$ ser 1 'ls -alh'

或者是对所有主机执行同一个命令:	

	$ ser '*' 'ls -alh'
	
甚至是读入标准输入流到到所有主机并同时执行命令:

	$ ser '*' 'cat | tee -a file' <<< 'hello'

**注意**: 当重定向输入流并且目标为多个主机时，只有第一个会真实的读取输入流数据 **并且** 保存到临时文件。之后的所有操作的标准输入均定向到临时文件。
	
**注意: 当前批量执行远程命令传入主机列表的方式并不够方便，在未来的版本中将会修改。**
	
### 重定向标准输出到文件

如果需要区分每条远程指令的标准输出，则可以传入指定的文件名以输出，此处的 `{name}` 会被替换为当前指令执行的主机名:

	$ ser '*' 'cat | tee -a file' <<< 'hello' "redirect/stdout/to/file-{name}"
	
等价于:

	$ ssh myhost1 'cat | tee -a file' <<< 'hello' > "redirect/stdout/to/file-myhost1"
	$ ssh myhost2 'cat | tee -a file' <<< 'hello' > "redirect/stdout/to/file-myhost2"
	$ ssh myhost3 'cat | tee -a file' <<< 'hello' > "redirect/stdout/to/file-myhost3"
	...
	
### 拷贝文件

	ser cp [options] <source ...> [:] <destination_file ...>
	ser cp [options] <source ...> [:] <destination_directory ...>

从本机拷贝一个或者多个文件或者目录到目标机器:

	$ ser cp "file1" "file2" : "*:~/"
	$ ser cp -r "dir1" "dir2" : "*:~/"
	
**注意:** 当目标有多个时必须使用 `:` 符号分隔。

或者是直接指定某几个主机索引来指定目标机器:

	$ ser cp "file1" "file2" : {1,3}":~/"
	$ ser cp "file1" "file2" : 1:~/ 3:~/
	
此处的花括号 `{}` 是被 Bash Shell 所解释的，所以不能被包含在引号之中。

## 隧道管理功能

**ser** 中集成了 SSH 中的 **本地**/**远端** (LocalForward/RemoteForward) 的转发管理功能，配置完成后可以便捷地停止/启动转发隧道。

### 创建一个转发隧道

	$ ser tunnel-add <隧道名> <主机名> local 80 80
	
创建完成后启动隧道相当于生成了一条如下的指令来启动 SSH 隧道:

	ssh -f -N <主机名> <其它选项> -L 127.0.0.1:5000:127.0.0.1:80
	
当然你也可以在同一个隧道中创建多个转发类型:

	$ ser tunnel-add <隧道名> <主机名> local 443 443
	$ ser tunnel-add <隧道名> <主机名> remote 22 8000
	$ ser tunnel-add <隧道名> <主机名> socks5 1080
	
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
	$ ser tunnel-stop <隧道名通配符>
	
### 重启隧道

	$ ser restart
	$ ser tunnel-restart
	$ ser tunnel-restart <隧道名通配符>
	
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
	 - out file: ~/.ser/tunnels/myhost1.out
	 - error file: ~/.ser/tunnels/myhost1.err
	 - forward #1: (local) 127.0.0.1:80 <= (remote) 127.0.0.1:80

### 检查隧道状态

检查已启用但未连接的隧道并启动它们。

	$ ser check
	$ ser tunnel-check
	
可以将这个命令加入到 crontab 实现断开的连接进行自动重连:

	crontab <<< "0-59 * * * * bash '/path/to/ser' tunnel-check"

上列命令可以通过 `ser help tunnel-check` 列出。

## SSH 配置文件支持

请参阅: [SSH 配置文件支持](docs/ssh_config_format_support_chs.md)

## 其它帮助内容

	$ ser help
	 
## LICENSE

MIT