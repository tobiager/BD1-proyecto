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
DELETE FROM dbo.seguimiento_usuarios;  -- Si ya ejecutaste el script de seguimiento
DELETE FROM dbo.seguimiento_ligas;     -- Si ya ejecutaste el script de seguimiento
DELETE FROM dbo.seguimiento_equipos;   -- Si ya ejecutaste el script de seguimiento
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
('22222222-2222-2222-2222-222222222222', 'ana.ferro@example.com', SYSDATETIME());

INSERT INTO dbo.perfiles (usuario_id, nombre_usuario, nombre_mostrar, avatar_url, biografia, creado_en, actualizado_en) VALUES
('11111111-1111-1111-1111-111111111111', 'tobiager', 'Tobias Orban', NULL, 'Hincha de River Plate', SYSDATETIME(), NULL),
('22222222-2222-2222-2222-222222222222', 'anaferro', 'Ana Ferro',     NULL, 'Hincha de Velez',      SYSDATETIME(), NULL);

-- ================== 2) Ligas ==================
INSERT INTO dbo.ligas (id, nombre, pais, slug, id_externo, creado_en) VALUES
(1, 'Primera Division Argentina', 'Argentina',  'liga-arg',     NULL, SYSDATETIME()),
(2, 'Copa Libertadores',          'Sudamerica', 'libertadores', NULL, SYSDATETIME());

-- ================== 3) Equipos ==================
INSERT INTO dbo.equipos (id, nombre, nombre_corto, pais, escudo_url, liga_id, id_externo, creado_en) VALUES
(1, 'River Plate',  'River', 'Argentina', NULL, 1, NULL, SYSDATETIME()),
(2, 'Boca Juniors', 'Boca',  'Argentina', NULL, 1, NULL, SYSDATETIME()),
(3, 'Fluminense',   'Flu',   'Brasil',    NULL, 2, NULL, SYSDATETIME());

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

-- ================== 5) Interacciones sobre partido_id = 1 ==================
-- Favorito
INSERT INTO dbo.favoritos (id, partido_id, usuario_id, creado_en) VALUES
(1, 1, '11111111-1111-1111-1111-111111111111', SYSDATETIME());

-- Calificacion
INSERT INTO dbo.calificaciones (id, partido_id, usuario_id, puntaje, creado_en) VALUES
(1, 1, '11111111-1111-1111-1111-111111111111', 5, SYSDATETIME());

-- Opinion (publica=1, tiene_spoilers=0)
INSERT INTO dbo.opiniones (
  id, partido_id, usuario_id, titulo, cuerpo, publica, tiene_spoilers, creado_en, actualizado_en
) VALUES (
  1, 1, '11111111-1111-1111-1111-111111111111',
  'La gloria eterna en Madrid',
  'Partidazo historico: River campeon con autoridad. 3–1 y a casa.',
  1, 0,
  SYSDATETIME(), NULL
);

-- Visualizacion
INSERT INTO dbo.visualizaciones (
  id, partido_id, usuario_id, medio, visto_en, minutos_vistos, ubicacion, creado_en
) VALUES (
  1, 1, '11111111-1111-1111-1111-111111111111',
  'tv',
  CAST('2018-12-09 19:30:00' AS DATETIME2),
  120,
  'Madrid',
  SYSDATETIME()
);

-- ================== 6) Social / Seguimientos ==================
-- IMPORTANTE: No especificar 'id' porque tiene IDENTITY(1,1)

-- El usuario 'tobiager' sigue a River y a Boca
INSERT INTO dbo.seguimiento_equipos (usuario_id, equipo_id, creado_en) VALUES
('11111111-1111-1111-1111-111111111111', 1, SYSDATETIME()),
('11111111-1111-1111-1111-111111111111', 2, SYSDATETIME());

-- El usuario 'tobiager' sigue la Copa Libertadores
INSERT INTO dbo.seguimiento_ligas (usuario_id, liga_id, creado_en) VALUES
('11111111-1111-1111-1111-111111111111', 2, SYSDATETIME());

-- El usuario 'tobiager' sigue a la usuaria 'anaferro'
INSERT INTO dbo.seguimiento_usuarios (usuario_id, usuario_seguido, creado_en) VALUES
('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', SYSDATETIME());

-- ================== 7) Recordatorio (histórico, 15 min antes) ==================
INSERT INTO dbo.recordatorios (id, usuario_id, partido_id, recordar_en, estado, creado_en) VALUES
(1,
 '11111111-1111-1111-1111-111111111111',
 1,
 CAST('2018-12-09 19:15:00' AS DATETIME2),
 'enviado',
 SYSDATETIME()
);

-- ================== 8) Partido destacado del dia ==================
INSERT INTO dbo.partidos_destacados (id, usuario_id, partido_id, destacado_en, nota) VALUES
(1, '22222222-2222-2222-2222-222222222222', 1, CAST('2018-12-09' AS DATE), 'Final de Madrid: River campeon 2018');

COMMIT;

PRINT 'Datos cargados correctamente.';
PRINT '';
PRINT '========== Verificacion de seguimientos ==========';
SELECT * FROM dbo.vw_resumen_seguimientos WHERE usuario_id = '11111111-1111-1111-1111-111111111111';
GO