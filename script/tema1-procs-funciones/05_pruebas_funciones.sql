-- =================================================================
-- TEMA 1: PROCEDIMIENTOS Y FUNCIONES
-- 05_pruebas_funciones.sql
--
-- Script para probar y demostrar el uso de las funciones
-- escalares creadas.
-- =================================================================
USE tribuneros_bdi;
GO

PRINT '-----------------------------------------------------'
PRINT '--- INICIO: Pruebas de Funciones ---'
PRINT '-----------------------------------------------------'
GO

PRINT '--- 1. Probando dbo.fn_ObtenerNombreUsuario ---';
PRINT 'Muestra las opiniones del partido 1 (River-Boca) con el nombre del autor obtenido desde la función.';

SELECT
    titulo,
    cuerpo,
    dbo.fn_ObtenerNombreUsuario(usuario_id) AS autor
FROM dbo.opiniones
WHERE partido_id = 1;
GO

PRINT ' '
PRINT '--- 2. Probando dbo.fn_CalcularPuntajePromedioPartido ---';
PRINT 'Calcula el puntaje promedio para cada partido registrado.';

SELECT
    p.id,
    eq_local.nombre AS local,
    eq_visit.nombre AS visitante,
    dbo.fn_CalcularPuntajePromedioPartido(p.id) AS puntaje_promedio
FROM dbo.partidos p
JOIN dbo.equipos eq_local ON p.equipo_local = eq_local.id
JOIN dbo.equipos eq_visit ON p.equipo_visitante = eq_visit.id
ORDER BY p.id;
GO

PRINT ' '
PRINT '--- 3. Probando dbo.fn_FormatearResultadoPartido ---';
PRINT 'Muestra el resultado formateado para todos los partidos.';

SELECT
    p.id,
    eq_local.nombre AS local,
    eq_visit.nombre AS visitante,
    dbo.fn_FormatearResultadoPartido(p.id) AS resultado
FROM dbo.partidos p
JOIN dbo.equipos eq_local ON p.equipo_local = eq_local.id
JOIN dbo.equipos eq_visit ON p.equipo_visitante = eq_visit.id
ORDER BY p.id;
GO

PRINT ' '
PRINT '-----------------------------------------------------'
PRINT '--- FIN: Pruebas de Funciones ---'
PRINT '-----------------------------------------------------'
GO