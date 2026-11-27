-- LiftLog: създаване на базата и таблиците
USE master;
GO
IF DB_ID('LiftLog') IS NOT NULL
BEGIN
    ALTER DATABASE LiftLog SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE LiftLog;
END
GO
CREATE DATABASE LiftLog;
GO
USE LiftLog;
GO

CREATE TABLE Users (
    UserId       INT IDENTITY(1,1) PRIMARY KEY,
    Username     NVARCHAR(50)  NOT NULL UNIQUE,
    Email        NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    BirthDate    DATE          NULL,
    Country      NVARCHAR(50)  NULL,
    CreatedAt    DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);

CREATE TABLE MuscleGroups (
    MuscleGroupId INT IDENTITY(1,1) PRIMARY KEY,
    Name          NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Exercises (
    ExerciseId    INT IDENTITY(1,1) PRIMARY KEY,
    Name          NVARCHAR(100) NOT NULL,
    MuscleGroupId INT           NOT NULL REFERENCES MuscleGroups(MuscleGroupId),
    Equipment     NVARCHAR(50)  NULL,
    Description   NVARCHAR(500) NULL
);

CREATE TABLE Routines (
    RoutineId INT IDENTITY(1,1) PRIMARY KEY,
    UserId    INT           NOT NULL REFERENCES Users(UserId),
    Name      NVARCHAR(100) NOT NULL,
    Notes     NVARCHAR(500) NULL,
    CreatedAt DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);

-- връзка много към много: програма <-> упражнение
CREATE TABLE RoutineExercises (
    RoutineId  INT NOT NULL REFERENCES Routines(RoutineId),
    ExerciseId INT NOT NULL REFERENCES Exercises(ExerciseId),
    OrderIndex INT NOT NULL,
    TargetSets INT NOT NULL DEFAULT 3,
    PRIMARY KEY (RoutineId, ExerciseId)
);

CREATE TABLE Workouts (
    WorkoutId   INT IDENTITY(1,1) PRIMARY KEY,
    UserId      INT           NOT NULL REFERENCES Users(UserId),
    RoutineId   INT           NULL REFERENCES Routines(RoutineId),
    StartTime   DATETIME2     NOT NULL,
    EndTime     DATETIME2     NULL,
    Notes       NVARCHAR(500) NULL,
    TotalVolume DECIMAL(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT CK_Workouts_Time CHECK (EndTime IS NULL OR EndTime >= StartTime)
);

CREATE TABLE WorkoutSets (
    SetId      INT IDENTITY(1,1) PRIMARY KEY,
    WorkoutId  INT          NOT NULL REFERENCES Workouts(WorkoutId),
    ExerciseId INT          NOT NULL REFERENCES Exercises(ExerciseId),
    SetNumber  INT          NOT NULL,
    WeightKg   DECIMAL(6,2) NOT NULL CHECK (WeightKg >= 0),
    Reps       INT          NOT NULL CHECK (Reps >= 1)
);
GO
