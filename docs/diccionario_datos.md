# Diccionario de datos — Tribuneros 

Este documento describe los objetos del esquema `tribuneros_bdi` implementado en SQL Server.

## Convenciones
- **Tipo**: se usan tipos compatibles (`INT`, `CHAR`, `VARCHAR`, `DATETIME2`, `SMALLINT`).
- **Booleanos**: representados con `BIT` (`0` para falso, `1` para verdadero).
- **PK/FK**: explícitas, con nombres `PK_`, `FK_`.
- **Nulos**: se indica si la columna admite `NULL`.

---

## 1. Gestión de usuarios

### Tabla: `usuarios`
| Columna     | Tipo        | Nulos | Predeterminado    | Restricciones | Descripción |
|-------------|------------|-------|-------------------|---------------|-------------|
| `id`        | `INT` | NO    | —                 | `PK_usuarios` | ID numérico del usuario |
| `correo`    | `VARCHAR(254)` | NO | —                 | `UQ_usuarios_correo` | Correo único |
| `password_hash`| `VARBINARY(64)`| SÍ | —              | —             | Hash de la contraseña (SHA2_512) |
| `creado_en` | `DATETIME2(3)`| NO    | `SYSUTCDATETIME()`| —             | Fecha de alta |

### Tabla: `perfiles`
| Columna        | Tipo         | Nulos | Predeterminado | Restricciones | Descripción |
|----------------|-------------|-------|----------------|---------------|-------------|
| `usuario_id`   | `INT`  | NO    | —              | `PK_perfiles`, `FK_perfiles_usuario` (CASCADE) | Ref a `usuarios` |
| `nombre_usuario` | `VARCHAR(30)` | NO | —              | `UQ_perfiles_usuario` | Alias público |
| `nombre_mostrar` | `NVARCHAR(60)` | SÍ | —              | — | Nombre completo |
| `avatar_url`   | `VARCHAR(400)` | SÍ | —              | — | URL de foto |
| `biografia`    | `NVARCHAR(400)` | SÍ | —              | — | Bio del usuario |
| `creado_en`    | `DATETIME2(3)` | NO   | `SYSUTCDATETIME()`| — | Fecha de creación |
| `actualizado_en`| `DATETIME2(3)` | SÍ  | —              | — | Última actualización |

---

## 2. Catálogos deportivos

### Tabla: `ligas`
| Columna | Tipo          | Nulos | Restricciones | Descripción |
|---------|--------------|-------|---------------|-------------|
| `id`    | `INT`        | NO    | `PK_ligas`    | ID de la liga |
| `nombre`| `NVARCHAR(120)`| NO   | —             | Nombre liga |
| `pais`  | `NVARCHAR(80)`| SÍ    | —             | País |
| `slug`  | `VARCHAR(120)`| SÍ   | `UQ_ligas_slug` | URL amigable |
| `id_externo`| `VARCHAR(80)`| SÍ| —             | Código externo |
| `creado_en`| `DATETIME2(3)`| NO   | `SYSUTCDATETIME()`| Fecha registro |

### Tabla: `equipos`
| Columna | Tipo          | Nulos | Restricciones | Descripción |
|---------|--------------|-------|---------------|-------------|
| `id`    | `INT`        | NO    | `PK_equipos`  | ID manual |
| `nombre`| `VARCHAR(120)`| NO   | —             | Nombre |
| `nombre_corto`|`VARCHAR(50)`| SÍ| —             | Abreviatura |
| `pais`  | `NVARCHAR(80)` | SÍ   | —             | País |
| `escudo_url`|`VARCHAR(400)`| SÍ| —             | Escudo |
| `liga_id` | `INT`       | SÍ   | `FK_equipos_liga` (SET NULL) | Ref liga |
| `id_externo`| `VARCHAR(80)`| SÍ| —             | Código ext |
| `creado_en` | `DATETIME2(3)`| NO | `SYSUTCDATETIME()`| Alta |

---

## 3. Partidos

