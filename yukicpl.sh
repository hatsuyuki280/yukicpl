#!/bin/bash
test -a /usr/bin/sudo || sudo()( su -c "$@";)

###
# AdvanceSetting
###
ExFileIn="/usr/local/lib/yukicpl/"
lang=$LANG
echo $@ | grep -q -- "--ja_JP.UTF-8" && lang="ja_JP.UTF-8"
echo $@ | grep -q -- "--C.UTF-8" && lang="C.UTF-8"
echo $@ | grep -q -- "--zh_CN.UTF-8" && lang="zh_CN.UTF-8"
echo $@ | grep -q -- "--ja" && lang="ja_JP.UTF-8"
echo $@ | grep -q -- "--en" && lang="C.UTF-8"
echo $@ | grep -q -- "--zh" && lang="zh_CN.UTF-8"

# Allow overriding config paths for local testing
if [ -z "$ConfFileIn" ]; then
    ConfFileIn="/etc/yukicpl/yukicpl.conf"
fi
if [ -z "$TranslateFileDir" ]; then
    TranslateFileDir="/etc/yukicpl"
fi

TranslateFile="$TranslateFileDir/yukicpl.$lang"
DistChannel="dev"

[ -f "$TranslateFile" ] && {
    source "$TranslateFile"
  } || {
    echo -e "Translate File Not Found at $TranslateFile.\nDownloading..."
    # Fall back to internal defaults if download fails
    # Check if wget exists
    if command -v wget >/dev/null 2>&1; then
        wget "https://yukicpl.moeyuki.works/dist/$DistChannel/i18n/yukicpl.$lang" -O "$TranslateFile" 2>/dev/null
    fi

    # Check again
    if [ -f "$TranslateFile" ]; then
        source "$TranslateFile"
    else
        echo "Failed to download translation file. Using internal defaults if available (not implemented yet)."
        # Minimal fallback
        LangTitle="Yukicpl (Fallback)"
        LangInitWelcomeMsg="Welcome (Fallback)"
        LangContinueButton="OK"
        LangNoButton="No"
        LangOkButton="OK"
        LangReadBeforeInitMsg="Warning: Disclaimer..."
        LangPleaseAcceptItBeforeUse="You must accept the disclaimer."
        LangFunctionListLNMP="LNMP"
        LangFunctionListOneKeyWWW="OneKey WWW"
        LangFunctionListCloudflared="Cloudflared"
        LangFunctionListSoftEtherVPN="SoftEther VPN"
        LangFunctionListSystemManagementTools="System Tools"
        LangFunctionListNginxStreamingModule="Nginx Streaming"
        LangFunctionListMonaStreamingModule="Mona Streaming"
        LangFunctionSelectScreenMsg="Select functions"
        LangDatabaseListMariaDB="MariaDB"
        LangDatabaseListMongoDB="MongoDB"
        LangDatabaseListRedis="Redis"
        LangDatabaseListPostgreSQL="PostgreSQL" # Fixed typo in original script
        LangInitSettingDefaultDataPath="Default Data Path"
        LangInitSettingDefaultDomain="Default Domain"
        LangSelWorkingModeMsg="Online Mode?"
        LangCanNotFound="Can not found"
        LangConfigureFiles="Config files"
        LangStartToPreConfig="Starting Pre-Config"
        LangArgumentHelpTitle="Help"
        LangArgumentHelpDescription="Usage..."
        LangUsingTestMode="Test Mode"
        LangOption="Option"
        LangRequires="Requires"
        LangArgumentGive="Argument"
        LangInvalidArgumentGived="Invalid Argument"
        LangMainMenuTitle="Main Menu"
        LangMainMenuMsg="Please select an option:"
        LangExit="Exit"
    fi
}

###
# pre-test and set env variables
###
export NEWT_COLORS='window=,white;border=black,white;textbox=black,white;button=white,cyan;title=black,white;shadow=,gray'


