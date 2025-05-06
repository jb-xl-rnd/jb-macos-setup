#!/bin/bash
# setupMacOS.sh
#
# Description: Comprehensive setup script for macOS applications and configurations
# - Updates macOS built-in software
# - Installs various command line utilities via Homebrew
# - Installs GUI applications via Homebrew Cask
# - Installs applications from the Mac App Store
# - Sets up Python development environment
# - Configures shell with useful functions and aliases
# - Sets up LaTeX environment for document preparation
# - Configures development tools for various domains (3D printing, electronics, etc.)

# Update Built-in Software
softwareupdate --install -a

# Install desired packages and applications
brew install neovim
brew install ffmpeg
brew install iterm2
brew install nmap
brew install rectangle
brew install bash-git-prompt
brew install mailsy
brew install wifi-password
brew install mas
brew install mpv
brew install htop
brew install yt-dlp     # redundant with mpv, maybe remove?
brew install jq
brew install nvtop      # doesn't do much on apple silicon but fun to see
brew install orbstack   # Performant Virtualization tool for Apple Silicon ONLY
brew install tmux

brew install libusb
pip3 install pyftdi adafruit-blinka
pip3 install adafruit-circuitpython-bme280

# App Store Installs using MAS, use the share app link to identify
# FIXME: temporarily hard linking here, should use some find automation maybe
# 1246969117  Steam Link    (1.2.0)
mas install 1246969117
# 1475387142 Tailscale for P2P VPN
mas install 1475387142
# 549083868 Display Menu for multi-window control & resolution control
mas install 549083868

# Install Firefox Developer Edition
brew tap homebrew/cask-versions
# Testing brave
brew install --cask brave-browser
# brew install --cask firefox-developer-edition

# MAS (Mac App Store Emulator) Automates App Store App Installation
# TODO: have not figured out App Store automation yet,
#  DISPLAY MENU: https://apps.apple.com/us/app/display-menu/id549083868?mt=12

# Install other cask applications
brew install --cask keepassxc
brew install --cask steam
# brew install --cask thunderbird
# For now testing Betterbird
brew install --cask visual-studio-code
brew install --cask discord
brew install --cask vlc
brew install --cask obs
brew install --cask zotero
brew install --cask spotify
brew install --cask autodesk-fusion360
brew install --cask raspberry-pi-imager
brew install --cask gimp
brew install --cask prusaslicer
brew install --cask ltspice
brew install --cask openvpn-connect
brew install --cask sublime-text
brew install --cask drawio
brew install --cask balenaetcher # TODO: Find a better image writer
brew install --cask arc           # TODO: still in evaluation

# Default Apps
brew install google-chrome
brew tap tsonglew/dutis https://github.com/tsonglew/dutis
brew install dutis      # Default App Setter, quite useful until Apple Fixes their crap
# brew install neofetch   # seems to be as good as the apt version, gives system stats in command line
brew install macchina   # Replaces neofetch as a more up to do package, replace in other OS'es

# Define variables
ZSHRC="$HOME/.zshrc"
NEOFETCH_COMMAND="neofetch"
MACCHINA_COMMAND="macchina"
ALIAS_COMMAND="alias neofetch='echo \"neofetch is not installed, using macchina instead\"; macchina'"

# Check if neofetch is installed
if ! command -v $NEOFETCH_COMMAND &> /dev/null; then
  # Check if .zshrc already contains the alias
  if ! grep -q "$ALIAS_COMMAND" "$ZSHRC"; then
    echo "Adding alias for neofetch to .zshrc..."
    echo "\n$ALIAS_COMMAND" >> "$ZSHRC"
  else
    echo "Alias for neofetch already exists in .zshrc."
  fi
else
  echo "neofetch is already installed."
fi

echo "Done. Please restart your terminal or run 'source ~/.zshrc' to apply changes."


# AI local for testing
# brew install ollama

# ##### vscode stuff

# Install MacTeX
brew install --cask mactex
echo "MAY REQUIRE RESTART OF BASH!"

