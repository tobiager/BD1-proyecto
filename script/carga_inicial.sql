-- =========================================================
-- Tribuneros - Carga representativa (DML) 
-- =========================================================
SET XACT_ABORT ON;
GO

USE tribuneros_bdi;
GO

BEGIN TRAN;

-- Limpieza de datos existentes (en orden inverso por las FK)
DELETE FROM dbo.recordatorios;
DELETE FROM dbo.partidos_destacados;
DELETE FROM dbo.seguimiento_usuarios;  
DELETE FROM dbo.seguimiento_ligas;     
DELETE FROM dbo.seguimiento_equipos;   
DELETE FROM dbo.visualizaciones;
DELETE FROM dbo.favoritos;
DELETE FROM dbo.opiniones;
DELETE FROM dbo.calificaciones;
DELETE FROM dbo.partidos;
DELETE FROM dbo.equipos;
DELETE FROM dbo.ligas;
DELETE FROM dbo.perfiles;
DELETE FROM dbo.usuarios;

-- ================== 1) Usuarios y perfiles ==================
-- Insertamos usuarios (password_hash se dejará NULL y se asignará con el SP)
-- Nota: usuario.id es INT y se insertan valores fijos 1..10
INSERT INTO dbo.usuarios (id, correo, creado_en) VALUES
(1, 'tobiager@example.com', SYSUTCDATETIME()),
(2, 'ana.ferro@example.com', SYSUTCDATETIME()),
(3, 'carlos.perez@example.com', SYSUTCDATETIME()),
(4, 'laura.gomez@example.com', SYSUTCDATETIME()),
(5, 'martin.diaz@example.com', SYSUTCDATETIME()),
(6, 'sofia.lopez@example.com', SYSUTCDATETIME()),
(7, 'juan.martinez@example.com', SYSUTCDATETIME()),
(8, 'lucia.fernandez@example.com', SYSUTCDATETIME()),
(9, 'diego.rodriguez@example.com', SYSUTCDATETIME()),
(10, 'elena.sanchez@example.com', SYSUTCDATETIME());

-- Asignar contraseñas a los usuarios iniciales (usa el procedimiento que hace HASH)
EXEC dbo.sp_usuario_set_password_simple
  @usuario_id = 1,
  @password   = N'RiverPlate2018!';
EXEC dbo.sp_usuario_set_password_simple
  @usuario_id = 2,
  @password   = N'VelezSarsfield!';
EXEC dbo.sp_usuario_set_password_simple
  @usuario_id = 3,
  @password   = N'BocaJuniors!';
EXEC dbo.sp_usuario_set_password_simple
  @usuario_id = 4,
  @password   = N'PremierLeagueFan!';
EXEC dbo.sp_usuario_set_password_simple 
  @usuario_id = 5, 
  @password = N'PassWord123!';
EXEC dbo.sp_usuario_set_password_simple 
  @usuario_id = 6, 
  @password = N'PassWord123!';
EXEC dbo.sp_usuario_set_password_simple 
  @usuario_id = 7, 
  @password = N'PassWord123!';
EXEC dbo.sp_usuario_set_password_simple 
  @usuario_id = 8, 
  @password = N'PassWord123!';
EXEC dbo.sp_usuario_set_password_simple 
  @usuario_id = 9, 
  @password = N'PassWord123!';
EXEC dbo.sp_usuario_set_password_simple
  @usuario_id = 10, 
  @password = N'PassWord123!';

-- Perfiles
INSERT INTO dbo.perfiles (usuario_id, nombre_usuario, nombre_mostrar, avatar_url, biografia, creado_en, actualizado_en) VALUES
(1, 'tobiager', 'Tobias Orban', NULL, N'Hincha de River Plate', SYSUTCDATETIME(), NULL),
(2, 'anaferro', 'Ana Ferro', NULL, N'Hincha de Velez', SYSUTCDATETIME(), NULL),
(3, 'carlosp', N'Carlos Pérez', NULL, N'Fan de Boca Jrs.', SYSUTCDATETIME(), NULL),
(4, 'laurag', N'Laura Gómez', NULL, N'Premier League watcher.', SYSUTCDATETIME(), NULL),
(5, 'martind', N'Martín Diaz', NULL, N'Apasionado del fútbol', SYSUTCDATETIME(), NULL),
(6, 'sofial', N'Sofia Lopez', NULL, N'Forza Milan!', SYSUTCDATETIME(), NULL),
(7, 'juanm', N'Juan Martinez', NULL, N'Siguiendo La Liga', SYSUTCDATETIME(), NULL),
(8, 'luciaf', N'Lucia Fernandez', NULL, N'Desde la tribuna', SYSUTCDATETIME(), NULL),
(9, 'diegor', N'Diego Rodriguez', NULL, N'Futbolero de ley', SYSUTCDATETIME(), NULL),
(10, 'elenas', N'Elena Sanchez', NULL, N'Amante del buen juego', SYSUTCDATETIME(), NULL);

