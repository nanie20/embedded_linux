import os
import json
import requests
import subprocess

# Configuration
repo_root_path = "/Users/patrickandreasen/Documents/SideProjects/embedded_linux/cloud"
photos_folder_name = "photos"
photos_folder_path = os.path.join(repo_root_path, photos_folder_name)
ollama_api_url = "http://localhost:8080/annotate"  # Ensure this matches your Flask server's port
git_user_name = "pandr20"
git_user_email = "pandr20@student.sdu.dk"
branch_name = "Cloud"

# Function to annotate an image using the Ollama API
def annotate_image(image_path):
    with open(image_path, 'rb') as img_file:
        response = requests.post(ollama_api_url, files={"file": img_file})
        response.raise_for_status()
        return response.json()['annotation']

# Function to update JSON metadata with annotations
def update_metadata(json_path, annotation):
    with open(json_path, 'r+') as json_file:
        data = json.load(json_file)
        print(f"Original data: {data}")
        if 'Annotation' in data and data['Annotation']['Text'] == annotation:
            print(f"No change needed for {json_path}")
            return False
        data['Annotation'] = {
            "Source": "Ollama",
            "Text": annotation
        }
        print(f"Updated data: {data}")
        json_file.seek(0)
        json.dump(data, json_file, indent=4)
        json_file.truncate()
    return True

# Function to commit and push changes to the Git repository using GitHub CLI
def commit_and_push(repo_path, commit_message, branch_name):
    try:
        os.chdir(repo_path)

        # Force stage all changes
        subprocess.run(['git', 'add', '--force', '.'], check=True)

        # Check if there are any changes to commit
        result = subprocess.run(['git', 'status', '--porcelain'], capture_output=True, text=True)
        if result.stdout.strip() == "":
            print("No changes to commit.")
            return

        # Commit changes
        subprocess.run(['git', 'commit', '-m', commit_message], check=True)

        # Pull the latest changes from the remote branch
        subprocess.run(['git', 'pull', 'origin', branch_name], check=True)

        # Force push changes using GitHub CLI
        subprocess.run(['gh', 'repo', 'sync', '--branch', branch_name, '--force'], check=True)

        # Force push changes using git for fallback
        subprocess.run(['git', 'push', 'origin', branch_name, '--force'], check=True)

        print("Changes pushed successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Git error: {e}")

# Main function to process the folder
def process_folder(folder_path, git_repo_path):
    any_changes = False
    for root, _, files in os.walk(folder_path):
        for file in files:
            if file.lower().endswith(('.jpg', '.jpeg', '.png')):
                image_path = os.path.join(root, file)
                json_path = os.path.splitext(image_path)[0] + '.json'
                if os.path.exists(json_path):
                    print(f"Processing {image_path} and updating {json_path}")
                    try:
                        annotation = annotate_image(image_path)
                        if update_metadata(json_path, annotation):
                            print(f"Updated {json_path} with annotation.")
                            any_changes = True
                    except Exception as e:
                        print(f"Failed to process {image_path}: {e}")

    if any_changes:
        commit_and_push(git_repo_path, "Add annotations to metadata JSON files", branch_name)
    else:
        print("No updates were made to JSON files.")

# Run the script
process_folder(photos_folder_path, repo_root_path)
