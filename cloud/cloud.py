import os
import json
import requests
from pygit2 import Repository, Signature

# Configuration
folder_path = "/Users/patrickandreasen/Desktop/photos"
git_repo_path = "https://github.com/nanie20/embedded_linux"
ollama_api_url = "http://localhost:5000/annotate"  # API endpoint for the Ollama model
git_user_name = "pandr20"
git_user_email = "pandr20@student.sdu.dk"

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

# Function to commit and push changes to the Git repository
def commit_and_push(repo_path, commit_message):
    repo = Repository(repo_path)
    index = repo.index
    index.add_all()
    index.write()
    author = committer = Signature(git_user_name, git_user_email)
    tree = index.write_tree()
    repo.create_commit(
        'refs/heads/main',  # Ref name
        author,  # Author signature
        committer,  # Committer signature
        commit_message,  # Commit message
        tree,  # Tree object
        [repo.head.target]  # Parent commit
    )
    origin = repo.remotes['origin']
    credentials = None  # Add your Git credentials if necessary
    callbacks = pygit2.RemoteCallbacks(credentials=credentials)
    origin.push(['refs/heads/main'], callbacks=callbacks)

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

    commit_and_push(git_repo_path, "Add annotations to metadata JSON files")

# Run the script
process_folder(folder_path, git_repo_path)