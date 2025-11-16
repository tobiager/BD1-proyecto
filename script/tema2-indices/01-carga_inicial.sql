-- =========================================================
-- Script de Carga Masiva y Pruebas de Índices - Tribuneros
-- Optimización de consultas a través de índices
-- Estructura Actualizada con INT e IDENTITY
-- =========================================================

USE tribuneros_bdi;
GO

-- =========================================================
-- TAREA 1: GENERACIÓN DE DATOS MASIVOS
-- =========================================================

-- 1.1 Generar Ligas (50 ligas)
PRINT '=== Generando ligas ===';

DECLARE @ultimo_liga INT = ISNULL((SELECT MAX(id) FROM dbo.ligas), 0);
DECLARE @liga INT = @ultimo_liga + 1;
DECLARE @max_ligas INT = @ultimo_liga + 50;
DECLARE @total_ligas_final INT;

PRINT 'Iniciando desde liga ID: ' + CAST(@liga AS VARCHAR(10));

WHILE @liga <= @max_ligas
BEGIN
    INSERT INTO dbo.ligas (id, nombre, pais, slug, id_externo, creado_en)
    VALUES (
        @liga,
        N'Liga ' + CAST(@liga AS NVARCHAR(10)),
        CASE (@liga - @ultimo_liga - 1) % 10 
            WHEN 0 THEN N'España' WHEN 1 THEN N'Inglaterra' 
            WHEN 2 THEN N'Italia' WHEN 3 THEN N'Alemania'
            WHEN 4 THEN N'Francia' WHEN 5 THEN N'Argentina'
            WHEN 6 THEN N'Brasil' WHEN 7 THEN N'México'
            WHEN 8 THEN N'Portugal' ELSE N'Holanda'
        END,
        'liga-' + CAST(@liga AS VARCHAR(10)),
        'EXT_LIGA_' + CAST(@liga AS VARCHAR(10)),
        SYSUTCDATETIME()
    );
    SET @liga = @liga + 1;
END;

SET @total_ligas_final = (SELECT COUNT(*) FROM dbo.ligas);
PRINT 'Total ligas en tabla: ' + CAST(@total_ligas_final AS VARCHAR(10));
GO

-- 1.2 Generar Equipos (500 equipos)
PRINT '=== Generando 500 equipos ===';

DECLARE @ultimo_equipo INT = ISNULL((SELECT MAX(id) FROM dbo.equipos), 0);
DECLARE @equipo INT = @ultimo_equipo + 1;
DECLARE @max_equipos INT = @ultimo_equipo + 500;
DECLARE @total_equipos_final INT;

-- Obtener rango de ligas disponibles
DECLARE @min_liga INT = (SELECT MIN(id) FROM dbo.ligas);
DECLARE @max_liga INT = (SELECT MAX(id) FROM dbo.ligas);

PRINT 'Iniciando desde equipo ID: ' + CAST(@equipo AS VARCHAR(10));

WHILE @equipo <= @max_equipos
BEGIN
    INSERT INTO dbo.equipos (id, nombre, nombre_corto, pais, escudo_url, liga_id, id_externo, creado_en)
    VALUES (
        @equipo,
        N'Equipo ' + CAST(@equipo AS NVARCHAR(10)),
        N'EQ' + CAST(@equipo AS NVARCHAR(10)),
        N'País ' + CAST(((@equipo - @ultimo_equipo - 1) % 10) + 1 AS NVARCHAR(10)),
        'https://escudos.tribuneros.com/' + CAST(@equipo AS VARCHAR(10)) + '.png',
        -- Asignar liga de forma cíclica dentro del rango disponible
        @min_liga + ((@equipo - @ultimo_equipo - 1) % (@max_liga - @min_liga + 1)),
        'EXT_EQUIPO_' + CAST(@equipo AS VARCHAR(10)),
        SYSUTCDATETIME()
    );
    
    IF (@equipo - @ultimo_equipo) % 100 = 0 PRINT 'Equipos insertados: ' + CAST(@equipo - @ultimo_equipo AS VARCHAR(10));
    SET @equipo = @equipo + 1;
END;

SET @total_equipos_final = (SELECT COUNT(*) FROM dbo.equipos);
PRINT 'Total equipos en tabla: ' + CAST(@total_equipos_final AS VARCHAR(10));
GO

-- =========================================================
-- CARGA MASIVA DE 1+ MILLÓN DE PARTIDOS SIN ÍNDICE EN FECHA
-- =========================================================

USE tribuneros_bdi;
GO

PRINT '=== TAREA 1: Carga masiva SIN índice en fecha ===';
PRINT 'Eliminando índice IX_partidos_fecha...';

-- Eliminar el índice de fecha si existe
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_partidos_fecha' AND object_id = OBJECT_ID('dbo.partidos'))
    DROP INDEX IX_partidos_fecha ON dbo.partidos;
GO

