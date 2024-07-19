#!/bin/bash  

# Function to check if the current directory is a git repository  
is_git_repository() {  
  git rev-parse --is-inside-work-tree > /dev/null 2>&1  
  return $?  
}  

# Function to display banner  
display_banner() {  
  echo "===================================="  
  echo "Git Commit Selector Script (v.1.0.1)"  
  echo "===================================="  
  echo "Author : wenkhairu"
  echo "Email  : wenkhairu@gmail.com"
  echo  
}  

# Check if correct number of arguments is passed  
if [ "$#" -ne 2 ]; then  
  display_banner  
  echo "Usage: $0 <branch> <release_version>"  
  exit 1  
fi  

# Check if current directory is a git repository  
if ! is_git_repository; then  
  echo "Error: The current directory is not a Git repository."  
  exit 1  
fi  

# Assign branch and release_version to variables  
branch="$1"  
release_version="$2"  

# Get the current branch  
current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)  
if [ $? -ne 0 ]; then  
  echo "Error: Failed to get the current branch"  
  exit 1  
fi  

# Check out to the desired branch if not already on it  
if [ "$current_branch" != "$branch" ]; then  
  echo "Current branch is $current_branch. Switching to $branch..."  
  if ! git checkout "$branch"; then  
    echo "Failed to checkout branch $branch. Aborting."  
    exit 1  
  fi  
  echo "Switched to branch $branch"  
else  
  echo "Already on branch $branch"  
fi  

# Search for commits  
echo "Searching for '$release_version' in branch $branch..."  
commits=$(git log --pretty=format:"%h - %ad: %s" --date=short | grep "$release_version")  
if [ $? -ne 0 ]; then  
  echo "Error: Failed to get the git log"  
  exit 1  
fi  

IFS=$'\n' read -d '' -ra filtered_commits <<< "$commits"  

if [ ${#filtered_commits[@]} -eq 0 ]; then  
  echo "No commits found matching '$release_version'"  
  exit 0  
else  
  echo "Found the following commits:"  
  for i in "${!filtered_commits[@]}"; do  
    echo "$((i+1)). ${filtered_commits[$i]}"  
  done  
  echo "$(( ${#filtered_commits[@]} + 1 )). Exit"  

  # Prompt the user to select a commit or exit  
  while true; do  
    read -p "Choose a commit to checkout (1-${#filtered_commits[@]} or $((${#filtered_commits[@]} + 1)) to Exit): " choice  
    if [[ "$choice" =~ ^[0-9]+$ ]]; then  
      if [ "$choice" -ge 1 ] && [ "$choice" -le "${#filtered_commits[@]}" ]; then  
        chosen_commit=$(echo "${filtered_commits[$((choice - 1))]}" | cut -d ' ' -f 1)  
        echo "Checking out to commit $chosen_commit..."  
        if git checkout "$chosen_commit"; then  
          echo "Successfully checked out to commit $chosen_commit"  
        else  
          echo "Error: Failed to checkout to commit $chosen_commit"  
          exit 1  
        fi  
        break  
      elif [ "$choice" -eq "$(( ${#filtered_commits[@]} + 1 ))" ]; then  
        echo "Exiting."  
        exit 0  
      else  
        echo "Invalid choice. Please choose a number between 1 and ${#filtered_commits[@]} or ${#filtered_commits[@]} + 1 to Exit."  
      fi  
    else  
      echo "Invalid input. Please enter a number."  
    fi  
  done  
fi