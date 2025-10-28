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
INSERT INTO dbo.usuarios (id, correo, creado_en) VALUES
('11111111-1111-1111-1111-111111111111', 'tobiager@example.com', SYSDATETIME()),
('22222222-2222-2222-2222-222222222222', 'ana.ferro@example.com', SYSDATETIME()),
('33333333-3333-3333-3333-333333333333', 'carlos.perez@example.com', SYSDATETIME()),
('44444444-4444-4444-4444-444444444444', 'laura.gomez@example.com', SYSDATETIME()),
('55555555-5555-5555-5555-555555555555', 'martin.diaz@example.com', SYSDATETIME()),
('66666666-6666-6666-6666-666666666666', 'sofia.lopez@example.com', SYSDATETIME()),
('77777777-7777-7777-7777-777777777777', 'juan.martinez@example.com', SYSDATETIME()),
('88888888-8888-8888-8888-888888888888', 'lucia.fernandez@example.com', SYSDATETIME()),
('99999999-9999-9999-9999-999999999999', 'diego.rodriguez@example.com', SYSDATETIME()),
('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', 'elena.sanchez@example.com', SYSDATETIME());

-- Asignar contraseñas a los usuarios iniciales
EXEC dbo.sp_usuario_set_password_simple
  @usuario_id = '11111111-1111-1111-1111-111111111111',
  @password   = N'RiverPlate2018!'; -- Contraseña de ejemplo para Tobias
EXEC dbo.sp_usuario_set_password_simple
  @usuario_id = '22222222-2222-2222-2222-222222222222',
  @password   = N'VelezSarsfield!'; -- Contraseña de ejemplo para Ana
EXEC dbo.sp_usuario_set_password_simple
  @usuario_id = '33333333-3333-3333-3333-333333333333',
  @password   = N'BocaJuniors!'; -- Contraseña de ejemplo para Carlos
EXEC dbo.sp_usuario_set_password_simple
  @usuario_id = '44444444-4444-4444-4444-444444444444',
  @password   = N'PremierLeagueFan!'; -- Contraseña de ejemplo para Laura
EXEC dbo.sp_usuario_set_password_simple 
  @usuario_id = '55555555-5555-5555-5555-555555555555', 
  @password = N'PassWord123!';
EXEC dbo.sp_usuario_set_password_simple 
  @usuario_id = '66666666-6666-6666-6666-666666666666', 
  @password = N'PassWord123!';
EXEC dbo.sp_usuario_set_password_simple 
  @usuario_id = '77777777-7777-7777-7777-777777777777', 
  @password = N'PassWord123!';
EXEC dbo.sp_usuario_set_password_simple 
  @usuario_id = '88888888-8888-8888-8888-888888888888', 
  @password = N'PassWord123!';
EXEC dbo.sp_usuario_set_password_simple 
  @usuario_id = '99999999-9999-9999-9999-999999999999', 
  @password = N'PassWord123!';
EXEC dbo.sp_usuario_set_password_simple
  @usuario_id = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', 
  @password = N'PassWord123!';

INSERT INTO dbo.perfiles (usuario_id, nombre_usuario, nombre_mostrar, avatar_url, biografia, creado_en, actualizado_en) VALUES
('11111111-1111-1111-1111-111111111111', 'tobiager', 'Tobias Orban', NULL, 'Hincha de River Plate', SYSDATETIME(), NULL),
('22222222-2222-2222-2222-222222222222', 'anaferro', 'Ana Ferro', NULL, 'Hincha de Velez', SYSDATETIME(), NULL),
('33333333-3333-3333-3333-333333333333', 'carlosp', 'Carlos Pérez', NULL, 'Fan de Boca Jrs.', SYSDATETIME(), NULL),
('44444444-4444-4444-4444-444444444444', 'laurag', 'Laura Gómez', NULL, 'Premier League watcher.', SYSDATETIME(), NULL),
('55555555-5555-5555-5555-555555555555', 'martind', 'Martín Diaz', NULL, 'Apasionado del fútbol', SYSDATETIME(), NULL),
('66666666-6666-6666-6666-666666666666', 'sofial', 'Sofia Lopez', NULL, 'Forza Milan!', SYSDATETIME(), NULL),
('77777777-7777-7777-7777-777777777777', 'juanm', 'Juan Martinez', NULL, 'Siguiendo La Liga', SYSDATETIME(), NULL),
('88888888-8888-8888-8888-888888888888', 'luciaf', 'Lucia Fernandez', NULL, 'Desde la tribuna', SYSDATETIME(), NULL),
('99999999-9999-9999-9999-999999999999', 'diegor', 'Diego Rodriguez', NULL, 'Futbolero de ley', SYSDATETIME(), NULL),
('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', 'elenas', 'Elena Sanchez', NULL, 'Amante del buen juego', SYSDATETIME(), NULL);

