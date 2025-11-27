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
if [ -z "$TraslateFileDir" ]; then
    TraslateFileDir="/etc/yukicpl"
fi

TraslateFile="$TraslateFileDir/yukicpl.$lang"
DistChannel="dev"

[ -f "$TraslateFile" ] && {
    source "$TraslateFile"
  } || {
    echo -e "Translate File Not Found at $TraslateFile.\nDownloading..."
    # If downloading fails (e.g. no network), fall back to basic English or exit nicely in test
    # Ideally we should just echo "Downloading" but in this environment we might fail.
    # We will try to download but if it fails we might continue if in test mode or exit.

    # Check if wget exists
    if command -v wget >/dev/null 2>&1; then
        wget "https://yukicpl.moeyuki.works/dist/$DistChannel/i18n/yukicpl.$lang" -O "$TraslateFile" 2>/dev/null
    fi

    # Check again
    if [ -f "$TraslateFile" ]; then
        source "$TraslateFile"
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
        LangFunctionListSystemManagermentTools="System Tools"
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
                      sm-tools $LangFunctionListSystemManagermentTools 0\
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

        MAIN_MENU_OPTIONS=""
        # Basic options always available
        MAIN_MENU_OPTIONS="$MAIN_MENU_OPTIONS sysinfo \"System Information\""

        # Check configured functions (simple check for now)
        # In a real scenario, we would check if module is installed.
        # Here we just show the menu items.

        MAIN_MENU_OPTIONS="$MAIN_MENU_OPTIONS lnmp \"$LangFunctionListLNMP\""
        MAIN_MENU_OPTIONS="$MAIN_MENU_OPTIONS ok-www \"$LangFunctionListOneKeyWWW\""
        MAIN_MENU_OPTIONS="$MAIN_MENU_OPTIONS cfd \"$LangFunctionListCloudflared\""
        MAIN_MENU_OPTIONS="$MAIN_MENU_OPTIONS sevpn \"$LangFunctionListSoftEtherVPN\""
        MAIN_MENU_OPTIONS="$MAIN_MENU_OPTIONS sm-tools \"$LangFunctionListSystemManagermentTools\""

        # Add Exit option
        MAIN_MENU_OPTIONS="$MAIN_MENU_OPTIONS exit \"$LangExit\""

        # eval is needed to expand MAIN_MENU_OPTIONS correctly with quotes
        CHOICE=$(eval whiptail --title \"$LangTitle\" --menu \"$LangMainMenuMsg\" 25 78 15 $MAIN_MENU_OPTIONS 3>&1 1>&2 2>&3)

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
                msgbox "LNMP function not implemented yet."
                ;;
            ok-www)
                msgbox "OneKey WWW function not implemented yet."
                ;;
            cfd)
                msgbox "Cloudflared function not implemented yet."
                ;;
            sevpn)
                msgbox "SoftEther VPN function not implemented yet."
                ;;
            sm-tools)
                msgbox "System Tools function not implemented yet."
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