-- ================== 2) Ligas ==================
INSERT INTO dbo.ligas (id, nombre, pais, slug, id_externo, creado_en) VALUES
(1, N'Primera Division Argentina', N'Argentina',  'liga-arg',        NULL, SYSUTCDATETIME()),
(2, N'Copa Libertadores',          N'Sudamerica', 'libertadores',    NULL, SYSUTCDATETIME()),
(3, N'La Liga',                    N'España',     'la-liga',         NULL, SYSUTCDATETIME()),
(4, N'Premier League',             N'Inglaterra', 'premier-league',  NULL, SYSUTCDATETIME()),
(5, N'Serie A',                    N'Italia',     'serie-a',         NULL, SYSUTCDATETIME()),
(6, N'Brasileirão Série A',        N'Brasil',     'brasil-serie-a',  NULL, SYSUTCDATETIME());

-- ================== 3) Equipos ==================
INSERT INTO dbo.equipos (id, nombre, nombre_corto, pais, escudo_url, liga_id, id_externo, creado_en) VALUES
(1, N'River Plate',  N'River', 'Argentina', NULL, 1, NULL, SYSUTCDATETIME()),
(2, N'Boca Juniors', N'Boca',  'Argentina', NULL, 1, NULL, SYSUTCDATETIME()),
(3, N'Fluminense',   N'Flu',   'Brasil',    NULL, 6, NULL, SYSUTCDATETIME()), 
(4, N'Real Madrid',  N'RMD',   'España',    NULL, 3, NULL, SYSUTCDATETIME()),
(5, N'FC Barcelona', N'BAR',   'España',    NULL, 3, NULL, SYSUTCDATETIME()),
(6, N'Manchester City', N'MCI', 'Inglaterra', NULL, 4, NULL, SYSUTCDATETIME()),
(7, N'Liverpool',    N'LIV',   'Inglaterra', NULL, 4, NULL, SYSUTCDATETIME()),
(8, N'Velez Sarsfield', N'Velez','Argentina', NULL, 1, NULL, SYSUTCDATETIME()),
(9, N'Inter Milan',  N'Inter', 'Italia',    NULL, 5, NULL, SYSUTCDATETIME()),
(10, N'AC Milan',    N'Milan', 'Italia',    NULL, 5, NULL, SYSUTCDATETIME()),
(11, N'Racing Club', N'Racing', 'Argentina', NULL, 1, NULL, SYSUTCDATETIME()),
(12, N'Independiente', N'Indep','Argentina', NULL, 1, NULL, SYSUTCDATETIME());

-- ================== 4) Partidos ==================


-- Partido 1: Final de Madrid (Copa Libertadores)
INSERT INTO dbo.partidos (id, id_externo, liga_id, temporada, ronda, fecha_utc, estado, estadio, equipo_local, equipo_visitante, goles_local, goles_visitante, creado_en) 
VALUES (1, NULL, 2, 2018, N'Final',CAST('2018-12-09 19:30:00' AS DATETIME2(0)),2, N'Santiago Bernabeu',1, 2, 3, 1,SYSUTCDATETIME());

-- Partido 2: Clásico Español (La Liga)
INSERT INTO dbo.partidos (id, id_externo, liga_id, temporada, ronda, fecha_utc, estado, estadio, equipo_local, equipo_visitante, goles_local, goles_visitante, creado_en)
VALUES (2, NULL, 3, 2023, N'Jornada 11', CAST('2023-10-28 14:15:00' AS DATETIME2(0)), 2, N'Estadi Olímpic Lluís Companys', 5, 4, 1, 2, SYSUTCDATETIME());

-- Partido 3: Duelo en la Premier (Premier League)
INSERT INTO dbo.partidos (id, id_externo, liga_id, temporada, ronda, fecha_utc, estado, estadio, equipo_local, equipo_visitante, goles_local, goles_visitante, creado_en)
VALUES (3, NULL, 4, 2023, N'Jornada 13', CAST('2023-11-25 12:30:00' AS DATETIME2(0)), 2, N'Etihad Stadium', 6, 7, 1, 1, SYSUTCDATETIME());