### Tabla: `partidos`
| Columna | Tipo        | Nulos | Restricciones | Descripción |
|---------|-------------|-------|---------------|-------------|
| `id`    | `INT`       | NO    | `PK_partidos` | ID manual |
| `id_externo`|`VARCHAR(80)`| SÍ| — | Código externo |
| `liga_id`|`INT`       | SÍ   | `FK_partidos_liga` (SET NULL), `IX_partidos_liga` | Ref a `ligas` |
| `temporada`|`SMALLINT`     | SÍ   | —             | Año de la temporada |
| `ronda` | `NVARCHAR(40)`| SÍ  | —             | Ronda del torneo |
| `fecha_utc`|`DATETIME2(0)`| NO  | `IX_partidos_fecha` | Fecha/hora del partido |
| `estado`| `TINYINT`| NO  | `CK_partidos_estado` | 0=prog,1=vivo,2=fin,3=posp,4=canc |
| `estadio`|`NVARCHAR(120)`|SÍ  | — | Estadio |
| `equipo_local`|`INT`  | NO   | `FK_partidos_local` | Local |
| `equipo_visitante`|`INT`|NO  | `FK_partidos_visitante` | Visitante |
| `goles_local`|`TINYINT`   | SÍ   | — | Goles local |
| `goles_visitante`|`TINYINT`|SÍ   | — | Goles visitante |
| `creado_en`|`DATETIME2(3)`|NO   | `SYSUTCDATETIME()`| Alta |
| — | — | — | `CK_partidos_equipos_distintos` | Local ≠ Visitante |

---

## 4. Interacciones de usuarios

### Tabla: `calificaciones`
| Columna | Tipo | Nulos | Restricciones |
|---------|------|-------|---------------|
| `id`    | `INT` | NO | `PK_calificaciones`, `IDENTITY(1,1)` |
| `partido_id` | `INT` | NO | `FK_calif_partido` (CASCADE) |
| `usuario_id` | `INT` | NO | `FK_calif_usuario` (CASCADE), `IX_calif_usuario` |
| `puntaje` | `TINYINT` | NO | `CK_calif_1_5 (1–5)` |
| `creado_en` | `DATETIME2(3)` | NO | `SYSUTCDATETIME()` |
| — | — | — | `UQ_calif (partido_id, usuario_id)` |

### Tabla: `opiniones`
| Columna | Tipo | Nulos | Restricciones |
|---------|------|-------|---------------|
| `id` | `INT` | NO | `PK_opiniones`, `IDENTITY(1,1)` |
| `partido_id` | `INT` | NO | `FK_opiniones_partido` (CASCADE) |
| `usuario_id` | `INT` | NO | `FK_opiniones_usuario` (CASCADE), `IX_opiniones_usuario` |
| `titulo` | `NVARCHAR(120)` | SÍ | — |
| `cuerpo` | `NVARCHAR(2000)` | SÍ | — |
| `publica` | `BIT` | NO | — (0/1) |
| `tiene_spoilers` | `BIT` | NO | — (0/1) |
| `creado_en` | `DATETIME2(3)` | NO | `SYSUTCDATETIME()` |
| `actualizado_en` | `DATETIME2(3)` | SÍ | — |
| — | — | — | `UQ_opiniones (partido_id, usuario_id)` |

### Tabla: `favoritos`
| Columna | Tipo | Nulos | Restricciones |
|---------|------|-------|---------------|
| `id` | `INT` | NO | `PK_favoritos`, `IDENTITY(1,1)` |
| `partido_id` | `INT` | NO | `FK_fav_partido` (CASCADE) |
| `usuario_id` | `INT` | NO | `FK_fav_usuario` (CASCADE), `IX_fav_usuario` |
| `creado_en` | `DATETIME2(3)` | NO | `SYSUTCDATETIME()` |
| — | — | — | `UQ_fav (partido_id, usuario_id)` |

### Tabla: `visualizaciones`
| Columna | Tipo | Nulos | Restricciones |
|---------|------|-------|---------------|
| `id` | `INT` | NO | `PK_visualizaciones`, `IDENTITY(1,1)` |
| `partido_id` | `INT` | NO | `FK_vis_partido` (CASCADE) |
| `usuario_id` | `INT` | NO | `FK_vis_usuario` (CASCADE), `IX_vis_usuario` |
| `medio` | `TINYINT` | NO | `CK_vis_medio` (0=estadio,1=tv,2=streaming,3=repeticion) |
| `visto_en` | `DATETIME2(3)` | NO | — |
| `minutos_vistos` | `TINYINT` | SÍ | `CK_vis_minutos (0–200)` |
| `ubicacion` | `NVARCHAR(120)` | SÍ | — |
| `creado_en` | `DATETIME2(3)` | NO | `SYSUTCDATETIME()` |

