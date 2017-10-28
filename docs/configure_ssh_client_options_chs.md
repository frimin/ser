## 设置你的 SSH 客户端配置文件

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

