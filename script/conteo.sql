
SELECT 'Usuarios' AS tabla, COUNT(*) AS filas FROM usuarios
UNION ALL
SELECT 'Ligas', COUNT(*) FROM ligas
UNION ALL
SELECT 'Equipos', COUNT(*) FROM equipos
UNION ALL
SELECT 'Partidos', COUNT(*) FROM partidos
UNION ALL
SELECT 'Calificaciones', COUNT(*) FROM calificaciones
UNION ALL
SELECT 'Opiniones', COUNT(*) FROM opiniones
UNION ALL
SELECT 'Favoritos', COUNT(*) FROM favoritos
UNION ALL
SELECT 'Visualizaciones', COUNT(*) FROM visualizaciones
UNION ALL
SELECT 'Seguidos', COUNT(*) FROM seguidos
UNION ALL
SELECT 'Recordatorios', COUNT(*) FROM recordatorios
UNION ALL
SELECT 'Partidos_Destacados', COUNT(*) FROM partidos_destacados;
