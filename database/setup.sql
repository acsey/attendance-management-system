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
        PAGER VARCHAR(20),
        BIRTHDAY DATETIME,
        HIREDDAY DATETIME,
        STREET VARCHAR(80),
        CITY VARCHAR(2),
        STATE VARCHAR(2),
        ZIP VARCHAR(12),
        OPHONE VARCHAR(20),
        FPHONE VARCHAR(20),
        VERIFICATIONMETHOD VARCHAR(10),
        DEFAULTDEPTID VARCHAR(10),
        SECURITYFLAGS VARCHAR(10),
        ATT INT,
        INLATE INT,
        OUTEARLY INT,
        OVERTIME INT,
        SEP INT,
        HOLIDAY INT,
        MINZU VARCHAR(8),
        PASSWORD VARCHAR(50),
        LUNCHDURATION INT,
        MVerifyPass VARCHAR(10),
        PHOTO IMAGE
    );
END
GO

-- Create CHECKINOUT table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CHECKINOUT]') AND type in (N'U'))
BEGIN
    CREATE TABLE CHECKINOUT (
        USERID VARCHAR(24),
        CHECKTIME DATETIME,
        CHECKTYPE VARCHAR(1),
        VERIFYCODE INT,
        SENSORID VARCHAR(5),
        WORKCODE VARCHAR(24),
        sn VARCHAR(20),
        UserExtFmt INT,
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

-- Insert test data
IF NOT EXISTS (SELECT * FROM USERINFO WHERE USERID = '12345')
BEGIN
    INSERT INTO USERINFO (USERID, NAME, GENDER, TITLE, HIREDDAY) 
    VALUES 
    ('12345', 'John Doe', 'M', 'Developer', GETDATE()),
    ('67890', 'Jane Smith', 'F', 'Manager', GETDATE()),
    ('11111', 'Bob Wilson', 'M', 'Engineer', GETDATE());
END
GO

-- Insert sample attendance records
INSERT INTO CHECKINOUT (USERID, CHECKTIME, CHECKTYPE, VERIFYCODE)
VALUES 
('12345', DATEADD(HOUR, -1, GETDATE()), 'I', 15),
('67890', DATEADD(HOUR, -2, GETDATE()), 'I', 15),
('11111', DATEADD(HOUR, -3, GETDATE()), 'I', 15);
GO

-- Create view for attendance reports
IF NOT EXISTS (SELECT * FROM sys.views WHERE name = 'vw_AttendanceReport')
BEGIN
    EXEC('
    CREATE VIEW vw_AttendanceReport AS
    SELECT 
        c.USERID,
        u.NAME,
        c.CHECKTIME,
        c.CHECKTYPE,
        CASE 
            WHEN c.VERIFYCODE = 15 THEN ''QR Code''
            ELSE ''Other''
        END as VerificationMethod
    FROM CHECKINOUT c
    JOIN USERINFO u ON c.USERID = u.USERID
    ');
END
GO

PRINT 'Database setup completed successfully!';
GO
