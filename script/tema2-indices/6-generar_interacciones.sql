USE tribuneros_bdi;
GO

-- =========================================================
-- TAREA 6: GENERAR DATOS PARA OTRAS TABLAS (INTERACCIONES)
-- =========================================================

PRINT '=== Generando interacciones de usuarios ===';

-- Calificaciones (100,000 registros) - Ahora con IDENTITY
PRINT 'Generando 100,000 calificaciones...';
DECLARE @calif INT = 0;
DECLARE @max_calif INT = 100000;

WHILE @calif < @max_calif
BEGIN
    BEGIN TRY
        INSERT INTO dbo.calificaciones (partido_id, usuario_id, puntaje, creado_en)
        SELECT TOP 1
            (ABS(CHECKSUM(NEWID())) % 1000000) + 1,
            (ABS(CHECKSUM(NEWID())) % 10000) + 1,
            CAST((ABS(CHECKSUM(NEWID())) % 5) + 1 AS TINYINT),
            DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, SYSUTCDATETIME())
        FROM (SELECT TOP 1 1 AS dummy FROM sys.objects) AS t;
        
        SET @calif = @calif + 1;
    END TRY
    BEGIN CATCH
        -- Ignorar duplicados por constraint UNIQUE
        SET @calif = @calif + 1;
    END CATCH;
    
    IF @calif % 10000 = 0 PRINT 'Calificaciones: ' + CAST(@calif AS VARCHAR(10));
END;

-- Favoritos (50,000 registros) - Ahora con IDENTITY
PRINT 'Generando 50,000 favoritos...';
DECLARE @fav INT = 0;
DECLARE @max_fav INT = 50000;

WHILE @fav < @max_fav
BEGIN
    BEGIN TRY
        INSERT INTO dbo.favoritos (partido_id, usuario_id, creado_en)
        SELECT TOP 1
            (ABS(CHECKSUM(NEWID())) % 1000000) + 1,
            (ABS(CHECKSUM(NEWID())) % 10000) + 1,
            DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, SYSUTCDATETIME())
        FROM (SELECT TOP 1 1 AS dummy FROM sys.objects) AS t;
        
        SET @fav = @fav + 1;
    END TRY
    BEGIN CATCH
        -- Ignorar duplicados
        SET @fav = @fav + 1;
    END CATCH;
    
    IF @fav % 5000 = 0 PRINT 'Favoritos: ' + CAST(@fav AS VARCHAR(10));
END;

-- Visualizaciones (75,000 registros)
PRINT 'Generando 75,000 visualizaciones...';
DECLARE @vis INT = 0;
DECLARE @max_vis INT = 75000;

WHILE @vis < @max_vis
BEGIN
    BEGIN TRY
        INSERT INTO dbo.visualizaciones (partido_id, usuario_id, medio, visto_en, minutos_vistos, ubicacion, creado_en)
        SELECT TOP 1
            (ABS(CHECKSUM(NEWID())) % 1000000) + 1,
            (ABS(CHECKSUM(NEWID())) % 10000) + 1,
            CAST(ABS(CHECKSUM(NEWID())) % 4 AS TINYINT), -- 0=estadio,1=tv,2=streaming,3=repeticion
            DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, SYSUTCDATETIME()),
            CAST((ABS(CHECKSUM(NEWID())) % 120) + 30 AS TINYINT), -- 30-150 minutos
            N'Ubicación ' + CAST(ABS(CHECKSUM(NEWID())) % 100 AS NVARCHAR(10)),
            SYSUTCDATETIME()
        FROM (SELECT TOP 1 1 AS dummy FROM sys.objects) AS t;
        
        SET @vis = @vis + 1;
    END TRY
    BEGIN CATCH
        SET @vis = @vis + 1;
    END CATCH;
    
    IF @vis % 10000 = 0 PRINT 'Visualizaciones: ' + CAST(@vis AS VARCHAR(10));
END;

PRINT '=====================================================';
PRINT '=== CARGA MASIVA COMPLETADA ===';
PRINT 'Total de registros generados:';
PRINT '- Usuarios: 10,000';
PRINT '- Perfiles: 10,000';
PRINT '- Ligas: 50';
PRINT '- Equipos: 500';
PRINT '- Partidos: 1,000,000';
PRINT '- Calificaciones: ~100,000';
PRINT '- Favoritos: ~50,000';
PRINT '- Visualizaciones: ~75,000';
PRINT '=====================================================';
GO

