CREATE OR ALTER PROCEDURE sp_CadastraNotas
	(
		@MATRICULA INT,
		@CURSO CHAR(3),
		@MATERIA CHAR(3),
		@PERLETIVO CHAR(4),
		@NOTA FLOAT,
		@FALTA INT,
		@BIMESTRE INT
	)
	AS
BEGIN

		IF @BIMESTRE = 1
		    BEGIN

                UPDATE MATRICULA
                SET N1 = @NOTA,
                    F1 = @FALTA,
                    TOTALPONTOS = @NOTA,
                    TOTALFALTAS = @FALTA,
                    MEDIA = @NOTA
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
		    END

        ELSE 
        
        IF @BIMESTRE = 2
            BEGIN

                UPDATE MATRICULA
                SET N2 = @NOTA,
                    F2 = @FALTA,
                    TOTALPONTOS = @NOTA + N1,
                    TOTALFALTAS = @FALTA + F1,
                    MEDIA = (@NOTA + N1) / 2
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
            END

        ELSE 
        
        IF @BIMESTRE = 3
            BEGIN

                UPDATE MATRICULA
                SET N3 = @NOTA,
                    F3 = @FALTA,
                    TOTALPONTOS = @NOTA + N1 + N2,
                    TOTALFALTAS = @FALTA + F1 + F2,
                    MEDIA = (@NOTA + N1 + N2) / 3
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
            END

        ELSE 
        
        IF @BIMESTRE = 4
            BEGIN

                DECLARE @RESULTADO VARCHAR(50),
                        @FREQUENCIA FLOAT,
                        @MEDIAFINAL FLOAT,
                        @CARGAHORA INT,
                        @TOTALFALTAS_ATUAL INT,
                        @MEDIA_ATUAL FLOAT
                
                SET @CARGAHORA = (
                    SELECT CARGAHORARIA FROM MATERIAS 
                    WHERE SIGLA = @MATERIA AND CURSO = @CURSO
                )

                UPDATE MATRICULA
                SET N4 = @NOTA,
                    F4 = @FALTA,
                    TOTALPONTOS = @NOTA + N1 + N2 + N3,
                    TOTALFALTAS = @FALTA + F1 + F2 + F3,
                    MEDIA = (@NOTA + N1 + N2 + N3) / 4
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;

                SELECT @TOTALFALTAS_ATUAL = TOTALFALTAS, @MEDIA_ATUAL = MEDIA
                FROM MATRICULA
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;    

                SET @FREQUENCIA = 100 * ((@CARGAHORA - @TOTALFALTAS_ATUAL) / CAST(@CARGAHORA AS FLOAT));

                IF @FREQUENCIA < 75.0
                BEGIN
                    SET @RESULTADO = 'REPROVADO POR FALTA';
                END
                ELSE IF @MEDIA_ATUAL >= 7.0
                BEGIN
                    SET @RESULTADO = 'APROVADO';
                END
                ELSE IF @MEDIA_ATUAL < 4.0
                BEGIN
                    SET @RESULTADO = 'REPROVADO POR NOTA';
                END

                ELSE

                BEGIN
                    SET @RESULTADO = 'EXAME FINAL';
                END

                UPDATE MATRICULA
                SET RESULTADO = @RESULTADO,
                    PERCFREQ = @FREQUENCIA,
                    MEDIAFINAL = CASE
                                    WHEN @RESULTADO = 'APROVADO' OR @RESULTADO = 'EXAME FINAL' THEN @MEDIA_ATUAL
                                    ELSE 0.0 
                                 END
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
            END
            
        ELSE
            IF @BIMESTRE = 5
            BEGIN
                DECLARE @MEDIA_ANTERIOR FLOAT,
                        @MEDIA_ATUALIZADA FLOAT;
                
                UPDATE MATRICULA
                SET NOTAEXAME = @NOTA
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO
                    AND RESULTADO = 'EXAME FINAL';

                SELECT @MEDIA_ANTERIOR = MEDIAFINAL
                FROM MATRICULA
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;

                SET @MEDIA_ATUALIZADA = (@MEDIA_ANTERIOR + @NOTA) / 2;

                UPDATE MATRICULA
                SET MEDIAFINAL = @MEDIA_ATUALIZADA,
                    RESULTADO = CASE   
                                    WHEN @MEDIA_ATUALIZADA >= 5.0 THEN 'APROVADO NO EXAME' 
                                    ELSE 'REPROVADO APÓS EXAME'
                                END
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
            END

		SELECT * FROM MATRICULA	WHERE MATRICULA = @MATRICULA
END





INSERT MATRICULA (MATRICULA, CURSO, MATERIA, PROFESSOR, PERLETIVO)
VALUES (4, 'ENG', 'PRG', 1, 2025); 

EXEC sp_CadastraNotas @MATRICULA = 4,      -- int
                      @CURSO = 'ENG',      -- char(3)
                      @MATERIA = 'PRG',    -- char(3)
                      @PERLETIVO = '2025', -- char(4)
                      @NOTA = 9,         -- float
                      @FALTA = 20,
                      @BIMESTRE = 4     -- int
          


SELECT * FROM MATRICULA
SELECT * FROM ALUNOS