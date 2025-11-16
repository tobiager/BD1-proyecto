-- =========================================================
-- Script de Carga Masiva y Pruebas de Índices - Tribuneros
-- Optimización de consultas a través de índices
-- Estructura Actualizada con INT e IDENTITY
-- =========================================================

USE tribuneros_bdi;
GO

-- =========================================================
-- PARTE 1: GENERACIÓN DE DATOS MASIVOS
-- =========================================================

-- 1.1 Generar Usuarios (10,000 usuarios base)
PRINT '=== Generando 10,000 usuarios ===';

-- Obtener el último ID existente
DECLARE @ultimo_usuario INT = ISNULL((SELECT MAX(id) FROM dbo.usuarios), 0);
DECLARE @i INT = @ultimo_usuario + 1;
DECLARE @max_usuarios INT = @ultimo_usuario + 10000;
DECLARE @total_usuarios INT;

PRINT 'Iniciando desde usuario ID: ' + CAST(@i AS VARCHAR(10));

WHILE @i <= @max_usuarios
BEGIN
    INSERT INTO dbo.usuarios (id, correo, password_hash, creado_en)
    VALUES (
        @i,
        'usuario' + CAST(@i AS VARCHAR(10)) + '@tribuneros.com',
        HASHBYTES('SHA2_512', CONVERT(VARBINARY(4000), N'password' + CAST(@i AS NVARCHAR(10)))),
        DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 730, SYSUTCDATETIME())
    );
    
    IF (@i - @ultimo_usuario) % 1000 = 0 PRINT 'Usuarios insertados: ' + CAST(@i - @ultimo_usuario AS VARCHAR(10));
    SET @i = @i + 1;
END;

SET @total_usuarios = (SELECT COUNT(*) FROM dbo.usuarios);
PRINT 'Total usuarios en tabla: ' + CAST(@total_usuarios AS VARCHAR(10));
GO

-- 1.2 Generar Perfiles para usuarios
PRINT '=== Generando perfiles ===';

-- Solo crear perfiles para usuarios que no tengan
INSERT INTO dbo.perfiles (usuario_id, nombre_usuario, nombre_mostrar, avatar_url, biografia, creado_en)
SELECT 
    u.id,
    'user_' + CAST(u.id AS VARCHAR(10)),
    N'Usuario ' + CAST(u.id AS NVARCHAR(10)),
    'https://avatar.tribuneros.com/' + CAST(NEWID() AS VARCHAR(36)),
    N'Fanático del fútbol apasionado',
    u.creado_en
FROM dbo.usuarios u
WHERE NOT EXISTS (SELECT 1 FROM dbo.perfiles p WHERE p.usuario_id = u.id);

DECLARE @total_perfiles INT = (SELECT COUNT(*) FROM dbo.perfiles);
PRINT 'Total perfiles en tabla: ' + CAST(@total_perfiles AS VARCHAR(10));
GO

-- 1.3 Generar Ligas (50 ligas)
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

-- 1.4 Generar Equipos (500 equipos)
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