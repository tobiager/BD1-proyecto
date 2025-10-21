# Diccionario de datos — Tribuneros 

Este documento describe los objetos del esquema `tribuneros_bdi` implementado en SQL Server usando sintaxis ANSI-friendly, sin `IDENTITY`, sin tipos exclusivos de otros motores.

## Convenciones
- **Tipo**: se usan tipos compatibles (`INT`, `CHAR`, `VARCHAR`, `DATETIME2`, `SMALLINT`).
- **Booleanos**: representados con `SMALLINT` y restricción `CHECK (valor IN (0,1))`.
- **PK/FK**: explícitas, con nombres `PK_`, `FK_`.
- **Nulos**: se indica si la columna admite `NULL`.

---

## 1. Gestión de usuarios

### Tabla: `usuarios`
| Columna     | Tipo        | Nulos | Predeterminado    | Restricciones | Descripción |
|-------------|------------|-------|-------------------|---------------|-------------|
| `id`        | `CHAR(36)` | NO    | —                 | `PK_usuarios` | UUID (formato 36 chars) |
| `correo`    | `VARCHAR(255)` | NO | —                 | `UQ_usuarios_correo` | Correo único |
| `creado_en` | `DATETIME2`| NO    | — (se carga a mano)| —             | Fecha de alta |

### Tabla: `perfiles`
| Columna        | Tipo         | Nulos | Predeterminado | Restricciones | Descripción |
|----------------|-------------|-------|----------------|---------------|-------------|
| `usuario_id`   | `CHAR(36)`  | NO    | —              | `PK_perfiles`, `FK_perfiles_usuario` (CASCADE) | Ref a `usuarios` |
| `nombre_usuario` | `VARCHAR(30)` | NO | —              | `UQ_perfiles_usuario` | Alias público |
| `nombre_mostrar` | `VARCHAR(60)` | SÍ | —              | — | Nombre completo |
| `avatar_url`   | `VARCHAR(400)` | SÍ | —              | — | URL de foto |
| `biografia`    | `VARCHAR(400)` | SÍ | —              | — | Bio del usuario |
| `creado_en`    | `DATETIME2` | NO   | —              | — | Fecha de creación |
| `actualizado_en`| `DATETIME2` | SÍ  | —              | — | Última actualización |

---

## 2. Catálogos deportivos

### Tabla: `ligas`
| Columna | Tipo          | Nulos | Restricciones | Descripción |
|---------|--------------|-------|---------------|-------------|
| `id`    | `INT`        | NO    | `PK_ligas`    | ID manual |
| `nombre`| `VARCHAR(120)`| NO   | —             | Nombre liga |
| `pais`  | `VARCHAR(80)`| SÍ    | —             | País |
| `slug`  | `VARCHAR(120)`| SÍ   | `UQ_ligas_slug` | Slug único |
| `id_externo`| `VARCHAR(80)`| SÍ| —             | Código externo |
| `creado_en`| `DATETIME2`| NO   | —             | Fecha registro |

### Tabla: `equipos`
| Columna | Tipo          | Nulos | Restricciones | Descripción |
|---------|--------------|-------|---------------|-------------|
| `id`    | `INT`        | NO    | `PK_equipos`  | ID manual |
| `nombre`| `VARCHAR(120)`| NO   | —             | Nombre |
| `nombre_corto`|`VARCHAR(50)`| SÍ| —             | Abreviatura |
| `pais`  | `VARCHAR(80)` | SÍ   | —             | País |
| `escudo_url`|`VARCHAR(400)`| SÍ| —             | Escudo |
| `liga_id` | `INT`       | SÍ   | `FK_equipos_liga` (SET NULL) | Ref liga |
| `id_externo`| `VARCHAR(80)`| SÍ| —             | Código ext |
| `creado_en` | `DATETIME2`| NO | —             | Alta |

---

## 3. Partidos

