## yukicpl自述文件 -yukicpl Readme-  
=====
[for English](https://github.com/hatsuyuki280/yukicpl/MISC/Readme_en.md)
[日本語説明](https://github.com/hatsuyuki280/yukicpl/MISC/Readme_jp.md)
=====
### 简介
yukicpl 全称 初雪的服务器管理面板。
简单的来说，只是为了方便咱自己日常使用/快速安装各种环境的一键脚本的集合。目前预计的目标系统是 Debian >= 9 的X86平台，其他平台不保证能运行。
虽然说最初是作为服务器的管理面板编写的，不过新版的 yukicpl 预计会添加一些更加日常的功能。  

虽然本面板咱自己也在用，但并不能保证本面板一定不会在所有人的环境下正常工作。即便无法正常运行/正常运行也不能保证不会对现有环境产生破坏。
设计之初并未考虑到与其他面板的兼容问题，因此推荐仅使用一种管理面板且不要在工作中的环境下运行。
亦不保证不会引起任何安全问题。由于执行诸操作时需要使用 root 权限，因此如果需要在生产环境下使用，请务必在征得系统管理员的许可，且理解可能存在的风险的前提下进行使用。
有本面板引起的一切损失，咱一概不负责任。

### 安装
请从[install.sh](https://github.com/hatsuyuki280/yukicpl/MISC/install.sh)开始体验。
或使用如下命令：
```
## 注意，这将请求你的用户密码/root密码，并以root权限运行 install.sh 请在运行前检视代码。
sudo su -c "bash <(wget -qO- https://github.com/hatsuyuki280/yukicpl/blob/master/MISC/install.sh)"
```
如无其他需求，将仅会下载[yukicpl.sh](https://github.com/hatsuyuki280/yukicpl/yukicpl.sh)进行使用，其他关联文件将会在第一次使用该功能时自动下载。
如果需要一次性下载所有文件，请运行：
```
## 注意，这将请求你的用户密码/root密码，并以root权限运行 install.sh 请在运行前检视代码。
sudo su -c "bash <(wget -qO- https://github.com/hatsuyuki280/yukicpl/blob/master/MISC/install_full.sh)"
```
完成安装后将会看到如下提示：
```安装完成，在当前终端输入 yukicpl 即可启动```

### 使用 (未完成)
完成安装后， yukicpl 将会被安装至 /usr/local/bin/ 目录中，其他额外的面板组件将会位于 /usr/local/lib/yukicpl/ 目录中 ，配置文件将位于 /etc/yukicpl/ 目录中。
其他使用到的软件将会安装至 apt 的默认安装目录。本面板管理的站点/其他非 apt 安装的后端，默认将会位于 /yuki/ 目录，此目录将会在第一次启动时询问用户是否需要修改。  
请使用root用户在终端内执行：
``` yukicpl ```
如使用一般用户将会通过 sudo 命令(优先)或 su 命令提升权限至root。请准备好相应的密码进行授权。
第一次启动或设置文件被移除后将会自动开始设置向导，以完成本面板必要的设置。
如需使用调试模式(所有命令将不会被实际执行，命令内容会被输出至当前终端内)，请在以任意用户执行：
``` yukicpl --test ```

本面板正常运行后将会显示功能选单，根据功能选单的提示在本面板的输入区内输入指定的命令即可执行该功能。  

#### 快速功能 (未完成)
当前正在计划中的功能，完成后将更新此段落。敬请期待。

### 卸载 (未完成)
出于安全考虑已移除旧版 yukicpl 内的一键跑路功能。
如需移除本面板请从[uninstall.sh](https://github.com/hatsuyuki280/yukicpl/MISC/uninstall.sh)开始。
或使用如下命令：
```
## 注意，这将请求你的用户密码/root密码，并以root权限运行 uninstall.sh 请在运行前检视代码。
## 该脚本确认执行后将会杀掉所有名称包含 yukicpl 的进程，为了防止不必要的损失，被询问是否终止进程时，请确实检查显示出来的进程列表。
sudo su -c "bash <(wget -qO- https://github.com/hatsuyuki280/yukicpl/blob/master/MISC/uninstall.sh)"
```
请根据卸载向导的提示完成卸载。
**重要提示**
卸载本面板时如果选择移除所有文件，经过两次确认后将会确实的移除所有与本面板相关的文件。包括经由本面板创建的一切环境及该环境下的一切用户数据
卸载完成后将会显示以下提示。
```卸载完成，部分文件可能未移除，请在手动重启后自行移除```
卸载过程完成后会提示是否愿意参与问卷调查，回复 0 为拒绝。该问卷用于决定将来的优先开发方向。此回答结果不会影响卸载。(当前版本问卷功能未完成，不会询问/收集/发送任何数据)
如果回复不为 0，该将会自动通过 wget 请求一次咱的计数器，此过程除了问卷结果外，仅会收集当前系统的发行版名和版本号，不会收集任何用户信息。
(发送前将会显示所有将会发送的数据以便最终确认是否发送，如果发送拒绝将不会发送任何信息)