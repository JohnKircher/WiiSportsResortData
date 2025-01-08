from flask import Flask, request, send_file
import os
import subprocess
import tempfile

app = Flask(__name__)

@app.route('/')
def index():
    return '''
    <!DOCTYPE html>
    <html>
    <head><title>Upload data.bin</title></head>
    <body>
        <h1>Upload your data.bin file</h1>
        <form action="/upload" method="post" enctype="multipart/form-data">
            <input type="file" name="file">
            <input type="submit" value="Upload">
        </form>
    </body>
    </html>
    '''

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return "No file uploaded", 400

    file = request.files['file']
    if file.filename == '':
        return "No file selected", 400

    with tempfile.TemporaryDirectory() as temp_dir:
        # Save the uploaded file
        bin_path = os.path.join(temp_dir, 'data.bin')
        file.save(bin_path)

        # Ensure ~/.wii directory exists and write key files
        wii_dir = os.path.expanduser('~/.wii')
        os.makedirs(wii_dir, exist_ok=True)
        with open(os.path.join(wii_dir, 'sd-key'), 'wb') as f:
            f.write(bytes.fromhex("ab01b9d8e1622b08afbad84dbfc2a55d"))
        with open(os.path.join(wii_dir, 'sd-iv'), 'wb') as f:
            f.write(bytes.fromhex("216712e6aa1f689f95c5a22324dc6a98"))
        with open(os.path.join(wii_dir, 'md5-blanker'), 'wb') as f:
            f.write(bytes.fromhex("0e65378199be4517ab06ec22451a5793"))

        # Run tachtig
        tachtig_path = os.path.abspath('./tachtig')  # Use the relative path

        os.chmod(tachtig_path, 0o755)

        # Run tachtig
        try:
            subprocess.run([tachtig_path, bin_path], cwd=temp_dir, check=True)
        except subprocess.CalledProcessError as e:
            print(f"Error running tachtig: {e}")
            return f"Error running tachtig: {e}", 500
        except FileNotFoundError:
            return "tachtig executable not found", 500

        # Run stamps.bash
        bash_script_path = os.path.abspath('./stamps.bash')
        try:
            subprocess.run(['bash', bash_script_path, os.path.join(temp_dir, "0001000053503245/Sports2.dat")],
                           cwd=temp_dir, check=True)
        except subprocess.CalledProcessError as e:
            print(f"Error running stamps.bash: {e}")
            return f"Error running stamps.bash: {e}", 500

        # Read the generated HTML file
        output_path = os.path.join(temp_dir, 'output.html')
        if not os.path.exists(output_path):
            return "output.html not found", 500
        with open(output_path, 'r') as f:
            html_content = f.read()

        # Serve the HTML content as the response
        return html_content

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
