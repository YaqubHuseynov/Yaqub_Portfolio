## Overview
My goal for this project is to identify trends and draw necessary conclusions through comprehensive analysis on relevant data.

## MySQL Setup Instructions

### Installation Guide
1. **MySQL Workbench:**
   - Download MySQL Workbench from [MySQL Downloads](https://dev.mysql.com/downloads/workbench/).
   - Follow the installation wizard instructions for your operating system.

2. **MySQL Server:**
   - Install MySQL Server based on your operating system:
     - **Windows:** Download MySQL Installer from [MySQL Downloads](https://dev.mysql.com/downloads/installer/) and follow the wizard to install MySQL Server.
     - **macOS:** Install MySQL using Homebrew:
       ```bash
       brew install mysql
       ```
     - **Linux:** Use your distribution’s package manager to install MySQL Server:
       ```bash
       sudo apt-get update
       sudo apt-get install mysql-server
       ```

### Adding CSV Files
- CSV files required for this project are included in the repository under `/data`. You can download them directly from [link to your repository's data folder].

### Importing CSV Files into MySQL

#### Using MySQL Workbench Table Wizard
1. Open MySQL Workbench and connect to your MySQL server.
2. Click on **Server** from the top menu and choose **Table Data Import Wizard**.
3. Select **Import from CSV file** option.
4. Browse and select the CSV file from your local machine.
5. Set the Target Schema or create a new one.
6. Configure import options as needed (field mapping, data types, etc.).
7. Click **Next** and then **Start Import** to import the CSV data into your MySQL database.

### Troubleshooting
- If you encounter any issues or errors during setup, refer to the [MySQL Documentation](https://dev.mysql.com/doc/) for detailed troubleshooting guides and solutions.