-- ================== 2) Ligas ==================
INSERT INTO dbo.ligas (id, nombre, pais, slug, id_externo, creado_en) VALUES
(1, 'Primera Division Argentina', 'Argentina',  'liga-arg',     NULL, SYSDATETIME()),
(2, 'Copa Libertadores',          'Sudamerica', 'libertadores', NULL, SYSDATETIME()),
(3, 'La Liga',                    'España',     'la-liga',      NULL, SYSDATETIME()),
(4, 'Premier League',             'Inglaterra', 'premier-league', NULL, SYSDATETIME()),
(5, 'Serie A',                    'Italia',     'serie-a',      NULL, SYSDATETIME()),
(6, 'Brasileirão Série A',        'Brasil',     'brasil-serie-a', NULL, SYSDATETIME());

-- ================== 3) Equipos ==================
INSERT INTO dbo.equipos (id, nombre, nombre_corto, pais, escudo_url, liga_id, id_externo, creado_en) VALUES
(1, 'River Plate',  'River', 'Argentina', NULL, 1, NULL, SYSDATETIME()),
(2, 'Boca Juniors', 'Boca',  'Argentina', NULL, 1, NULL, SYSDATETIME()),
(3, 'Fluminense',   'Flu',   'Brasil',    NULL, 6, NULL, SYSDATETIME()), -- Ahora pertenece al Brasileirão
(4, 'Real Madrid',  'RMD',   'España',    NULL, 3, NULL, SYSDATETIME()),
(5, 'FC Barcelona', 'BAR',   'España',    NULL, 3, NULL, SYSDATETIME()),
(6, 'Manchester City', 'MCI', 'Inglaterra', NULL, 4, NULL, SYSDATETIME()),
(7, 'Liverpool',    'LIV',   'Inglaterra', NULL, 4, NULL, SYSDATETIME()),
(8, 'Velez Sarsfield', 'Velez', 'Argentina', NULL, 1, NULL, SYSDATETIME()),
(9, 'Inter Milan', 'Inter', 'Italia', NULL, 5, NULL, SYSDATETIME()),
(10, 'AC Milan', 'Milan', 'Italia', NULL, 5, NULL, SYSDATETIME()),
(11, 'Racing Club', 'Racing', 'Argentina', NULL, 1, NULL, SYSDATETIME()),
(12, 'Independiente', 'Indep', 'Argentina', NULL, 1, NULL, SYSDATETIME());

-- ================== 4) Partidos ==================
-- Partido 1: Final de Madrid (Copa Libertadores)
INSERT INTO dbo.partidos (
  id, id_externo, liga_id, temporada, ronda, fecha_utc, estado, estadio,
  equipo_local, equipo_visitante, goles_local, goles_visitante, creado_en
) VALUES (
  1, NULL, 2, 2018, 'Final',
  CAST('2018-12-09 19:30:00' AS DATETIME2),
  'finalizado',
  'Santiago Bernabeu',
  1, 2, 3, 1,
  SYSDATETIME()
);

