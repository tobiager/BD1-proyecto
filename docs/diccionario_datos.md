# Diccionario de datos completo — Tribuneros

Este documento describe en detalle los objetos del esquema `dbo` implementado para la plataforma Tribuneros en SQL Server. Se especifican los campos, tipos de datos, restricciones y propósito funcional de cada tabla con el fin de facilitar la comprensión, el mantenimiento y la evolución del modelo.

## Convenciones
- **Tipo**: se expresa utilizando la sintaxis de SQL Server.
- **Nulos**: se indica si la columna admite valores `NULL`.
- **Predeterminado**: valor asignado automáticamente cuando no se proporciona un dato.
- **Restricciones y reglas**: incluye claves, restricciones `CHECK`, `UNIQUE`, índices y referencias a otras tablas.

---

## 1. Gestión de usuarios

### Tabla: `usuarios`
| Columna | Tipo | Nulos | Predeterminado | Restricciones y reglas | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `UNIQUEIDENTIFIER` | NO | — | `PK_usuarios` | Identificador global del usuario; se genera en la capa de aplicación (`NEWID()`). |
| `correo` | `NVARCHAR(255)` | NO | — | `UQ_usuarios_correo` | Correo electrónico utilizado como credencial única de acceso. |
| `creado_en` | `DATETIME2` | NO | `SYSUTCDATETIME()` | `DF_usuarios_creado` | Marca temporal de alta en UTC para auditoría. |

### Tabla: `perfiles`
| Columna | Tipo | Nulos | Predeterminado | Restricciones y reglas | Descripción |
| --- | --- | --- | --- | --- | --- |
| `usuario_id` | `UNIQUEIDENTIFIER` | NO | — | `PK_perfiles`, `FK_perfiles_usuario` (ON DELETE CASCADE) | Identificador del usuario dueño del perfil; coincide 1:1 con `usuarios.id`. |
| `nombre_usuario` | `NVARCHAR(30)` | NO | — | `UQ_perfiles_usuario` | Alias público y único en la red social. |
| `nombre_mostrar` | `NVARCHAR(60)` | SÍ | — | — | Nombre visible en la interfaz. |
| `avatar_url` | `NVARCHAR(400)` | SÍ | — | — | URL de la imagen de perfil. |
| `biografia` | `NVARCHAR(400)` | SÍ | — | — | Breve descripción personal del usuario. |
| `creado_en` | `DATETIME2` | NO | `SYSUTCDATETIME()` | `DF_perfiles_creado` | Fecha y hora de creación del perfil. |
| `actualizado_en` | `DATETIME2` | SÍ | — | — | Última actualización del perfil. |

---

## 2. Catálogos deportivos

### Tabla: `ligas`
| Columna | Tipo | Nulos | Predeterminado | Restricciones y reglas | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT IDENTITY(1,1)` | NO | — | `PK_ligas` | Identificador interno de la liga. |
| `nombre` | `NVARCHAR(120)` | NO | — | — | Nombre oficial de la liga o competición. |
| `pais` | `NVARCHAR(80)` | SÍ | — | — | País donde se disputa la liga. |
| `slug` | `NVARCHAR(120)` | SÍ | — | `UQ_ligas_slug` | Identificador legible y único para URLs o integraciones. |
| `id_externo` | `NVARCHAR(80)` | SÍ | — | — | Código de referencia en servicios externos. |
| `creado_en` | `DATETIME2` | NO | `SYSUTCDATETIME()` | `DF_ligas_creado` | Marca temporal de registro de la liga. |

### Tabla: `equipos`
| Columna | Tipo | Nulos | Predeterminado | Restricciones y reglas | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT IDENTITY(1,1)` | NO | — | `PK_equipos` | Identificador interno del equipo. |
| `nombre` | `NVARCHAR(120)` | NO | — | — | Nombre completo del club. |
| `nombre_corto` | `NVARCHAR(50)` | SÍ | — | — | Abreviatura para listados y marcadores. |
| `pais` | `NVARCHAR(80)` | SÍ | — | — | País de origen del equipo. |
| `escudo_url` | `NVARCHAR(400)` | SÍ | — | — | Ruta o URL del escudo institucional. |
| `liga_id` | `BIGINT` | SÍ | — | `FK_equipos_liga` (ON DELETE SET NULL) | Liga en la que compite; se vacía si la liga se elimina. |
| `id_externo` | `NVARCHAR(80)` | SÍ | — | — | Código de referencia en proveedores externos. |
| `creado_en` | `DATETIME2` | NO | `SYSUTCDATETIME()` | `DF_equipos_creado` | Fecha de incorporación del equipo al catálogo. |

---

## 3. Gestión de partidos

