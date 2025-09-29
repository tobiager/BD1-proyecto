-- =========================================================
-- Tribuneros - Carga representativa (DML)
-- =========================================================
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE tribuneros_bdi;
GO

BEGIN TRAN;

-- Usuarios
DECLARE @u1 UNIQUEIDENTIFIER = '11111111-1111-1111-1111-111111111111';
DECLARE @u2 UNIQUEIDENTIFIER = '22222222-2222-2222-2222-222222222222';

INSERT INTO dbo.usuarios(id, correo) VALUES
(@u1, N'tobiager@example.com'),
(@u2, N'ana.ferro@example.com');

INSERT INTO dbo.perfiles(usuario_id, nombre_usuario, nombre_mostrar, biografia)
VALUES
(@u1, N'tobiager', N'Tobias Orban', N'Hincha de River Plate'),
(@u2, N'anaferro', N'Ana Ferro', N'Hincha de Vélez');

-- Ligas
INSERT INTO dbo.ligas(nombre, pais, slug) VALUES
(N'Primera División Argentina', N'Argentina', N'liga-arg'),
(N'Copa Libertadores', N'Sudamérica', N'libertadores');

-- Equipos
INSERT INTO dbo.equipos(nombre, nombre_corto, pais, liga_id) VALUES
(N'River Plate', N'River', N'Argentina', 1),
(N'Boca Juniors', N'Boca', N'Argentina', 1),
(N'Fluminense', N'Flu', N'Brasil', 2);

-- Partido: Final de Madrid (Copa Libertadores)
INSERT INTO dbo.partidos(liga_id, temporada, ronda, fecha_utc, estado, estadio, equipo_local, equipo_visitante, goles_local, goles_visitante
)
VALUES (
  2,                -- Copa Libertadores
  2018,
  N'Final',
  '2018-12-09T19:30:00Z',
  N'finalizado',
  N'Santiago Bernabéu',
  1,                -- River (local designado)
  2,                -- Boca
  3,                -- River 3
  1                 -- Boca 1
);

-- Interacciones sobre la Final de Madrid (partido_id = 1)
INSERT INTO dbo.favoritos(partido_id, usuario_id) VALUES (1, @u1);

INSERT INTO dbo.calificaciones(partido_id, usuario_id, puntaje)
VALUES (1, @u1, 5);

INSERT INTO dbo.opiniones(
  partido_id, usuario_id, titulo, cuerpo, publica, tiene_spoilers
)
VALUES (
  1, @u1,
  N'La gloria eterna en Madrid',
  N'Partidazo histórico: River campeón con autoridad. 3–1 y a casa.',
  1, 0
);

INSERT INTO dbo.visualizaciones(
  partido_id, usuario_id, medio, visto_en, minutos_vistos, ubicacion
)
VALUES (
  1, @u1,
  N'tv',
  '2018-12-09T19:30:00Z',
  120,
  N'Madrid'
);

-- Seguimiento & Recordatorio (histórico, 15 min antes del inicio)
INSERT INTO dbo.seguidos(usuario_id, equipo_id) VALUES (@u1, 1), (@u1, 2);

INSERT INTO dbo.recordatorios(usuario_id, partido_id, recordar_en, estado)
VALUES (@u1, 1, DATEADD(MINUTE, -15, '2018-12-09T19:30:00Z'), N'enviado');

-- Partido destacado del día
INSERT INTO dbo.partidos_destacados(usuario_id, partido_id, destacado_en, nota)
VALUES (@u2, 1, CONVERT(date, '2018-12-09'), N'Final de Madrid: River campeón 2018');

COMMIT;
PRINT 'Datos cargados correctamente.';
