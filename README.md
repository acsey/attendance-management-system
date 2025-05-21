# Attendance System

A comprehensive attendance management system that integrates biometric data from ZKTeco terminals with a modern web interface.

## Features

- Biometric attendance tracking via ZKTeco terminals
- QR code-based attendance for remote work
- Real-time synchronization between SQL Server and PostgreSQL
- Role-based access control (Admin, HR, Worker)
- Automated report generation
- Geolocation tracking for QR attendance

## Prerequisites

1. Node.js (v18 or later)
2. Docker
3. PostgreSQL (v14 or later)
4. Git

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd attendance-system
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Set Up SQL Server (ZKTeco Data)

This will set up a SQL Server instance in Docker with test data simulating a ZKTeco terminal:

```bash
# Make the setup script executable
chmod +x setup-sqlserver.sh

# Run the setup script
./setup-sqlserver.sh
```

The script will:
- Pull and run SQL Server in Docker
- Create the AttendanceDB database
- Set up tables matching ZKTeco schema
- Populate test data for the last 30 days
- Update .env with connection details

### 4. Set Up PostgreSQL (Application Data)

```bash
# Create database
createdb attendance_db

# Push schema and generate client
npx prisma db push
npx prisma generate

# Create test users
chmod +x setup-test-users.sh
./setup-test-users.sh
```

### 5. Configure Environment

Copy the example environment file:
```bash
cp .env.example .env
```

Update the following variables in .env:
```env
DATABASE_URL="postgresql://username:password@localhost:5432/attendance_db?schema=public"
MSSQL_CONNECTION_STRING="Server=localhost;Database=AttendanceDB;User Id=sa;Password=YourStrong@Passw0rd;Encrypt=true;TrustServerCertificate=true;"
JWT_SECRET="your-secret-key"
```

### 6. Start the Development Server

```bash
npm run dev
```

The application will be available at http://localhost:8000

## Test Accounts

After running setup-test-users.sh, the following accounts will be available:

1. Admin User
   - Email: admin@example.com
   - Password: admin123

2. HR Manager
   - Email: hr@example.com
   - Password: hr123

3. Worker
   - Email: worker@example.com
   - Password: worker123

## Database Architecture

The system uses two databases:

1. SQL Server (ZKTeco Data)
   - USERINFO: Employee information from biometric devices
   - CHECKINOUT: Raw attendance logs from terminals

2. PostgreSQL (Application Data)
   - Users: Extended user profiles and authentication
   - Attendance: Processed attendance records
   - QRAttendance: Mobile attendance records
   - Reports: Report configurations and generated reports
   - SyncLogs: Synchronization tracking

## Data Synchronization

Data flows from SQL Server to PostgreSQL through:

1. Periodic Sync (Every hour)
   - Automatically syncs new attendance records
   - Updates user information
   - Maintains sync logs

2. Manual Sync (Admin only)
   - Available through /api/sync endpoint
   - Forces immediate synchronization
   - Updates all pending records

## Development Notes

### API Routes

- Authentication: `/api/auth/*`
- Attendance: `/api/attendance/*`
- Reports: `/api/reports/*`
- Biometric: `/api/biometric/*`
- QR: `/api/qr/*`
- Sync: `/api/sync`

### Testing

1. SQL Server Data:
   - Test data includes 10 employees
   - 30 days of attendance records
   - 95% attendance rate
   - Realistic check-in/out times

2. QR Attendance:
   - Can be tested without biometric hardware
   - Includes geolocation validation
   - Device information tracking

## Troubleshooting

### SQL Server Issues

1. Container not starting:
```bash
docker ps -a  # Check container status
docker logs attendance-sqlserver  # Check logs
```

2. Connection issues:
```bash
docker exec -it attendance-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd
```

### PostgreSQL Issues

1. Database connection:
```bash
psql -d attendance_db  # Connect to database
```

2. Reset database:
```bash
dropdb attendance_db
createdb attendance_db
npx prisma db push
./setup-test-users.sh
```

### Sync Issues

1. Check sync logs:
```sql
SELECT * FROM sync_logs ORDER BY created_at DESC LIMIT 10;
```

2. Manual sync:
```bash
curl -X POST http://localhost:8000/api/sync -H "Authorization: Bearer <token>"
```

## License

MIT
