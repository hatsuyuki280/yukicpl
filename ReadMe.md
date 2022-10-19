# yukicpl自述文件 -yukicpl Readme-

---
### 簡単な紹介
yukicpl是 @hatsuyuki280 开发的 Linux 系服务器管理面板。  

虽然这个名字的由来有点中二，但它是由我的用户名 hatsuyuki 和control panel 的缩写组成的。  

这是我最初为自己制作的一组用于服务器管理的有用脚本，但我正在考虑从现在开始支持更多日常功能。  

目前，我主要在 Debian >= 9 / Ubuntu >= 18.04 作为目标平台进行开发。  
由于服务管理使用systemd，因此不支持 Windows 子系统 Linux（WSL）。  

**Important Request**
原本这个面板是为我自己开发的，从一开始就没有考虑和其他管理面板的兼容性，所以即使是在目标平台上不能保证它可以和所有环境下的所有软件共存。  
此外，由于尚未在业务用途等管理权限复杂的环境中进行验证，因此在这样的环境中使用时无法保证安全。  
无论是否可以执行，都存在破坏现有文件、系统等的风险。  
使用之前请自行评估风险。  
尽量避免与其他控制面板共同使用。  
该软件管理并使用多个第三方和开源软件，因此，它可以为任何操作请求root权限，在生产业务系统中使用时，请务必获得系统管理员的许可。  
最后也是最重要的：  
请在使用前了解风险并获得系统管理员的许可。  
我不能对该控制面板造成的任何损坏负责。  

---

### 機能・特徴紹介
- 对象平台
    - Linux
        - [x] Debian >= 9.0 [ ARM / ARM x64 / i386 / amd64 ]
        - [x] Ubuntu >= 18.04 [ ARM / ARM x64 / i386 / amd64 ]
        - [ ] CentOS
        - [ ] Fedora
- 特征
    - [x] 开源
    - [x] 由于解释器使用的是bash，如果有标准的系统环境就可以执行
    - [x] 即使对于不熟悉命令行操作的人也能提供易于操作的 UI
        - [x] 友好的 CLI
        - [ ] 可以通过指定参数在没有 UI 的情况下执行
        - [ ] TUI [ 未完成 ]
        - [ ] GUI [ 未完成 ]
    - [x] 即使对于初学者来说也易于阅读的注释
    - [x] 由于每个功能都是脚本化的，因此可以自由添加和删除。
    - [x] 因为它使用了包管理器，所以即使不再使用这个面板，也可以人为操作。

- 可以管理的功能
    - Web相关
        - [ ] Nginx [安装 / 管理]
            - [ ] Nginx Reverse Proxy 配置
            - [ ] Nginx RTMP 配置
        - [ ] PHP [安装 / 基本管理]
        - [ ] MySQL [安装 / 管理]
        - [ ] MariaDB [安装 / 管理]
        - [ ] Redis [安装 / 基本管理]
        - [ ] Lets Encrypt [ 申请 / 自动更新 / CSR生成 ]
        - [ ] One Key Create Site [ 网站创建 ]
            - [ ] WordPress [ 安装 ]
            - [ ] Static File Index Site [ 配置 ]
    - 服务相关
        - [ ] aria2 RPC & WebUI [ 安装 / 简单管理 ]
        - [ ] Deluge BitTorrent Downloader [ 安装 / 简单管理 ]
        - [ ] codeserver [ 安装 / 简单管理 ]
        - [ ] docker [ 安装 / 简单管理 ]
        - [ ] jupyter [ 安装 / 简单管理 ]
        - [ ] cloudflare 经由 DDNS・ZeroTrust・NAT 直通 [ 简单管理 ]
        - [ ] FRP [ 安装 / 简单管理 ]
    - 系统相关
        - [ ] Shadowsocks [ 安装 / 简单管理 ]
        - [ ] SoftEther VPN [ 安装 / 简单管理 ]
        - [ ] OpenVPN [ 安装 / 简单管理 ]
        - [ ] WireGuard [ 安装 / 简单管理 ]
        - [ ] Cloudflare Warp [ 安装 / 简单管理 ]
        - [ ] 防火墙路由表 [ 简单管理 ]
        - [ ] Samba [ 用于 Windows 文件共享的简单管理 ]

