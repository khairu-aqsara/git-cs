import os  
import subprocess  
import sys  

def is_git_repository():  
    try:  
        subprocess.check_output(["git", "rev-parse", "--is-inside-work-tree"], stderr=subprocess.STDOUT)  
        return True  
    except subprocess.CalledProcessError:  
        return False  

def display_banner():  
    banner = """  
====================================
Git Commit Selector Script (v.1.0.0)
====================================
Author : wenkhairu
Email  : wenkhairu@gmail.com
    """  
    print(banner)  

def main():  
    display_banner()  

    if len(sys.argv) != 3:  
        print(f"Usage: {sys.argv[0]} <branch> <release_version>")
        print(f"Example: {sys.argv[0]} MOODLE_401_STABLE '4.1.3'\n")        
        sys.exit(1)  

    if not is_git_repository():  
        print("Error: The current directory is not a Git repository.")  
        sys.exit(1)  

    branch = sys.argv[1]  
    release_version = sys.argv[2]  

    try:  
        current_branch = subprocess.check_output(  
            ["git", "rev-parse", "--abbrev-ref", "HEAD"]  
        ).strip().decode('utf-8')  
    except subprocess.CalledProcessError as e:  
        print(f"Error: Failed to get the current branch: {e}")  
        sys.exit(1)  
    except UnicodeDecodeError as e:  
        print(f"Error: Failed to decode the current branch: {e}")  
        sys.exit(1)  

    if current_branch != branch:  
        print(f"Current branch is {current_branch}. Switching to {branch}...")  
        try:  
            if subprocess.call(["git", "checkout", branch]) != 0:  
                print(f"Failed to checkout branch {branch}. Aborting.")  
                sys.exit(1)  
            print(f"Switched to branch {branch}")  
        except subprocess.CalledProcessError as e:  
            print(f"Error: Failed to checkout branch {branch}: {e}")  
            sys.exit(1)  
    else:  
        print(f"Already on branch {branch}")  

    print(f"Searching for '{release_version}' in branch {branch}...")  
    try:  
        result = subprocess.check_output(  
            ["git", "log", "--pretty=format:%h - %ad: %s", "--date=short"]  
        )  
        result = result.decode('utf-8', errors='ignore')  # Decode with 'errors' parameter to ignore invalid bytes  
    except subprocess.CalledProcessError as e:  
        print(f"Error: Failed to get the git log: {e}")  
        sys.exit(1)  
    except UnicodeDecodeError as e:  
        print(f"Error: Failed to decode the git log output: {e}")  
        sys.exit(1)  

    # Filter the result to include only commits containing the version  
    filtered_commits = [line for line in result.split('\n') if f"{release_version}" in line]  

    if not filtered_commits:  
        print(f"No commits found matching '{release_version}'")  
    else:  
        print(f"Found the following commits:")  
        for idx, commit in enumerate(filtered_commits, 1):  
            print(f"{idx}. {commit}")  

        print(f"{len(filtered_commits) + 1}. Exit")  

        # Prompt user to select a commit or exit  
        while True:  
            try:  
                choice = int(input(f"Choose a commit to checkout (1-{len(filtered_commits)} or {len(filtered_commits) + 1} to Exit): "))  
                if 1 <= choice <= len(filtered_commits):  
                    # Extract the chosen commit hash  
                    chosen_commit = filtered_commits[choice - 1].split()[0]  
                    
                    print(f"Checking out to commit {chosen_commit}...")  
                    try:  
                        subprocess.check_call(["git", "checkout", chosen_commit])  
                        print(f"Successfully checked out to commit {chosen_commit}")  
                    except subprocess.CalledProcessError as e:  
                        print(f"Error: Failed to checkout to commit {chosen_commit}: {e}")  
                        sys.exit(1)  
                    break  
                elif choice == len(filtered_commits) + 1:  
                    print("Exiting.")  
                    sys.exit(0)  
                else:  
                    print(f"Invalid choice. Please choose a number between 1 and {len(filtered_commits)} or {len(filtered_commits) + 1} to Exit.")  
            except ValueError:  
                print("Invalid input. Please enter a number.")  

if __name__ == "__main__":  
    main()