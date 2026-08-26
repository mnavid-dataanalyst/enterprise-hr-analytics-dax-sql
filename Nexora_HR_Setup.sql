CREATE DATABASE Nexora_HR
USE Nexora_HR
CREATE TABLE DimDepartment
(
    DepartmentKey INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentCode VARCHAR(20) NOT NULL UNIQUE,
    DepartmentName VARCHAR(100) NOT NULL,
    BusinessUnit VARCHAR(100),
    CostCenter VARCHAR(50),
    DepartmentHead VARCHAR(150),
    IsActive BIT DEFAULT 1
)
CREATE TABLE DimLocation
(
    LocationKey INT IDENTITY(1,1) PRIMARY KEY,
    LocationCode VARCHAR(20) NOT NULL UNIQUE,
    City VARCHAR(100),
    Country VARCHAR(100),
    OfficeType VARCHAR(50),
    IsRemote BIT DEFAULT 0
)
CREATE TABLE DimJob
(
    JobKey INT IDENTITY(1,1) PRIMARY KEY,
    JobCode VARCHAR(30) NOT NULL UNIQUE,
    JobTitle VARCHAR(150),
    JobFamily VARCHAR(100),
    JobLevel VARCHAR(50),
    EmploymentType VARCHAR(50),
    MinimumSalary DECIMAL(18,2),
    MaximumSalary DECIMAL(18,2)
)
CREATE TABLE DimRecruitmentSource
(
    RecruitmentSourceKey INT IDENTITY(1,1) PRIMARY KEY,
    SourceName VARCHAR(100),
    SourceCategory VARCHAR(100)
)
CREATE TABLE DimTraining
(
    TrainingKey INT IDENTITY(1,1) PRIMARY KEY,
    TrainingCode VARCHAR(30) UNIQUE,
    TrainingName VARCHAR(150),
    TrainingCategory VARCHAR(100),
    DeliveryMethod VARCHAR(50),
    Provider VARCHAR(150)
)
CREATE TABLE DimExitReason
(
    ExitReasonKey INT IDENTITY(1,1) PRIMARY KEY,
    ExitReason VARCHAR(150),
    ExitCategory VARCHAR(100),
    VoluntaryFlag BIT
)
CREATE TABLE DimPerformanceRating
(
    PerformanceRatingKey INT PRIMARY KEY,
    RatingName VARCHAR(50),
    RatingDescription VARCHAR(255),
    RatingScore DECIMAL(5,2)
)
CREATE TABLE DimEmployee
(
    EmployeeKey INT IDENTITY(1,1) PRIMARY KEY,

    EmployeeID VARCHAR(20) NOT NULL UNIQUE,

    FirstName VARCHAR(100),
    LastName VARCHAR(100),

    Gender VARCHAR(30),
    DateOfBirth DATE,

    HireDate DATE,
    ConfirmationDate DATE,

    TerminationDate DATE,

    EmploymentStatus VARCHAR(50),

    DepartmentKey INT,
    JobKey INT,
    LocationKey INT,

    ManagerEmployeeKey INT NULL,

    RecruitmentSourceKey INT,

    EducationLevel VARCHAR(100),
    FieldOfStudy VARCHAR(150),

    YearsOfExperience DECIMAL(5,2),

    BaseSalary DECIMAL(18,2),

    IsRemote BIT DEFAULT 0,

    CreatedDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_Employee_Department
        FOREIGN KEY (DepartmentKey)
        REFERENCES DimDepartment(DepartmentKey),

    CONSTRAINT FK_Employee_Job
        FOREIGN KEY (JobKey)
        REFERENCES DimJob(JobKey),

    CONSTRAINT FK_Employee_Location
        FOREIGN KEY (LocationKey)
        REFERENCES DimLocation(LocationKey),

    CONSTRAINT FK_Employee_RecruitmentSource
        FOREIGN KEY (RecruitmentSourceKey)
        REFERENCES DimRecruitmentSource(RecruitmentSourceKey)
)
CREATE TABLE DimDate
(
    DateKey INT PRIMARY KEY,

    FullDate DATE NOT NULL,

    Year INT,
    Quarter INT,
    QuarterName VARCHAR(10),

    MonthNumber INT,
    MonthName VARCHAR(20),

    WeekNumber INT,
    DayOfMonth INT,
    DayName VARCHAR(20),

    IsWeekend BIT
)
DECLARE @StartDate DATE = '2019-01-01';
DECLARE @EndDate DATE = '2026-12-31';

WHILE @StartDate <= @EndDate
BEGIN

    INSERT INTO DimDate
    (
        DateKey,
        FullDate,
        [Year],
        [Quarter],
        QuarterName,
        MonthNumber,
        MonthName,
        WeekNumber,
        DayOfMonth,
        DayName,
        IsWeekend
    )
    VALUES
    (
        CONVERT(INT, CONVERT(CHAR(8), @StartDate, 112)),
        @StartDate,
        YEAR(@StartDate),
        DATEPART(QUARTER, @StartDate),
        CONCAT('Q', DATEPART(QUARTER, @StartDate)),
        MONTH(@StartDate),
        DATENAME(MONTH, @StartDate),
        DATEPART(WEEK, @StartDate),
        DAY(@StartDate),
        DATENAME(WEEKDAY, @StartDate),
        CASE
            WHEN DATEPART(WEEKDAY, @StartDate) IN (6, 7)
            THEN 1
            ELSE 0
        END
    );

    SET @StartDate = DATEADD(DAY, 1, @StartDate);

