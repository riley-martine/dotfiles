#!/bin/bash
# not usr/bin/env so that this stays compatible

# MacOS Setup Script
# Copyright © 2023 Riley Martine

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Script to set up a new MacOS computer for development.

# DO NOT RUN THIS without reading through it and tweaking to your liking.

# GOALS:
#  - Sets up a decent development workstation.
#  - Works on a fresh MacOS Ventura install, with nothing set up
#  - As much as possible, does things without user intervention.
#    - I am not going to write too many applescripts to click on things, PROBABLY.
#  - When things need user intervention, do them as late as possible.
#  - Idempotent.
#    - Running twice is safe.
#    - Running, then uninstalling half of the things, then running again, is safe.
#    - Running, then deleting your dotfiles, then running again restores the dotfiles.
#    - Running twice does not change your dotfiles more than running once.
#  - For now, compatible with external dotfiles. That means everything goes in a '.d' directory
#    so that I can pull other dotfiles without overwriting, and don't clutter my own with
#    tool-specific config. (e.g. pyenv path)
#    - Eventually, the script will regenerate my preferred dotfiles from scratch.
#  - Passes shellcheck with no warnings or errors

# NON-GOALS:
#  - All things to all people. This is highly opionated; it is how I want MY workstation set up.
#    It WILL mess with preferences you want one way. It WILL have opinions about how you should
#    organize things you don't agree with. It WILL install applications and utilities you have
#    no use for.
#    - Eventually, I may twiddle this to be super configurable, because maybe not everyone wants
#      three jdks. This would be a large rewrite, but make it useful in the base form.
#    - The goal for this would be: Does not mutate computer state without making sure the user
#      understands exactly what would happen, and the user is able to confirm/deny each choice.
#  - Being pretty (this will come later)
#  - An update script. There are sections that run updates; this script should not be run in order
#    to update the things it installs. (that will come later)
#  - Modular; while linear, dependency relations are not encoded as a proper DAG.
#    Delete sections at your own risk.

# You may have to run this script several times to work through all the updates.

# For developing, a pretty good method of figuring out preferences is:
# 1) Find the "domain" you're operating in (com.apple.Dock)
# 2) `defaults read <domain> > before`
# 3) Edit the preferences for that thing
# 4) `defaults read <domain> > after`
# 5) `diff before after`
# You can also omit the domain to get ALL the values. Sometimes you need the -currentHost flag,
# sometimes you need to run with sudo.

# More useful generic tips for plist munging here:
#	https://apple.stackexchange.com/questions/79761/editing-system-preferences-via-terminal
#       alias plist='plutil -convert xml1 -o /dev/stdout'

# Bits taken from anywhere linked, and the following:
# https://sourabhbajaj.com/mac-setup/SystemPreferences/
# https://macos-defaults.com/#💻-list-of-commands
# https://www.stuartellis.name/articles/mac-setup/
# https://www.robinwieruch.de/mac-setup-web-development/
# https://github.com/pivotal/workstation-setup/blob/main/setup.sh
# https://github.com/geerlingguy/dotfiles/blob/master/.osx
# https://github.com/mathiasbynens/dotfiles/blob/main/.macos
# https://github.com/thoughtbot/laptop/blob/main/mac
#
# TODO impl https://git.herrbischoff.com/awesome-macos-command-line/about/

set -euo pipefail

if [[ $EUID -eq 0 ]]; then
    echo "This script should not be run as root."
    exit 1
fi

echo "Caching password..."
sudo -K
sudo true

###################
#    Functions    #
###################

# https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout
# zsh:
# .zshenv is sourced for scripts (non-login, non-interactive shells, e.g. zsh -c 'command')
# .zshenv and .zshrc are sourced for interactive shells (e.g. just typing zsh)
# .zprofile is sourced for login shells. You only get login shells on MacOS if you pop a new terminal tab or window.

# https://unix.stackexchange.com/questions/119627/why-are-interactive-shells-on-osx-login-shells-by-default
# bash:
# the file specified by $BASH_ENV is sourced for scripts (bash -c 'command', ./test.sh)
# .bashrc is sourced for interactive, non-login shells (popping a subshell with bash)
# .bash_profile is sourced for login shells. You only get login shells on MacOS if you pop a new terminal tab or window.

# https://fishshell.com/docs/current/faq.html#how-do-i-run-a-command-every-login-what-s-fish-s-equivalent-to-bashrc-or-profile
# fish:
# ~/.config/fish/config.fish is always sourced. To make something only run for interactive shells, use:
#	if status is-interactive
# fish also sources everything in ~/.config/fish/conf.d/*.fish, in lexical sort order.

# exporting an env var makes it available to all subshells. e.g. setting PATH in .zshrc allows it to be read from a bash script called from an interactive zshell.

# TODO finish section

# https://gist.github.com/ptc-mrucci/61772387878ed53a6c717d51a21d9371
# some
SCRIPT_DIR=$( dirname "$(readlink -f "$0")" )
export PATH="$SCRIPT_DIR/bin:$PATH"

# This wraps brew install calls in a bundle command, so we don't get error messages
# about the program already being installed, and don't have to do extra typing to write
# the brewfiles ourselves.
# https://github.com/Homebrew/brew/issues/2491
brew-get() {
    local PREFIX="brew"
    local ARGS=""
    for arg in "$@"; do
        case "$arg" in
            --cask)
                PREFIX="cask"
                shift
                ;;
            --HEAD)
                # https://github.com/Homebrew/homebrew-bundle/issues/1042
                ARGS=', args: ["head"]'
                shift
                ;;
            *) ;;

        esac
    done

    for arg in "$@"; do echo "${PREFIX} \"${arg}\"${ARGS}"; done | brew bundle --file=-
}

# https://www.dzombak.com/blog/2021/11/macOS-Scripting-How-to-tell-if-the-Terminal-app-has-Full-Disk-Access.html
if ! plutil -lint /Library/Preferences/com.apple.TimeMachine.plist > /dev/null; then
    echo "This script requires granting Terminal.app (or whatever terminal it is running in) Full Disk Access permissions."
    echo "Please navigate to System Preferences -> Security & Privacy -> Full Disk Access and check the box for Terminal."
    echo "Once you've done so, quit and reopen Terminal and re-run this script."
    exit 1
fi

echo "Detecting system properties..."
if [ "$(arch)" = "arm64" ]; then
    echo "This script is running on Apple silicon (ARM)."
    arm=true
else
    echo "This script is running an intel processor (x86)."
    arm=false
fi
echo "Done detecting system properties."

echo "Updating MacOS..."
softwareupdate -i -a
add-update macos 'softwareupdate -i -a'

echo "Closing system preferences..."
osascript -e 'tell application "System Preferences" to quit'

echo "Disabling boot sound..."
sudo nvram SystemAudioVolume=" "

echo "Enabling MacOS auto-update..."
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1
sudo defaults write \
    /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled \
    -bool TRUE
sudo defaults write \
    /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload \
    -bool TRUE
sudo defaults write \
    /Library/Preferences/com.apple.SoftwareUpdate \
    AutomaticallyInstallMacOSUpdates \
    -bool TRUE
# App store auto-update
sudo defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdate \
    -bool TRUE