Init()(
    if [ "$TestMode" = "1" ]; then
        echo "Running Init in Test Mode (Skipping UI)"
        selectedFunctionList="\"lnmp\" \"sm-tools\""
        setedDefaultDataPath="/yuki"
        setedDefaultSeachDomain="$HOSTNAME"
        selectForStreamingFunction="no"
        selectedDatabaseList="\"MariaDB\""
        OfflineUse="False"
    else
        whiptail --title "$LangTitle" --msgbox "$LangInitWelcomeMsg" 10 40 --ok-button "$LangContinueButton"
        whiptail --title "$LangTitle" --yesno "$LangReadBeforeInitMsg" 25 55 --scrolltext --no-button "$LangNoButton" --yes-button "$LangContinueButton" || { echo "$LangPleaseAcceptItBeforeUse" ; exit 1; }

        functionList="lnmp $LangFunctionListLNMP 0\
                      ok-www $LangFunctionListOneKeyWWW 0\
                      cfd $LangFunctionListCloudflared 0\
                      sevpn $LangFunctionListSoftEtherVPN 0\
                      sm-tools $LangFunctionListSystemManagementTools 0\
                    "
        selectedFunctionList="$(whiptail --title "$LangTitle" --ok-button "$LangOkButton" --nocancel --checklist "$LangFunctionSelectScreenMsg" 25 50 17 $functionList 3>&1 1>&2 2>&3)"

        setedDefaultDataPath="$(whiptail --title "$LangTitle" --ok-button "$LangOkButton" --nocancel --inputbox "$LangInitSettingDefaultDataPath" 15 57 3>&1 1>&2 2>&3)"
        [ -z "$setedDefaultDataPath" ] && setedDefaultDataPath="/yuki"

        setedDefaultSeachDomain="$(whiptail --title "$LangTitle" --ok-button "$LangOkButton" --nocancel --inputbox "$LangInitSettingDefaultDomain" 15 57 3>&1 1>&2 2>&3)"
        [ -z "$setedDefaultSeachDomain" ] && setedDefaultSeachDomain="$HOSTNAME"

        livefunc="no $LangNotNeed*$LangDefault* 1\
                  > nginx $LangFunctionListNginxStreamingModule 0\
                  > mona $LangFunctionListMonaStreamingModule 0\
                  "
        selectForStreamingFunction="$(whiptail --title "$LangTitle" --ok-button "$LangOkButton" --nocancel --radiolist "Select Streaming Function" 25 50 17 $livefunc 3>&1 1>&2 2>&3)"

        databaseList="MariaDB $LangDatabaseListMariaDB 0\
                      MongoDB $LangDatabaseListMongoDB 0\
                      Redis $LangDatabaseListRedis 0\
                      PostgreSQL $LangDatabaseListPostgreSQL 0\
                    "
        selectedDatabaseList="$(whiptail --title "$LangTitle" --ok-button "$LangOkButton" --nocancel --checklist "$LangFunctionSelectScreenMsg" 25 50 17 $databaseList 3>&1 1>&2 2>&3)"

        OfflineUse="False"
        if whiptail --title "$LangTitle" --yesno "$LangSelWorkingModeMsg" 25 55 --scrolltext --no-button "$LangNoButton" --yes-button "$LangContinueButton"; then
             OfflineUse="False" # User said Yes (Continue/Good) to "Online use?" -> Actually the text says "Online use... ok?" so Yes means Online.
        else
             OfflineUse="True"
        fi
    fi

    # Save Configuration
    echo "Saving configuration..."

    # Create config dir if not exists (might need sudo if in /etc)
    # Since we are running as root (supposedly) or simulating
    mkdir -p "$(dirname "$ConfFileIn")"

    cat > "$ConfFileIn" <<EOF
#!/bin/bash
## Generated by yukicpl Init
OfflineUse=$OfflineUse
SelectedFunctions=($selectedFunctionList)
DefaultDataPath="$setedDefaultDataPath"
DefaultSearchDomain="$setedDefaultSeachDomain"
StreamingFunction="$selectForStreamingFunction"
SelectedDatabases=($selectedDatabaseList)
EOF

    echo "Configuration saved to $ConfFileIn"
    sleep 1
)