END;
CREATE TABLE FactAttendance
(
    AttendanceKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    EmployeeKey INT NOT NULL,
    DateKey INT NOT NULL,

    CheckIn DATETIME,
    CheckOut DATETIME,

    ScheduledHours DECIMAL(5,2),
    WorkedHours DECIMAL(5,2),

    LateMinutes INT DEFAULT 0,

    AttendanceStatus VARCHAR(50),

    IsLate BIT,
    IsAbsent BIT,
    IsRemote BIT,

    CONSTRAINT FK_Attendance_Employee
        FOREIGN KEY (EmployeeKey)
        REFERENCES DimEmployee(EmployeeKey),

    CONSTRAINT FK_Attendance_Date
        FOREIGN KEY (DateKey)
        REFERENCES DimDate(DateKey)
)
CREATE TABLE FactPayroll
(
    PayrollKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    EmployeeKey INT NOT NULL,
    DateKey INT NOT NULL,

    BasicSalary DECIMAL(18,2),

    HousingAllowance DECIMAL(18,2),
    MedicalAllowance DECIMAL(18,2),
    TransportAllowance DECIMAL(18,2),

    OvertimePay DECIMAL(18,2),
    Bonus DECIMAL(18,2),

    GrossSalary DECIMAL(18,2),

    TaxDeduction DECIMAL(18,2),
    OtherDeduction DECIMAL(18,2),

    NetSalary DECIMAL(18,2),

    CONSTRAINT FK_Payroll_Employee
        FOREIGN KEY (EmployeeKey)
        REFERENCES DimEmployee(EmployeeKey),

    CONSTRAINT FK_Payroll_Date
        FOREIGN KEY (DateKey)
        REFERENCES DimDate(DateKey)
)
CREATE TABLE FactPerformance
(
    PerformanceKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    EmployeeKey INT NOT NULL,
    DateKey INT NOT NULL,

    PerformanceRatingKey INT,

    GoalAchievement DECIMAL(5,2),
    ProductivityScore DECIMAL(5,2),
    QualityScore DECIMAL(5,2),
    CollaborationScore DECIMAL(5,2),

    ManagerRating DECIMAL(5,2),

    PromotionRecommended BIT,

    PerformanceComment VARCHAR(500),

    CONSTRAINT FK_Performance_Employee
        FOREIGN KEY (EmployeeKey)
        REFERENCES DimEmployee(EmployeeKey),

    CONSTRAINT FK_Performance_Date
        FOREIGN KEY (DateKey)
        REFERENCES DimDate(DateKey),

    CONSTRAINT FK_Performance_Rating
        FOREIGN KEY (PerformanceRatingKey)
        REFERENCES DimPerformanceRating(PerformanceRatingKey)
)
CREATE TABLE FactTraining
(
    TrainingRecordKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    EmployeeKey INT NOT NULL,
    TrainingKey INT NOT NULL,
    DateKey INT NOT NULL,

    TrainingHours DECIMAL(6,2),
    TrainingCost DECIMAL(18,2),

    CompletionStatus VARCHAR(50),

    PreAssessmentScore DECIMAL(5,2),
    PostAssessmentScore DECIMAL(5,2),

    CertificationObtained BIT,

    EmployeeFeedbackScore DECIMAL(5,2),

    CONSTRAINT FK_Training_Employee
        FOREIGN KEY (EmployeeKey)
        REFERENCES DimEmployee(EmployeeKey),

    CONSTRAINT FK_Training_Type
        FOREIGN KEY (TrainingKey)
        REFERENCES DimTraining(TrainingKey),

    CONSTRAINT FK_Training_Date
        FOREIGN KEY (DateKey)
        REFERENCES DimDate(DateKey)
)
CREATE TABLE FactLeave
(
    LeaveKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    EmployeeKey INT NOT NULL,

    StartDateKey INT,
    EndDateKey INT,

    LeaveType VARCHAR(50),

    LeaveDays DECIMAL(6,2),

    ApprovalStatus VARCHAR(50),

    LeaveReason VARCHAR(255),

    CONSTRAINT FK_Leave_Employee
        FOREIGN KEY (EmployeeKey)
        REFERENCES DimEmployee(EmployeeKey)
)
CREATE TABLE FactOvertime
(
    OvertimeKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    EmployeeKey INT NOT NULL,
    DateKey INT NOT NULL,

    OvertimeHours DECIMAL(6,2),

    OvertimeReason VARCHAR(255),

    Approved BIT,

    OvertimeCost DECIMAL(18,2),

    CONSTRAINT FK_Overtime_Employee
        FOREIGN KEY (EmployeeKey)
        REFERENCES DimEmployee(EmployeeKey),

    CONSTRAINT FK_Overtime_Date
        FOREIGN KEY (DateKey)
        REFERENCES DimDate(DateKey)
)
CREATE TABLE FactEmployeeSurvey
(
    SurveyResponseKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    EmployeeKey INT NOT NULL,
    DateKey INT NOT NULL,

    EngagementScore DECIMAL(5,2),
    SatisfactionScore DECIMAL(5,2),
    ManagerScore DECIMAL(5,2),
    CompensationSatisfaction DECIMAL(5,2),
    CareerGrowthScore DECIMAL(5,2),
    WorkLifeBalanceScore DECIMAL(5,2),

    IntentToLeaveScore DECIMAL(5,2),

    eNPSScore INT,

    CONSTRAINT FK_Survey_Employee
        FOREIGN KEY (EmployeeKey)
        REFERENCES DimEmployee(EmployeeKey),

    CONSTRAINT FK_Survey_Date
        FOREIGN KEY (DateKey)
        REFERENCES DimDate(DateKey)
)
CREATE TABLE FactPromotion
(
    PromotionKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    EmployeeKey INT NOT NULL,

    DateKey INT NOT NULL,

    PreviousJobKey INT,
    NewJobKey INT,

    PreviousSalary DECIMAL(18,2),
    NewSalary DECIMAL(18,2),

    PromotionType VARCHAR(100),

    CONSTRAINT FK_Promotion_Employee
        FOREIGN KEY (EmployeeKey)
        REFERENCES DimEmployee(EmployeeKey),

    CONSTRAINT FK_Promotion_Date
        FOREIGN KEY (DateKey)
        REFERENCES DimDate(DateKey)
)
CREATE TABLE FactExit
(
    ExitKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    EmployeeKey INT NOT NULL,
    DateKey INT NOT NULL,

    ExitReasonKey INT,

    ExitInterviewCompleted BIT,

    FinalEngagementScore DECIMAL(5,2),

    WouldRecommendCompany BIT,

    RehireEligible BIT,

    ExitComment VARCHAR(500),

    CONSTRAINT FK_Exit_Employee
        FOREIGN KEY (EmployeeKey)
        REFERENCES DimEmployee(EmployeeKey),

    CONSTRAINT FK_Exit_Date
        FOREIGN KEY (DateKey)
        REFERENCES DimDate(DateKey),

    CONSTRAINT FK_Exit_Reason
        FOREIGN KEY (ExitReasonKey)
        REFERENCES DimExitReason(ExitReasonKey)
)
CREATE TABLE FactRecruitment
(
    RecruitmentKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    CandidateID VARCHAR(30),

    ApplicationDateKey INT,

    RecruitmentSourceKey INT,

    JobKey INT,

    LocationKey INT,

    CandidateStatus VARCHAR(50),

    ScreeningDateKey INT,
    InterviewDateKey INT,
    OfferDateKey INT,
    JoiningDateKey INT,

    ExpectedSalary DECIMAL(18,2),

    OfferedSalary DECIMAL(18,2),

    RecruitmentCost DECIMAL(18,2),

    DaysToHire INT,

    OfferAccepted BIT,

    JoinedCompany BIT,

    CONSTRAINT FK_Recruitment_Source
        FOREIGN KEY (RecruitmentSourceKey)
        REFERENCES DimRecruitmentSource(RecruitmentSourceKey),

    CONSTRAINT FK_Recruitment_Job
        FOREIGN KEY (JobKey)
        REFERENCES DimJob(JobKey),

    CONSTRAINT FK_Recruitment_Location
        FOREIGN KEY (LocationKey)
        REFERENCES DimLocation(LocationKey)
)
INSERT INTO DimDepartment
(
    DepartmentCode,
    DepartmentName,
    BusinessUnit,
    CostCenter,
    DepartmentHead
)
VALUES
('SE',   'Software Engineering', 'Technology Services', 'CC-TECH-001', 'Arif Rahman'),
('GD',   'Graphic Design',       'Creative Services',   'CC-CREATIVE-001', 'Nadia Islam'),
('UX',   'UI/UX Design',         'Creative Services',   'CC-CREATIVE-002', 'Fahim Ahmed'),
('BPO',  'BPO Operations',       'Business Process Services', 'CC-BPO-001', 'Sadia Khan'),
('DM',   'Digital Marketing',    'Digital Services',  'CC-DIGITAL-001', 'Tanvir Hasan'),
('QA',   'Quality Assurance',    'Technology Services', 'CC-TECH-002', 'Mahmudul Hasan'),
('CS',   'Client Success',       'Client Services',    'CC-CLIENT-001', 'Nusrat Jahan'),
('SAL',  'Sales',                'Commercial',         'CC-SALES-001', 'Imran Hossain'),
('HR',   'Human Resources',      'Corporate Services', 'CC-HR-001', 'Samira Ahmed'),
('FIN',  'Finance',              'Corporate Services', 'CC-FIN-001', 'Rafiq Chowdhury'),
('IT',   'IT & Infrastructure',  'Technology Services', 'CC-TECH-003', 'Mehedi Hasan')
INSERT INTO DimLocation
(
    LocationCode,
    City,
    Country,
    OfficeType,
    IsRemote
)
VALUES
('DHK-HQ', 'Dhaka', 'Bangladesh', 'Head Office', 0),
('DHK-02', 'Dhaka', 'Bangladesh', 'Branch Office', 0),
('CTG-01', 'Chattogram', 'Bangladesh', 'Branch Office', 0),
('SYL-01', 'Sylhet', 'Bangladesh', 'Branch Office', 0),
('REMOTE', 'Multiple', 'Bangladesh', 'Remote', 1)
INSERT INTO DimRecruitmentSource
(
    SourceName,
    SourceCategory
)
VALUES
('LinkedIn', 'Professional Network'),
('Bdjobs', 'Job Portal'),
('Employee Referral', 'Internal Referral'),
('Company Website', 'Direct Application'),
('Recruitment Agency', 'Agency'),
('University Recruitment', 'Campus'),
('Facebook', 'Social Media'),
('Walk-in Application', 'Direct Application'),
('Internal Transfer', 'Internal Mobility'),
('Freelancer Conversion', 'Talent Conversion')
INSERT INTO DimJob
(
    JobCode,
    JobTitle,
    JobFamily,
    JobLevel,
    EmploymentType,
    MinimumSalary,
    MaximumSalary
)
VALUES

