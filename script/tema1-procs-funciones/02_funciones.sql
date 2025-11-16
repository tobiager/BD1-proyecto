-- =================================================================
-- TEMA 1: PROCEDIMIENTOS Y FUNCIONES
-- 02_funciones.sql 
-- =================================================================
USE tribuneros_bdi;
GO

-------------------------------------------------------------------
-- 1. Función para obtener el nombre de usuario a partir de su ID
-------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_ObtenerNombreUsuario(@usuario_id INT)
RETURNS VARCHAR(30)
AS
BEGIN
    DECLARE @nombre_usuario VARCHAR(30);

    SELECT @nombre_usuario = nombre_usuario
    FROM dbo.perfiles
    WHERE usuario_id = @usuario_id;

    RETURN @nombre_usuario;
END;
GO

-------------------------------------------------------------------
-- 2. Función para calcular el puntaje promedio de un partido
-------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_CalcularPuntajePromedioPartido(@partido_id INT)
RETURNS DECIMAL(3, 2)
AS
BEGIN
    DECLARE @promedio DECIMAL(3, 2);

    SELECT @promedio = AVG(CAST(puntaje AS DECIMAL(3, 2)))
    FROM dbo.calificaciones
    WHERE partido_id = @partido_id;

    RETURN ISNULL(@promedio, 0.00);
END;
GO

-------------------------------------------------------------------
-- 3. Función para formatear el resultado de un partido
-------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_FormatearResultadoPartido(@partido_id INT)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @resultado VARCHAR(20);
    DECLARE @goles_local INT, @goles_visitante INT;

    SELECT @goles_local = goles_local, @goles_visitante = goles_visitante
    FROM dbo.partidos
    WHERE id = @partido_id;

    IF @goles_local IS NOT NULL AND @goles_visitante IS NOT NULL
        SET @resultado = CONCAT(@goles_local, ' - ', @goles_visitante);
    ELSE
        SET @resultado = 'vs';

    RETURN @resultado;
END;
GO