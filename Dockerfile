# Use an official Python image as the base
FROM python:3.11-slim

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    vim-common \
    bc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy all files into the container
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Ensure scripts and binaries are executable
RUN chmod +x /app/stamps.bash && chmod +x /app/tachtig && chmod +x /app/xxd

# Expose the application port
EXPOSE 8080

# Run the Flask application
CMD ["python", "app.py"]
