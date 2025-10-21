-- =========================================================
-- TEMA 2: Pruebas Comparativas de Procedimientos y Funciones
-- Script 3: Pruebas y Comparación de Eficiencia
-- =========================================================
-- Este script realiza pruebas comparativas entre INSERT directo
-- y procedimientos almacenados, además de pruebas de permisos.
-- =========================================================

USE tribuneros_bdi;
GO

SET NOCOUNT ON;
GO

PRINT '==================================================';
PRINT 'PRUEBAS COMPARATIVAS - PROCEDIMIENTOS VS INSERT DIRECTO';
PRINT '==================================================';
PRINT '';

-- =========================================================
-- SECCIÓN 1: Preparación de Datos de Prueba
-- =========================================================
PRINT '==================================================';
PRINT 'SECCIÓN 1: PREPARACIÓN DE DATOS';
PRINT '==================================================';
PRINT '';

-- Limpiar partidos de prueba anteriores
DELETE FROM dbo.partidos WHERE id >= 900000;
PRINT 'Datos de pruebas anteriores eliminados.';
PRINT '';

-- Verificar que existen equipos para las pruebas
DECLARE @equipo1 INT, @equipo2 INT, @equipo3 INT;
SELECT TOP 1 @equipo1 = id FROM dbo.equipos ORDER BY id;
SELECT @equipo2 = id FROM dbo.equipos WHERE id > @equipo1 ORDER BY id OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY;
SELECT @equipo3 = id FROM dbo.equipos WHERE id > @equipo2 ORDER BY id OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY;

IF @equipo1 IS NULL OR @equipo2 IS NULL
BEGIN
    PRINT 'ERROR: Se necesitan al menos 2 equipos en la base de datos para las pruebas.';
    RETURN;
END

PRINT 'Equipos disponibles para pruebas:';
PRINT '  - Equipo 1: ' + CAST(@equipo1 AS VARCHAR(10));
PRINT '  - Equipo 2: ' + CAST(@equipo2 AS VARCHAR(10));
IF @equipo3 IS NOT NULL
    PRINT '  - Equipo 3: ' + CAST(@equipo3 AS VARCHAR(10));
PRINT '';

-- =========================================================
-- SECCIÓN 2: Lote de Prueba con INSERT DIRECTO
-- =========================================================
PRINT '==================================================';
PRINT 'SECCIÓN 2: LOTE DE PRUEBA - INSERT DIRECTO';
PRINT '==================================================';
PRINT '';

DECLARE @inicio_insert DATETIME2;
DECLARE @fin_insert DATETIME2;
DECLARE @duracion_insert INT;

-- Capturar tiempo de inicio
SET @inicio_insert = SYSDATETIME();

-- Insertar 100 registros con INSERT directo
DECLARE @i INT = 0;
WHILE @i < 100
BEGIN
    INSERT INTO dbo.partidos (
        id, liga_id, temporada, ronda, fecha_utc, estado, estadio,
        equipo_local, equipo_visitante, goles_local, goles_visitante, creado_en
    ) VALUES (
        900000 + @i,
        1,
        2025,
        'Prueba INSERT ' + CAST(@i AS VARCHAR(10)),
        DATEADD(DAY, @i, SYSDATETIME()),
        'programado',
        'Estadio Prueba',
        @equipo1,
        @equipo2,
        NULL,
        NULL,
        SYSDATETIME()
    );
    
    SET @i = @i + 1;
END

-- Capturar tiempo de fin
SET @fin_insert = SYSDATETIME();
SET @duracion_insert = DATEDIFF(MILLISECOND, @inicio_insert, @fin_insert);

PRINT 'INSERT DIRECTO completado:';
PRINT '  - Registros insertados: 100';
PRINT '  - Tiempo total: ' + CAST(@duracion_insert AS VARCHAR(10)) + ' ms';
PRINT '  - Tiempo promedio por registro: ' + CAST(@duracion_insert / 100.0 AS VARCHAR(10)) + ' ms';
PRINT '';

-- =========================================================
-- SECCIÓN 3: Lote de Prueba con PROCEDIMIENTO ALMACENADO
-- =========================================================
PRINT '==================================================';
PRINT 'SECCIÓN 3: LOTE DE PRUEBA - PROCEDIMIENTO ALMACENADO';
PRINT '==================================================';
PRINT '';

DECLARE @inicio_sp DATETIME2;
DECLARE @fin_sp DATETIME2;
DECLARE @duracion_sp INT;

-- Capturar tiempo de inicio
SET @inicio_sp = SYSDATETIME();