---


### 快速开始 （因主体未完成，以下内容无法使用）
如果您不确定如何使用、请从这里开始体验[install.sh](https://github.com/hatsuyuki280/yukicpl/blob/master/MISC/install.sh)。  
或运行以下命令：
```
## 警告：此命令需要用户或 root 密码并以 root 身份运行。 请在本次执行前仔细确认install.sh的内容后使用。
## 内容的日语化尚未完成。
sudo su -c "bash <(wget -qO- https://yukicpl.moeyuki.works/dist/etc/misc/install_jp.sh)"
```
通过执行上述命令，将下载[yukicpl.sh](https://github.com/hatsuyuki280/yukicpl/blob/master/MISC/yukicpl.sh)。  
从现在开始，每次使用新功能时，您都可以只自动下载必要的部分。
如果你想一次下载它们，运行以下命令：
```
## 警告：此命令需要用户或 root 密码并以 root 身份运行。 请在本次执行前仔细确认install.sh的内容后使用。
## 内容的日语化尚未完成。
sudo su -c "bash <(wget -qO- https://yukicpl.moeyuki.works/dist/etc/misc/install_full_jp.sh)"
```
安装完成后会出现如下显示：
```安装完成。 您可以通过在终端中键入“yukicpl”来运行它。```

---

### 使用（未完成）
安装后，yukicpl 位于/usr/local/bin/ 目录下，其他部分位于/usr/local/lib/yukicpl/ 目录下。
初始化时安装的所有软件都由包管理器“APT”管理，因此每个软件都安装在默认目录中。
有关如何使用此控制面板目录的详细信息，请参阅 。https://yukicpl.moeyuki.works/dict_def_jp.json

请以 root 用户身份启动控制面板：
``` yukicpl ```
如果您以普通用户身份运行它，它将自动使用 sudo 命令（首选）或 su 命令请求 root 权限。（提前准备一个的密码）  
未找到配置文件时，启动时自动显示初始化设置向导。 按照说明完成初始设置。  
如果要手动编辑配置文件，请参考[yukicpl.conf](https://github.com/hatsuyuki280/yukicpl/blob/master/config-simple/yukicpl.conf)
在空运行下执行时（不执行所有命令，命令内容显示在终端上，您可以直接查看。） 以任意用户执行以下命令。：  
``` yukicpl --test ```  

如果您正确运行此控制面板，您将看到功能选择用户界面。  
根据需要选择并按照向导进行操作。  
手动安装的程序不需要编写配置文件，但如果你想自己安排，请参考各自的默认文件夹。  

---

#### 快速功能（未完成）
我还在努力。 完成后我会更新它，所以敬请期待。  

---

### 卸载（未完成）
移除 yukicpl 的“一键跑路”功能，提高安全性。
如果要删除此控制面板，请使用 [uninstall.sh](https://github.com/hatsuyuki280/yukicpl/blob/master/MISC/uninstall.sh)  
或运行此命令：
```
## 警告：此命令需要用户或 root 密码并以 root 身份运行。 请在本次执行前确认uninstall.sh的内容后再使用。
## 这个脚本会杀掉所有包含字符串yukicpl的进程，为了避免风险，你要终止运行吗？ 被询问时，请务必检查显示的进程列表。
sudo su -c "bash <(wget -qO- https://yukicpl.moeyuki.works/dist/etc/misc/uninstall_jp.sh)"
```
运行后，按照向导完成卸载过程。  
**重要**
卸载时选择“全部删除”时，在两次确认后删除所有相关文件。
这包括从此控制面板创建的所有环境以及可以由您安装的程序管理的所有文件。  
当显示以下文字时，表示卸载完成。  
```卸载完成。 某些文件可能无法删除，因为它们正在使用中，请手动重启并删除。 ```
就在卸载向导结束之前，系统会询问您“您要配合调查问卷吗？” 您可以通过输入“N”来拒绝调查。
（由于此时调查功能还没有完成，所以我们不会听调查，也不会发送任何东西，请放心。）  
“N”以外的任何输入都默认为同意。 之后，使用 wget 命令自动访问问卷计数器并发送。
除了调查内容和系统分发之外，我们不会收集或发送用户信息。  
（发送前会显示发送内容和要执行的命令）。  