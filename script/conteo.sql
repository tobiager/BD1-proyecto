
SELECT N'Usuarios' AS tabla, COUNT(*) AS filas FROM usuarios
UNION ALL
SELECT N'Ligas', COUNT(*) FROM ligas
UNION ALL
SELECT N'Equipos', COUNT(*) FROM equipos
UNION ALL
SELECT N'Partidos', COUNT(*) FROM partidos
UNION ALL
SELECT N'Calificaciones', COUNT(*) FROM calificaciones
UNION ALL
SELECT N'Opiniones', COUNT(*) FROM opiniones
UNION ALL
SELECT N'Favoritos', COUNT(*) FROM favoritos
UNION ALL
SELECT N'Visualizaciones', COUNT(*) FROM visualizaciones
UNION ALL
SELECT N'Seguimiento_Equipos', COUNT(*) FROM seguimiento_equipos
UNION ALL
SELECT N'Seguimiento_Ligas', COUNT(*) FROM seguimiento_ligas
UNION ALL
SELECT N'Seguimiento_Usuarios', COUNT(*) FROM seguimiento_usuarios
UNION ALL
SELECT N'Recordatorios', COUNT(*) FROM recordatorios
UNION ALL
SELECT N'Partidos_Destacados', COUNT(*) FROM partidos_destacados;