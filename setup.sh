#!/bin/bash

# Create necessary directories
mkdir -p database

# Install dependencies
echo "Installing dependencies..."
npm install

# Create .env.local if it doesn't exist
if [ ! -f .env.local ]; then
    echo "Creating .env.local file..."
    cat > .env.local << EOL
# Database Configuration
MSSQL_USER=sa
MSSQL_PASSWORD=YourStrong@Passw0rd
MSSQL_SERVER=localhost
MSSQL_DATABASE=AttendanceDB
MSSQL_PORT=1433

# App Configuration
NEXT_PUBLIC_APP_URL=http://localhost:8000
EOL
    echo ".env.local file created successfully!"
fi

echo """
Setup completed! Next steps:

1. Install SQL Server if not already installed:
   - Windows: Download SQL Server Express
   - Linux: Use Docker with the following command:
     docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=YourStrong@Passw0rd' \\
        -p 1433:1433 -d mcr.microsoft.com/mssql/server:2019-latest

2. Run the database setup script:
   - Windows: Use SQL Server Management Studio
   - Linux/Mac: Use sqlcmd or Azure Data Studio

3. Update .env.local with your database credentials

4. Start the development server:
   npm run dev

The app will be available at http://localhost:8000
"""

# Make the script executable
chmod +x setup.sh