### Tabla: `partidos`
| Columna | Tipo        | Nulos | Restricciones | Descripción |
|---------|-------------|-------|---------------|-------------|
| `id`    | `INT`       | NO    | `PK_partidos` | ID manual |
| `id_externo`|`VARCHAR(80)`| SÍ| — | Código externo |
| `liga_id`|`INT`       | SÍ   | `FK_partidos_liga` (SET NULL), `IX_partidos_liga` | Liga |
| `temporada`|`INT`     | SÍ   | —             | Temporada |
| `ronda` | `VARCHAR(40)`| SÍ  | —             | Ronda |
| `fecha_utc`|`DATETIME2`| NO  | `IX_partidos_fecha` | Fecha/hora |
| `estado`| `VARCHAR(15)`| NO  | `CK_partidos_estado` | programado/en_vivo/finalizado/pospuesto/cancelado |
| `estadio`|`VARCHAR(120)`|SÍ  | — | Estadio |
| `equipo_local`|`INT`  | NO   | `FK_partidos_local` | Local |
| `equipo_visitante`|`INT`|NO  | `FK_partidos_visitante` | Visitante |
| `goles_local`|`INT`   | SÍ   | — | Goles local |
| `goles_visitante`|`INT`|SÍ   | — | Goles visitante |
| `creado_en`|`DATETIME2`|NO   | — | Alta |
| — | — | — | `CK_partidos_equipos_distintos` | Local ≠ Visitante |

---

## 4. Interacciones de usuarios

### Tabla: `calificaciones`
| Columna | Tipo | Nulos | Restricciones |
|---------|------|-------|---------------|
| `id`    | `INT` | NO | `PK_calificaciones` |
| `partido_id` | `INT` | NO | `FK_calif_partido` (CASCADE) |
| `usuario_id` | `CHAR(36)` | NO | `FK_calif_usuario` (CASCADE), `IX_calif_usuario` |
| `puntaje` | `SMALLINT` | NO | `CK_calif_1_5 (1–5)` |
| `creado_en` | `DATETIME2` | NO | — |
| — | — | — | `UQ_calif (partido_id, usuario_id)` |

### Tabla: `opiniones`
| Columna | Tipo | Nulos | Restricciones |
|---------|------|-------|---------------|
| `id` | `INT` | NO | `PK_opiniones` |
| `partido_id` | `INT` | NO | `FK_opiniones_partido` (CASCADE) |
| `usuario_id` | `CHAR(36)` | NO | `FK_opiniones_usuario` (CASCADE), `IX_opiniones_usuario` |
| `titulo` | `VARCHAR(120)` | SÍ | — |
| `cuerpo` | `VARCHAR(4000)` | SÍ | — |
| `publica` | `SMALLINT` | NO | `CK_opiniones_publica (0/1)` |
| `tiene_spoilers` | `SMALLINT` | NO | `CK_opiniones_spoilers (0/1)` |
| `creado_en` | `DATETIME2` | NO | — |
| `actualizado_en` | `DATETIME2` | SÍ | — |
| — | — | — | `UQ_opiniones (partido_id, usuario_id)` |

### Tabla: `favoritos`
| Columna | Tipo | Nulos | Restricciones |
|---------|------|-------|---------------|
| `id` | `INT` | NO | `PK_favoritos` |
| `partido_id` | `INT` | NO | `FK_fav_partido` (CASCADE) |
| `usuario_id` | `CHAR(36)` | NO | `FK_fav_usuario` (CASCADE), `IX_fav_usuario` |
| `creado_en` | `DATETIME2` | NO | — |
| — | — | — | `UQ_fav (partido_id, usuario_id)` |

### Tabla: `visualizaciones`
| Columna | Tipo | Nulos | Restricciones |
|---------|------|-------|---------------|
| `id` | `INT` | NO | `PK_visualizaciones` |
| `partido_id` | `INT` | NO | `FK_vis_partido` (CASCADE) |
| `usuario_id` | `CHAR(36)` | NO | `FK_vis_usuario` (CASCADE), `IX_vis_usuario` |
| `medio` | `VARCHAR(12)` | NO | `CK_vis_medio` (`estadio`,`tv`,`streaming`,`repeticion`) |
| `visto_en` | `DATETIME2` | NO | — |
| `minutos_vistos` | `INT` | SÍ | `CK_vis_minutos (0–200)` |
| `ubicacion` | `VARCHAR(120)` | SÍ | — |
| `creado_en` | `DATETIME2` | NO | — |

---

## 5. Social y curaduría

### Tabla: `seguidos`
| Columna | Tipo | Nulos | Restricciones |
|---------|------|-------|---------------|
| `id` | `INT` | NO | `PK_seguidos` |
| `usuario_id` | `CHAR(36)` | NO | `FK_seguidos_usuario` (CASCADE), `IX_seguidos_usuario` |
| `equipo_id` | `INT` | NO | `FK_seguidos_equipo` (CASCADE) |
| `creado_en` | `DATETIME2` | NO | — |
| — | — | — | `UQ_seguidos (usuario_id, equipo_id)` |