-- Insertar 100 registros con procedimiento almacenado
SET @i = 0;
WHILE @i < 100
BEGIN
    EXEC dbo.sp_InsertPartido
        @id = 900100 + @i,
        @liga_id = 1,
        @temporada = 2025,
        @ronda = 'Prueba SP',
        @fecha_utc = @inicio_sp,
        @estado = 'programado',
        @estadio = 'Estadio SP',
        @equipo_local = @equipo1,
        @equipo_visitante = @equipo2,
        @goles_local = NULL,
        @goles_visitante = NULL;
    
    SET @i = @i + 1;
END

-- Capturar tiempo de fin
SET @fin_sp = SYSDATETIME();
SET @duracion_sp = DATEDIFF(MILLISECOND, @inicio_sp, @fin_sp);

PRINT 'PROCEDIMIENTO ALMACENADO completado:';
PRINT '  - Registros insertados: 100';
PRINT '  - Tiempo total: ' + CAST(@duracion_sp AS VARCHAR(10)) + ' ms';
PRINT '  - Tiempo promedio por registro: ' + CAST(@duracion_sp / 100.0 AS VARCHAR(10)) + ' ms';
PRINT '';

-- =========================================================
-- SECCIÓN 4: Comparación de Eficiencia
-- =========================================================
PRINT '==================================================';
PRINT 'SECCIÓN 4: COMPARACIÓN DE EFICIENCIA';
PRINT '==================================================';
PRINT '';

PRINT 'Resultados comparativos:';
PRINT '  INSERT DIRECTO:        ' + CAST(@duracion_insert AS VARCHAR(10)) + ' ms';
PRINT '  PROCEDIMIENTO ALMC.:   ' + CAST(@duracion_sp AS VARCHAR(10)) + ' ms';
PRINT '  Diferencia:            ' + CAST(ABS(@duracion_sp - @duracion_insert) AS VARCHAR(10)) + ' ms';
PRINT '';

IF @duracion_sp > @duracion_insert
BEGIN
    DECLARE @overhead DECIMAL(5,2) = ((@duracion_sp - @duracion_insert) * 100.0) / @duracion_insert;
    PRINT 'El procedimiento es ' + CAST(@overhead AS VARCHAR(10)) + '% más lento.';
    PRINT 'Razón: Las validaciones de negocio agregan overhead, pero garantizan integridad.';
END
ELSE
BEGIN
    PRINT 'El procedimiento tiene rendimiento similar o mejor.';
END
PRINT '';

-- =========================================================
-- SECCIÓN 5: Pruebas de UPDATE con Procedimiento
-- =========================================================
PRINT '==================================================';
PRINT 'SECCIÓN 5: PRUEBAS DE UPDATE';
PRINT '==================================================';
PRINT '';

-- Actualizar un partido a estado finalizado con goles
PRINT 'Actualizando partido 900000 a estado finalizado...';
EXEC dbo.sp_UpdatePartido
    @id = 900000,
    @estado = 'finalizado',
    @goles_local = 2,
    @goles_visitante = 1;
PRINT '';

-- Verificar la actualización
SELECT 
    id, estado, goles_local, goles_visitante
FROM dbo.partidos
WHERE id = 900000;
PRINT '';

-- =========================================================
-- SECCIÓN 6: Pruebas de DELETE con Procedimiento
-- =========================================================
PRINT '==================================================';
PRINT 'SECCIÓN 6: PRUEBAS DE DELETE';
PRINT '==================================================';
PRINT '';

-- Prueba de eliminación lógica
PRINT 'Eliminación LÓGICA del partido 900001...';
EXEC dbo.sp_DeletePartido @id = 900001, @eliminacion_fisica = 0;
PRINT '';

-- Verificar eliminación lógica
PRINT 'Estado del partido 900001 después de eliminación lógica:';
SELECT id, estado FROM dbo.partidos WHERE id = 900001;
PRINT '';

-- Prueba de eliminación física
PRINT 'Eliminación FÍSICA del partido 900002...';
EXEC dbo.sp_DeletePartido @id = 900002, @eliminacion_fisica = 1;
PRINT '';

-- Verificar eliminación física
PRINT 'Verificar si existe el partido 900002:';
IF EXISTS (SELECT 1 FROM dbo.partidos WHERE id = 900002)
    PRINT 'ERROR: El partido aún existe.';
ELSE
    PRINT 'CORRECTO: El partido fue eliminado físicamente.';
PRINT '';

-- =========================================================
-- SECCIÓN 7: Pruebas de Funciones
-- =========================================================
PRINT '==================================================';
PRINT 'SECCIÓN 7: PRUEBAS DE FUNCIONES';
PRINT '==================================================';
PRINT '';

