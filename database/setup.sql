-- Create the database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'AttendanceDB')
BEGIN
    CREATE DATABASE AttendanceDB;
END
GO

USE AttendanceDB;
GO

-- Create USERINFO table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USERINFO]') AND type in (N'U'))
BEGIN
    CREATE TABLE USERINFO (
        USERID VARCHAR(24) PRIMARY KEY,
        NAME NVARCHAR(40),
        GENDER VARCHAR(8),
        TITLE VARCHAR(20),
        HIREDDAY DATETIME,
        DEFAULTDEPTID VARCHAR(10),
        PASSWORD VARCHAR(50)
    );
END
GO

-- Create CHECKINOUT table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CHECKINOUT]') AND type in (N'U'))
BEGIN
    CREATE TABLE CHECKINOUT (
        id INT IDENTITY(1,1) PRIMARY KEY,
        USERID VARCHAR(24),
        CHECKTIME DATETIME,
        CHECKTYPE VARCHAR(1),
        VERIFYCODE INT,
        FOREIGN KEY (USERID) REFERENCES USERINFO(USERID)
    );
END
GO

-- Add indexes for better performance
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_CHECKINOUT_USERID_CHECKTIME' AND object_id = OBJECT_ID('CHECKINOUT'))
BEGIN
    CREATE INDEX IX_CHECKINOUT_USERID_CHECKTIME ON CHECKINOUT(USERID, CHECKTIME);
END
GO

-- Insert test data for departments
DECLARE @departments TABLE (id VARCHAR(10), name VARCHAR(20));
INSERT INTO @departments VALUES 
('IT', 'IT Department'),
('HR', 'Human Resources'),
('FIN', 'Finance'),
('MKT', 'Marketing'),
('OPS', 'Operations');

-- Insert test users with realistic data
INSERT INTO USERINFO (USERID, NAME, GENDER, TITLE, HIREDDAY, DEFAULTDEPTID)
SELECT t.USERID, t.NAME, t.GENDER, t.TITLE, t.HIREDDAY, t.DEPTID
FROM (
    VALUES 
    ('1001', 'John Smith', 'M', 'Developer', '2022-01-15', 'IT'),
    ('1002', 'Sarah Johnson', 'F', 'HR Manager', '2021-06-20', 'HR'),
    ('1003', 'Michael Brown', 'M', 'Accountant', '2022-03-10', 'FIN'),
    ('1004', 'Emily Davis', 'F', 'Marketing Specialist', '2022-08-05', 'MKT'),
    ('1005', 'James Wilson', 'M', 'Operations Manager', '2021-11-30', 'OPS'),
    ('1006', 'Lisa Anderson', 'F', 'Developer', '2022-04-15', 'IT'),
    ('1007', 'Robert Taylor', 'M', 'HR Assistant', '2022-09-01', 'HR'),
    ('1008', 'Jennifer Martin', 'F', 'Financial Analyst', '2022-02-28', 'FIN'),
    ('1009', 'William Moore', 'M', 'Marketing Manager', '2021-08-15', 'MKT'),
    ('1010', 'Emma Thompson', 'F', 'Operations Assistant', '2022-07-20', 'OPS')
) AS t(USERID, NAME, GENDER, TITLE, HIREDDAY, DEPTID)
WHERE NOT EXISTS (SELECT 1 FROM USERINFO WHERE USERID = t.USERID);
GO

-- Function to generate random time between two dates
CREATE OR ALTER FUNCTION GenerateRandomTime(
    @StartDate DATETIME,
    @EndDate DATETIME
)
RETURNS DATETIME
AS
BEGIN
    DECLARE @Seconds INT = DATEDIFF(SECOND, @StartDate, @EndDate);
    DECLARE @Random INT = ROUND(RAND() * @Seconds, 0);
    RETURN DATEADD(SECOND, @Random, @StartDate);
END;
GO

-- Generate attendance records for the last 30 days
DECLARE @StartDate DATETIME = DATEADD(DAY, -30, GETDATE());
DECLARE @EndDate DATETIME = GETDATE();
DECLARE @CurrentDate DATETIME = @StartDate;

WHILE @CurrentDate <= @EndDate
BEGIN
    -- Skip weekends
    IF DATEPART(WEEKDAY, @CurrentDate) NOT IN (1, 7) -- 1 = Sunday, 7 = Saturday
    BEGIN
        INSERT INTO CHECKINOUT (USERID, CHECKTIME, CHECKTYPE, VERIFYCODE)
        SELECT 
            USERID,
            -- Generate check-in time between 8:00 AM and 9:30 AM
            dbo.GenerateRandomTime(
                DATEADD(HOUR, 8, CAST(CAST(@CurrentDate AS DATE) AS DATETIME)),
                DATEADD(MINUTE, 90, DATEADD(HOUR, 8, CAST(CAST(@CurrentDate AS DATE) AS DATETIME)))
            ),
            'I', -- Check-in
            15  -- Verification code
        FROM USERINFO
        WHERE RAND() < 0.95; -- 95% attendance rate

        INSERT INTO CHECKINOUT (USERID, CHECKTIME, CHECKTYPE, VERIFYCODE)
        SELECT 
            USERID,
            -- Generate check-out time between 5:00 PM and 6:30 PM
            dbo.GenerateRandomTime(
                DATEADD(HOUR, 17, CAST(CAST(@CurrentDate AS DATE) AS DATETIME)),
                DATEADD(MINUTE, 90, DATEADD(HOUR, 17, CAST(CAST(@CurrentDate AS DATE) AS DATETIME)))
            ),
            'O', -- Check-out
            15  -- Verification code
        FROM USERINFO
        WHERE RAND() < 0.95; -- 95% attendance rate
    END

    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END;
GO

-- Create view for attendance reports
IF NOT EXISTS (SELECT * FROM sys.views WHERE name = 'vw_AttendanceReport')
BEGIN
    EXEC('
    CREATE VIEW vw_AttendanceReport AS
    SELECT 
        c.USERID,
        u.NAME,
        u.TITLE,
        u.DEFAULTDEPTID as DEPARTMENT,
        CAST(c.CHECKTIME AS DATE) as ATTENDANCE_DATE,
        MIN(CASE WHEN c.CHECKTYPE = ''I'' THEN c.CHECKTIME END) as FIRST_CHECK_IN,
        MAX(CASE WHEN c.CHECKTYPE = ''O'' THEN c.CHECKTIME END) as LAST_CHECK_OUT
    FROM CHECKINOUT c
    JOIN USERINFO u ON c.USERID = u.USERID
    GROUP BY c.USERID, u.NAME, u.TITLE, u.DEFAULTDEPTID, CAST(c.CHECKTIME AS DATE)
    ');
END
GO

PRINT 'Database setup completed successfully with test data!';
GO