### Tabla: `partidos`
| Columna | Tipo | Nulos | Predeterminado | Restricciones y reglas | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT IDENTITY(1,1)` | NO | — | `PK_partidos` | Identificador del partido. |
| `id_externo` | `NVARCHAR(80)` | SÍ | — | — | Código de sincronización con APIs deportivas. |
| `liga_id` | `BIGINT` | SÍ | — | `FK_partidos_liga` (ON DELETE SET NULL), índice `IX_partidos_liga` | Liga asociada al partido. |
| `temporada` | `INT` | SÍ | — | — | Año o temporada deportiva. |
| `ronda` | `NVARCHAR(40)` | SÍ | — | — | Jornada, fecha o etapa del torneo. |
| `fecha_utc` | `DATETIME2` | NO | — | Índice `IX_partidos_fecha` | Fecha y hora programada en UTC. |
| `estado` | `NVARCHAR(15)` | NO | — | `CK_partidos_estado` | Estado del partido (`programado`, `en_vivo`, `finalizado`, `pospuesto`, `cancelado`). |
| `estadio` | `NVARCHAR(120)` | SÍ | — | — | Estadio o sede del encuentro. |
| `equipo_local` | `BIGINT` | NO | — | `FK_partidos_local` | Equipo que actúa como local. |
| `equipo_visitante` | `BIGINT` | NO | — | `FK_partidos_visitante` | Equipo visitante. |
| `goles_local` | `INT` | SÍ | — | — | Goles convertidos por el equipo local. |
| `goles_visitante` | `INT` | SÍ | — | — | Goles convertidos por el equipo visitante. |
| `creado_en` | `DATETIME2` | NO | `SYSUTCDATETIME()` | `DF_partidos_creado`, `CK_partidos_equipos_distintos` | Fecha de registro y control de que los equipos sean distintos. |

---

## 4. Interacciones de usuarios

### Tabla: `calificaciones`
| Columna | Tipo | Nulos | Predeterminado | Restricciones y reglas | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT IDENTITY(1,1)` | NO | — | `PK_calificaciones` | Identificador de la calificación. |
| `partido_id` | `BIGINT` | NO | — | `FK_calif_partido` (ON DELETE CASCADE) | Partido evaluado. |
| `usuario_id` | `UNIQUEIDENTIFIER` | NO | — | `FK_calif_usuario` (ON DELETE CASCADE), índice `IX_calif_usuario` | Usuario que realiza la calificación. |
| `puntaje` | `TINYINT` | NO | — | `CK_calif_1_5` | Valoración numérica entre 1 y 5 puntos. |
| `creado_en` | `DATETIME2` | NO | `SYSUTCDATETIME()` | `DF_calif_creado`, `UQ_calif (partido_id, usuario_id)` | Fecha de registro; evita calificaciones duplicadas por usuario y partido. |

### Tabla: `opiniones`
| Columna | Tipo | Nulos | Predeterminado | Restricciones y reglas | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT IDENTITY(1,1)` | NO | — | `PK_opiniones` | Identificador de la opinión o reseña. |
| `partido_id` | `BIGINT` | NO | — | `FK_opiniones_partido` (ON DELETE CASCADE) | Partido sobre el que se escribe la reseña. |
| `usuario_id` | `UNIQUEIDENTIFIER` | NO | — | `FK_opiniones_usuario` (ON DELETE CASCADE), índice `IX_opiniones_usuario` | Autor de la reseña. |
| `titulo` | `NVARCHAR(120)` | SÍ | — | — | Encabezado corto de la reseña. |
| `cuerpo` | `NVARCHAR(MAX)` | SÍ | — | — | Texto completo de la opinión. |
| `publica` | `BIT` | NO | `1` | `DF_opiniones_publica` | Indica si la reseña es pública (`1`) o privada (`0`). |
| `tiene_spoilers` | `BIT` | NO | `0` | `DF_opiniones_spoilers` | Marca si el contenido contiene spoilers. |
| `creado_en` | `DATETIME2` | NO | `SYSUTCDATETIME()` | `DF_opiniones_creado` | Fecha de publicación. |
| `actualizado_en` | `DATETIME2` | SÍ | — | — | Última modificación de la reseña. |
| — | — | — | — | `UQ_opiniones (partido_id, usuario_id)` | Evita más de una reseña por usuario y partido. |

### Tabla: `favoritos`
| Columna | Tipo | Nulos | Predeterminado | Restricciones y reglas | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT IDENTITY(1,1)` | NO | — | `PK_favoritos` | Identificador del marcador de favorito. |
| `partido_id` | `BIGINT` | NO | — | `FK_fav_partido` (ON DELETE CASCADE) | Partido marcado como favorito. |
| `usuario_id` | `UNIQUEIDENTIFIER` | NO | — | `FK_fav_usuario` (ON DELETE CASCADE), índice `IX_fav_usuario` | Usuario que marca el favorito. |
| `creado_en` | `DATETIME2` | NO | `SYSUTCDATETIME()` | `DF_fav_creado`, `UQ_fav (partido_id, usuario_id)` | Fecha de registro y unicidad por usuario y partido. |