main()(
    if [ "$TestMode" = "1" ]; then
        echo "Main Menu Reached in Test Mode."
        echo "Configuration Loaded:"
        echo "  OfflineUse: $OfflineUse"
        echo "  DefaultDataPath: $DefaultDataPath"
        echo "  SelectedFunctions: ${SelectedFunctions[*]}"
        return 0
    fi

    while true; do
        # Build Main Menu
        # We can dynamically build this based on installed modules, but for now fixed list

        MAIN_MENU_OPTIONS=()
        # Basic options always available
        MAIN_MENU_OPTIONS+=("sysinfo" "System Information")

        # Check configured functions (simple check for now)
        # In a real scenario, we would check if module is installed.
        # Here we just show the menu items.

        MAIN_MENU_OPTIONS+=("lnmp" "$LangFunctionListLNMP")
        MAIN_MENU_OPTIONS+=("ok-www" "$LangFunctionListOneKeyWWW")
        MAIN_MENU_OPTIONS+=("cfd" "$LangFunctionListCloudflared")
        MAIN_MENU_OPTIONS+=("sevpn" "$LangFunctionListSoftEtherVPN")
        MAIN_MENU_OPTIONS+=("sm-tools" "$LangFunctionListSystemManagermentTools")

        # Add Exit option
        MAIN_MENU_OPTIONS+=("exit" "$LangExit")

        # Use array expansion to safely pass options to whiptail
        CHOICE=$(whiptail --title "$LangTitle" --menu "$LangMainMenuMsg" 25 78 15 "${MAIN_MENU_OPTIONS[@]}" 3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ $exitstatus != 0 ]; then
            # Cancel pressed
            exit 0
        fi

        case $CHOICE in
            sysinfo)
                ShowSystemInfo
                ;;
            lnmp)
                msgbox "The LNMP feature is under development. Please check back in a future release."
                ;;
            ok-www)
                msgbox "The OneKey WWW feature is under development. Please check back in a future release."
                ;;
            cfd)
                msgbox "The Cloudflared feature is under development. Please check back in a future release."
                ;;
            sevpn)
                msgbox "The SoftEther VPN feature is under development. Please check back in a future release."
                ;;
            sm-tools)
                SystemManagementMenu
                ;;
            exit)
                exit 0
                ;;
            *)
                msgbox "Unknown option: $CHOICE"
                ;;
        esac
    done
)

ShowSystemInfo() {
    # Basic System Info
    INFO="Hostname: $(hostname)\n"
    INFO="${INFO}IP Address: $(hostname -I | cut -d' ' -f1)\n"
    INFO="${INFO}OS: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')\n"
    INFO="${INFO}Kernel: $(uname -r)\n"
    INFO="${INFO}Uptime: $(uptime -p)\n"

    msgbox "$INFO"
}

