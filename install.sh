#!/bin/bash  

# Variables  
REPO_URL="https://github.com/khairu-aqsara/git-cs.git"  
SCRIPT_DIR="$HOME/git-cs"  
SCRIPT_NAME="gitcs.sh"  

# Functions  
echo "====================================="  
echo " Git Commit Selector Script Installer"  
echo "====================================="  

function clone_repo() {  
    if [ -d "$SCRIPT_DIR" ]; then  
        echo "Directory $SCRIPT_DIR already exists. Pulling the latest changes..."  
        cd "$SCRIPT_DIR" || exit  
        git pull  
    else  
        echo "Cloning repository..."  
        git clone "$REPO_URL" "$SCRIPT_DIR"  
    fi  
}  

function make_executable() {  
    echo "Making script executable..."  
    chmod +x "$SCRIPT_DIR/$SCRIPT_NAME"  
}  

function add_to_path() {  
    echo "Would you like to add the script directory to your PATH? (y/n): "  
    read -r add_path  
    if [ "$add_path" = "y" ] || [ "$add_path" = "Y" ]; then  
        SHELL_PROFILE=""  
        if [ -f "$HOME/.bashrc" ]; then  
            SHELL_PROFILE="$HOME/.bashrc"  
        elif [ -f "$HOME/.bash_profile" ]; then  
            SHELL_PROFILE="$HOME/.bash_profile"  
        elif [ -f "$HOME/.zshrc" ]; then  
            SHELL_PROFILE="$HOME/.zshrc"  
        fi  

        if [ -n "$SHELL_PROFILE" ]; then
            cp $SCRIPT_DIR/$SCRIPT_NAME $SCRIPT_DIR/gitcs
            echo "Adding $SCRIPT_DIR to PATH in $SHELL_PROFILE..."  
            echo "export PATH=\"\$PATH:$SCRIPT_DIR\"" >> "$SHELL_PROFILE"  
            echo "Please restart your terminal or run 'source $SHELL_PROFILE' to apply the changes."  
        else  
            echo "No supported shell profile file found. Please manually add $SCRIPT_DIR to your PATH."  
        fi  
    fi  
}  

# Execution  
clone_repo  
make_executable  
add_to_path  

echo "Installation complete. You can now use the script by running: $SCRIPT_DIR/$SCRIPT_NAME"