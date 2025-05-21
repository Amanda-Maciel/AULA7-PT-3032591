-- Cria ou altera uma procedure chamada salaryHistogram, que recebe como parâmetro o número de intervalos desejado
CREATE OR ALTER PROCEDURE dbo.salaryHistogram
@num_intervals INT
AS
BEGIN
    -- Declaração de variáveis para armazenar o menor e maior salário, e o tamanho do intervalo
    DECLARE @min_salary FLOAT, @max_salary FLOAT, @range FLOAT;
    -- Contador para o loop
    DECLARE @i INT = 0;
    -- Variáveis para os limites inferior e superior de cada faixa salarial
    DECLARE @start_range FLOAT, @end_range FLOAT;

    -- Busca o menor e maior salário da tabela de instrutores
    SELECT @min_salary = MIN(salary), @max_salary = MAX(salary)
    FROM instructor;

    -- Verifica se todos os salários são iguais; se forem, apenas exibe a mensagem e encerra a procedure
    IF @min_salary = @max_salary
    BEGIN
        PRINT 'Todos os salários são iguais: ' + CAST(@min_salary AS VARCHAR(20));
        RETURN;
    END

    -- Calcula o tamanho de cada faixa com base na diferença entre o salário máximo e mínimo
    SET @range = (@max_salary - @min_salary) / @num_intervals;

    -- Cria uma tabela temporária para armazenar os resultados do histograma
    CREATE TABLE #Histogram (
        valorMinimo FLOAT,
        valorMaximo FLOAT,
        total INT
    );

    -- Loop que percorre todos os intervalos e contabiliza quantos instrutores se encaixam em cada um
    WHILE @i < @num_intervals
    BEGIN
        -- Define o início e o fim da faixa atual
        SET @start_range = @min_salary + @i * @range;
        SET @end_range = @start_range + @range;

        -- Para o último intervalo, inclui os salários iguais ao limite superior
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
            -- Para os demais intervalos, exclui o limite superior para evitar sobreposição
            INSERT INTO #Histogram
            SELECT
                @start_range,
                @end_range,
                COUNT(*)
            FROM instructor
            WHERE salary >= @start_range AND salary < @end_range;
        END

        -- Incrementa o contador para a próxima faixa
        SET @i = @i + 1;
    END

    -- Exibe o resultado formatado, mostrando os limites de cada faixa e a quantidade de instrutores
    SELECT
        FORMAT(valorMinimo, 'N3') AS valorMinimo,
        FORMAT(valorMaximo, 'N3') AS valorMaximo,
        total
    FROM #Histogram;

    -- Remove a tabela temporária ao final da execução
    DROP TABLE #Histogram;
END;

-- Executa a procedure passando o número de intervalos desejado
EXEC dbo.salaryHistogram 5;