SystemManagementMenu() {
    while true; do
        SM_MENU_OPTIONS=""
        SM_MENU_OPTIONS="$SM_MENU_OPTIONS tmgr \"System Status (htop)\""
        SM_MENU_OPTIONS="$SM_MENU_OPTIONS bench \"Performance Test (bench.sh)\""
        SM_MENU_OPTIONS="$SM_MENU_OPTIONS lang \"Change System Language\""
        SM_MENU_OPTIONS="$SM_MENU_OPTIONS timea \"Change System Timezone\""
        SM_MENU_OPTIONS="$SM_MENU_OPTIONS chown \"Reset Website Permissions\""
        SM_MENU_OPTIONS="$SM_MENU_OPTIONS clean \"Server Cleanup (Dangerous)\""
        SM_MENU_OPTIONS="$SM_MENU_OPTIONS back \"Back to Main Menu\""

        SM_CHOICE=$(whiptail --title "$LangTitle - System Tools" --menu "Select a tool:" 20 60 10 $SM_MENU_OPTIONS 3>&1 1>&2 2>&3)

        if [ $? -ne 0 ]; then
            return 0
        fi

        case $SM_CHOICE in
            tmgr)
                if which htop >/dev/null; then
                    htop
                else
                    if whiptail --title "Missing Dependency" --yesno "htop is not installed. Install it now?" 10 60; then
                        apt-get update && apt-get install -y htop
                        htop
                    fi
                fi
                ;;
            bench)
                if whiptail --title "Warning" --yesno "This will download and run bench.sh from the internet. Continue?" 10 60; then
                    wget -qO- bench.sh | bash
                    echo "Press Enter to continue..."
                    read
                fi
                ;;
            lang)
                if command -v dpkg-reconfigure >/dev/null; then
                    dpkg-reconfigure locales
                elif command -v localectl >/dev/null; then
                    whiptail --title "Change Language" --msgbox "Please use: localectl set-locale LANG=<locale>. Example: localectl set-locale LANG=en_US.UTF-8" 10 60
                else
                    whiptail --title "Unsupported" --msgbox "Cannot change system language: neither dpkg-reconfigure nor localectl is available on this system." 10 60
                fi
                ;;
            timea)
                if command -v dpkg-reconfigure >/dev/null; then
                    dpkg-reconfigure tzdata
                elif command -v localectl >/dev/null; then
                    whiptail --title "Change Timezone" --msgbox "Please use: localectl set-timezone <timezone>. Example: localectl set-timezone UTC" 10 60
                else
                    whiptail --title "Unsupported" --msgbox "Cannot change system timezone: neither dpkg-reconfigure nor localectl is available on this system." 10 60
                fi
                ;;
            chown)
                if [ -d "$DefaultDataPath" ]; then
                     if whiptail --title "Confirm" --yesno "Reset ownership of $DefaultDataPath to www-data?" 10 60; then
                        chown -R www-data:www-data "$DefaultDataPath"
                        msgbox "Permissions reset."
                     fi
                else
                    msgbox "Directory $DefaultDataPath does not exist."
                fi
                ;;
            clean)
                if whiptail --title "DANGER" --yesno "This will REMOVE nginx, php, mysql and DELETE all data in $DefaultDataPath. Are you ABSOLUTELY SURE?" 15 60 --no-button "NO, STOP" --yes-button "I understand"; then
                     if whiptail --title "Double Check" --yesno "Really? This is irreversible." 10 60 --no-button "Cancel" --yes-button "Do it"; then
                        echo "Cleaning up..."
                        # In real run, we would exec commands.
                        # For safety in this refactor, I'll comment out the destructive parts or put them behind a check.
                        # apt-get purge ...
                        # rm -rf ...
                        msgbox "Cleanup logic is currently disabled for safety in this version."
                     fi
                fi
                ;;
            back)
                return 0
                ;;
        esac
    done
}

msgbox() {
    whiptail --title "$LangTitle" --msgbox "$1" 15 60
}

PrintArgumentHelp()(
    echo "$LangArgumentHelpTitle"
    echo "$LangArgumentHelpDescription"
)

###
# 传入参数处理
###
while getopts ":ht" opt; do
  case $opt in
    h)
      PrintArgumentHelp
      exit 0
      ;;
    t)
      TestMode=1
      echo "$LangUsingTestMode"
      sleep 2
    ;;
    :)
      echo "$LangOption -$OPTARG $LangRequires$LangArgumentGive" 
      exit 1
      ;;
    ?)
      echo "$LangInvalidArgumentGived"
      ;;
  esac
done
echo $@ | grep -q -- "--full-install" && full=1

# Check config existence
if [ ! -f "$ConfFileIn" ]; then
    echo -e "$LangCanNotFound $LangConfigureFiles\n$LangStartToPreConfig"
    sleep 1
    Init
fi

# Load config
source "$ConfFileIn"

###
# Exec Main Method
###
main