-- Partido 4: Partido futuro para recordatorio (Liga Argentina)
INSERT INTO dbo.partidos (id, id_externo, liga_id, temporada, ronda, fecha_utc, estado, estadio, equipo_local, equipo_visitante, goles_local, goles_visitante, creado_en)
VALUES (4, NULL, 1, 2024, N'Jornada 10', CAST(DATEADD(day, 7, CAST(SYSUTCDATETIME() AS DATETIME2(0))) AS DATETIME2(0)), 0, N'Estadio Monumental', 1, 8, NULL, NULL, SYSUTCDATETIME());

-- Partido 5: Derby della Madonnina (Serie A)
INSERT INTO dbo.partidos (id, id_externo, liga_id, temporada, ronda, fecha_utc, estado, estadio, equipo_local, equipo_visitante, goles_local, goles_visitante, creado_en)
VALUES (5, NULL, 5, 2023, N'Jornada 4', CAST('2023-09-16 16:00:00' AS DATETIME2(0)), 2, N'San Siro', 9, 10, 5, 1, SYSUTCDATETIME());

-- Partido 6: Clásico de Avellaneda (Liga Argentina)
INSERT INTO dbo.partidos (id, id_externo, liga_id, temporada, ronda, fecha_utc, estado, estadio, equipo_local, equipo_visitante, goles_local, goles_visitante, creado_en)
VALUES (6, NULL, 1, 2023, N'Jornada 7', CAST('2023-09-30 17:00:00' AS DATETIME2(0)), 2, N'Estadio Presidente Perón', 11, 12, 0, 2, SYSUTCDATETIME());

-- ================== 5) Interacciones sobre partido_id = 1 ==================
-- Favorito 
INSERT INTO dbo.favoritos (partido_id, usuario_id, creado_en) VALUES
(1, 1, SYSUTCDATETIME());

-- Calificaciones 
INSERT INTO dbo.calificaciones (partido_id, usuario_id, puntaje, creado_en) VALUES
(1, 1, 5, SYSUTCDATETIME()),
(1, 3, 1, SYSUTCDATETIME()); 

-- Opiniones 
INSERT INTO dbo.opiniones (partido_id, usuario_id, titulo, cuerpo, publica, tiene_spoilers, creado_en, actualizado_en)
VALUES (1, 1,N'La gloria eterna en Madrid',N'Partidazo histórico: River campeón con autoridad. 3–1 y a casa.',1, 0,SYSUTCDATETIME(), NULL);

INSERT INTO dbo.opiniones (partido_id, usuario_id, titulo, cuerpo, publica, tiene_spoilers, creado_en, actualizado_en)
VALUES (1, 3, N'Un día para el olvido', N'Prefiero no hablar de este partido.', 0, 1, SYSUTCDATETIME(), NULL); -- Privada y con spoilers

-- Visualizaciones (medio: 0=estadio,1=tv,2=streaming,3=repeticion)
INSERT INTO dbo.visualizaciones (partido_id, usuario_id, medio, visto_en, minutos_vistos, ubicacion, creado_en) VALUES
(1, 1, 1, CAST('2018-12-09 19:30:00' AS DATETIME2(3)), 120, N'Casa', SYSUTCDATETIME()),
(1, 3, 2, CAST('2018-12-09 19:30:00' AS DATETIME2(3)), 120, N'Bar con amigos', SYSUTCDATETIME());

-- ================== 5.1) Interacciones sobre otros partidos ==================
-- Partido 2 (El Clásico)
INSERT INTO dbo.calificaciones (partido_id, usuario_id, puntaje, creado_en) VALUES
(2, 4, 4, SYSUTCDATETIME());
INSERT INTO dbo.opiniones (partido_id, usuario_id, titulo, cuerpo, publica, tiene_spoilers, creado_en, actualizado_en)
VALUES (2, 4, N'Bellingham es de otro planeta', N'Qué remontada del Madrid. Increíble la actuación del inglés.', 1, 1, SYSUTCDATETIME(), NULL);
INSERT INTO dbo.visualizaciones (partido_id, usuario_id, medio, visto_en, minutos_vistos, ubicacion, creado_en)
VALUES (2, 4, 1, CAST('2023-10-28 14:15:00' AS DATETIME2(3)), 90, NULL, SYSUTCDATETIME());

