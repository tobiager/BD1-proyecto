-- =========================================================
-- Tribuneros - Verificación legible de datos y lógica
-- Objetivo: Mostrar nombres/estados en lugar de solo ids para facilitar revisión
-- =========================================================

USE tribuneros_bdi;
GO

-- Usuarios y perfiles: mostrar id, correo y nombre de usuario (legible)
SELECT u.id AS usuario_id,
       u.correo,
       p.nombre_usuario,
       p.nombre_mostrar,
       p.biografia,
       u.creado_en
FROM dbo.usuarios AS u
LEFT JOIN dbo.perfiles AS p ON p.usuario_id = u.id
ORDER BY u.id;
GO

-- Ligas y equipos: mostrar nombres y referencias legibles
SELECT l.id AS liga_id, l.nombre AS liga_nombre, l.pais, l.slug, l.creado_en
FROM dbo.ligas AS l
ORDER BY l.id;

SELECT e.id AS equipo_id, e.nombre, e.nombre_corto, e.pais,
       ISNULL(l.nombre, '(sin liga)') AS liga_nombre,
       e.creado_en
FROM dbo.equipos AS e
LEFT JOIN dbo.ligas AS l ON l.id = e.liga_id
ORDER BY e.id;
GO

-- Partidos: mostrar fechas, equipos por nombre y estado legible
SELECT p.id AS partido_id,
       ISNULL(l.nombre, '(sin liga)') AS liga,
       p.temporada, p.ronda,
       p.fecha_utc,
       CASE p.estado
         WHEN 0 THEN N'PROGRAMADO'
         WHEN 1 THEN N'EN_VIVO'
         WHEN 2 THEN N'FINALIZADO'
         WHEN 3 THEN N'POSPUESTO'
         WHEN 4 THEN N'CANCELADO'
         ELSE N'OTRO'
       END AS estado_texto,
       p.estadio,
       e_local.nombre AS equipo_local_nombre,
       e_visit.nombre AS equipo_visitante_nombre,
       p.goles_local, p.goles_visitante,
       p.creado_en
FROM dbo.partidos AS p
LEFT JOIN dbo.ligas AS l ON l.id = p.liga_id
LEFT JOIN dbo.equipos AS e_local ON e_local.id = p.equipo_local
LEFT JOIN dbo.equipos AS e_visit ON e_visit.id = p.equipo_visitante
ORDER BY p.fecha_utc;
GO

-- Calificaciones: mostrar usuario (nombre_usuario) y partido (liga + equipos) legible
SELECT c.id AS calificacion_id,
       c.puntaje,
       c.creado_en,
       c.partido_id,
       ISNULL(p_part.ronda, '') + ' ' + ISNULL(liga.nombre, '') AS partido_ref,
       u.id AS usuario_id,
       p_user.nombre_usuario AS usuario_nombre
FROM dbo.calificaciones AS c
LEFT JOIN dbo.partidos AS p_part ON p_part.id = c.partido_id
LEFT JOIN dbo.ligas AS liga ON liga.id = p_part.liga_id
LEFT JOIN dbo.usuarios AS u ON u.id = c.usuario_id
LEFT JOIN dbo.perfiles AS p_user ON p_user.usuario_id = u.id
ORDER BY c.id;
GO

-- Opiniones: usuario legible y partido legible
SELECT o.id AS opinion_id,
       o.titulo,
       LEFT(o.cuerpo, 120) + CASE WHEN LEN(o.cuerpo) > 120 THEN '...' ELSE '' END AS cuerpo_preview,
       o.publica, o.tiene_spoilers,
       o.creado_en, o.actualizado_en,
       o.partido_id,
       ISNULL(plocal.nombre, '') + ' vs ' + ISNULL(pvisit.nombre, '') AS partido,
       per.nombre_usuario AS autor
FROM dbo.opiniones AS o
LEFT JOIN dbo.partidos AS p ON p.id = o.partido_id
LEFT JOIN dbo.equipos AS plocal ON plocal.id = p.equipo_local
LEFT JOIN dbo.equipos AS pvisit ON pvisit.id = p.equipo_visitante
LEFT JOIN dbo.perfiles AS per ON per.usuario_id = o.usuario_id
ORDER BY o.id;
GO

-- Favoritos: mostrar usuario y partido legible
SELECT f.id AS favorito_id,
       f.creado_en,
       f.partido_id,
       ISNULL(el.nombre, '') + ' vs ' + ISNULL(ev.nombre, '') AS partido,
       per.nombre_usuario AS usuario
FROM dbo.favoritos AS f
LEFT JOIN dbo.partidos AS p ON p.id = f.partido_id
LEFT JOIN dbo.equipos AS el ON el.id = p.equipo_local
LEFT JOIN dbo.equipos AS ev ON ev.id = p.equipo_visitante
LEFT JOIN dbo.perfiles AS per ON per.usuario_id = f.usuario_id
ORDER BY f.id;
GO

-- Visualizaciones: medio legible y usuario/partido legible
SELECT v.id AS visualizacion_id,
       v.visto_en,
       CASE v.medio WHEN 0 THEN N'ESTADIO' WHEN 1 THEN N'TV' WHEN 2 THEN N'STREAMING' WHEN 3 THEN N'REPETICION' ELSE N'OTRO' END AS medio_texto,
       v.minutos_vistos,
       v.ubicacion,
       per.nombre_usuario AS usuario,
       ISNULL(el.nombre, '') + ' vs ' + ISNULL(ev.nombre, '') AS partido