### Tabla: `visualizaciones`
| Columna | Tipo | Nulos | Predeterminado | Restricciones y reglas | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT IDENTITY(1,1)` | NO | — | `PK_visualizaciones` | Identificador del registro de visualización. |
| `partido_id` | `BIGINT` | NO | — | `FK_vis_partido` (ON DELETE CASCADE) | Partido que se vio. |
| `usuario_id` | `UNIQUEIDENTIFIER` | NO | — | `FK_vis_usuario` (ON DELETE CASCADE), índice `IX_vis_usuario` | Usuario que registró la visualización. |
| `medio` | `NVARCHAR(12)` | NO | — | `CK_vis_medio` | Medio de consumo (`estadio`, `tv`, `streaming`, `repetición`). |
| `visto_en` | `DATETIME2` | NO | — | — | Fecha y hora en que se vio el partido. |
| `minutos_vistos` | `INT` | SÍ | — | `CK_vis_minutos` | Minutos efectivamente vistos (0 a 200). |
| `ubicacion` | `NVARCHAR(120)` | SÍ | — | — | Ubicación libre (ciudad, país o contexto). |
| `creado_en` | `DATETIME2` | NO | `SYSUTCDATETIME()` | `DF_vis_creado` | Marca temporal de registro. |

---

## 5. Participación social y curaduría

### Tabla: `seguidos`
| Columna | Tipo | Nulos | Predeterminado | Restricciones y reglas | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT IDENTITY(1,1)` | NO | — | `PK_seguidos` | Identificador del seguimiento. |
| `usuario_id` | `UNIQUEIDENTIFIER` | NO | — | `FK_seguidos_usuario` (ON DELETE CASCADE), índice `IX_seguidos_usuario` | Usuario que sigue al equipo. |
| `equipo_id` | `BIGINT` | NO | — | `FK_seguidos_equipo` (ON DELETE CASCADE) | Equipo seguido. |
| `creado_en` | `DATETIME2` | NO | `SYSUTCDATETIME()` | `DF_seguidos_creado`, `UQ_seguidos (usuario_id, equipo_id)` | Fecha de alta y unicidad del vínculo. |

### Tabla: `partidos_destacados`
| Columna | Tipo | Nulos | Predeterminado | Restricciones y reglas | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT IDENTITY(1,1)` | NO | — | `PK_destacados` | Identificador del registro destacado. |
| `usuario_id` | `UNIQUEIDENTIFIER` | SÍ | — | `FK_destacados_usuario` (ON DELETE SET NULL) | Usuario curator que selecciona el partido; puede ser `NULL` si se elimina. |
| `partido_id` | `BIGINT` | NO | — | `FK_destacados_partido` (ON DELETE CASCADE) | Partido destacado. |
| `destacado_en` | `DATE` | NO | — | — | Fecha en la que el partido fue destacado. |
| `nota` | `NVARCHAR(240)` | SÍ | — | — | Comentario o motivo del destacado. |

### Tabla: `recordatorios`
| Columna | Tipo | Nulos | Predeterminado | Restricciones y reglas | Descripción |
| --- | --- | --- | --- | --- | --- |
| `id` | `BIGINT IDENTITY(1,1)` | NO | — | `PK_recordatorios` | Identificador del recordatorio programado. |
| `usuario_id` | `UNIQUEIDENTIFIER` | NO | — | `FK_recordatorios_usuario` (ON DELETE CASCADE) | Usuario que programa la alerta. |
| `partido_id` | `BIGINT` | NO | — | `FK_recordatorios_partido` (ON DELETE CASCADE) | Partido asociado al recordatorio. |
| `recordar_en` | `DATETIME2` | NO | — | Índice `IX_recordatorios` | Fecha y hora en que se debe enviar la notificación. |
| `estado` | `NVARCHAR(12)` | NO | — | `CK_recordatorios_estado` | Estado operativo (`pendiente`, `enviado`, `cancelado`). |
| `creado_en` | `DATETIME2` | NO | `SYSUTCDATETIME()` | `DF_recordatorios_creado` | Fecha de creación del recordatorio. |

---

## 6. Dependencias y consideraciones generales
- Todas las claves foráneas se declaran con acciones `ON DELETE` que preservan la integridad referencial acorde al proceso de negocio: las interacciones se eliminan si desaparece el partido o usuario, mientras que catálogos se desacoplan estableciendo `NULL` donde corresponde.
- Las columnas de auditoría (`creado_en`, `actualizado_en`) utilizan `SYSUTCDATETIME()` para favorecer operaciones en múltiples zonas horarias.
- Se incluyen índices auxiliares en columnas de búsqueda frecuente (`usuario_id`, `recordar_en`, `fecha_utc`) para optimizar consultas analíticas y operativas.
- El esquema completo se inicializa mediante `script/creacion.sql` y se complementa con cargas de ejemplo en `script/carga_inicial.sql`.

Este diccionario debe revisarse y actualizarse ante cualquier cambio en la definición de tablas o reglas del negocio para mantener la trazabilidad documental del proyecto.
