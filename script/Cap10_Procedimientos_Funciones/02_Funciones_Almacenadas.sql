-- =========================================================
-- TEMA 2: Funciones Almacenadas
-- Script 2: Creación de Funciones
-- =========================================================
-- Este script crea funciones almacenadas para cálculos
-- y consultas reutilizables en el sistema Tribuneros.
-- =========================================================

USE tribuneros_bdi;
GO

-- =========================================================
-- SECCIÓN 1: Limpieza de Funciones Existentes
-- =========================================================
PRINT '==================================================';
PRINT 'LIMPIEZA DE FUNCIONES EXISTENTES';
PRINT '==================================================';

IF OBJECT_ID('dbo.fn_CalcularEdad', 'FN') IS NOT NULL
BEGIN
    DROP FUNCTION dbo.fn_CalcularEdad;
    PRINT 'Función "fn_CalcularEdad" eliminada.';
END

IF OBJECT_ID('dbo.fn_ObtenerPromedioCalificaciones', 'FN') IS NOT NULL
BEGIN
    DROP FUNCTION dbo.fn_ObtenerPromedioCalificaciones;
    PRINT 'Función "fn_ObtenerPromedioCalificaciones" eliminada.';
END

IF OBJECT_ID('dbo.fn_ContarPartidosPorEstado', 'FN') IS NOT NULL
BEGIN
    DROP FUNCTION dbo.fn_ContarPartidosPorEstado;
    PRINT 'Función "fn_ContarPartidosPorEstado" eliminada.';
END
PRINT '';

-- =========================================================
-- SECCIÓN 2: Función fn_CalcularEdad
-- =========================================================
PRINT '==================================================';
PRINT 'CREACIÓN DE FUNCIÓN: fn_CalcularEdad';
PRINT '==================================================';
GO

CREATE FUNCTION dbo.fn_CalcularEdad
(
    @fecha_nacimiento DATETIME2
)
RETURNS INT
AS
BEGIN
    DECLARE @edad INT;
    DECLARE @fecha_hoy DATETIME2 = SYSDATETIME();
    
    -- Calcular edad en años
    SET @edad = DATEDIFF(YEAR, @fecha_nacimiento, @fecha_hoy);
    
    -- Ajustar si aún no ha cumplido años este año
    IF (MONTH(@fecha_nacimiento) > MONTH(@fecha_hoy)) OR 
       (MONTH(@fecha_nacimiento) = MONTH(@fecha_hoy) AND DAY(@fecha_nacimiento) > DAY(@fecha_hoy))
    BEGIN
        SET @edad = @edad - 1;
    END
    
    RETURN @edad;
END
GO

PRINT 'Función "fn_CalcularEdad" creada exitosamente.';
PRINT 'Descripción: Calcula la edad en años a partir de fecha de nacimiento.';
PRINT 'Parámetros: @fecha_nacimiento (DATETIME2)';
PRINT 'Retorna: INT (edad en años)';
PRINT '';

-- =========================================================
-- SECCIÓN 3: Función fn_ObtenerPromedioCalificaciones
-- =========================================================
PRINT '==================================================';
PRINT 'CREACIÓN DE FUNCIÓN: fn_ObtenerPromedioCalificaciones';
PRINT '==================================================';
GO

CREATE FUNCTION dbo.fn_ObtenerPromedioCalificaciones
(
    @partido_id INT
)
RETURNS DECIMAL(3,2)
AS
BEGIN
    DECLARE @promedio DECIMAL(3,2);
    
    -- Calcular promedio de calificaciones para el partido
    SELECT @promedio = AVG(CAST(puntaje AS DECIMAL(3,2)))
    FROM dbo.calificaciones
    WHERE partido_id = @partido_id;
    
    -- Si no hay calificaciones, retornar 0
    IF @promedio IS NULL
        SET @promedio = 0.00;
    
    RETURN @promedio;
END
GO

PRINT 'Función "fn_ObtenerPromedioCalificaciones" creada exitosamente.';
PRINT 'Descripción: Calcula el promedio de calificaciones de un partido.';
PRINT 'Parámetros: @partido_id (INT)';
PRINT 'Retorna: DECIMAL(3,2) (promedio de 0.00 a 5.00)';
PRINT '';

-- =========================================================
-- SECCIÓN 4: Función fn_ContarPartidosPorEstado
-- =========================================================
PRINT '==================================================';
PRINT 'CREACIÓN DE FUNCIÓN: fn_ContarPartidosPorEstado';
PRINT '==================================================';
GO

CREATE FUNCTION dbo.fn_ContarPartidosPorEstado
(
    @estado VARCHAR(15)
)
RETURNS INT
AS
BEGIN
    DECLARE @cantidad INT;
    
    -- Contar partidos con el estado especificado
    SELECT @cantidad = COUNT(*)
    FROM dbo.partidos
    WHERE estado = @estado;
    
    -- Si no hay partidos, retornar 0
    IF @cantidad IS NULL
        SET @cantidad = 0;
    
    RETURN @cantidad;
END
GO

PRINT 'Función "fn_ContarPartidosPorEstado" creada exitosamente.';
PRINT 'Descripción: Cuenta la cantidad de partidos en un estado específico.';
PRINT 'Parámetros: @estado (VARCHAR(15))';
PRINT 'Retorna: INT (cantidad de partidos)';
PRINT 'Estados válidos: programado, en_vivo, finalizado, pospuesto, cancelado';
PRINT '';