---

## 5. Social, curaduría y recordatorios

### Tabla: `seguimiento_equipos`
| Columna | Tipo | Nulos | Restricciones |
|---------|------|-------|---------------|
| `id` | `INT` | NO | `PK_seguimiento_equipos` |
| `usuario_id` | `CHAR(36)` | NO | `FK_seg_equipos_usuario` (CASCADE), `IX_seg_equipos_usuario` |
| `equipo_id` | `INT` | NO | `FK_seg_equipos_equipo` (CASCADE) |
| `creado_en` | `DATETIME2` | NO | — |
| — | — | — | `UQ_seguimiento_equipos (usuario_id, equipo_id)` |

### Tabla: `seguimiento_ligas`
| Columna | Tipo | Nulos | Restricciones |
|---------|------|-------|---------------|
| `id` | `INT` | NO | `PK_seguimiento_ligas` |
| `usuario_id` | `CHAR(36)` | NO | `FK_seg_ligas_usuario` (CASCADE), `IX_seg_ligas_usuario` |
| `liga_id` | `INT` | NO | `FK_seg_ligas_liga` (CASCADE) |
| `creado_en` | `DATETIME2` | NO | — |
| — | — | — | `UQ_seguimiento_ligas (usuario_id, liga_id)` |

### Tabla: `seguimiento_usuarios`
| Columna | Tipo | Nulos | Restricciones |
|---------|------|-------|---------------|
| `id` | `INT` | NO | `PK_seguimiento_usuarios`, `IDENTITY(1,1)` |
| `usuario_id` | `INT` | NO | `FK_seg_usuarios_seguidor` (CASCADE), `IX_seg_usuarios_seguidor` |
| `usuario_seguido` | `INT` | NO | `FK_seg_usuarios_seguido` (NO ACTION) |
| `creado_en` | `DATETIME2(3)` | NO | `SYSUTCDATETIME()` |
| — | — | — | `UQ_seguimiento_usuarios (usuario_id, usuario_seguido)` |
| — | — | — | `CK_seg_usuarios_no_self` (usuario_id ≠ usuario_seguido) |

### Tabla: `partidos_destacados`
| Columna | Tipo | Nulos | Restricciones |
|---------|------|-------|---------------|
| `id` | `INT` | NO | `PK_destacados`, `IDENTITY(1,1)` |
| `usuario_id` | `INT` | SÍ | `FK_destacados_usuario` (SET NULL) |
| `partido_id` | `INT` | NO | `FK_destacados_partido` (CASCADE) |
| `destacado_en` | `DATE` | NO | `CAST(SYSUTCDATETIME() AS DATE)` |
| `nota` | `NVARCHAR(240)` | SÍ | — |

### Tabla: `recordatorios`
| Columna | Tipo | Nulos | Restricciones |
|---------|------|-------|---------------|
| `id` | `INT` | NO | `PK_recordatorios`, `IDENTITY(1,1)` |
| `usuario_id` | `INT` | NO | `FK_recordatorios_usuario` (CASCADE) |
| `partido_id` | `INT` | NO | `FK_recordatorios_partido` (CASCADE) |
| `recordar_en` | `DATETIME2(3)` | NO | `IX_recordatorios_when` |
| `estado` | `TINYINT` | NO | `CK_recordatorios_estado` (0=pendiente,1=enviado,2=cancelado) |
| `creado_en` | `DATETIME2(3)` | NO | `SYSUTCDATETIME()` |

---

## 6. Dependencias y consideraciones generales
- Todas las claves foráneas apuntan a claves primarias definidas explícitamente y contemplan reglas de eliminación (`CASCADE`, `SET NULL`, `NO ACTION`).
- Las restricciones `CHECK` aseguran dominios válidos para estados, medios y rangos numéricos.
- Los índices secundarios (`IX_*`) facilitan consultas frecuentes por usuario, partido y fechas clave.
- El modelo está diseñado y probado para SQL Server. Utiliza `IDENTITY` para claves primarias autoincrementales en tablas transaccionales y `DEFAULT SYSUTCDATETIME()` para timestamps.
- El esquema completo se inicializa mediante `script/creacion.sql` y se complementa con cargas de ejemplo en `script/carga_inicial.sql`.

Este diccionario debe revisarse y actualizarse ante cualquier cambio en la definición de tablas o reglas del negocio para mantener la trazabilidad documental del proyecto.
