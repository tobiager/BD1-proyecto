# Capítulo I — Introducción

## Tema y contexto
**Tribuneros** es una red social del fútbol orientada a que las personas aficionadas puedan **registrar, puntuar y comentar** los partidos que ven. El proyecto propone el diseño e implementación de un **modelo de datos relacional** que sirva de base para futuras aplicaciones web y móviles centradas en la experiencia pospartido.

El trabajo se enmarca en la asignatura Bases de Datos I (FaCENA–UNNE) y se desarrolla bajo una modalidad iterativa que combina investigación, diseño conceptual y validación técnica mediante scripts en ANSI SQL. La documentación se organiza en capítulos para reflejar el recorrido académico solicitado por la cátedra.

## Definición del problema
En la actualidad los hinchas gestionan su historial futbolero de forma dispersa (aplicaciones de resultados, redes sociales generalistas y notas personales). Esto dificulta:

- Consolidar estadísticas personales y comparativas.
- Compartir opiniones con control de *spoilers* y privacidad.
- Recibir recordatorios y recomendaciones personalizadas.
- Identificar partidos destacados curados por la comunidad.

Tribuneros busca unificar estas necesidades en una plataforma que capture la trazabilidad completa de las interacciones con cada partido, desde la visualización hasta la publicación de reseñas. Este requerimiento se traduce en el modelado de entidades, relaciones y reglas de negocio que garanticen integridad y escalabilidad.

## Objetivos
### Objetivo general
Diseñar, documentar e implementar el modelo de datos de Tribuneros en SQL Server, asegurando coherencia con los requisitos funcionales de la plataforma social propuesta.

### Objetivos específicos
- Identificar actores, eventos y catálogos propios del dominio futbolero.
- Elaborar un esquema relacional normalizado con claves y restricciones explícitas.
- Implementar la base mediante scripts [`script/creacion.sql`](../script/creacion.sql) y poblarla con datos representativos desde [`script/carga_inicial.sql`](../script/carga_inicial.sql).
- Registrar la lógica de validación y métricas básicas en [`script/verificacion.sql`](../script/verificacion.sql) y [`script/conteo.sql`](../script/conteo.sql).
- Documentar decisiones de diseño, terminología y procesos para facilitar revisiones académicas.

## Alcances y limitaciones
- **Alcance funcional**: se cubren usuarios, perfiles, partidos, ligas, equipos, interacciones (visualizaciones, calificaciones, opiniones), curaduría de destacados, favoritos, seguimientos y recordatorios.
- **Alcance técnico**: la implementación apunta a SQL Server 2019+ utilizando T-SQL. Se contemplan claves primarias, foráneas, restricciones `CHECK` y valores predeterminados.
- **Fuera de alcance**: algoritmos de recomendación avanzados, integración con APIs externas y análisis estadístico profundo quedan como trabajo futuro.
- **Suposiciones**: los datos de ejemplo son ilustrativos y pueden ampliarse en iteraciones posteriores; la autenticación y la gestión de multimedia se delegan a capas superiores de la aplicación.


---

|  Anterior | Siguiente  |
| --- | --- |
| [Índice del proyecto](indice.md) | [Capítulo II — Marco conceptual](capitulo-2-marco-conceptual.md) |