# Install Homebrew Packages
brew install gnuplot imagemagick
brew install --cask skim

# LaTeX Packages Installation
sudo tlmgr update --self
sudo tlmgr install latexmk subfiles ctablestack luacode luatex85 silence emptypage framed biblatex logreq xstring chngcntr sectsty minted fvextra ifplatform ifoddpage relsize csquotes pgfplots circuitikz paralist enumitem glossaries datatool glossaries-english glossaries-italian glossaries-german mfirstuc xfor substr imakeidx fourier utopia quotchap soul collection-fontsrecommended algorithm2e xargs stanli preview standalone tikz-qtree latexindent

# CPAN and Dependencies for latexindent
sudo tlmgr option repository ctan
sudo cpan -fi Log::Dispatch Log::Log4perl YAML::Tiny Getopt::Long File::HomeDir Unicode::GCString

# Sublime Text Package Installation
# Note: User needs to manually add packages to Sublime Text settings as per guide.

# Pygments Installation
pip install pygmentize
# Optional: Link pygmentize if installed via Anaconda
# sudo ln -s /anaconda3/bin/pygmentize /usr/local/bin/pygmentize

echo "LaTeX environment setup is complete."


# TODO: ADD BETAFLIGHT BREW
# codesign --remove-signature /Applications/Betaflight\ Configurator.app/Contents/Frameworks/nwjs\ Framework.framework/Helpers/nwjs\ Helper\ \(Renderer\).app
brew install --cask blheli-configurator
codesign --remove-signature /Applications/BLHeli\ Configurator.app/Contents/Frameworks/nwjs\ Framework.framework/Helpers/nwjs\ Helper\ \(Renderer\).app
# Check the MACOS Build for BLHeliSuite32 see official release: https://github.com/bitdump/BLHeli/releases/download/BLHeliSuite32_32.9.0.5/BLHeliSuite32xm_MacOS64_1042.zip

# For Autonomous Flight Stuff
brew install --cask qgroundcontrol

brew install python --framework

sudo pip3 install wxPython
sudo pip3 install gnureadline
sudo pip3 install billiard
sudo pip3 install numpy pyparsing
sudo pip3 install MAVProxy


# Add pyenv initialization to .zshrc, only if it hasn't been added already
if ! grep -q 'export PYENV_ROOT="\$HOME/.pyenv"' ~/.zshrc; then
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(pyenv init --path)"' >> ~/.zshrc
    echo 'eval "$(pyenv init -)"' >> ~/.zshrc
fi

# Add customized prompt to .zshrc, only if it hasn't been added already
if ! grep -q 'set_prompt()' ~/.zshrc; then
    echo '
    set_prompt() {
        USER_NAME="%F{red}$(whoami)%f"
        BASEDIR=${PWD##*/}
        SUBDIR=${PWD%/*}
        SUBDIR=${SUBDIR##*/}
        PS1="$USER_NAME@%F{green}$SUBDIR/%F{blue}$BASEDIR %f\$ "
    }
    precmd_functions+=(set_prompt)' >> ~/.zshrc
fi

# Add ollamaQuery function to .zshrc, only if it hasn't been added already
if ! grep -q 'ollamaQuery' ~/.zshrc; then
    cat << 'EOF' >> ~/.zshrc
    # Function to query the Ollama server using a model and a prompt
    function ollamaQuery() {
        local prompt="\$1"
        local model="\${2:-llama3}"  # Default to llama3 model if not specified
        # Escape the prompt for JSON using jq
        local escaped_prompt=\$(printf %s "\$prompt" | jq -Rsa .)
        # Perform a POST request to the Ollama server and parse the response to return only the "response" field
        curl -s -X POST "http://ollama.local:11434/api/generate" \
             -H "Content-Type: application/json" \
             -d "{\"model\": \"\$model\", \"prompt\": \$escaped_prompt, \"stream\": false}" | jq -r ".response"
    }
    alias ollama="ollamaQuery"  # Alias for easy access to the ollamaQuery function
EOF
fi

# Source the zshrc file to apply changes to the current shell
source ~/.zshrc