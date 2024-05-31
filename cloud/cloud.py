import os
import json
import requests
import subprocess

# Configuration
folder_path = "/Users/patrickandreasen/Desktop/photos"
git_repo_path = "/Users/patrickandreasen/Documents/SideProjects/embedded_linux/cloud"
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
        data['Annotation'] = {
            "Source": "Ollama",
            "Text": annotation
        }
        json_file.seek(0)
        json.dump(data, json_file, indent=4)
        json_file.truncate()

# Function to commit and push changes to the Git repository using GitHub CLI
def commit_and_push(repo_path, commit_message, branch_name):
    try:
        os.chdir(repo_path)

        # Stage all changes
        subprocess.run(['git', 'add', '.'], check=True)

        # Commit changes
        subprocess.run(['git', 'commit', '-m', commit_message], check=True)

        # Pull the latest changes from the remote branch
        subprocess.run(['git', 'pull', 'origin', branch_name], check=True)

        # Push changes using GitHub CLI
        subprocess.run(['gh', 'repo', 'sync', '--branch', branch_name], check=True)
        
        # Push changes using git for fallback
        subprocess.run(['git', 'push', 'origin', branch_name], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Git error: {e}")

# Main function to process the folder
def process_folder(folder_path, git_repo_path):
    for root, _, files in os.walk(folder_path):
        for file in files:
            if file.lower().endswith(('.jpg', '.jpeg', '.png')):
                image_path = os.path.join(root, file)
                json_path = os.path.splitext(image_path)[0] + '.json'
                if os.path.exists(json_path):
                    print(f"Processing {image_path} and updating {json_path}")
                    try:
                        annotation = annotate_image(image_path)
                        update_metadata(json_path, annotation)
                    except Exception as e:
                        print(f"Failed to process {image_path}: {e}")

    commit_and_push(git_repo_path, "Add annotations to metadata JSON files", branch_name)

# Run the script
process_folder(folder_path, git_repo_path)