-- =========================================================
-- SECCIÓN 5: Pruebas Rápidas de Funciones
-- =========================================================
PRINT '==================================================';
PRINT 'PRUEBAS RÁPIDAS DE FUNCIONES';
PRINT '==================================================';
PRINT '';

-- Prueba 1: fn_CalcularEdad
PRINT 'PRUEBA 1: fn_CalcularEdad';
DECLARE @fecha_prueba DATETIME2 = '1990-05-15';
DECLARE @edad_resultado INT;
SET @edad_resultado = dbo.fn_CalcularEdad(@fecha_prueba);
PRINT 'Fecha de nacimiento: 1990-05-15';
PRINT 'Edad calculada: ' + CAST(@edad_resultado AS VARCHAR(10)) + ' años';
PRINT '';

-- Prueba 2: fn_ObtenerPromedioCalificaciones
PRINT 'PRUEBA 2: fn_ObtenerPromedioCalificaciones';
-- Verificar si existe partido con ID 1
IF EXISTS (SELECT 1 FROM dbo.partidos WHERE id = 1)
BEGIN
    DECLARE @promedio_resultado DECIMAL(3,2);
    SET @promedio_resultado = dbo.fn_ObtenerPromedioCalificaciones(1);
    PRINT 'Promedio de calificaciones del partido ID 1: ' + CAST(@promedio_resultado AS VARCHAR(10));
END
ELSE
BEGIN
    PRINT 'No existe partido con ID 1 para probar la función.';
END
PRINT '';

-- Prueba 3: fn_ContarPartidosPorEstado
PRINT 'PRUEBA 3: fn_ContarPartidosPorEstado';
DECLARE @cnt_finalizado INT, @cnt_programado INT, @cnt_cancelado INT;
SET @cnt_finalizado = dbo.fn_ContarPartidosPorEstado('finalizado');
SET @cnt_programado = dbo.fn_ContarPartidosPorEstado('programado');
SET @cnt_cancelado = dbo.fn_ContarPartidosPorEstado('cancelado');
PRINT 'Partidos finalizados: ' + CAST(@cnt_finalizado AS VARCHAR(10));
PRINT 'Partidos programados: ' + CAST(@cnt_programado AS VARCHAR(10));
PRINT 'Partidos cancelados: ' + CAST(@cnt_cancelado AS VARCHAR(10));
PRINT '';

-- =========================================================
-- SECCIÓN 6: Ejemplos de Uso Avanzado
-- =========================================================
PRINT '==================================================';
PRINT 'EJEMPLOS DE USO AVANZADO';
PRINT '==================================================';
PRINT '';
PRINT 'Ejemplo 1: Listar partidos con su promedio de calificaciones';
PRINT 'SELECT p.id, p.ronda, dbo.fn_ObtenerPromedioCalificaciones(p.id) AS promedio';
PRINT 'FROM dbo.partidos p';
PRINT 'WHERE p.estado = ''finalizado''';
PRINT 'ORDER BY promedio DESC;';
PRINT '';
PRINT 'Ejemplo 2: Estadísticas de partidos por estado';
PRINT 'SELECT ';
PRINT '    ''finalizado'' AS estado, dbo.fn_ContarPartidosPorEstado(''finalizado'') AS cantidad';
PRINT 'UNION ALL';
PRINT 'SELECT ';
PRINT '    ''programado'', dbo.fn_ContarPartidosPorEstado(''programado'')';
PRINT 'UNION ALL';
PRINT 'SELECT ';
PRINT '    ''cancelado'', dbo.fn_ContarPartidosPorEstado(''cancelado'');';
PRINT '';
PRINT 'Ejemplo 3: Calcular edad de un usuario (si se agrega fecha_nacimiento)';
PRINT 'SELECT u.id, p.nombre_mostrar,';
PRINT '       dbo.fn_CalcularEdad(u.fecha_nacimiento) AS edad';
PRINT 'FROM dbo.usuarios u';
PRINT 'INNER JOIN dbo.perfiles p ON u.id = p.usuario_id;';
PRINT '';

-- =========================================================
-- SECCIÓN 7: Resumen de Funciones Creadas
-- =========================================================
PRINT '==================================================';
PRINT 'RESUMEN DE FUNCIONES CREADAS';
PRINT '==================================================';
PRINT '';
PRINT 'Funciones almacenadas:';
PRINT '';
PRINT '1. fn_CalcularEdad';
PRINT '   - Parámetros: @fecha_nacimiento (DATETIME2)';
PRINT '   - Retorna: INT (edad en años)';
PRINT '   - Uso: Calcular edad a partir de fecha de nacimiento';
PRINT '';
PRINT '2. fn_ObtenerPromedioCalificaciones';
PRINT '   - Parámetros: @partido_id (INT)';
PRINT '   - Retorna: DECIMAL(3,2) (promedio 0.00-5.00)';
PRINT '   - Uso: Obtener calificación promedio de un partido';
PRINT '';
PRINT '3. fn_ContarPartidosPorEstado';
PRINT '   - Parámetros: @estado (VARCHAR(15))';
PRINT '   - Retorna: INT (cantidad de partidos)';
PRINT '   - Uso: Contar partidos por estado específico';
PRINT '';
PRINT 'Características:';
PRINT '   - Funciones escalares (retornan un solo valor)';
PRINT '   - Reutilizables en consultas SELECT';
PRINT '   - Optimizadas para cálculos frecuentes';
PRINT '   - Sin efectos secundarios (DETERMINISTIC)';
PRINT '';
PRINT '==================================================';
PRINT 'Script completado exitosamente.';
PRINT '==================================================';
GO