echo "Installing developer tools..."
if ! pkgutil --pkg-info=com.apple.pkg.CLTools_Executables > /dev/null; then
    echo "Please select 'Yes' on the prompt."
    xcode-select --install
    echo "Press any key when done."
    read -r
fi

if [ $arm = true ]; then
    echo "Installing rosetta..."
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license
    echo "Done installing rosetta."
fi

echo "Enabling FileVault..."
if [ "$(sudo fdesetup status)" = "FileVault is Off." ]; then
    # fdesetup scares me. Make user do it manually.
    echo "Please enable filevault."
    open /System/Library/PreferencePanes/Security.prefPane
    read -rp "Press any key once complete."
fi

echo "Installing homebrew..."
if ! which brew; then
    NONINTERACTIVE=1 HOMEBREW_NO_ANALYTICS=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Disabling homebrew analytics..."
brew analytics off

echo "Updating homebrew..."
brew update

echo "Installing homebrew services..."
brew tap homebrew/services

# echo "Cleaning up homebrew installation..."
# brew cleanup

append ~/.zshrc '# Set PATH, MANPATH, etc., for Homebrew.'
append ~/.zshrc 'eval "$(/opt/homebrew/bin/brew shellenv)"'

append ~/.bash_profile 'if [ -f ~/.bashrc ]; then .  ~/.bashrc; fi'
append ~/.bashrc '# Set PATH, MANPATH, etc., for Homebrew.'
append ~/.bashrc 'eval "$(/opt/homebrew/bin/brew shellenv)"'

mkdir -p ~/.config/fish/conf.d/
append ~/.config/fish/conf.d/00_brew.fish 'eval (/opt/homebrew/bin/brew shellenv)'

eval "$(/opt/homebrew/bin/brew shellenv)"

add-update homebrew 'brew update
brew upgrade
brew upgrade --cask --greedy'

# Could've sworn I heard about this in this talk, but can't find it:
# https://xeiaso.net/talks/rustconf-2022-sheer-terror-pam
echo "Enabling touch-id for sudo..."

if ! grep -qe "pam_tid.so" /etc/pam.d/sudo; then
    sudo sed -i '' '2i\
auth       sufficient     pam_tid.so
' /etc/pam.d/sudo
fi

# https://birkhoff.me/make-sudo-authenticate-with-touch-id-in-a-tmux/
brew-get pam-reattach # This is so we can use it in tmux sessions
if ! grep -qe "pam_reattach.so" /etc/pam.d/sudo; then
    sudo sed -i '' '2i\
auth       optional       /opt/homebrew/lib/pam/pam_reattach.so
' /etc/pam.d/sudo
fi

echo "Setting screenshots as jpg and not png, for smaller file size..."
# TODO nvm?
defaults write com.apple.screencapture type png

echo 'Disabling opening previous previewed files (e.g. PDFs) when opening a new one'
defaults write com.apple.Preview ApplePersistenceIgnoreState YES

echo "Showing ~/Library and /Volumes folders..."
chflags nohidden ~/Library
xattr -d com.apple.FinderInfo ~/Library || true
sudo chflags nohidden /Volumes

# https://apple.stackexchange.com/questions/408716/setting-safari-preferences-from-script-on-big-sur
echo "Configuring Safari settings..."
echo "Disabling websites prompting to allow notifications..."
defaults write com.apple.Safari CanPromptForPushNotifications -bool FALSE

echo 'Setting find-in-page to "Contains Match" rather than "Starts with Match"...'
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

echo 'Disabling history auto-erasing (default 1 year)...'
sudo defaults write com.apple.Safari HistoryAgeInDaysLimit -int 365000

echo "Showing the full URL in the address bar (note: this still hides the scheme)..."
sudo defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool TRUE

echo "Showing URLs on hover..."
defaults write com.apple.Safari ShowStatusBar -bool TRUE

echo "Enabling restore of last session on re-launch..."
defaults write com.apple.Safari AlwaysRestoreSessionAtLaunch -bool TRUE

echo 'Setting Safari’s home page to `about:blank` for faster loading...'
defaults write com.apple.Safari HomePage -string "about:blank"

echo "Enabling extenstion auto-update..."
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool TRUE

echo "Switching default search provider to DuckDuckGo..."
defaults write com.apple.Safari SearchProviderShortName 'DuckDuckGo'

echo "Disabling some weasel-worded tracking code..."
defaults write com.apple.Safari "WebKitPreferences.privateClickMeasurementEnabled" -bool FALSE

echo "Enabling developer options..."
defaults write com.apple.Safari IncludeDevelopMenu -bool TRUE
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool TRUE
defaults write com.apple.Safari "WebKitPreferences.developerExtrasEnabled" -bool TRUE
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

echo "Disabling auto-open of files..."
defaults write com.apple.Safari AutoOpenSafeDownloads -bool FALSE

echo "Disabling preloading top hit & safari suggestions so apple doesn't get them..."
defaults write com.apple.Safari PreloadTopHit -bool FALSE
defaults write com.apple.Safari UniversalSearchEnabled -bool FALSE
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

echo "Hiding bookmarks bar..."
defaults write com.apple.Safari ShowFavoritesBar -bool false

echo "Hiding sidebar in top sites..."
defaults write com.apple.Safari ShowSidebarInTopSites -bool false

echo "Disabling auto-fill..."
defaults write com.apple.Safari AutoFillFromAddressBook -bool false
defaults write com.apple.Safari AutoFillPasswords -bool false
defaults write com.apple.Safari AutoFillCreditCardData -bool false
defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false

echo "Warning about fraudulent websites..."
defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

echo "Disabling autoplay..."
defaults write com.apple.Safari WebKitMediaPlaybackAllowsInline -bool false
defaults write com.apple.SafariTechnologyPreview WebKitMediaPlaybackAllowsInline -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false
defaults write com.apple.SafariTechnologyPreview com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false

echo "Enabling do-not-track..."
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

echo "Done configuring Safari settings."

echo "Expanding save panel by default..."
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

echo "Expanding print panel by default..."
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

echo "Setting printer app to quit once print jobs complete..."
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

echo "Displaying control characters in default views..."
# Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

echo "Showing all processes in Activity Monitor..."
defaults write com.apple.ActivityMonitor ShowCategory -int 0

echo "Setting up AdGuard DNS servers..."

# We do this in a weird way so we get DNS-over-HTTPS.
# "networksetup -setdnsservers Wi-Fi servers" would work if we didn't need that.
# Using AdGuard for grapheneos' reasoning:
# https://grapheneos.org/faq#ad-blocking
# > Apps and web sites can detect that ad-blocking is being used and can determine what's being blocked. This can be used as part of fingerprinting users. Using a widely used service like AdGuard with a standard block list is much less of an issue than a custom set of subscriptions / rules, but it still stands out compared to the default of not doing it.
# We'll still do browser-local content blocking as well though. But not for safari, I don't use it much.
# Safari makes actual content blocking hard. See:
# https://github.com/el1t/uBlock-Safari/issues/158

if profiles show | grep -qe "dns.adguard-dns.com"; then
    echo "DNS profile already installed, nothing to do."
