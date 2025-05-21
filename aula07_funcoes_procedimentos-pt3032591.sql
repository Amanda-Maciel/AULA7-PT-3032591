CREATE OR ALTER PROCEDURE dbo.salaryHistogram
@num_intervals INT
AS
BEGIN
DECLARE @min_salary FLOAT, @max_salary FLOAT, @range FLOAT;
DECLARE @i INT = 0;
DECLARE @start_range FLOAT, @end_range FLOAT;


SELECT @min_salary = MIN(salary), @max_salary = MAX(salary)
FROM instructor;

IF @min_salary = @max_salary
BEGIN
PRINT 'Todos os salários são iguais: ' + CAST(@min_salary AS VARCHAR(20));
RETURN;
END


SET @range = (@max_salary - @min_salary) / @num_intervals;


CREATE TABLE #Histogram (
valorMinimo FLOAT,
valorMaximo FLOAT,
total INT
);


WHILE @i < @num_intervals
BEGIN
SET @start_range = @min_salary + @i * @range;
SET @end_range = @start_range + @range;


IF @i = @num_intervals - 1
BEGIN
INSERT INTO #Histogram
SELECT
@start_range,
@end_range,
COUNT(*)
FROM instructor
WHERE salary >= @start_range AND salary <= @end_range;
END
ELSE
BEGIN
INSERT INTO #Histogram
SELECT
@start_range,
@end_range,
COUNT(*)
FROM instructor
WHERE salary >= @start_range AND salary < @end_range;
END

SET @i = @i + 1;
END


SELECT
FORMAT(valorMinimo, 'N3') AS valorMinimo,
FORMAT(valorMaximo, 'N3') AS valorMaximo,
total
FROM #Histogram;

DROP TABLE #Histogram;
END;


EXEC dbo.salaryHistogram 5