### Tabla: `partidos_destacados`
| Columna | Tipo | Nulos | Restricciones |
|---------|------|-------|---------------|
| `id` | `INT` | NO | `PK_destacados` |
| `usuario_id` | `CHAR(36)` | SÍ | `FK_destacados_usuario` (SET NULL) |
| `partido_id` | `INT` | NO | `FK_destacados_partido` (CASCADE) |
| `destacado_en` | `DATE` | NO | — |
| `nota` | `VARCHAR(240)` | SÍ | — |

### Tabla: `recordatorios`
| Columna | Tipo | Nulos | Restricciones |
|---------|------|-------|---------------|
| `id` | `INT` | NO | `PK_recordatorios` |
| `usuario_id` | `CHAR(36)` | NO | `FK_recordatorios_usuario` (CASCADE) |
| `partido_id` | `INT` | NO | `FK_recordatorios_partido` (CASCADE) |
| `recordar_en` | `DATETIME2` | NO | `IX_recordatorios_when` |
| `estado` | `VARCHAR(12)` | NO | `CK_recordatorios_estado` (`pendiente`,`enviado`,`cancelado`) |
| `creado_en` | `DATETIME2` | NO | — |

---

## 6. Dependencias y consideraciones generales
- Todas las claves foráneas apuntan a claves primarias definidas explícitamente y contemplan reglas de eliminación (`CASCADE`, `SET NULL`, `NO ACTION`).
- Las restricciones `CHECK` aseguran dominios válidos para estados, medios y rangos numéricos.
- Los índices secundarios (`IX_*`) facilitan consultas frecuentes por usuario, partido y fechas clave.
- El modelo fue verificado con los scripts de carga y validación incluidos en la carpeta `script/` empleando PostgreSQL 15 en modo ANSI SQL.
- El esquema completo se inicializa mediante `script/creacion.sql` y se complementa con cargas de ejemplo en `script/carga_inicial.sql`.

Este diccionario debe revisarse y actualizarse ante cualquier cambio en la definición de tablas o reglas del negocio para mantener la trazabilidad documental del proyecto.

---

## 7. Procedimientos Almacenados

### sp_InsertPartido
| Parámetro | Tipo | Descripción | Tabla(s) Afectada(s) |
|-----------|------|-------------|---------------------|
| @id | INT | ID único del partido (requerido) | partidos |
| @id_externo | VARCHAR(80) | Código externo opcional | partidos |
| @liga_id | INT | ID de la liga (opcional, debe existir) | partidos → ligas |
| @temporada | INT | Año de la temporada | partidos |
| @ronda | VARCHAR(40) | Nombre o número de ronda | partidos |
| @fecha_utc | DATETIME2 | Fecha y hora del partido (requerido) | partidos |
| @estado | VARCHAR(15) | Estado del partido: programado, en_vivo, finalizado, pospuesto, cancelado | partidos |
| @estadio | VARCHAR(120) | Nombre del estadio | partidos |
| @equipo_local | INT | ID del equipo local (requerido, debe existir) | partidos → equipos |
| @equipo_visitante | INT | ID del equipo visitante (requerido, debe existir) | partidos → equipos |
| @goles_local | INT | Goles del equipo local (NULL si no finalizado) | partidos |
| @goles_visitante | INT | Goles del equipo visitante (NULL si no finalizado) | partidos |

**Descripción**: Inserta un nuevo partido con validaciones de integridad (equipos diferentes, equipos y liga existentes, estado válido, goles para finalizados). Maneja errores con TRY-CATCH. Retorna 0 si éxito, valores negativos si error.

### sp_UpdatePartido
| Parámetro | Tipo | Descripción | Tabla(s) Afectada(s) |
|-----------|------|-------------|---------------------|
| @id | INT | ID del partido a actualizar (requerido) | partidos |
| @estado | VARCHAR(15) | Nuevo estado (opcional) | partidos |
| @goles_local | INT | Nuevos goles locales (opcional) | partidos |
| @goles_visitante | INT | Nuevos goles visitantes (opcional) | partidos |
| @estadio | VARCHAR(120) | Nuevo estadio (opcional) | partidos |

**Descripción**: Actualiza un partido existente. Valida que el partido existe, estado es válido, goles no negativos, y partidos finalizados tienen ambos goles. Solo actualiza campos no nulos. Retorna 0 si éxito, negativo si error.

### sp_DeletePartido
| Parámetro | Tipo | Descripción | Tabla(s) Afectada(s) |
|-----------|------|-------------|---------------------|
| @id | INT | ID del partido a eliminar (requerido) | partidos (y cascada) |
| @eliminacion_fisica | BIT | 0=lógica (estado=cancelado), 1=física (DELETE) | partidos |

