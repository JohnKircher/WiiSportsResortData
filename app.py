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
        
        # Set up the wii directory
        wii_dir = os.path.join(temp_dir, 'wii')
        os.makedirs(wii_dir, exist_ok=True)
        
        # Write sd-key, sd-iv, and md5-blanker files
        with open(os.path.join(wii_dir, 'sd-key'), 'w') as f:
            f.write("ab01b9d8e1622b08afbad84dbfc2a55d")
        with open(os.path.join(wii_dir, 'sd-iv'), 'w') as f:
            f.write("216712e6aa1f689f95c5a22324dc6a98")
        with open(os.path.join(wii_dir, 'md5-blanker'), 'w') as f:
            f.write("0e65378199be4517ab06ec22451a5793")
        
        # Make tachtig executable and run it
        tachtig_path = os.path.abspath('./tachtig')
        os.chmod(tachtig_path, 0o755)
        subprocess.run([tachtig_path, bin_path], cwd=temp_dir, check=True)
        
        # Locate Sports2.dat
        folder_name = "0001000053503245"  # Adjust if tachtig creates a different folder
        sports2_path = os.path.join(temp_dir, folder_name, 'Sports2.dat')
        if not os.path.exists(sports2_path):
            return "Sports2.dat not found", 500
        
        # Run stamps.bash
        bash_script_path = os.path.abspath('./stamps.bash')
        subprocess.run(['bash', bash_script_path, sports2_path], cwd=temp_dir, check=True)
        
        # Locate output.html
        output_path = os.path.join(temp_dir, 'output.html')
        if not os.path.exists(output_path):
            return "output.html not generated", 500
        
        # Serve the output file
        return send_file(output_path, as_attachment=True)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