-- Partido 2: Clásico Español (La Liga)
INSERT INTO dbo.partidos (id, id_externo, liga_id, temporada, ronda, fecha_utc, estado, estadio, equipo_local, equipo_visitante, goles_local, goles_visitante, creado_en)
VALUES (2, NULL, 3, 2023, 'Jornada 11', CAST('2023-10-28 14:15:00' AS DATETIME2), 'finalizado', 'Estadi Olímpic Lluís Companys', 5, 4, 1, 2, SYSDATETIME());

-- Partido 3: Duelo en la Premier (Premier League)
INSERT INTO dbo.partidos (id, id_externo, liga_id, temporada, ronda, fecha_utc, estado, estadio, equipo_local, equipo_visitante, goles_local, goles_visitante, creado_en)
VALUES (3, NULL, 4, 2023, 'Jornada 13', CAST('2023-11-25 12:30:00' AS DATETIME2), 'finalizado', 'Etihad Stadium', 6, 7, 1, 1, SYSDATETIME());

-- Partido 4: Partido futuro para recordatorio (Liga Argentina)
INSERT INTO dbo.partidos (id, id_externo, liga_id, temporada, ronda, fecha_utc, estado, estadio, equipo_local, equipo_visitante, goles_local, goles_visitante, creado_en)
VALUES (4, NULL, 1, 2024, 'Jornada 10', DATEADD(day, 7, GETDATE()), 'programado', 'Estadio Monumental', 1, 8, NULL, NULL, SYSDATETIME());

-- Partido 5: Derby della Madonnina (Serie A)
INSERT INTO dbo.partidos (id, id_externo, liga_id, temporada, ronda, fecha_utc, estado, estadio, equipo_local, equipo_visitante, goles_local, goles_visitante, creado_en)
VALUES (5, NULL, 5, 2023, 'Jornada 4', CAST('2023-09-16 16:00:00' AS DATETIME2), 'finalizado', 'San Siro', 9, 10, 5, 1, SYSDATETIME());

-- Partido 6: Clásico de Avellaneda (Liga Argentina)
INSERT INTO dbo.partidos (id, id_externo, liga_id, temporada, ronda, fecha_utc, estado, estadio, equipo_local, equipo_visitante, goles_local, goles_visitante, creado_en)
VALUES (6, NULL, 1, 2023, 'Jornada 7', CAST('2023-09-30 17:00:00' AS DATETIME2), 'finalizado', 'Estadio Presidente Perón', 11, 12, 0, 2, SYSDATETIME());



-- ================== 5) Interacciones sobre partido_id = 1 ==================
-- Favorito
INSERT INTO dbo.favoritos (id, partido_id, usuario_id, creado_en) VALUES
(1, 1, '11111111-1111-1111-1111-111111111111', SYSDATETIME());

-- Calificaciones
INSERT INTO dbo.calificaciones (id, partido_id, usuario_id, puntaje, creado_en) VALUES
(1, 1, '11111111-1111-1111-1111-111111111111', 5, SYSDATETIME()),
(2, 1, '33333333-3333-3333-3333-333333333333', 1, SYSDATETIME()); -- Hincha de Boca

-- Opiniones
INSERT INTO dbo.opiniones (
  id, partido_id, usuario_id, titulo, cuerpo, publica, tiene_spoilers, creado_en, actualizado_en
) VALUES (
  1, 1, '11111111-1111-1111-1111-111111111111',
  'La gloria eterna en Madrid',
  'Partidazo histórico: River campeón con autoridad. 3–1 y a casa.',
  1, 0,
  SYSDATETIME(), NULL
);

INSERT INTO dbo.opiniones (id, partido_id, usuario_id, titulo, cuerpo, publica, tiene_spoilers, creado_en, actualizado_en)
VALUES (2, 1, '33333333-3333-3333-3333-333333333333', 'Un día para el olvido', 'Prefiero no hablar de este partido.', 0, 1, SYSDATETIME(), NULL); -- Privada y con spoilers