FROM dbo.visualizaciones AS v
LEFT JOIN dbo.perfiles AS per ON per.usuario_id = v.usuario_id
LEFT JOIN dbo.partidos AS p ON p.id = v.partido_id
LEFT JOIN dbo.equipos AS el ON el.id = p.equipo_local
LEFT JOIN dbo.equipos AS ev ON ev.id = p.equipo_visitante
ORDER BY v.id;
GO

-- Seguimiento de equipos/ligas/usuarios: mostrar nombres legibles
SELECT s.id, per.nombre_usuario AS seguidor, e.nombre AS equipo_seguido, s.creado_en
FROM dbo.seguimiento_equipos AS s
LEFT JOIN dbo.perfiles AS per ON per.usuario_id = s.usuario_id
LEFT JOIN dbo.equipos AS e ON e.id = s.equipo_id
ORDER BY s.id;

SELECT s.id, per.nombre_usuario AS seguidor, l.nombre AS liga_seguida, s.creado_en
FROM dbo.seguimiento_ligas AS s
LEFT JOIN dbo.perfiles AS per ON per.usuario_id = s.usuario_id
LEFT JOIN dbo.ligas AS l ON l.id = s.liga_id
ORDER BY s.id;

SELECT s.id, per.nombre_usuario AS seguidor, per2.nombre_usuario AS seguido, s.creado_en
FROM dbo.seguimiento_usuarios AS s
LEFT JOIN dbo.perfiles AS per ON per.usuario_id = s.usuario_id
LEFT JOIN dbo.perfiles AS per2 ON per2.usuario_id = s.usuario_seguido
ORDER BY s.id;
GO

-- Recordatorios: mostrar estado legible y partido/usuario legible
SELECT r.id AS recordatorio_id,
       per.nombre_usuario AS usuario,
       ISNULL(el.nombre, '') + ' vs ' + ISNULL(ev.nombre, '') AS partido,
       r.recordar_en,
       CASE r.estado WHEN 0 THEN N'PENDIENTE' WHEN 1 THEN N'ENVIADO' WHEN 2 THEN N'CANCELADO' ELSE N'OTRO' END AS estado_texto,
       r.creado_en
FROM dbo.recordatorios AS r
LEFT JOIN dbo.perfiles AS per ON per.usuario_id = r.usuario_id
LEFT JOIN dbo.partidos AS p ON p.id = r.partido_id
LEFT JOIN dbo.equipos AS el ON el.id = p.equipo_local
LEFT JOIN dbo.equipos AS ev ON ev.id = p.equipo_visitante
ORDER BY r.recordar_en;
GO

-- Partidos destacados: mostrar usuario y partido legible
SELECT pd.id AS destacado_id,
       ISNULL(per.nombre_usuario, N'(anónimo)') AS usuario,
       ISNULL(el.nombre, '') + ' vs ' + ISNULL(ev.nombre, '') AS partido,
       pd.destacado_en,
       pd.nota
FROM dbo.partidos_destacados AS pd
LEFT JOIN dbo.perfiles AS per ON per.usuario_id = pd.usuario_id
LEFT JOIN dbo.partidos AS p ON p.id = pd.partido_id
LEFT JOIN dbo.equipos AS el ON el.id = p.equipo_local
LEFT JOIN dbo.equipos AS ev ON ev.id = p.equipo_visitante
ORDER BY pd.destacado_en;
GO

PRINT N'=================================================';
PRINT N'======= Verificación de Autenticación =========';
PRINT N'=================================================';

-- Caso 1: Login exitoso con contraseña correcta
PRINT N'-> Test 1: Login para tobiager@example.com con contraseña correcta (RiverPlate2018!). Esperado: ok=1.';
EXEC dbo.sp_usuario_login_simple @correo = N'tobiager@example.com', @password = N'RiverPlate2018!';
GO

-- Caso 2: Login fallido con contraseña incorrecta
PRINT N'-> Test 2: Login para tobiager@example.com con contraseña incorrecta. Esperado: ok=0.';
EXEC dbo.sp_usuario_login_simple @correo = N'tobiager@example.com', @password = N'ContrasenaFalsa!';
GO

-- Caso 3: Login exitoso para otro usuario
PRINT N'-> Test 3: Login para ana.ferro@example.com con contraseña correcta (VelezSarsfield!). Esperado: ok=1.';
EXEC dbo.sp_usuario_login_simple @correo = N'ana.ferro@example.com', @password = N'VelezSarsfield!';
GO

-- Caso 4: Cambio de contraseña y nuevo login
PRINT N'-> Test 4: Cambiando contraseña para tobiager (id=1) a "NewRiverPass!"...';
EXEC dbo.sp_usuario_set_password_simple @usuario_id = 1, @password = N'NewRiverPass!';
PRINT N'-> Test 4.1: Re-intentando login con la nueva contraseña. Esperado: ok=1.';
EXEC dbo.sp_usuario_login_simple @correo = N'tobiager@example.com', @password = N'NewRiverPass!';
PRINT N'-> Test 4.2: Intentando login con la contraseña antigua. Esperado: ok=0.';
EXEC dbo.sp_usuario_login_simple @correo = N'tobiager@example.com', @password = N'RiverPlate2018!';
GO