-- Prueba 1: Calcular promedio de calificaciones
IF EXISTS (SELECT 1 FROM dbo.partidos WHERE id = 900000)
BEGIN
    PRINT 'Promedio de calificaciones del partido 900000:';
    SELECT dbo.fn_ObtenerPromedioCalificaciones(900000) AS promedio;
    PRINT '';
END

-- Prueba 2: Contar partidos por estado
PRINT 'Estadísticas de partidos por estado:';
SELECT 
    'finalizado' AS estado,
    dbo.fn_ContarPartidosPorEstado('finalizado') AS cantidad
UNION ALL
SELECT 
    'programado',
    dbo.fn_ContarPartidosPorEstado('programado')
UNION ALL
SELECT 
    'cancelado',
    dbo.fn_ContarPartidosPorEstado('cancelado')
UNION ALL
SELECT 
    'en_vivo',
    dbo.fn_ContarPartidosPorEstado('en_vivo');
PRINT '';

-- =========================================================
-- SECCIÓN 8: Pruebas de Permisos con Procedimientos
-- =========================================================
PRINT '==================================================';
PRINT 'SECCIÓN 8: PRUEBAS DE PERMISOS';
PRINT '==================================================';
PRINT '';

-- Prueba con LecturaSolo_Usuario ejecutando procedimiento
PRINT 'PRUEBA: LecturaSolo_Usuario ejecutando sp_InsertPartido';
PRINT 'Resultado esperado: ÉXITO (tiene permiso EXECUTE)';
PRINT '';

EXECUTE AS USER = 'LecturaSolo_Usuario';
BEGIN TRY
    EXEC dbo.sp_InsertPartido
        @id = 900500,
        @liga_id = 1,
        @temporada = 2025,
        @ronda = 'Prueba Permisos',
        @fecha_utc = @inicio_sp,
        @estado = 'programado',
        @estadio = 'Estadio Permisos',
        @equipo_local = @equipo1,
        @equipo_visitante = @equipo2;
    
    PRINT 'RESULTADO: ÉXITO - LecturaSolo_Usuario puede insertar vía SP.';
    PRINT 'Esto demuestra el concepto de "cadena de propiedad" (ownership chaining).';
    PRINT 'El usuario no tiene permiso directo sobre la tabla, pero puede';
    PRINT 'ejecutar el procedimiento que sí tiene permisos.';
END TRY
BEGIN CATCH
    PRINT 'RESULTADO: ERROR - ' + ERROR_MESSAGE();
END CATCH
REVERT;
PRINT '';

-- =========================================================
-- SECCIÓN 9: Limpieza de Datos de Prueba
-- =========================================================
PRINT '==================================================';
PRINT 'SECCIÓN 9: LIMPIEZA DE DATOS DE PRUEBA';
PRINT '==================================================';
PRINT '';

-- Preguntar si desea limpiar (en producción, descomentar la siguiente línea)
-- Si desea conservar los datos de prueba, comente el DELETE
DELETE FROM dbo.partidos WHERE id >= 900000;
PRINT 'Datos de prueba eliminados.';
PRINT '';

-- =========================================================
-- SECCIÓN 10: Conclusiones
-- =========================================================
PRINT '==================================================';
PRINT 'CONCLUSIONES';
PRINT '==================================================';
PRINT '';
PRINT 'Ventajas de los Procedimientos Almacenados:';
PRINT '  ✓ Validaciones de negocio centralizadas';
PRINT '  ✓ Control de integridad de datos';
PRINT '  ✓ Manejo de errores con TRY-CATCH';
PRINT '  ✓ Reutilización de lógica';
PRINT '  ✓ Seguridad mejorada (ownership chaining)';
PRINT '  ✓ Encapsulación de complejidad';
PRINT '';
PRINT 'Desventajas:';
PRINT '  ✗ Ligero overhead de rendimiento (validaciones)';
PRINT '  ✗ Mayor complejidad de mantenimiento';
PRINT '';
PRINT 'Ventajas de las Funciones:';
PRINT '  ✓ Reutilizables en consultas SELECT';
PRINT '  ✓ Simplifican cálculos complejos';
PRINT '  ✓ Código más legible y mantenible';
PRINT '  ✓ Optimizadas por el motor de BD';
PRINT '';
PRINT 'Recomendación:';
PRINT '  Usar procedimientos para operaciones de escritura (INSERT/UPDATE/DELETE)';
PRINT '  y funciones para cálculos y consultas frecuentes.';
PRINT '';
PRINT '==================================================';
PRINT 'Script de pruebas completado exitosamente.';
PRINT '==================================================';
GO