-- Partido 3 (Premier)
INSERT INTO dbo.calificaciones (partido_id, usuario_id, puntaje, creado_en) VALUES
(3, 4, 3, SYSUTCDATETIME());
INSERT INTO dbo.favoritos (partido_id, usuario_id, creado_en) VALUES
(3, 4, SYSUTCDATETIME());

-- Partido 5 (Derby de Milan)
INSERT INTO dbo.calificaciones (partido_id, usuario_id, puntaje, creado_en) VALUES
(5, 6, 1, SYSUTCDATETIME()), -- Hincha del Milan
(5, 9, 5, SYSUTCDATETIME()); -- Hincha del Inter
INSERT INTO dbo.opiniones (partido_id, usuario_id, titulo, cuerpo, publica, tiene_spoilers, creado_en, actualizado_en)
VALUES (5, 9, N'¡Paliza histórica!', N'5-1 en el clásico, una noche soñada para el Inter.', 1, 1, SYSUTCDATETIME(), NULL);

-- Partido 6 (Clásico de Avellaneda)
INSERT INTO dbo.calificaciones (partido_id, usuario_id, puntaje, creado_en) VALUES
(6, 8, 5, SYSUTCDATETIME()); -- Hincha de Independiente
INSERT INTO dbo.visualizaciones (partido_id, usuario_id, medio, visto_en, minutos_vistos, ubicacion, creado_en)
VALUES (6, 8, 0, CAST('2023-09-30 17:00:00' AS DATETIME2(3)), 95, N'Avellaneda', SYSUTCDATETIME());

-- ================== 6) Social / Seguimientos ==================
-- Seguimiento de equipos 
INSERT INTO dbo.seguimiento_equipos (usuario_id, equipo_id, creado_en) VALUES
(1, 1, SYSUTCDATETIME()),
(2, 8, SYSUTCDATETIME()),
(3, 2, SYSUTCDATETIME()),
(4, 6, SYSUTCDATETIME()),
(4, 7, SYSUTCDATETIME()),
(6, 10, SYSUTCDATETIME()),
(9, 9, SYSUTCDATETIME()),
(8, 12, SYSUTCDATETIME()),
(7, 4, SYSUTCDATETIME()),
(7, 5, SYSUTCDATETIME());

-- Seguimiento de Ligas
INSERT INTO dbo.seguimiento_ligas (usuario_id, liga_id, creado_en) VALUES
(1, 2, SYSUTCDATETIME()),
(2, 1, SYSUTCDATETIME()),
(4, 4, SYSUTCDATETIME()),
(6, 5, SYSUTCDATETIME()),
(7, 3, SYSUTCDATETIME());

-- Seguimiento de Usuarios (nota: la constraint evita seguirse a uno mismo)
INSERT INTO dbo.seguimiento_usuarios (usuario_id, usuario_seguido, creado_en) VALUES
(1, 2, SYSUTCDATETIME()),
(3, 1, SYSUTCDATETIME()),
(6, 9, SYSUTCDATETIME());

-- ================== 7) Recordatorios ==================
-- recordatorios.estado: 0=pendiente,1=enviado,2=cancelado
INSERT INTO dbo.recordatorios (usuario_id, partido_id, recordar_en, estado, creado_en) VALUES
(1, 1, CAST('2018-12-09 19:15:00' AS DATETIME2(3)), 1, SYSUTCDATETIME()), -- histórico enviado
(1, 4, DATEADD(hour, -1, (SELECT fecha_utc FROM dbo.partidos WHERE id = 4)), 0, SYSUTCDATETIME()), -- pendiente 1h antes
(2, 4, DATEADD(minute, -30, (SELECT fecha_utc FROM dbo.partidos WHERE id = 4)), 0, SYSUTCDATETIME()); -- pendiente 30m antes

-- ================== 8) Partidos destacados ==================

INSERT INTO dbo.partidos_destacados (usuario_id, partido_id, destacado_en, nota) VALUES
(1, 1, CAST('2018-12-09' AS DATE), N'Final de Madrid: River campeón 2018'),
(NULL, 2, CAST('2023-10-28' AS DATE), N'El Clásico: Remontada del Madrid con doblete de Bellingham.'),
(NULL, 5, CAST('2023-09-16' AS DATE), N'Goleada del Inter en el Derby della Madonnina.');

COMMIT;

PRINT 'Datos cargados correctamente.';
PRINT '';
GO