else
    echo "DNS profile not yet installed."
    profile_path="$(curl -X POST https://api.adguard-dns.io/public_api/v1/dns/mobile_config --data '{"dns_proto_type":"DOH","filtering_type":"DEFAULT"}' -H 'Content-Type: application/json' | sed -n 's/^{"download_link":"\(.*\)"}$/\1/p')"k
    curl "https://api.adguard-dns.io${profile_path}" > adguard-dns.mobileconfig
    open /System/Library/PreferencePanes/Profiles.prefPane adguard-dns.mobileconfig
    echo "Manual intervention required. Please install profile. Press any key to continue."
    read
    rm adguard-dns.mobileconfig
    echo "Flushing DNS cache..."
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
fi

echo "Always showing scroll bars, instead of just when scrolling..."
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

echo "Enabling tap-to-click..."
# https://osxdaily.com/2014/01/31/turn-on-mac-touch-to-click-command-line/
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool TRUE
sudo defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool TRUE
sudo defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
sudo defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

echo "Setting dock to auto-hide..."
defaults write com.apple.Dock autohide -bool TRUE
killall Dock

echo "Putting screenshots in ~/Screenshots..."
mkdir -p ~/Screenshots
defaults write com.apple.screencapture location "$HOME/Screenshots/"
killall SystemUIServer

echo "Preventing Photos from opening on volume connected..."
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

echo "Setting language and locale..."
defaults write NSGlobalDomain AppleLanguages -array "en-US"
defaults write NSGlobalDomain AppleLocale -string "en_US"
sudo systemsetup -settimezone 'America/Denver' > /dev/null

echo "Configuring Finder..."
echo "Setting new window to open to home directory..."
# note "finder" not "Finder"
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/"

echo "Showing all extensions..."
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool TRUE

echo "Not prompting on extension change..."
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool FALSE

echo "Disabling iCloud bits..."
defaults write com.apple.finder FXEnableRemoveFromICloudDriveWarning -bool FALSE
defaults write NSGlobalDomain "NSDocumentSaveNewDocumentsToCloud" -bool FALSE

echo "Showing hidden files..."
defaults write com.apple.finder "AppleShowAllFiles" -bool "true"

echo "Deleting trash after 30 days..."
defaults write com.apple.finder FXRemoveOldTrashItems -bool TRUE

echo "Setting default view to columns..."
defaults write com.apple.finder "FXPreferredViewStyle" -string "clmv"

echo "Keeping folders on top for sorting..."
defaults write com.apple.finder "_FXSortFoldersFirst" -bool "true"
defaults write com.apple.finder "_FXSortFoldersFirstOnDesktop" -bool "true"

echo "Setting default search scope to current folder, instead of system-wide..."
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

echo "Not creating .DS_Store files on network volumes or USB stores..."
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

echo "Showing full path in title bar..."
defaults write com.apple.finder '_FXShowPosixPathInTitle' -bool true

echo "Enabling Command-Q to quit..."
defaults write com.apple.finder QuitMenuItem -bool true

echo "Hiding tags..."
defaults write com.apple.finder ShowRecentTags -bool FALSE

echo "Modifying Favorites..."
brew-get --cask mysides
echo "Removing airdrop..."
mysides remove / || true
echo "Removing applications..."
mysides remove Applications || true
echo "Adding HOME..."
mysides add "$(whoami)" "file://$HOME/"
echo "Adding dev..."
mkdir -p ~/dev
mysides add "Dev" "file://$HOME/dev/"
echo "Adding screenshots..."
mysides add "Screenshots" "file://$HOME/Screenshots/"

echo "Showing path and status bar..."
defaults write com.apple.finder "ShowPathbar" -bool "true"
defaults write com.apple.finder ShowStatusBar -bool true

killall Finder
echo "Done configuring Finder."

echo "Modifying spotlight search..."
# MENU_SPOTLIGHT_SUGGESTIONS sends search queries to Apple

# TODO I don't think this is working... it isn't changing what it says in sysprefs
#  or what comes out of spotlight.
# Maybe it needs to be in the same order?
# defaults write com.apple.spotlight orderedItems -array \
# 	'{"enabled" = 1;"name" = "APPLICATIONS";}' \
# 	'{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
# 	'{"enabled" = 1;"name" = "DIRECTORIES";}' \
# 	'{"enabled" = 1;"name" = "PDF";}' \
# 	'{"enabled" = 1;"name" = "MENU_DEFINITION";}' \
# 	'{"enabled" = 1;"name" = "MENU_EXPRESSION";}' \
# 	'{"enabled" = 1;"name" = "MENU_CONVERSION";}' \
# 	'{"enabled" = 0;"name" = "FONTS";}' \
# 	'{"enabled" = 0;"name" = "DOCUMENTS";}' \
# 	'{"enabled" = 0;"name" = "MESSAGES";}' \
# 	'{"enabled" = 0;"name" = "CONTACT";}' \
# 	'{"enabled" = 0;"name" = "EVENT_TODO";}' \
# 	'{"enabled" = 0;"name" = "IMAGES";}' \
# 	'{"enabled" = 0;"name" = "BOOKMARKS";}' \
# 	'{"enabled" = 0;"name" = "MUSIC";}' \
# 	'{"enabled" = 0;"name" = "MOVIES";}' \
# 	'{"enabled" = 0;"name" = "PRESENTATIONS";}' \
# 	'{"enabled" = 0;"name" = "SPREADSHEETS";}' \
# 	'{"enabled" = 0;"name" = "SOURCE";}' \
# 	'{"enabled" = 0;"name" = "MENU_OTHER";}' \
# 	'{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'

# Load new settings before rebuilding the index
# killall mds || true
# Make sure indexing is enabled for the main volume
# sudo mdutil -i on /
# Rebuild the index from scratch
# sudo mdutil -E /

echo "Setting terminal to only use utf-8..."
defaults write com.apple.terminal StringEncodings -array 4

echo "Enabling secure keyboard entry..."
# See: https://security.stackexchange.com/a/47786/8918
defaults write com.apple.terminal SecureKeyboardEntry -bool true

echo "Enabling disk utility debug menu..."
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true

echo "Setting TextEdit to use UTF-8 .txt for new files instead of rtf..."
defaults write com.apple.TextEdit "RichText" -bool "false"
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4
defaults write com.apple.TextEdit PlainTextEncoding -int 4

echo "Allowing help viewer to go behind other windows..."
defaults write com.apple.helpviewer "DevMode" -bool "true"

echo "Setting press-and-hold to repeat keys..."
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# This also makes holding delete much faster
defaults write "Apple Global Domain" KeyRepeat -int 2
defaults write "Apple Global Domain" InitialKeyRepeat -int 15

echo "Disabling auto-correct..."
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

echo "Disabling Apple's targeted advertising..."
defaults write "com.apple.AdLib" allowApplePersonalizedAdvertising -bool FALSE
defaults write "com.apple.AdLib" allowIdentifierForAdvertising -bool FALSE

echo "Setting screensaver to activate after 10m..."
defaults -currentHost write com.apple.screensaver idleTime -int 600

echo "Setting sleep to start at 10m..."
sudo pmset -a displaysleep 10
sudo pmset -b sleep 10

