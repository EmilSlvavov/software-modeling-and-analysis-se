USE LiftLog;
GO

-- Функция: обем на една серия (тежест x повторения)
CREATE OR ALTER FUNCTION dbo.fn_SetVolume (@WeightKg DECIMAL(6,2), @Reps INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @WeightKg * @Reps;
END
GO

-- Съхранена процедура: прогрес на потребител по дадено упражнение
CREATE OR ALTER PROCEDURE dbo.usp_GetExerciseProgress
    @UserId INT,
    @ExerciseId INT
AS
BEGIN
    SELECT CAST(w.StartTime AS DATE)                AS WorkoutDate,
           MAX(s.WeightKg)                          AS MaxWeightKg,
           SUM(dbo.fn_SetVolume(s.WeightKg, s.Reps)) AS Volume
    FROM WorkoutSets s
    JOIN Workouts w ON w.WorkoutId = s.WorkoutId
    WHERE w.UserId = @UserId AND s.ExerciseId = @ExerciseId
    GROUP BY CAST(w.StartTime AS DATE)
    ORDER BY WorkoutDate;
END
GO

-- Тригер: преизчислява общия обем на тренировката при промяна на сериите
CREATE OR ALTER TRIGGER dbo.trg_WorkoutSets_UpdateVolume
ON WorkoutSets
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE w
    SET TotalVolume = ISNULL((SELECT SUM(dbo.fn_SetVolume(s.WeightKg, s.Reps))
                              FROM WorkoutSets s WHERE s.WorkoutId = w.WorkoutId), 0)
    FROM Workouts w
    WHERE w.WorkoutId IN (SELECT WorkoutId FROM inserted UNION SELECT WorkoutId FROM deleted);
END
GO
