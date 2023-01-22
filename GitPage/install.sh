#!/bin/bash
## 雪次元服务器控制面板安装程序

###
# init install script
###
test -a /usr/bin/sudo || sudo() (su -c "$@")
full=0
[ "${FULL_INSTALL}" == "true" ] && full=1
DistChannel="dev"

###
# main
###
main() {
	install && {
		success
	} || {
		fail
	}
}
#shellcheck disable=SC2120
install() {
	###
	# Show Readme and license
	###
	read -r -p "Do you want to see the README? [y/N] " showReadme
	[ "$showReadme" == "y" ] && wget -qO - "https://yukicpl.moeyuki.works/dist/README_en.md" | less
	echo "Yukicpl is licensed under the GNU General Public License v3.0.
	You can find a copy of the license at https://www.gnu.org/licenses/gpl-3.0.html
	A copy of the license is also included in the LICENSE file.
	Yukicpl is made with love by moeyuki."
	read -r -p "Do you agree with the license? [y/N] " agree
	[ "$agree" != "y" ] && {
		echo "You must agree with the license to continue."
		return 1
	}

	###
	# Download main file and grant exec permission
	###
	sudo wget -O /usr/local/bin/yukicpl "https://yukicpl.moeyuki.works/dist/$DistChannel/bin/yukicpl.sh"
	sudo chmod +x /usr/local/bin/yukicpl

	###
	# Creat dir and generate some files
	###
	sudo mkdir -p /usr/local/share/yukicpl /usr/local/lib/yukicpl /yukicpl/ssl /yukicpl/site /yukicpl/opt /yukicpl/log /etc/yukicpl
	# sudo wget -O "/usr/share/locale/${LANG}/LC_MESSAGES/yukicpl.mo" "https://yukicpl.moeyuki.works/dist/i18n/${LANG}/yukicpl.mo"
	sudo touch /etc/yukicpl/yukicpl.conf
	sudo tee "/etc/yukicpl/yukicpl.conf" <<EOF1
prefix=/yukicpl
EOF1
	sudo touch /usr/local/lib/yukicpl/installer.sh
	sudo tee "/usr/local/lib/yukicpl/installer.sh" <<EOF2
#!/bin/bash
pre_check() {
	# Check if the user is root
	if [ "$(id -u)" != "0" ]; then
		gettext "Please run this script as root."
		echo "This script must be run as root" 1>&2
		exit 1
	fi
	# Check system distribution
	if [ -f /etc/debian_version ]; then
		DISTRO="Debian"
	elif [ -f /etc/os-release ]; then
		DISTRO="Ubuntu"
	else
		echo "This script only supports Debian and Ubuntu, will exit with err code 2." 1>&2
		exit 2
	fi
	# Check package manager
	if [ -f /usr/bin/apt ]; then
		PKG_MGR="apt"
	elif [ -f /usr/bin/yum ]; then
		PKG_MGR="yum"
	else
		echo "This script only supports apt and yum" 1>&2
		exit 1
	fi
	# Check Package Manager and Update
	if [ "$PKG_MGR" = "apt" ]; then
		apt update >/dev/null 2>>/var/log/yukicpl_spm.err
	elif [ "$PKG_MGR" = "yum" ]; then
		echo "yum is not supported yet" | tee -a /var/log/yukicpl_installer.err 1>&2
		# yum update > /dev/null 2>>/var/log/yukicpl_spm.err
	fi
	# Check dependencies
	if ! command -v whiptail >/dev/null 2>&1; then
		echo "whiptail is not installed, will running at text mode" | tee -a /var/log/yukicpl_installer.err 1>&2
	fi
	echo "TUI is not ready yet, please wait release version." | tee -a /var/log/yukicpl_installer.err 1>&2
	if ! command -v msgfmt >/dev/null 2>&1; then
		echo "gettext is not installed, will install it later" | tee -a /var/log/yukicpl_installer.err 1>&2
		install -p "gettext"
	fi
}

install() (
	while getopts "p:" opt; do
		# shellcheck disable=SC2220
		# shellcheck disable=SC2154
		case $opt in
		p)
			$PKG_MGR install -y "$OPTARG" >/dev/null 2>>/var/log/yukicpl_spm.err
			;;
		esac
	done
)

pre_check
[ "${#@}" -gt 0 ] && install "$@"
EOF2
	sudo chmod +x /usr/local/lib/yukicpl/installer.sh
	/usr/local/lib/yukicpl/installer.sh -p gettext

	[ $full -eq 1 ] && {
		echo "Yukicpl will execute after 3s, And full-downloading all yukicpl files.please complete the init setting following wizard first."
		yukicpl -o full-install
	}

	return 0
}

success() {
	echo "Install is Successfully Done, you can execute yukicpl in terminal for run."
}
fail() {
	echo "Install is Failed. Can not complete some tasks." >&2
}

main