# This MAY actually prompt for password immediately. It may also do nothing.
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

echo "Enabling firewall..."
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

echo "Disabling asking if disks should be used for time machine backup..."
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

echo "Making external monitors look a bit better..."
# https://tonsky.me/blog/monitors/
defaults -currentHost write -g AppleFontSmoothing -int 0
defaults write NSGlobalDomain AppleFontSmoothing -int 0
sudo defaults write /Library/Preferences/com.apple.windowserver \
    DisplayResolutionEnabled -bool true

echo "Disabling some keyboard auto-fixers..."
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write "Apple Global Domain" NSAutomaticCapitalizationEnabled \
    -bool FALSE
defaults write "Apple Global Domain" NSAutomaticDashSubstitutionEnabled \
    -bool FALSE
defaults write "Apple Global Domain" NSAutomaticQuoteSubstitutionEnabled \
    -bool FALSE
defaults write "Apple Global Domain" "KB_DoubleQuoteOption" -string "\\"abc\\""
defaults write "Apple Global Domain" "KB_SingleQuoteOption" -string "'abc'"
# Good lady this one was painful to write
defaults write "Apple Global Domain" NSUserQuotesArray \
    -array '"\""' '"\""' "\'" "\'"

echo "Setting computer name to not contain login name..."
sudo scutil --set ComputerName "Computer"
sudo scutil --set LocalHostName "Computer"
sudo scutil --set HostName "Computer"
sudo defaults write \
    /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName \
    -string "Computer"

echo "Installing quicklook plugins..."
if ! defaults read "com.apple.preferences.extensions.QuickLook" | grep -qe QLMarkdown; then
    brew install --cask qlmarkdown
    xattr -r -d com.apple.quarantine /Applications/QLMarkdown.app
    defaults write org.sbarex.QLMarkdown SUEnableAutomaticChecks -bool FALSE
    echo "Opening QLMarkdown to register Extension..."
    open /Applications/QLMarkdown.app && sleep 5 && killall QLMarkdown
fi

if ! defaults read "com.apple.preferences.extensions.QuickLook" | grep -qe SyntaxHighlight; then
    brew install --cask --no-quarantine syntax-highlight
    echo "Opening Syntax Highlight to register extension..."
    open '/Applications/Syntax Highlight.app' &&
        sleep 5 &&
        killall 'Syntax Highlight'
fi
defaults write com.apple.finder QLEnableTextSelection -bool TRUE
echo "Done installing quicklook plugins."

# TODO other shell integration
echo "Installing iTerm2..."
brew-get --cask iterm2
curl -L --no-progress-bar https://iterm2.com/shell_integration/fish \
    -o ~/.config/fish/conf.d/90_iterm2_shell_integration.fish
add-update iterm2 \
    'curl -L --no-progress-bar https://iterm2.com/shell_integration/fish \
    -o ~/.config/fish/conf.d/90_iterm2_shell_integration.fish'

# Makes copying dotfiles easier
# https://imarslo.gitbook.io/handbook/gitbook/app/iterm2
# TODO check out this doc more
defaults write com.googlecode.iterm2 "Coprocess MRU" -int 0

brew tap homebrew/cask-fonts
brew-get --cask font-roboto font-blex-mono-nerd-font

echo "Installing GNU utilities..."
brew-get \
    bash \
    gawk \
    wget \
    parallel \
    gnu-time \
    gettext \
    grep \
    less \
    gsed \
    gnu-tar \
    gnupg \
    aspell \
    findutils \
    grep \
    coreutils \
    binutils \
    diffutils \
    readline

echo "will cite" | parallel --citation

add-update gpg 'gpg --refresh-keys'

echo "Installing various utilities..."
brew-get \
    git \
    bash-completion \
    bash-language-server \
    zsh-completions \
    vim \
    dict \
    fish \
    tree \
    jq \
    yq \
    htop \
    watch \
    cowsay \
    sl \
    ddate \
    gifsicle \
    ffmpeg \
    gh \
    pandoc \
    tmux \
    pinentry-mac \
    imagemagick \
    openssl \
    openssh \
    lynx \
    html2text \
    direnv \
    jump \
    reattach-to-user-namespace

brew unlink openssh # needed so we can UseKeychain

brew-get --HEAD universal-ctags/universal-ctags/universal-ctags

echo "Installing zsh plugins..."
brew-get \
    zsh-syntax-highlighting

echo "Installing next-gen CLI utilities..."
brew-get \
    git-delta \
    git-absorb \
    exa \
    bat \
    duf \
    fzf \
    tldr \
    fd \
    ripgrep \
    ripgrep-all \
    hyperfine \
    tz \
    mdcat

add-update tldr 'tldr --update'

/opt/homebrew/opt/fzf/install --all
add-update fzf '/opt/homebrew/opt/fzf/install --all'

echo "Installing texlive..."
brew-get texlive

echo "Adding bash completion..."
append ~/.bashrc \
    "[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion"

echo "Adding zsh completion to zshrc..."
append ~/.zshrc 'if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
    autoload -Uz compinit
    compinit
    autoload bashcompinit && bashcompinit # Unsure if this is needed
fi'
rm -f ~/.zcompdump

# https://unix.stackexchange.com/questions/383365/zsh-compinit-insecure-directories-run-compaudit-for-list
zsh -c 'autoload -Uz compinit && compinit && compaudit | xargs chmod g-w'

echo "Setting editor..."
append ~/.bashrc 'export EDITOR=vim'
append ~/.zshrc 'export EDITOR=vim'
append ~/.config/fish/conf.d/10_editor.fish 'set -x EDITOR vim'

echo "Installing fisher..."
fish -c 'curl -sL https://git.io/fisher | source && \
    fisher install jorgebucaran/fisher'
add-update fisher 'fish -c "fisher update"'

echo "Configuring starship..."
brew-get starship

append ~/.zshrc 'eval "$(starship init zsh)"'
append ~/.bashrc 'eval "$(starship init bash)"'
append ~/.config/fish/conf.d/99_starship.fish 'starship init fish | source'

echo "Installing python via pyenv..."
brew-get pyenv

# TODO consolidate appends
append ~/.bashrc 'export PYENV_ROOT="$HOME/.pyenv"'
append ~/.bashrc \
    'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"'
append ~/.bashrc 'eval "$(pyenv init -)"'
append ~/.bashrc 'export PYTHON_CONFIGURE_OPTS="--enable-framework"'

append ~/.zshrc 'export PYENV_ROOT="$HOME/.pyenv"'
append ~/.zshrc \
    'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"'
append ~/.zshrc 'eval "$(pyenv init -)"'
append ~/.zshrc 'export PYTHON_CONFIGURE_OPTS="--enable-framework"'

fish -c 'set -Ux PYENV_ROOT $HOME/.pyenv'
fish -c 'set -U fish_user_paths $PYENV_ROOT/bin $fish_user_paths'

append ~/.config/fish/conf.d/30_pyenv.fish 'pyenv init - | source'
append ~/.config/fish/conf.d/30_pyenv.fish \
    'set -x PYTHON_CONFIGURE_OPTS "--enable-framework"'

# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
brew-get openssl readline sqlite3 xz zlib tcl-tk

eval "$(pyenv init -)"
# Install latest stable python
pyenv install --skip-existing \
    "$(pyenv install --list | sed 's/ //g' | ggrep -P '^[\d\.]+$' | tail -n 1)"
pyenv global "$(pyenv latest 3)"

git clone https://github.com/pyenv/pyenv-update.git $(pyenv root)/plugins/pyenv-update

# Update pyenv and plugins
add-update pyenv 'pyenv update'

# Update to latest python from pyenv
# https://stackoverflow.com/questions/4664229/here-document-as-an-argument-to-bash-function
# This is really cool; it lets us not have to escape anything.
add-update pyenv "$(
    cat << "EOF"
pyenv install --skip-existing \
    "$(pyenv install --list | sed 's/ //g' | ggrep -P '^[\d\.]+$' | tail -n 1)"
pyenv global "$(pyenv latest 3)"
EOF
)"

# Update installed fellas from each pyenv
add-update pyenv "$(
    cat << "EOF"
pyenv versions --bare |
    gxargs -d \$'\n' bash -c $'eval "$(pyenv init -)";
    for arg; do
        pyenv shell $arg
        python --version
        python -m pip install --upgrade pip
        pip list --format=freeze |
            grep -v "^\-e" |
            cut -d = -f 1 |
            xargs -n1 pip install -U
    done' _
EOF
)"

# We also have to add updates for brew python packages
# TODO figure out expected fails like libtorrent
add-update brew-python "$(
    cat << "EOF"
# Update pip itself
brew list |
    sed -rn 's/python@(.+)/\1/p' |
    xargs -I{} bash -c '/opt/homebrew/bin/"python{}" -m pip install --upgrade pip'

# Update packages installed by pip
brew list |
    sed -rn 's/python@(.+)/\1/p' |
    xargs -I{} bash -c '/opt/homebrew/bin/"pip{}" list --format=freeze |
        grep -v "^\-e" |
        cut -d = -f 1 |
        xargs -n1 pip{} install -U'
EOF
)"

echo "Installing python packages..."
brew-get pkg-config poppler python
mkdir -p ~/.config/python
# This is where I'm keeping my binaries to bring with on new python versions
append ~/.config/python/global-requirements.txt "pdftotext"
pip install -r  ~/.config/python/global-requirements.txt
add-update pyenv 'pip install -r ~/.config/python/global-requirements.txt'

#TODO should I use asdf, or fnm?
# https://github.com/Schniz/fnm ooh its rust
echo "Installing node and nvm..."
# brew-get nvm node
# TODO make this use latest tag
# Review if appends are needed
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
mkdir -p ~/.nvm

append ~/.zshrc 'export NVM_DIR="$HOME/.nvm"'
append ~/.zshrc '[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"'
append ~/.zshrc '[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"'

append ~/.bashrc 'export NVM_DIR="$HOME/.nvm"'
append ~/.bashrc '[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"'
append ~/.bashrc '[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"'

fish -c 'fisher install jorgebucaran/nvm.fish'

# So despite installing nvm, we're going to use homebrew node for everything global.
set +u
# TODO fix
# source /opt/homebrew/opt/nvm/nvm.sh
# nvm use system
set -u

add-update npm 'npm update -g'

echo "Installing go..."
brew-get go

append ~/.bashrc 'export PATH=$PATH:$(go env GOPATH)/bin'
append ~/.bashrc 'export GOPATH="$HOME/go"'

append ~/.zshrc 'export PATH=$PATH:$(go env GOPATH)/bin'
append ~/.zshrc 'export GOPATH="$HOME/go"'

mkdir -p "$HOME/go/bin"
fish -c 'set -Ux GOPATH $HOME/go'
fish -c 'set -U fish_user_paths $(go env GOPATH)/bin $fish_user_paths'

echo 'Installing gup (go global update)'
go install github.com/nao1215/gup@latest
add-update go "gup update"

echo "Installing rust..."
brew-get rustup
rustup-init -y
source "$HOME/.cargo/env"

append ~/.bashrc 'export PATH=$PATH:~/.cargo/bin'
append ~/.zshrc 'export PATH=$PATH:~/.cargo/bin'
fish -c 'set -U fish_user_paths ~/.cargo/bin $fish_user_paths'

cargo install cargo-update

add-update rust "cargo install-update -a"
add-update rust "rustup update"

echo "Installing ruby..."
brew-get rbenv ruby-build
brew-get autoconf automake gdbm gmp \
    libksba libtool libyaml openssl pkg-config readline

append ~/.bashrc 'eval "$(rbenv init - bash)"'
append ~/.zshrc 'eval "$(rbenv init - zsh)"'
append ~/.config/fish/conf.d/52_rbenv.fish \
    "status --is-interactive; and rbenv init - fish | source"

# we're not using homebrew ruby because of package shennanigans
rbenv install "$(rbenv install -l | grep -v - | tail -1)" --skip-existing
if [ "$(rbenv global)" = system ]; then
    rbenv global "$(rbenv versions | tail -n1 | sed 's/ //g')"
fi

# Disables doc generation, speeding up gem installs
append ~/.gemrc 'gem: --no-ri --no-rdoc'

latest="$(rbenv install -l | grep -v - | tail -1)"
if [ ! "$(rbenv global)" = "$latest" ]; then
    echo "updateme"
fi

add-update ruby 'gem update --system && gem update'

echo 'Installing Java \(Temurin 8, 11, 17\) with jenv...'
brew tap homebrew/cask-versions
brew update
brew tap homebrew/cask
brew-get --cask temurin8 temurin11 temurin17
brew-get jenv

append ~/.bashrc 'export PATH="$HOME/.jenv/bin:$PATH"'
append ~/.bashrc 'eval "$(jenv init -)"'

append ~/.zshrc 'export PATH="$HOME/.jenv/bin:$PATH"'
append ~/.zshrc 'eval "$(jenv init -)"'

append ~/.config/fish/conf.d/53_jenv.fish 'set PATH "$HOME"/.jenv/bin "$PATH"'
append ~/.config/fish/conf.d/53_jenv.fish \
    "status --is-interactive; and jenv init - | source"

jenv add /Library/Java/JavaVirtualMachines/temurin-8.jdk/Contents/Home
jenv add /Library/Java/JavaVirtualMachines/temurin-11.jdk/Contents/Home
jenv add /Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
# jenv enable-plugin export # Not for fish! Disable for fish!

echo "Installing perl via perlbrew..."
if ! type perlbrew; then
    SHELL=bash curl -L https://install.perlbrew.pl | bash
fi

append ~/.bashrc 'source ~/perl5/perlbrew/etc/bashrc'
append ~/.zshrc 'source ~/perl5/perlbrew/etc/bashrc'
append ~/.config/fish/conf.d/13_perlbrew.fish \
    '. ~/perl5/perlbrew/etc/perlbrew.fish'

set +u
SHELL=bash source "$HOME/perl5/perlbrew/etc/bashrc"
set -u
SHELL=bash perlbrew init

latest="$(perlbrew available | /usr/bin/sed -nE 's/.*(perl-.*)/\1/p' | head -n1 | tr -d '[:space:]')"
if ! perlbrew list | grep -qF "$latest"; then
    perlbrew install "$latest"
