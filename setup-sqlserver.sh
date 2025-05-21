#!/bin/bash
echo "Setting up SQL Server database..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

# Pull SQL Server Docker image
echo "Pulling SQL Server Docker image..."
docker pull mcr.microsoft.com/mssql/server:2019-latest

# Start SQL Server container
echo "Starting SQL Server container..."
docker run -e "ACCEPT_EULA=Y" \
    -e "SA_PASSWORD=YourStrong@Passw0rd" \
    -p 1433:1433 \
    --name attendance-sqlserver \
    -d mcr.microsoft.com/mssql/server:2019-latest

echo "Waiting for SQL Server to start..."
sleep 20

# Create database and tables
echo "Creating database and tables..."
docker cp database/setup.sql attendance-sqlserver:/setup.sql
docker exec attendance-sqlserver /opt/mssql-tools/bin/sqlcmd \
    -S localhost -U sa -P YourStrong@Passw0rd \
    -i /setup.sql

# Update .env file with SQL Server connection string
if [ -f .env ]; then
    # Backup existing .env
    cp .env .env.backup
fi

echo "Updating .env file with SQL Server connection string..."
echo "MSSQL_CONNECTION_STRING=\"Server=localhost;Database=AttendanceDB;User Id=sa;Password=YourStrong@Passw0rd;Encrypt=true;TrustServerCertificate=true;\"" >> .env

echo "SQL Server setup completed!"
echo "Connection Details:"
echo "Server: localhost"
echo "Port: 1433"
echo "Database: AttendanceDB"
echo "Username: sa"
echo "Password: YourStrong@Passw0rd"
echo ""
echo "To connect using sqlcmd:"
echo "sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -d AttendanceDB"
echo ""
echo "To stop the container:"
echo "docker stop attendance-sqlserver"
echo ""
echo "To start the container again:"
echo "docker start attendance-sqlserver"
