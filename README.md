# ser

使用 Bash Shell 编写的终端下的 SSH 登录辅助脚本，以及隧道进程管理脚本。

### 安装

	$ sudo curl -L https://frimin.com/update/ser/last/ser -o /usr/local/bin/ser
	$ sudo chmod a+rx /usr/local/bin/ser
	
### 更新

	$ sudo ser update

### 准备工作

**ser** 仅是一个 SSH 的辅助脚本，使用它之前必须正确的配置 SSH Config 文件。

你可以从下列**三项**选择中选择一项:

#### 1.创建密钥进行无密码登录

	$ [[ ! -d ~/.ssh ]] && mkdir ~/.ssh && chmod 700 .ssh; ssh-keygen -t rsa
	
在交互模式下通过连续回车使用默认的配置生成 **KeyPair**: 保存路径为 ~/.ssh/id_rsa, 且不创建密码。

发布你的公钥到远端机器:

	cat ~/.ssh/id_rsa.pub | ssh <用户名>@<主机名> "[[ ! -d ~/.ssh ]] && mkdir ~/.ssh && chmod 700 .ssh; cat >> ~/.ssh/authorized_keys"

配置 SSH 配置文件, 请将下列内容添加到你的 **~/.ssh/config** 文件中:

	Host <名称>
	HostName <主机地址>
	User <登录用户名>
	Port <端口>
	PreferredAuthentications publickey
	IdentityFile <密钥地址>

配置正确则可以直接通过命令 `ssh <名称>` 来直接登录对应配置的主机且不需要输入密码。

**ser** 也是基于这个配置来工作的。

#### 2.创建密钥对且使用密码

创建密钥时看到如下提示的时候请输入密钥的密码：

	Enter passphrase (empty for no passphrase):

之后请重复输入密码一次:

	Enter same passphrase again:
	
之后每次使用密钥时都需要键入该密码以提高密钥的安全性（当密钥被盗取时没有密码也无法直接使用）。

但是有方法可以暂时省略掉每次键入密码：

对于 **Mac** 可以配置 UseKeychain 项保存密码到钥匙串。

	Host *
	UseKeychain yes
	
对于 **Linux** 各种发行版，可以使用 **ssh-agent** 来记住密钥的密码于内存中，这里不作详细的说明。

#### 3.仅使用密码

对于仅使用密码的情况，在配置 **ssh config** 中不填写 `PreferredAuthentications` 项即可。 

## SSH 登录功能

### 显示 SSH 配置中的所有主机名

	$ ser
	
会以如下形式显示主机列表:

	1) myhost1 - user@myhost1.com:22
	2) myhost2 - user@myhost2.com:22
	3) myhost3 - user@myhost3.com:22
	...
		
### SSH 登入

通过主机列表中显示的索引:

	$ ser 1
	
通过主机名:

	$ ser myhost1
	
或者是文本模式:

	$ ser 'myh*'
	
当然也可以添加一段命令在主机上执行:

	$ ser 1 'ls -alh'

或者是所有主机:	

	$ ser '*' 'ls -alh'
	
甚至是读入标准输入流到到所有主机:

	$ ser '*' 'cat > testfile' < ~/.bash_profile

**注意**: 当重定向输入流并且目标主机匹配多个时，只有第一个会真实的读取输入流数据并且保存到临时文件。之后的所有操作的标准输入均定向到临时文件。
	
### 重定向标准输入到指令

	$ ser cp "*:~/file" "redirect/stdout/to/file-{name}"
	
### 通过 SCP 拷贝文件到所有主机

	$ ser cp "file" "*:~/"

## 有限的 SSH 配置格式支持

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

但是 **ser** 目前只能识别对于单个配置下的完整配置，所以配置应该是如下形式:

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

## 隧道管理

**ser** 中集成了 SSH 中的 **本地**/**远端** (LocalForward/RemoteForward) 转发功能，配置完成后可以便捷地停止/启动转发隧道。

### 创建一个转发隧道

	$ ser tunnel-add <隧道名> <主机名> local 80 80
	
创建完成后启动隧道相当于生成了一条如下的指令来启动 SSH 隧道:

	ssh -f -N <主机名> <其它选项> -L 127.0.0.1:5000:127.0.0.1:80
	
当然你也可以在同一个隧道中创建多个转发:

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
	 - out file: ~/.ser/tunnels/myhost1.out
	 - error file: ~/.ser/tunnels/myhost1.err
	 - forward #1: (local) 127.0.0.1:80 <= (remote) 127.0.0.1:80

### 检查隧道状态

检查已启用但未连接的隧道并启动它们。

	$ ser check
	$ ser tunnel-check
	
可以将这个命令加入到 crontab 实现断开的连接进行自动重连:

	crontab <<< '0-59 * * * * bash '/path/to/ser' tunnel-check

上列命令可以通过 `ser help tunnel-check` 列出。
	 
## 其它帮助内容

	$ ser help
	 
## LICENSE

MIT