fi
perlbrew switch "$latest"

if [ ! -f "$PERLBREW_ROOT/bin/cpanm" ]; then
    perlbrew install-cpanm --yes
fi

# TODO global perl deps
cpanm Perl::Critic
cpanm CPAN::DistnameInfo
cpanm Text::Levenshtein
cpanm Log::Log4perl
cpanm Term::ReadLine::Perl
cpanm App::cpanoutdated

# add-update perl 'yes | perl -MCPAN -e "upgrade /(.\*)/"'
add-update perl 'cpanm --self-upgrade || perlbrew install-cpanm --yes'
add-update perl 'cpan-outdated -p | cpanm'

echo "Installing lua via brew..."
brew-get lua luarocks

echo "Installing linters and fixers..."
# bash
brew-get \
    shellcheck \
    shfmt \
    bash-language-server

pip install bashate

# cloudformation
brew-get cfn-lint

# css
npm i -g vscode-langservers-extracted

# docker
npm install -g dockerfile_lint
brew-get hadolint

# git
brew-get gitlint

# go handled by vim-go

# graphql
npm install -g gqlint

# HCL
brew tap hashicorp/tap
brew-get \
    hashicorp/tap/packer \
    hashicorp/tap/terraform \
    hashicorp/tap/terraform-ls \
    tflint \
    tfsec \
    checkov

# Skipping java bc lazy rn
# Same for js

# json
npm install jsonlint -g

# kotlin
brew-get \
    kotlin-language-server \
    kotlin \
    ktlint

# latex
brew-get texlab

#lua
brew-get stylua
luarocks install luacheck
luarocks install lanes
# TODO global lua deps
add-update luarocks 'luarocks install luacheck'
add-update luarocks 'luarocks install lanes'

#md
brew-get markdownlint-cli

# perl
cpanm Perl::Critic

# protobuf
brew tap bufbuild/buf
brew-get bufbuild/buf/buf

# python
# This way these come with us to new python versions
append ~/.config/python/global-requirements.txt 'black'
append ~/.config/python/global-requirements.txt 'isort'
append ~/.config/python/global-requirements.txt 'autoflake'
append ~/.config/python/global-requirements.txt 'bandit[toml]'
append ~/.config/python/global-requirements.txt 'vulture'
append ~/.config/python/global-requirements.txt 'mypy'
append ~/.config/python/global-requirements.txt 'pylint'
append ~/.config/python/global-requirements.txt 'mccabe'
append ~/.config/python/global-requirements.txt 'pylsp-rope'
append ~/.config/python/global-requirements.txt 'python-lsp-server[rope]'
pip install -r  ~/.config/python/global-requirements.txt

# puppet
gem install puppet-lint

# rust
rustup component add rust-src
rustup component add rust-analyzer
ln -sf "$(rustup which --toolchain stable rust-analyzer)" ~/.cargo/bin/

# typescript
npm install -g typescript \
    ts-node

# TODO text valerc
brew-get \
    vale \
    languagetool \
    redpen

add-update vale 'vale sync'

npm install alex --global

# vim
npm install -g vim-language-server
pip install vim-vint

# xml
brew-get libxml2
ln -sf /opt/homebrew/opt/libxml2/bin/xmllint /opt/homebrew/bin/

# yaml
npm install -g yaml-language-server
brew-get yamllint

# TODO sdkman

echo "Installing Docker..."
brew-get --cask Docker
# Not bothering with k8s. I do not see myself using it for local dev.

# Bash completion
etc=/Applications/Docker.app/Contents/Resources/etc
ln -sf "$etc"/docker.bash-completion \
    "$(brew --prefix)"/etc/bash_completion.d/docker
ln -sf "$etc"/docker-compose.bash-completion \
    "$(brew --prefix)"/etc/bash_completion.d/docker-compose

# zsh completion
ln -sf "$etc"/docker.zsh-completion \
    "$(brew --prefix)"/share/zsh/site-functions/_docker
ln -sf "$etc"/docker-compose.zsh-completion \
    "$(brew --prefix)"/share/zsh/site-functions/_docker-compose

# fish completion
mkdir -p ~/.config/fish/completions
ln -sf "$etc"/docker.fish-completion \
    ~/.config/fish/completions/docker.fish
ln -sf "$etc"/docker-compose.fish-completion \
    ~/.config/fish/completions/docker-compose.fish

echo "Installing Firefox..."
brew-get --cask firefox

echo "Installing Discord..."
brew-get --cask discord

echo "Installing Bitwarden..."
brew-get --cask bitwarden
brew-get bitwarden-cli

echo "Installing lunar..."
brew-get --cask lunar
# TODO configure lunar
# TODO night and day configs
# TODO test
defaults write fyi.lunar.Lunar SUAutomaticallyUpdate -bool false
defaults write fyi.lunar.Lunar SUHasLaunchedBefore -bool true
defaults write fyi.lunar.Lunar adaptiveBrightnessMode -string '"Manual"'
defaults write fyi.lunar.Lunar completedOnboarding -bool true
defaults write fyi.lunar.Lunar launchCount -int 42424242 # just to mess with analytics
defaults write com.lunar.Lunar lunarProActive -bool false
defaults write com.lunar.Lunar lunarProOnTrial -bool false
defaults write com.lunar.Lunar lunarProAccessDialogShown -bool true

echo "Installing keepingyouawake..."
brew-get --cask keepingyouawake
# TODO settigns

echo "Installing Signal..."
brew-get --cask signal

echo "Installing VLC..."
brew-get --cask vlc

echo "Installing Calibre..."
brew-get --cask calibre

echo "Installing LibreOffice..."
brew-get --cask libreoffice

echo "Installing Nextcloud..."
brew-get --cask nextcloud

echo "Installing veracrypt..."
brew-get --cask veracrypt
# TODO print this mayb
# macfuse requires a kernel extension to work.
#If the installation fails, retry after you enable it in:
#  System Preferences → Security & Privacy → General

#For more information, refer to vendor documentation or this Apple Technical Note:
#  https://developer.apple.com/library/content/technotes/tn2459/_index.html

echo "Installing rectangle..."
brew-get --cask rectangle
defaults write "com.knollsoft.Rectangle" SUEnableAutomaticChecks -bool FALSE
defaults write "com.knollsoft.Rectangle" alternateDefaultShortcuts -bool TRUE
defaults write "com.knollsoft.Rectangle" launchOnLogin -bool TRUE
defaults write "com.knollsoft.Rectangle" SUHasLaunchedBefore -bool TRUE

# TODO only do this if not installed yet
open '/Applications/Rectangle.app'
# Needed because we can't write to Accessibility without SIP disabled
# https://github.com/jacobsalmela/tccutil#sip-notice
echo "Follow prompts in app, then press enter to continue."
read -r
echo "Done installing rectangle."

echo "Installing moonlander config software..."
# brew tap homebrew/cask-drivers
brew-get zsa-wally libusb
go install github.com/zsa/wally-cli@latest
# TODO flash firmware