-- SOFTWARE
('SE-JR', 'Junior Software Engineer', 'Software Engineering', 'Entry', 'Full-Time', 30000, 50000),
('SE-MID', 'Software Engineer', 'Software Engineering', 'Mid', 'Full-Time', 50000, 85000),
('SE-SR', 'Senior Software Engineer', 'Software Engineering', 'Senior', 'Full-Time', 85000, 140000),
('SE-LEAD', 'Technical Lead', 'Software Engineering', 'Lead', 'Full-Time', 130000, 200000),

-- DESIGN
('GD-JR', 'Junior Graphic Designer', 'Graphic Design', 'Entry', 'Full-Time', 22000, 35000),
('GD-MID', 'Graphic Designer', 'Graphic Design', 'Mid', 'Full-Time', 35000, 60000),
('GD-SR', 'Senior Graphic Designer', 'Graphic Design', 'Senior', 'Full-Time', 60000, 95000),
('GD-LEAD', 'Creative Lead', 'Graphic Design', 'Lead', 'Full-Time', 85000, 140000),

-- UX
('UX-JR', 'Junior UI/UX Designer', 'UI/UX Design', 'Entry', 'Full-Time', 28000, 45000),
('UX-MID', 'UI/UX Designer', 'UI/UX Design', 'Mid', 'Full-Time', 45000, 75000),
('UX-SR', 'Senior UI/UX Designer', 'UI/UX Design', 'Senior', 'Full-Time', 75000, 120000),