**Descripción**: Elimina un partido de forma lógica (cambia estado a cancelado) o física (DELETE con cascada a calificaciones, opiniones, etc.). Valida existencia del partido. Retorna 0 si éxito, negativo si error.

---

## 8. Funciones Almacenadas

| Nombre | Parámetros | Retorna | Descripción |
|--------|------------|---------|-------------|
| fn_CalcularEdad | @fecha_nacimiento (DATETIME2) | INT | Calcula la edad en años a partir de una fecha de nacimiento, considerando si ya cumplió años en el año actual. |
| fn_ObtenerPromedioCalificaciones | @partido_id (INT) | DECIMAL(3,2) | Calcula el promedio de calificaciones (puntaje 1-5) de un partido específico. Retorna 0.00 si no hay calificaciones. |
| fn_ContarPartidosPorEstado | @estado (VARCHAR(15)) | INT | Cuenta la cantidad de partidos en un estado específico (programado, en_vivo, finalizado, pospuesto, cancelado). Retorna 0 si no hay partidos. |

---

## 9. Índices Adicionales

Además de los índices declarados en el script de creación, se agregan para optimización:

| Nombre | Tipo | Tabla | Columnas Clave | Columnas Incluidas | Descripción |
|--------|------|-------|----------------|-------------------|-------------|
| IX_partidos_fecha | NONCLUSTERED | partidos | fecha_utc | — | Índice existente para búsquedas por fecha |
| IX_partidos_liga | NONCLUSTERED | partidos | liga_id | — | Índice existente para filtrar por liga |
| IX_partidos_fecha_test | NONCLUSTERED | partidos | fecha_utc | — | Índice de prueba simple (filtrado: id >= 1000000) |
| IX_partidos_fecha_incluido_test | NONCLUSTERED | partidos | fecha_utc | id, estado, estadio, goles_local, goles_visitante | Índice covering de prueba (filtrado: id >= 1000000) para eliminar Key Lookups |

**Nota sobre índices de prueba**: Los índices `*_test` son creados como parte de las pruebas de optimización (Cap11) y pueden eliminarse después del análisis. El índice covering demuestra mejoras de 10-20x en consultas por rango de fechas.

---

## 10. Usuarios y Roles

### Usuarios de Base de Datos

| Usuario | Tipo | Login | Rol/Permisos | Descripción |
|---------|------|-------|--------------|-------------|
| Admin_Usuario | SQL User | Admin_Usuario | db_owner | Usuario administrador con control total de la base de datos. Puede SELECT, INSERT, UPDATE, DELETE y EXECUTE todo. |
| LecturaSolo_Usuario | SQL User | LecturaSolo_Usuario | db_datareader + EXECUTE en SPs | Usuario de solo lectura con permiso adicional para ejecutar procedimientos almacenados. Demuestra "ownership chaining". |
| Usuario_ConRol | SQL User | Usuario_ConRol | RolLectura | Usuario con permisos asignados a través del rol personalizado RolLectura. |
| Usuario_SinRol | SQL User | Usuario_SinRol | public (sin permisos adicionales) | Usuario sin permisos específicos, usado para demostrar control de acceso. |

### Roles Personalizados

| Rol | Tipo | Permisos | Miembros | Descripción |
|-----|------|----------|----------|-------------|
| RolLectura | Database Role | SELECT en: partidos, equipos, ligas | Usuario_ConRol | Rol personalizado para lectura de tablas específicas relacionadas con partidos y equipos. No tiene acceso a usuarios, calificaciones u opiniones. |

### Permisos Especiales

- **LecturaSolo_Usuario**: Tiene EXECUTE en sp_InsertPartido, sp_UpdatePartido, sp_DeletePartido
- **Ownership Chaining**: LecturaSolo_Usuario puede insertar/modificar/eliminar partidos mediante procedimientos almacenados aunque no tiene permisos directos sobre la tabla.

---

## 11. Consideraciones de Seguridad y Optimización

### Seguridad (Cap 09)
- Modo de autenticación mixto requerido para usuarios SQL
- Principio de menor privilegio implementado
- Segregación de permisos mediante roles
- Cadena de propiedad (ownership chaining) para control granular

### Optimización (Cap 11)
- Dataset de prueba: 1,000,000+ registros
- Índices covering reducen lecturas lógicas en 80-90%
- Mejora de rendimiento de 10-20x en consultas por rango de fechas
- Índices filtrados para optimizar subconjuntos específicos
- Trade-off: espacio en disco vs velocidad de consultas