# TODO add bitwarden
# https://github.com/kcrawford/dockutil/issues/127
# https://github.com/pivotal/workstation-setup/blob/main/scripts/common/configuration-osx.sh
echo "Cleaning up Dock..."
brew-get --cask hpedrorodrigues/tools/dockutil
dockutil --list |
    awk -F'\t' '{print "dockutil --remove \""$1"\" --no-restart"}' |
    sh
dockutil --add /Applications/Firefox.app --no-restart
dockutil --add /Applications/iTerm.app --no-restart
# dockutil --add /System/Applications/Utilities/Terminal.app --no-restart
dockutil --add /System/Applications/System\ Settings.app --no-restart
killall Dock

echo "Setting default browser..."
# Forked so I have my own copy of the code
# This way I have read all of it, and don't have to trust as much
# that future updates won't break things

if [ ! -d ~/dev/defaultbrowser ]; then
    git clone \
        https://github.com/riley-martine/defaultbrowser \
        ~/dev/defaultbrowser
fi
cd ~/dev/defaultbrowser
git pull
make

# https://www.felixparadis.com/posts/how-to-set-the-default-browser-from-the-command-line-on-a-mac/
./defaultbrowser firefox && osascript << EOF
try
	tell application "System Events"
		tell application process "CoreServicesUIAgent"
			tell window 1
				tell (first button whose name starts with "use")
					perform action "AXPress"
				end tell
			end tell
		end tell
	end tell
end try
EOF

cd -

login_bitwarden() {
    echo "Logging in to bitwarden CLI..."
    echo "This is necessary for generating and storing passwords."
    if ! bw login --check > /dev/null; then
        export BW_SESSION="$(bw login riley.martine@protonmail.com | sed -E -n 's/\$ export BW_SESSION="(.*)"/\1/p')"
    else
        if [ -z "${BW_SESSION-}" ] || [ "$(bw status | jq -r '.status')" != unlocked ]; then
            export BW_SESSION="$(bw unlock | sed -E -n 's/\$ export BW_SESSION="(.*)"/\1/p')"
        fi
    fi
}

login_github() {
    echo "Logging in to github..."
    if ! gh auth status; then
        open https://github.com/login/device
        GH_PROMPT_DISABLED="true" gh auth login \
            --hostname github.com \
            --git-protocol ssh \
            --scopes write:gpg_key admin:public_key
    fi
}

# https://serverfault.com/questions/818289/add-second-sub-key-to-unattended-gpg-key#962553
echo "Generating GPG key for github..."
if ! gpg --list-secret-keys | grep -q github; then
    login_bitwarden
    login_github

    # https://bitwarden.com/help/cli/#create
    GPG_PASS_ID="$(bw get template item | jq ".type = 2 | .secureNote.type = 0 | .notes = \"$(bw generate --length 32)\" | .name = \"GPG key MacOS $(date)\"" | bw encode | bw create item | jq -r '.id')"
    bw sync
    GPG_PASS="$(bw get notes "$GPG_PASS_ID")"

    KEYID="$(
           gpg \
              --with-colons --batch --status-fd=1 \
              --passphrase "$GPG_PASS" \
              --quick-generate-key \
              "Oneirophage (codeberg) <oneirophage@pm.me>" \
                  default cert 1y |
            sed -E -n 's/\[GNUPG:\] KEY_CREATED P (.*)/\1/p'
    )"
    gpg --batch --passphrase "$GPG_PASS" --pinentry-mode loopback \
        --quick-add-key "$KEYID" default sign 1y
    gpg --batch --passphrase "$GPG_PASS" --pinentry-mode loopback \
        --quick-add-key "$KEYID" default encrypt 1y

    gpg --armor --export "$KEYID" | gh gpg-key add

    # https://gist.github.com/bmhatfield/cc21ec0a3a2df963bffa3c1f884b676b
    brew-get pinentry-mac
    append ~/.gnupg/gpg-agent.conf \
        "pinentry-program $(brew --prefix)/bin/pinentry-mac"
    append ~/.gnupg/gpg.conf "use-agent"
    gpgconf --kill gpg-agent

    # Fragile! This signs something w/ the pw and in doing so, adds to the MacOS keychain.
    echo test | gpg --clearsign &
    osascript << EOF
delay 2
try
    tell application "System Events"
        tell application process "CoreServicesUIAgent"
            tell window 1
                keystroke "$GPG_PASS"
                keystroke return
            end tell
        end tell
    end tell
end try
EOF

fi

echo "Generating ssh key for github..."
mkdir -p ~/.ssh

brew unlink openssh # needed so we can UseKeychain
append ~/.ssh/config "Host *.github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_github"

if [ ! -f ~/.ssh/id_github ]; then
    login_bitwarden
    login_github

    SSH_PASS_ID="$(bw get template item |
        jq ".type = 2 | \
            .secureNote.type = 0 | \
            .notes = \"$(bw generate --length 32)\" | \
            .name = \"Github SSH key MacOS $(date)\"" |
        bw encode |
        bw create item |
        jq -r '.id')"

    bw sync
    SSH_PASS="$(bw get notes "$SSH_PASS_ID")"

    ssh-keygen \
        -t ed25519 \
        -C "riley.martine@protonmail.com" \
        -f ~/.ssh/id_github \
        -N "$SSH_PASS"

    # https://stackoverflow.com/questions/13033799/how-to-make-ssh-add-read-passphrase-from-a-file
    mask="$(umask)"
    umask 077
    ap=$(mktemp)
    [ -f "${ap}" ] && cat << EOF > "$ap"
#!/bin/bash
# Parameter $1 passed to the script is the prompt text
# READ Secret from STDIN and echo it
read SECRET
echo "\$SECRET"
EOF
    chmod +x "$ap"

    SSH_ASKPASS_REQUIRE=force SSH_ASKPASS="$ap" /usr/bin/ssh-add \
        --apple-use-keychain ~/.ssh/id_github <<< "$SSH_PASS"

    rm "${ap}"
    umask "$mask"

fi

# https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
# work machine has thing i wrote how to make it do keychain I think...

echo "Setting default shell to fish..."
if ! grep -qe "/opt/homebrew/bin/fish" /etc/shells; then
    echo "/opt/homebrew/bin/fish" | sudo tee -a /etc/shells
fi

if ! grep -q fish < "$(perl -e '@pw = getpwuid $< ; print $pw[8], "\n"')"; then
    chsh -s "$(which fish)"
fi

echo "Setting PATH to include ~/bin..."
fish -c 'set -U fish_user_paths $HOME/bin $fish_user_paths'
# TODO bash and zsh

echo "Installing fonts..."
brew tap homebrew/cask-fonts
# TODO replace w/ the one I want
brew-get --cask font-meslo-lg-nerd-font

echo "Installing sundial..."
brew tap riley-martine/sundial https://github.com/riley-martine/sundial
brew-get riley-martine/sundial/sundial
sundial --city Denver

echo "Configuring dotfiles..."
mkdir -p ~/dev
if [ ! -d ~/dev/dotfiles ]; then
    git clone https://github.com/riley-martine/dotfiles ~/dev/dotfiles
fi
cd ~/dev/dotfiles

git fetch --all
if [ "$(git rev-parse @)" != "$(git rev-parse '@{u}')" ]; then
    git pull # Not always correct, but good enough. Fails on error st8.