-- BPO
('BPO-AGT', 'BPO Service Associate', 'BPO Operations', 'Entry', 'Full-Time', 18000, 28000),
('BPO-SR', 'Senior BPO Associate', 'BPO Operations', 'Mid', 'Full-Time', 26000, 40000),
('BPO-SUP', 'BPO Supervisor', 'BPO Operations', 'Supervisor', 'Full-Time', 40000, 65000),
('BPO-MGR', 'BPO Operations Manager', 'BPO Operations', 'Manager', 'Full-Time', 65000, 110000),

-- MARKETING
('DM-EXE', 'Digital Marketing Executive', 'Digital Marketing', 'Entry', 'Full-Time', 25000, 40000),
('DM-SPEC', 'Digital Marketing Specialist', 'Digital Marketing', 'Mid', 'Full-Time', 40000, 70000),
('DM-MGR', 'Digital Marketing Manager', 'Digital Marketing', 'Manager', 'Full-Time', 70000, 120000),

-- QA
('QA-JR', 'Junior QA Engineer', 'Quality Assurance', 'Entry', 'Full-Time', 28000, 45000),
('QA-MID', 'QA Engineer', 'Quality Assurance', 'Mid', 'Full-Time', 45000, 75000),
('QA-SR', 'Senior QA Engineer', 'Quality Assurance', 'Senior', 'Full-Time', 75000, 115000),

-- CLIENT / SALES
('CS-EXE', 'Client Success Executive', 'Client Success', 'Entry', 'Full-Time', 28000, 45000),
('CS-MGR', 'Client Success Manager', 'Client Success', 'Manager', 'Full-Time', 65000, 110000),
('SAL-EXE', 'Sales Executive', 'Sales', 'Entry', 'Full-Time', 25000, 45000),
('SAL-MGR', 'Sales Manager', 'Sales', 'Manager', 'Full-Time', 70000, 120000),

-- CORPORATE
('HR-EXE', 'HR Executive', 'Human Resources', 'Entry', 'Full-Time', 30000, 50000),
('HR-MGR', 'HR Manager', 'Human Resources', 'Manager', 'Full-Time', 70000, 120000),
('FIN-EXE', 'Finance Executive', 'Finance', 'Entry', 'Full-Time', 30000, 50000),
('FIN-MGR', 'Finance Manager', 'Finance', 'Manager', 'Full-Time', 70000, 120000),
('IT-ENG', 'IT Support Engineer', 'IT & Infrastructure', 'Mid', 'Full-Time', 40000, 70000),
('IT-MGR', 'IT Manager', 'IT & Infrastructure', 'Manager', 'Full-Time', 75000, 130000)
INSERT INTO DimTraining
(
    TrainingCode,
    TrainingName,
    TrainingCategory,
    DeliveryMethod,
    Provider
)
VALUES
('TRN-001', 'Technical Skills Development', 'Technical', 'Instructor Led', 'Nexora Academy'),
('TRN-002', 'Advanced Graphic Design', 'Creative', 'Workshop', 'Nexora Academy'),
('TRN-003', 'UI/UX Design Principles', 'Creative', 'Workshop', 'Nexora Academy'),
('TRN-004', 'Leadership Development', 'Leadership', 'Instructor Led', 'Nexora Academy'),
('TRN-005', 'Project Management', 'Management', 'Online', 'External Provider'),
('TRN-006', 'Client Communication', 'Soft Skills', 'Instructor Led', 'Nexora Academy'),
('TRN-007', 'Business English', 'Soft Skills', 'Online', 'External Provider'),
('TRN-008', 'Cybersecurity Awareness', 'Compliance', 'Online', 'External Provider'),
('TRN-009', 'Performance Management', 'HR', 'Workshop', 'Nexora Academy'),
('TRN-010', 'Strategic HRM', 'HR', 'Workshop', 'External Consultant'),
('TRN-011', 'Data Analytics', 'Technical', 'Online', 'External Provider'),
('TRN-012', 'Agile & Scrum', 'Technical', 'Instructor Led', 'External Provider')
INSERT INTO DimExitReason
(
    ExitReason,
    ExitCategory,
    VoluntaryFlag
)
VALUES
('Better Compensation', 'External Opportunity', 1),
('Career Growth', 'Career Development', 1),
('Better Role', 'External Opportunity', 1),
('Poached by Competitor', 'External Opportunity', 1),
('Manager Relationship', 'Management', 1),
('Workload / Burnout', 'Work Environment', 1),
('Lack of Promotion', 'Career Development', 1),
('Lack of Training', 'Career Development', 1),
('Relocation', 'Personal', 1),
('Higher Education', 'Personal', 1),
('Personal Reasons', 'Personal', 1),
('Health Reasons', 'Personal', 1),
('Performance Termination', 'Involuntary', 0),
('Policy Violation', 'Involuntary', 0),
('Redundancy', 'Involuntary', 0),
('End of Contract', 'Involuntary', 0)
INSERT INTO DimPerformanceRating
(
    PerformanceRatingKey,
    RatingName,
    RatingDescription,
    RatingScore
)
VALUES
(1, 'Unsatisfactory', 'Performance significantly below expectations', 1.00),
(2, 'Needs Improvement', 'Performance below expected standards', 2.00),
(3, 'Meets Expectations', 'Consistently meets job expectations', 3.00),
(4, 'Exceeds Expectations', 'Frequently exceeds expectations', 4.00),
(5, 'Exceptional', 'Consistently demonstrates exceptional performance', 5.00)
CREATE TABLE #NamePool
(
    NameID INT IDENTITY(1,1),
    FirstName VARCHAR(100),
    Gender VARCHAR(20)
)
INSERT INTO #NamePool (FirstName, Gender)
VALUES
('Arif','Male'),
('Rahim','Male'),
('Sakib','Male'),
('Tanvir','Male'),
('Fahim','Male'),
('Nabil','Male'),
('Imran','Male'),
('Shakib','Male'),
('Mehedi','Male'),
('Hasan','Male'),
('Rafi','Male'),
('Adnan','Male'),
('Mahmud','Male'),
('Nayeem','Male'),
('Farhan','Male'),
('Shuvo','Male'),
('Siam','Male'),
('Arafat','Male'),
('Tareq','Male'),
('Rakib','Male'),
('Nusrat','Female'),
('Sadia','Female'),
('Nadia','Female'),
('Samira','Female'),
('Maliha','Female'),
('Tasnim','Female'),
('Jannat','Female'),
('Sumaiya','Female'),
('Farzana','Female'),
('Faria','Female'),
('Raisa','Female'),
('Tanjila','Female'),
('Mim','Female'),
('Sanjida','Female'),
('Ayesha','Female'),
('Rumana','Female'),
('Mahira','Female'),
('Anika','Female'),
('Sharmeen','Female'),
('Sabrina','Female')
CREATE TABLE #SurnamePool
(
    SurnameID INT IDENTITY(1,1),
    LastName VARCHAR(100)
);

