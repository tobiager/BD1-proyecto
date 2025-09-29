SELECT 'Usuarios' AS tabla, COUNT(*) AS filas FROM dbo.users
UNION ALL
SELECT 'Ligas', COUNT(*) FROM dbo.leagues
UNION ALL
SELECT 'Equipos', COUNT(*) FROM dbo.teams
UNION ALL
SELECT 'Partidos', COUNT(*) FROM dbo.matches
UNION ALL
SELECT 'Ratings', COUNT(*) FROM dbo.match_ratings
UNION ALL
SELECT 'Opiniones', COUNT(*) FROM dbo.match_opinions
UNION ALL
SELECT 'Favoritos', COUNT(*) FROM dbo.favorites
UNION ALL
SELECT 'Vistas', COUNT(*) FROM dbo.views
UNION ALL
SELECT 'Follow Teams', COUNT(*) FROM dbo.follow_teams
UNION ALL
SELECT 'Reminders', COUNT(*) FROM dbo.reminders
UNION ALL
SELECT 'Featured', COUNT(*) FROM dbo.featured_matches;
