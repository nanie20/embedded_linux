from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

@app.route('/annotate', methods=['POST'])
def annotate():
    file = request.files['file']
    if file:
        # For simplicity, we will assume the annotation is generated from a fixed prompt
        prompt = "Describe the following image: [IMAGE]"
        
        # Call the Ollama model through subprocess
        process = subprocess.Popen(
            ['ollama', 'run', 'llama3'],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        stdout, stderr = process.communicate(input=prompt)

        # Return the annotation from Ollama model
        return jsonify({"annotation": stdout.strip()})
    else:
        return jsonify({"error": "No file provided"}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