INSERT INTO #SurnamePool (LastName)
VALUES
('Rahman'),
('Ahmed'),
('Hossain'),
('Islam'),
('Khan'),
('Chowdhury'),
('Hasan'),
('Karim'),
('Mahmud'),
('Uddin'),
('Sarker'),
('Miah'),
('Kabir'),
('Bhuiyan'),
('Akter'),
('Jahan'),
('Haque'),
('Rashid'),
('Siddique'),
('Alam')
;WITH Numbers AS
(
    SELECT TOP (10000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS EmployeeNumber
    FROM sys.all_objects A
    CROSS JOIN sys.all_objects B
)
USE Nexora_HR;
GO

IF OBJECT_ID('dbo.EmployeeSeed', 'U') IS NOT NULL
    DROP TABLE dbo.EmployeeSeed;
GO

CREATE TABLE dbo.EmployeeSeed
(
    EmployeeNumber INT PRIMARY KEY,
    DepartmentCode VARCHAR(20) NOT NULL,
    JobCode VARCHAR(30) NULL
);
GO
;WITH EmployeeAssignment AS
(
    SELECT
        EmployeeNumber,

        CASE
            WHEN EmployeeNumber BETWEEN 1 AND 2500
                THEN 'BPO'

            WHEN EmployeeNumber BETWEEN 2501 AND 4300
                THEN 'SE'

            WHEN EmployeeNumber BETWEEN 4301 AND 5800
                THEN 'GD'

            WHEN EmployeeNumber BETWEEN 5801 AND 6600
                THEN 'UX'

            WHEN EmployeeNumber BETWEEN 6601 AND 7400
                THEN 'DM'

            WHEN EmployeeNumber BETWEEN 7401 AND 8100
                THEN 'QA'

            WHEN EmployeeNumber BETWEEN 8101 AND 8700
                THEN 'CS'

            WHEN EmployeeNumber BETWEEN 8701 AND 9200
                THEN 'SAL'

            WHEN EmployeeNumber BETWEEN 9201 AND 9500
                THEN 'HR'

            WHEN EmployeeNumber BETWEEN 9501 AND 9800
                THEN 'FIN'

            WHEN EmployeeNumber BETWEEN 9801 AND 10000
                THEN 'IT'
        END AS DepartmentCode

    FROM #EmployeeNumbers
)

INSERT INTO dbo.EmployeeSeed
(
    EmployeeNumber,
    DepartmentCode,
    JobCode
)

SELECT
    EmployeeNumber,
    DepartmentCode,
    NULL
FROM EmployeeAssignment
WITH RankedEmployees AS
(
    SELECT
        EmployeeNumber,
        DepartmentCode,

        ROW_NUMBER() OVER
        (
            PARTITION BY DepartmentCode
            ORDER BY EmployeeNumber
        ) AS DeptRow,

        COUNT(*) OVER
        (
            PARTITION BY DepartmentCode
        ) AS DeptTotal

    FROM EmployeeSeed
)

UPDATE E
SET JobCode =
    CASE R.DepartmentCode

        /* =========================
           BPO
           ========================= */

        WHEN 'BPO' THEN
            CASE
                WHEN R.DeptRow <= R.DeptTotal * 0.70
                    THEN 'BPO-AGT'

                WHEN R.DeptRow <= R.DeptTotal * 0.90
                    THEN 'BPO-SR'

                WHEN R.DeptRow <= R.DeptTotal * 0.98
                    THEN 'BPO-SUP'

                ELSE 'BPO-MGR'
            END

        /* =========================
           SOFTWARE ENGINEERING
           ========================= */

        WHEN 'SE' THEN
            CASE
                WHEN R.DeptRow <= R.DeptTotal * 0.40
                    THEN 'SE-JR'

                WHEN R.DeptRow <= R.DeptTotal * 0.75
                    THEN 'SE-MID'

                WHEN R.DeptRow <= R.DeptTotal * 0.95
                    THEN 'SE-SR'

                ELSE 'SE-LEAD'
            END

        /* =========================
           GRAPHIC DESIGN
           ========================= */

        WHEN 'GD' THEN
            CASE
                WHEN R.DeptRow <= R.DeptTotal * 0.40
                    THEN 'GD-JR'

                WHEN R.DeptRow <= R.DeptTotal * 0.75
                    THEN 'GD-MID'

                WHEN R.DeptRow <= R.DeptTotal * 0.95
                    THEN 'GD-SR'

                ELSE 'GD-LEAD'
            END

        /* =========================
           UI / UX
           ========================= */

        WHEN 'UX' THEN
            CASE
                WHEN R.DeptRow <= R.DeptTotal * 0.45
                    THEN 'UX-JR'

                WHEN R.DeptRow <= R.DeptTotal * 0.80
                    THEN 'UX-MID'

                ELSE 'UX-SR'
            END

        /* =========================
           DIGITAL MARKETING
           ========================= */

        WHEN 'DM' THEN
            CASE
                WHEN R.DeptRow <= R.DeptTotal * 0.50
                    THEN 'DM-EXE'

                WHEN R.DeptRow <= R.DeptTotal * 0.85
                    THEN 'DM-SPEC'

                ELSE 'DM-MGR'
            END

        /* =========================
           QUALITY ASSURANCE
           ========================= */

        WHEN 'QA' THEN
            CASE
                WHEN R.DeptRow <= R.DeptTotal * 0.45
                    THEN 'QA-JR'

                WHEN R.DeptRow <= R.DeptTotal * 0.80
                    THEN 'QA-MID'

                ELSE 'QA-SR'
            END

        /* =========================
           CLIENT SUCCESS
           ========================= */

        WHEN 'CS' THEN
            CASE
                WHEN R.DeptRow <= R.DeptTotal * 0.75
                    THEN 'CS-EXE'

                ELSE 'CS-MGR'
            END

        /* =========================
           SALES
           ========================= */

        WHEN 'SAL' THEN
            CASE
                WHEN R.DeptRow <= R.DeptTotal * 0.75
                    THEN 'SAL-EXE'

                ELSE 'SAL-MGR'
            END

        /* =========================
           HR
           ========================= */

        WHEN 'HR' THEN
            CASE
                WHEN R.DeptRow <= R.DeptTotal * 0.75
                    THEN 'HR-EXE'

                ELSE 'HR-MGR'
            END

        /* =========================
           FINANCE
           ========================= */

        WHEN 'FIN' THEN
            CASE
                WHEN R.DeptRow <= R.DeptTotal * 0.75
                    THEN 'FIN-EXE'

                ELSE 'FIN-MGR'
            END

        /* =========================
           IT
           ========================= */

        WHEN 'IT' THEN
            CASE
                WHEN R.DeptRow <= R.DeptTotal * 0.75
                    THEN 'IT-ENG'

                ELSE 'IT-MGR'
            END

    END

FROM EmployeeSeed E

INNER JOIN RankedEmployees R
    ON E.EmployeeNumber = R.EmployeeNumber
SELECT
    ORDINAL_POSITION,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'DimEmployee'
  AND ORDINAL_POSITION >= 22
ORDER BY ORDINAL_POSITION
USE Nexora_HR;
GO

BEGIN TRANSACTION;

BEGIN TRY

    INSERT INTO dbo.DimEmployee
    (
        EmployeeID,
        FirstName,
        LastName,
        Gender,
        DateOfBirth,
        HireDate,
        ConfirmationDate,
        TerminationDate,
        EmploymentStatus,
        DepartmentKey,
        JobKey,
        LocationKey,
        ManagerEmployeeKey,
        RecruitmentSourceKey,
        EducationLevel,
        FieldOfStudy,
        YearsOfExperience,
        BaseSalary,
        IsRemote,
        CreatedDate
    )

    SELECT

        /* =====================================================
           EMPLOYEE ID
           ===================================================== */

        CONCAT(
            'EMP',
            RIGHT(
                '00000' + CAST(S.EmployeeNumber AS VARCHAR(5)),
                5
            )
        ) AS EmployeeID,


        /* =====================================================
           NAME
           ===================================================== */

        N.FirstName,

        SN.LastName,

        N.Gender,


        /* =====================================================
           DATE OF BIRTH
           Job level influences age
           ===================================================== */

        DATEADD(
            DAY,
            -(
                CASE J.JobLevel

                    WHEN 'Entry'
                        THEN 7300 + ABS(CHECKSUM(NEWID())) % 3500

                    WHEN 'Mid'
                        THEN 8500 + ABS(CHECKSUM(NEWID())) % 3500

                    WHEN 'Senior'
                        THEN 9500 + ABS(CHECKSUM(NEWID())) % 4000

                    WHEN 'Supervisor'
                        THEN 10000 + ABS(CHECKSUM(NEWID())) % 3500

                    WHEN 'Lead'
                        THEN 10500 + ABS(CHECKSUM(NEWID())) % 3500

                    WHEN 'Manager'
                        THEN 11000 + ABS(CHECKSUM(NEWID())) % 4000

                    ELSE
                        8500 + ABS(CHECKSUM(NEWID())) % 3500

                END
            ),
            CAST(GETDATE() AS DATE)
        ) AS DateOfBirth,


        /* =====================================================
           HIRE DATE
           Mostly 2019-2026
           ===================================================== */

        DATEADD(
            DAY,
            -(
                30 +
                ABS(CHECKSUM(NEWID())) % 2850
            ),
            CAST(GETDATE() AS DATE)
        ) AS HireDate,


        /* =====================================================
           CONFIRMATION DATE
           3-6 months after joining
           ===================================================== */

        DATEADD(
            DAY,
            90 + ABS(CHECKSUM(NEWID())) % 91,

            DATEADD(
                DAY,
                -(
                    30 +
                    ABS(CHECKSUM(NEWID())) % 2850
                ),
                CAST(GETDATE() AS DATE)
            )
        ) AS ConfirmationDate,


        /* =====================================================
           TERMINATION DATE
           ~18% former employees
           ===================================================== */

        CASE
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 18
            THEN
                DATEADD(
                    DAY,
                    -(
                        ABS(CHECKSUM(NEWID())) % 900
                    ),
                    CAST(GETDATE() AS DATE)
                )
            ELSE NULL
        END AS TerminationDate,


        /* =====================================================
           EMPLOYMENT STATUS
           ===================================================== */

        CASE
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 18
                THEN 'Terminated'
            ELSE 'Active'
        END AS EmploymentStatus,


        /* =====================================================
           DEPARTMENT
           ===================================================== */

        D.DepartmentKey,


        /* =====================================================
           JOB
           ===================================================== */

        J.JobKey,


        /* =====================================================
           LOCATION
           ===================================================== */

        L.LocationKey,


        /* =====================================================
           MANAGER
           Populated later
           ===================================================== */

        NULL AS ManagerEmployeeKey,


        /* =====================================================
           RECRUITMENT SOURCE
           ===================================================== */

        RS.RecruitmentSourceKey,


        /* =====================================================
           EDUCATION
           ===================================================== */

        CASE
            WHEN J.JobLevel IN ('Senior', 'Lead', 'Manager')
            THEN
                CASE
                    WHEN ABS(CHECKSUM(NEWID())) % 100 < 65
                        THEN 'Masters'
                    WHEN ABS(CHECKSUM(NEWID())) % 100 < 95
                        THEN 'Bachelor'
                    ELSE 'Professional Certification'
                END

            WHEN ABS(CHECKSUM(NEWID())) % 100 < 10
                THEN 'Secondary'

            WHEN ABS(CHECKSUM(NEWID())) % 100 < 70
                THEN 'Bachelor'

            WHEN ABS(CHECKSUM(NEWID())) % 100 < 95
                THEN 'Masters'

            ELSE 'Professional Certification'
        END AS EducationLevel,


        /* =====================================================
           FIELD OF STUDY
           ===================================================== */

        CASE

            WHEN J.JobFamily = 'Software Engineering'
                THEN 'Computer Science'

            WHEN J.JobFamily = 'Graphic Design'
                THEN 'Graphic Design'

            WHEN J.JobFamily = 'UI/UX Design'
                THEN 'Design & Multimedia'

            WHEN J.JobFamily = 'Digital Marketing'
                THEN 'Marketing'

            WHEN J.JobFamily = 'Quality Assurance'
                THEN 'Computer Science'

            WHEN J.JobFamily = 'BPO Operations'
                THEN 'Business Administration'

            WHEN J.JobFamily = 'Client Success'
                THEN 'Business Administration'

            WHEN J.JobFamily = 'Sales'
                THEN 'Business Administration'

            WHEN J.JobFamily = 'Human Resources'
                THEN 'Human Resource Management'

            WHEN J.JobFamily = 'Finance'
                THEN 'Finance & Accounting'

            WHEN J.JobFamily = 'IT & Infrastructure'
                THEN 'Computer Science'

            ELSE 'General'
        END AS FieldOfStudy,


        /* =====================================================
           EXPERIENCE
           Correlated with job level
           ===================================================== */

        CAST(

            CASE J.JobLevel

                WHEN 'Entry'
                    THEN 0.5 + ABS(CHECKSUM(NEWID())) % 25 / 10.0

                WHEN 'Mid'
                    THEN 2.5 + ABS(CHECKSUM(NEWID())) % 40 / 10.0

                WHEN 'Senior'
                    THEN 5.0 + ABS(CHECKSUM(NEWID())) % 50 / 10.0

                WHEN 'Supervisor'
                    THEN 5.0 + ABS(CHECKSUM(NEWID())) % 60 / 10.0

                WHEN 'Lead'
                    THEN 7.0 + ABS(CHECKSUM(NEWID())) % 60 / 10.0

                WHEN 'Manager'
                    THEN 8.0 + ABS(CHECKSUM(NEWID())) % 80 / 10.0

                ELSE 2.0

            END

            AS DECIMAL(5,2)

        ) AS YearsOfExperience,


        /* =====================================================
           SALARY
           Position within job salary band
           ===================================================== */

        CAST(

            J.MinimumSalary +

            (
                ABS(CHECKSUM(NEWID()))
                %
                (
                    CAST(
                        J.MaximumSalary -
                        J.MinimumSalary
                        AS INT
                    ) + 1
                )
            )

            AS DECIMAL(18,2)

        ) AS BaseSalary,


        /* =====================================================
           REMOTE
           BPO / technology / creative have greater probability
           ===================================================== */

        CASE

            WHEN J.JobFamily IN
            (
                'Software Engineering',
                'Graphic Design',
                'UI/UX Design',
                'Digital Marketing',
                'Quality Assurance'
            )
            THEN
                CASE
                    WHEN ABS(CHECKSUM(NEWID())) % 100 < 45
                        THEN 1
                    ELSE 0
                END

            WHEN J.JobFamily = 'BPO Operations'
            THEN
                CASE
                    WHEN ABS(CHECKSUM(NEWID())) % 100 < 30
                        THEN 1
                    ELSE 0
                END

            ELSE
                CASE
                    WHEN ABS(CHECKSUM(NEWID())) % 100 < 15
                        THEN 1
                    ELSE 0
                END

        END AS IsRemote,


        /* =====================================================
           CREATED DATE
           ===================================================== */

        GETDATE() AS CreatedDate


    FROM dbo.EmployeeSeed S


    /* =========================================================
       NAME
       ========================================================= */

    CROSS APPLY
    (
        SELECT TOP 1
            FirstName,
            Gender
        FROM #NamePool
        ORDER BY ABS(CHECKSUM(NEWID()))
    ) N


    CROSS APPLY
    (
        SELECT TOP 1
            LastName
        FROM #SurnamePool
        ORDER BY ABS(CHECKSUM(NEWID()))
    ) SN


    /* =========================================================
       DEPARTMENT
       ========================================================= */

    INNER JOIN dbo.DimDepartment D
        ON D.DepartmentCode = S.DepartmentCode


    /* =========================================================
       JOB
       ========================================================= */

    INNER JOIN dbo.DimJob J
        ON J.JobCode = S.JobCode


    /* =========================================================
       LOCATION
       ========================================================= */

    CROSS APPLY
    (
        SELECT TOP 1
            LocationKey
        FROM dbo.DimLocation
        ORDER BY ABS(CHECKSUM(NEWID()))
    ) L


    /* =========================================================
       RECRUITMENT SOURCE
       ========================================================= */

    CROSS APPLY
    (
        SELECT TOP 1
            RecruitmentSourceKey
        FROM dbo.DimRecruitmentSource
        ORDER BY ABS(CHECKSUM(NEWID()))
    ) RS;


    /* =========================================================
       BASIC INSERT QC
       ========================================================= */

    IF (SELECT COUNT(*) FROM dbo.DimEmployee) <> 10000
    BEGIN
        THROW 50001,
        'Employee population is not exactly 10,000. Transaction cancelled.',
        1;
    END;


    COMMIT TRANSACTION;

    PRINT 'SUCCESS: 10,000 employees generated successfully.';

END TRY

BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
USE Nexora_HR;
GO

;WITH FirstNamePool AS
(
    SELECT *
    FROM
    (
        VALUES
        (1,  'Arif',     'Male'),
        (2,  'Tanvir',   'Male'),
        (3,  'Fahim',    'Male'),
        (4,  'Sakib',    'Male'),
        (5,  'Nabil',    'Male'),
        (6,  'Rafi',     'Male'),
        (7,  'Adnan',    'Male'),
        (8,  'Shakil',   'Male'),
        (9,  'Imran',    'Male'),
        (10, 'Farhan',   'Male'),
        (11, 'Mahin',    'Male'),
        (12, 'Tawhid',   'Male'),
        (13, 'Arafat',   'Male'),
        (14, 'Nayeem',   'Male'),
        (15, 'Siam',     'Male'),
        (16, 'Rahat',    'Male'),
        (17, 'Mehedi',   'Male'),
        (18, 'Hasan',    'Male'),
        (19, 'Zubair',   'Male'),
        (20, 'Nafis',    'Male'),

        (21, 'Nadia',    'Female'),
        (22, 'Maliha',   'Female'),
        (23, 'Jannat',   'Female'),
        (24, 'Sadia',    'Female'),
        (25, 'Samira',   'Female'),
        (26, 'Raisa',    'Female'),
        (27, 'Nusrat',   'Female'),
        (28, 'Faria',    'Female'),
        (29, 'Sumaiya',  'Female'),
        (30, 'Tanjila',  'Female'),
        (31, 'Farzana',  'Female'),
        (32, 'Tasnim',   'Female'),
        (33, 'Mim',      'Female'),
        (34, 'Sanjida',  'Female'),
        (35, 'Ayesha',   'Female'),
        (36, 'Rumana',   'Female'),
        (37, 'Nabila',   'Female'),
        (38, 'Lamisa',   'Female'),
        (39, 'Anika',    'Female'),
        (40, 'Safiya',   'Female')
    ) AS X(NameNumber, FirstName, Gender)
),

SurnamePool AS
(
    SELECT *
    FROM
    (
        VALUES
        (1,  'Islam'),
        (2,  'Rahman'),
        (3,  'Ahmed'),
        (4,  'Hasan'),
        (5,  'Khan'),
        (6,  'Chowdhury'),
        (7,  'Sarker'),
        (8,  'Hossain'),
        (9,  'Mahmud'),
        (10, 'Kabir'),
        (11, 'Alam'),
        (12, 'Karim'),
        (13, 'Miah'),
        (14, 'Uddin'),
        (15, 'Jahan'),
        (16, 'Akter'),
        (17, 'Siddique'),
        (18, 'Bhuiyan'),
        (19, 'Haque'),
        (20, 'Talukder')
    ) AS Y(SurnameNumber, LastName)
),

EmployeeNumbered AS
(
    SELECT
        EmployeeKey,

        Gender,

        ROW_NUMBER() OVER
        (
            PARTITION BY Gender
            ORDER BY EmployeeKey
        ) AS GenderSequence

    FROM dbo.DimEmployee
)

UPDATE E

SET
    E.FirstName = F.FirstName,

    E.LastName = S.LastName

FROM dbo.DimEmployee E

INNER JOIN EmployeeNumbered EN
    ON E.EmployeeKey = EN.EmployeeKey

INNER JOIN FirstNamePool F
    ON F.Gender = EN.Gender

    AND F.NameNumber =
    CASE
        WHEN EN.Gender = 'Male'
            THEN ((EN.GenderSequence - 1) % 20) + 1

        WHEN EN.Gender = 'Female'
            THEN ((EN.GenderSequence - 1) % 20) + 21

        ELSE
            ((EN.GenderSequence - 1) % 40) + 1
    END

CROSS APPLY
(
    SELECT
        ((E.EmployeeKey * 7 - 1) % 20) + 1
        AS SurnameNumber
) SN

INNER JOIN SurnamePool S
    ON S.SurnameNumber = SN.SurnameNumber;

PRINT 'Names successfully redistributed.';
GO
SELECT
    Gender,
    COUNT(*) AS EmployeeCount
FROM dbo.DimEmployee
GROUP BY Gender
ORDER BY Gender;
SELECT
    Gender,
    COUNT(DISTINCT FirstName) AS UniqueFirstNames
FROM dbo.DimEmployee
GROUP BY Gender
ORDER BY Gender;