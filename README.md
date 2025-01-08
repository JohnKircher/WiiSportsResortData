# Wii Sports Resort Stamp Viewer

This project provides a web-based interface for parsing and visualizing **Wii Sports Resort** save data. Uploading a `data.bin` file from your Wii system enables the application to decode and display the stamps collected for each player across various sports.

## Table of Contents

- [Overview](#overview)
- [Technologies Used](#technologies-used)
- [Usage Instructions](#usage-instructions)
- [Local Development Setup](#local-development-setup)
- [Deployment](#deployment)
- [Acknowledgments](#acknowledgments)
- [License](#license)

---

## Overview

The **Wii Sports Resort Stamp Viewer** allows users to upload their Wii save data (`data.bin`) and view a detailed report of stamps collected by all players. Each player's stamp progress is displayed with timestamps and categorized by sport. The project leverages hex decoding and binary conversion techniques to extract and visualize this data in a user-friendly HTML format.

---

## Technologies Used

- **Python 3.11**: Backend server for file upload and processing.
- **Flask**: Lightweight web framework for the application.
- **Bash**: Processing script for decoding and formatting the Wii save data.
- **Docker**: Containerized environment for consistent builds.
- **xxd**: Utility for hex decoding, installed via `vim-common`.

---

## Usage Instructions

### For End Users
1. Navigate to the deployed application URL on render: https://wiisportsresortdata-docker.onrender.com *(it may take 1-2min for the site to load)*
2. Upload the `data.bin` file from your Wii system.
3. View the generated HTML report showing players and their stamps.

---

### Local Development Setup

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/JohnKircher/WiiSportsResortData.git
   cd WiiSportsResortData
   ```

2. **Build and Run with Docker**:
   - Build the Docker image:
     ```bash
     docker build -t wii-sports-stamps .
     ```
   - Run the container:
     ```bash
     docker run -p 8080:8080 wii-sports-stamps
     ```

3. **Access the Application**:
   - Open your browser and navigate to `http://localhost:8080`.

4. **Test the Application**:
   - Upload a `data.bin` file to view the stamp report.

---

### Deployment

#### Using Render
1. Ensure the repository contains the `Dockerfile` in the root directory.
2. Push your changes to GitHub.
3. Set up a new web service on Render:
   - Select the **Docker** environment.
   - Configure the service to use port `8080`.
4. Deploy the service, and your application will be live.

---

## Acknowledgments

This project builds upon the work of others:

- **[Aaron98990](https://github.com/Aaron98990)**:
  - Created (`stamps.bash`) script for decoding Wii save data.
- **[Plombo](https://github.com/Plombo)**:
  - Created the `tachtig` tool for extracting data from Wii save files.

Thanks :)

---

## License

This project is released under the **MIT License**.