-- Visualizaciones
INSERT INTO dbo.visualizaciones (
  id, partido_id, usuario_id, medio, visto_en, minutos_vistos, ubicacion, creado_en
) VALUES (
  1, 1, '11111111-1111-1111-1111-111111111111',
  'tv',
  CAST('2018-12-09 19:30:00' AS DATETIME2),
  120, 'Casa', SYSDATETIME()
),
(2, 1, '33333333-3333-3333-3333-333333333333', 'streaming', CAST('2018-12-09 19:30:00' AS DATETIME2), 120, 'Bar con amigos', SYSDATETIME());

-- ================== 5.1) Interacciones sobre otros partidos ==================
-- Partido 2 (El Clásico)
INSERT INTO dbo.calificaciones (id, partido_id, usuario_id, puntaje, creado_en) VALUES
(3, 2, '44444444-4444-4444-4444-444444444444', 4, SYSDATETIME());
INSERT INTO dbo.opiniones (id, partido_id, usuario_id, titulo, cuerpo, publica, tiene_spoilers, creado_en, actualizado_en)
VALUES (3, 2, '44444444-4444-4444-4444-444444444444', 'Bellingham es de otro planeta', 'Qué remontada del Madrid. Increíble la actuación del inglés.', 1, 1, SYSDATETIME(), NULL);
INSERT INTO dbo.visualizaciones (id, partido_id, usuario_id, medio, visto_en, minutos_vistos, ubicacion, creado_en)
VALUES (3, 2, '44444444-4444-4444-4444-444444444444', 'tv', CAST('2023-10-28 14:15:00' AS DATETIME2), 90, NULL, SYSDATETIME());

-- Partido 3 (Premier)
INSERT INTO dbo.calificaciones (id, partido_id, usuario_id, puntaje, creado_en) VALUES
(4, 3, '44444444-4444-4444-4444-444444444444', 3, SYSDATETIME());
INSERT INTO dbo.favoritos (id, partido_id, usuario_id, creado_en) VALUES
(2, 3, '44444444-4444-4444-4444-444444444444', SYSDATETIME());

-- Partido 5 (Derby de Milan)
INSERT INTO dbo.calificaciones (id, partido_id, usuario_id, puntaje, creado_en) VALUES
(5, 5, '66666666-6666-6666-6666-666666666666', 1, SYSDATETIME()), -- Hincha del Milan
(6, 5, '99999999-9999-9999-9999-999999999999', 5, SYSDATETIME()); -- Hincha del Inter
INSERT INTO dbo.opiniones (id, partido_id, usuario_id, titulo, cuerpo, publica, tiene_spoilers, creado_en, actualizado_en)
VALUES (4, 5, '99999999-9999-9999-9999-999999999999', '¡Paliza histórica!', '5-1 en el clásico, una noche soñada para el Inter.', 1, 1, SYSDATETIME(), NULL);

-- Partido 6 (Clásico de Avellaneda)
INSERT INTO dbo.calificaciones (id, partido_id, usuario_id, puntaje, creado_en) VALUES
(7, 6, '88888888-8888-8888-8888-888888888888', 5, SYSDATETIME()); -- Hincha de Independiente
INSERT INTO dbo.visualizaciones (id, partido_id, usuario_id, medio, visto_en, minutos_vistos, ubicacion, creado_en)
VALUES (4, 6, '88888888-8888-8888-8888-888888888888', 'estadio', CAST('2023-09-30 17:00:00' AS DATETIME2), 95, 'Avellaneda', SYSDATETIME());


-- ================== 6) Social / Seguimientos ==================
-- El usuario 'tobiager' sigue a River
INSERT INTO dbo.seguimiento_equipos (usuario_id, equipo_id, creado_en) VALUES
('11111111-1111-1111-1111-111111111111', 1, SYSDATETIME());

-- El usuario 'anaferro' sigue a Velez
INSERT INTO dbo.seguimiento_equipos (usuario_id, equipo_id, creado_en) VALUES
('22222222-2222-2222-2222-222222222222', 8, SYSDATETIME());

-- El usuario 'carlos.perez' sigue a Boca
INSERT INTO dbo.seguimiento_equipos (usuario_id, equipo_id, creado_en) VALUES
('33333333-3333-3333-3333-333333333333', 2, SYSDATETIME());