fi

# Copy dotfile from a repo to local machine.
# If not exists, copy it in.
# If exists, then
#   If same file by sha256sum, skip
#   Else prompt with delta
copy_dotfile() {
    local from="$1"
    local to="$2"

    mkdir -p "$(dirname "$to")"

    if [ ! -f "$to" ]; then
        cp "$from" "$to"
        return 0
    fi

    if [ "$(sha256sum "$from" | cut -d' ' -f1)" = "$(sha256sum "$to" | cut -d' ' -f1)" ]; then
        echo "Existing file is the same as remote file."
        return 0
    fi

    delta "$from" "$to" || true
    cp -i "$from" "$to" || true
}

echo "Installing tmux conf..."
copy_dotfile "tmux/.tmux.conf" "$HOME/.tmux.conf"
copy_dotfile "tmux/tokyonight_day.tmux" \
    "$HOME/.config/tmux/tokyonight_day.tmux"
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
~/.tmux/plugins/tpm/bin/install_plugins
~/.tmux/plugins/tpm/bin/update_plugins all
add-update tpm '~/.tmux/plugins/tpm/bin/update_plugins all'

# See also:
# https://gist.github.com/bbqtd/a4ac060d6f6b9ea6fe3aabe735aa9d95
# https://github.com/tmux/tmux/issues/2262
# TODO switch to https://gpanders.com/blog/the-definitive-guide-to-using-tmux-256color-on-macos/
echo "Adding tmux-256color terminal info..."
umask 077
file=$(mktemp)
[ -f "${file}" ] && curl --silent https://gist.githubusercontent.com/nicm/ea9cf3c93f22e0246ec858122d9abea1/raw/37ae29fc86e88b48dbc8a674478ad3e7a009f357/tmux-256color >"${file}"
sudo /usr/bin/tic -x "${file}"
rm "${file}"

echo "Installing vim conf..."
copy_dotfile "vim/vimrc" "$HOME/.vim/vimrc"
curl --no-progress-bar -fLo  ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# YCM reqs
# Unsure if e.g. nvm node yields a completer. See:
# https://github.com/ycm-core/YouCompleteMe#installation
brew install cmake
vim +PlugUpgrade +PlugInstall +PlugUpdate +qall
add-update vim 'vim +PlugUpgrade +PlugInstall +PlugUpdate +qall'

#TODO review and make sure we got em all
#better, unify w/ diff.sh
copy_dotfile "starship/starship.toml" "$HOME/.config/starship.toml"

copy_dotfile "git/.gitconfig" "$HOME/.gitconfig"
copy_dotfile "git/identity.gitconfig" "$HOME/.config/git/identity.gitconfig"
copy_dotfile "git/tokyonight_day.gitconfig" \
    "$HOME/.config/git/tokyonight_day.gitconfig"
copy_dotfile "git/gitmessage" "$HOME/.config/git/gitmessage"
copy_dotfile "git/gitignore" "$HOME/.config/git/gitignore"

copy_dotfile "bat/tokyonight_day.tmTheme" \
    "$HOME/.config/bat/themes/tokyonight_day.tmTheme"
bat cache --build

copy_dotfile "fish/fish_plugins" "$HOME/.config/fish/fish_plugins"
copy_dotfile "fish/config.fish" "$HOME/.config/fish/config.fish"
copy_dotfile "fish/themes/tokyonight_day.fish" \
    "$HOME/.config/fish/themes/tokyonight_day.fish"
fish -c 'fisher update'
add-update fisher 'fish -c "fisher update"'

copy_dotfile "bin/random-words" "$HOME/bin/random-words"

copy_dotfile "bin/update.d/lulu.sh" "$HOME/.local/share/update.d/lulu.sh"

# https://apple.stackexchange.com/questions/344401/how-to-programatically-set-terminal-theme-profile
theme=$(< terminal.app/Tokyonight\ Day.xml)
plutil -replace Window\ Settings.Tokyonight\ Day \
    -xml "$theme" ~/Library/Preferences/com.apple.Terminal.plist
defaults write com.apple.Terminal \
    "Default Window Settings" -string "Tokyonight Day"
defaults write com.apple.Terminal \
    "Startup Window Settings" -string "Tokyonight Day"

cd -

# TODO stackexchange all sites only necessary cookies
#   This depends on ubo settings:
# stackexchange.com##.js-consent-banner
# stackoverflow.com##.js-consent-banner
# superuser.com##.js-consent-banner
# askubuntu.com##.js-consent-banner
# https://meta.stackoverflow.com/questions/406344/cookie-settings-on-every-page

# TODO switch known tn themes to real repo
# TODO iTerm2 settings
# TODO lunar prefs disable pro check
# TODO make look pretty w brew install script bits
# TODO install non-brew list (gem, npm, go, etc)
# TODO remove safari favorites
# TODO sudo delay increase
# TODO casks don't launch if already configured
# TODO auto-update disable in syntax-highlight
# TODO change control keys
# TODO disable tips
# TODO NVM Fish https://github.com/nvm-sh/nvm#important-notes
# TODO .zshenv vs .zprofile vs .zshrc vs .profile etc
# TODO Docker config
# TODO appleID/find my mac?
# TODO firefox config (incl UBO config)
# TODO night shift
# todo  turn off Location Services for Spotlight Suggestions and Safari Suggestions,
# TODO disable location services for "analytics"
# TODO set require password immediately from CLI
# TODO Select System Preferences > Spotlight > Search Results, and ensure that Siri Suggestions is not enabled.
# TODO night shift
# TODO set notification prefs defaults read "com.apple.ncprefs" apps to disable tips
# TODO set caps to control
# TODO enable firewall
# TODO Storage Remove Garage Band & Sound Library Remove iMovie
# TODO bitwarden setup (enable touchid)
# TODO ohmyzsh
# TODO update script incl nvm install node --reinstall-packages-from=node
# TODO check out git duet https://github.com/pivotal/workstation-setup/blob/25e73693f5f2e991f7c08c039fd6ae42abc2a390/scripts/common/git.sh#L14
# TODO remove sidebar widgets
# TODO install dictionaries
# TODO hide spotlight tray icon
# TODO gum
# TODO uhh nextcloud plubming calendar notes sync etc
# # TODO system prefs close windows when quitting an app
# TODO tn vim theme
# TODO vlc english default subs
# TODO prefixed vs not coreutils
# TODO should I have like, brewfiles?
# TODO look into nix
# TODO add little snitch downloading and registering and preferencing
# TODO work and personal profile
# TODO pre-commit
# TODO try pipx
# TODO try direnv + pyenv
# TODO version control torrent scripts + plist
#     AND BREW THEM HOLY HELL SERVICES
# TODO Syncthing
# TODO https://github.com/tmux/tmux/issues/3218
# TODO undercurl proper tic overrides
# TODO https://github.com/term7/MacOS-Privacy-and-Security-Enhancements/tree/main
# TODO https://furbo.org/2015/03/30/paste-without-style/

echo "The following must be done manually:"
echo '  - Finder -> Preferences -> Sidebar
        -> Locations -> Uncheck iCloud Drive'