-- Registrar tiempo de inicio
DECLARE @inicio_carga DATETIME2 = SYSDATETIME();
PRINT 'Inicio de carga: ' + CAST(@inicio_carga AS VARCHAR(30));

-- Obtener rangos de IDs disponibles
DECLARE @min_liga_id INT = (SELECT MIN(id) FROM dbo.ligas);
DECLARE @max_liga_id INT = (SELECT MAX(id) FROM dbo.ligas);
DECLARE @min_equipo_id INT = (SELECT MIN(id) FROM dbo.equipos);
DECLARE @max_equipo_id INT = (SELECT MAX(id) FROM dbo.equipos);
DECLARE @total_ligas INT = @max_liga_id - @min_liga_id + 1;
DECLARE @total_equipos INT = @max_equipo_id - @min_equipo_id + 1;

PRINT 'Rango de ligas: ' + CAST(@min_liga_id AS VARCHAR(10)) + ' a ' + CAST(@max_liga_id AS VARCHAR(10));
PRINT 'Rango de equipos: ' + CAST(@min_equipo_id AS VARCHAR(10)) + ' a ' + CAST(@max_equipo_id AS VARCHAR(10));

-- Generar 1,000,000 de partidos en lotes de 10,000
DECLARE @contador INT = 0;
DECLARE @total_partidos INT = 1000000;
DECLARE @lote INT = 10000;
DECLARE @partido_id INT = ISNULL((SELECT MAX(id) FROM dbo.partidos), 0) + 1;

PRINT 'Iniciando desde partido ID: ' + CAST(@partido_id AS VARCHAR(10));

WHILE @contador < @total_partidos
BEGIN
    INSERT INTO dbo.partidos (
        id, id_externo, liga_id, temporada, ronda, 
        fecha_utc, estado, estadio, 
        equipo_local, equipo_visitante, 
        goles_local, goles_visitante, creado_en
    )
    SELECT TOP (@lote)
        @partido_id + n - 1 AS id,
        'EXT_PARTIDO_' + CAST(@partido_id + n - 1 AS VARCHAR(20)),
        @min_liga_id + (ABS(CHECKSUM(NEWID())) % @total_ligas),
        2019 + (ABS(CHECKSUM(NEWID())) % 6), -- temporada 2019-2024 (SMALLINT)
        N'J' + CAST((ABS(CHECKSUM(NEWID())) % 38) + 1 AS NVARCHAR(3)),
        -- Fecha aleatoria entre 2019-01-01 y 2025-10-30 (DATETIME2(0) - sin segundos)
        CAST(DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 2495, '2019-01-01') AS DATETIME2(0)),
        -- estado: TINYINT (0=prog,1=vivo,2=fin,3=posp,4=canc)
        CASE ABS(CHECKSUM(NEWID())) % 5
            WHEN 0 THEN 0  -- programado
            WHEN 1 THEN 1  -- en_vivo
            WHEN 2 THEN 2  -- finalizado
            WHEN 3 THEN 3  -- pospuesto
            ELSE 2         -- finalizado
        END,
        N'Estadio ' + CAST((ABS(CHECKSUM(NEWID())) % 200) + 1 AS NVARCHAR(10)),
        equipo_local,
        -- Asegurar que visitante sea diferente de local
        CASE 
            WHEN equipo_local = @max_equipo_id THEN equipo_local - 1
            ELSE equipo_local + 1
        END AS equipo_visitante,
        -- goles: TINYINT (0-5 o NULL)
        CASE WHEN ABS(CHECKSUM(NEWID())) % 3 = 0 THEN NULL 
             ELSE CAST(ABS(CHECKSUM(NEWID())) % 6 AS TINYINT) END,
        CASE WHEN ABS(CHECKSUM(NEWID())) % 3 = 0 THEN NULL 
             ELSE CAST(ABS(CHECKSUM(NEWID())) % 6 AS TINYINT) END,
        SYSUTCDATETIME()
    FROM (
        SELECT 
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n,
            @min_equipo_id + (ABS(CHECKSUM(NEWID())) % @total_equipos) AS equipo_local
        FROM sys.all_columns c1, sys.all_columns c2
    ) AS datos;
    
    SET @contador = @contador + @lote;
    SET @partido_id = @partido_id + @lote;
    
    IF @contador % 100000 = 0
        PRINT 'Partidos insertados: ' + CAST(@contador AS VARCHAR(20)) + ' / ' + CAST(@total_partidos AS VARCHAR(20));
END;

DECLARE @fin_carga DATETIME2 = SYSDATETIME();
PRINT 'Fin de carga: ' + CAST(@fin_carga AS VARCHAR(30));
PRINT 'Tiempo de carga SIN índice: ' + CAST(DATEDIFF(SECOND, @inicio_carga, @fin_carga) AS VARCHAR(20)) + ' segundos';
PRINT '=====================================================';
GO