-- La usuaria 'laura.gomez' sigue a equipos de la Premier
INSERT INTO dbo.seguimiento_equipos (usuario_id, equipo_id, creado_en) VALUES
('44444444-4444-4444-4444-444444444444', 6, SYSDATETIME()),
('44444444-4444-4444-4444-444444444444', 7, SYSDATETIME());

-- Más seguimientos de equipos
INSERT INTO dbo.seguimiento_equipos (usuario_id, equipo_id, creado_en) VALUES
('66666666-6666-6666-6666-666666666666', 10, SYSDATETIME()), -- Sofia sigue al Milan
('99999999-9999-9999-9999-999999999999', 9, SYSDATETIME()),  -- Diego sigue al Inter
('88888888-8888-8888-8888-888888888888', 12, SYSDATETIME()), -- Lucia sigue a Independiente
('77777777-7777-7777-7777-777777777777', 4, SYSDATETIME()),  -- Juan sigue al Real Madrid
('77777777-7777-7777-7777-777777777777', 5, SYSDATETIME());  -- y al Barcelona

-- Seguimiento de Ligas
INSERT INTO dbo.seguimiento_ligas (usuario_id, liga_id, creado_en) VALUES
('11111111-1111-1111-1111-111111111111', 2, SYSDATETIME()), -- Tobiager sigue la Libertadores
('22222222-2222-2222-2222-222222222222', 1, SYSDATETIME()), -- Ana sigue la Liga Argentina
('44444444-4444-4444-4444-444444444444', 4, SYSDATETIME()), -- Laura sigue la Premier
('66666666-6666-6666-6666-666666666666', 5, SYSDATETIME()), -- Sofia sigue la Serie A
('77777777-7777-7777-7777-777777777777', 3, SYSDATETIME()); -- Juan sigue La Liga

-- Seguimiento de Usuarios
INSERT INTO dbo.seguimiento_usuarios (usuario_id, usuario_seguido, creado_en) VALUES
('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', SYSDATETIME()), -- Tobiager sigue a Ana
('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', SYSDATETIME()), -- Carlos sigue a Tobiager (rivalidad)
('66666666-6666-6666-6666-666666666666', '99999999-9999-9999-9999-999999999999', SYSDATETIME()); -- Sofia sigue a Diego (rivalidad Milan/Inter)

-- ================== 7) Recordatorios ==================
-- Recordatorio histórico (partido 1)
INSERT INTO dbo.recordatorios (id, usuario_id, partido_id, recordar_en, estado, creado_en) VALUES
(1,
 '11111111-1111-1111-1111-111111111111',
 1,
 CAST('2018-12-09 19:15:00' AS DATETIME2),
 'enviado',
 SYSDATETIME()
),
-- Recordatorio para partido futuro (partido 4)
(2,
 '11111111-1111-1111-1111-111111111111',
 4,
 DATEADD(hour, -1, (SELECT fecha_utc FROM dbo.partidos WHERE id = 4)), -- 1 hora antes del partido
 'pendiente',
 SYSDATETIME()
),
(3,
 '22222222-2222-2222-2222-222222222222',
 4,
 DATEADD(minute, -30, (SELECT fecha_utc FROM dbo.partidos WHERE id = 4)), -- 30 min antes
 'pendiente',
 SYSDATETIME()
);

-- ================== 8) Partidos destacados ==================
INSERT INTO dbo.partidos_destacados (id, usuario_id, partido_id, destacado_en, nota) VALUES
(1, '11111111-1111-1111-1111-111111111111', 1, CAST('2018-12-09' AS DATE), 'Final de Madrid: River campeón 2018'),
(2, NULL, 2, CAST('2023-10-28' AS DATE), 'El Clásico: Remontada del Madrid con doblete de Bellingham.'),
(3, NULL, 5, CAST('2023-09-16' AS DATE), 'Goleada del Inter en el Derby della Madonnina.');

COMMIT;

PRINT 'Datos cargados correctamente.';
PRINT '';
GO