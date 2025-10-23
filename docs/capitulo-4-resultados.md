# Capítulo IV — Resultados

## Modelo de datos consolidado

El modelo consolidado cubre el ciclo completo de interacción en Tribuneros: identificación de usuarios y perfiles, catalogación de ligas/equipos, programación y registro de partidos, acciones sociales (calificaciones, opiniones, favoritos, seguimientos) y mecanismos de curaduría y recordatorios. El diagrama entidad-relación actualizado se encuentra en `assets/der-tribuneros.png` y sintetiza las cardinalidades y claves primarias/foráneas definidas.

## Esquema relacional y DDL

El script [`script/creacion.sql`](../script/creacion.sql) materializa el modelo lógico en SQL Server. Entre los puntos más relevantes se destacan:

- Declaración explícita de claves primarias (`PK_*`) y foráneas con reglas de eliminación (`ON DELETE`).
- Inclusión de la columna `password_hash` en la tabla `usuarios` para el almacenamiento seguro de contraseñas.
- Restricciones de dominio (`CHECK`) para estados de partidos (`estado`), medios de visualización (`medio`), rangos de puntaje y estados de recordatorios.
- Índices de apoyo (`IX_*`) para optimizar consultas por usuario, partido y fechas clave.
- Valores predeterminados de fechas mediante `CURRENT_TIMESTAMP` para trazabilidad temporal.
- Implementación de procedimientos almacenados (`sp_usuario_set_password_simple`, `sp_usuario_login_simple`) para la gestión de autenticación.

La ejecución del script crea la base `tribuneros_bdi` y garantiza un estado limpio al reiniciar el entorno (drop condicional de tablas).

## Modelo de seguridad y permisos (Módulo 1)

Se ha implementado un **modelo de permisos granular** basado en el principio de menor privilegio, utilizando una combinación de roles fijos del sistema, roles personalizados y procedimientos almacenados con `EXECUTE AS OWNER`.

### Arquitectura de seguridad implementada

La estructura de seguridad se encuentra documentada en el directorio `script/modulo1-permisos/` con los siguientes componentes:

1. **`01_logins_y_usuarios.sql`**: Creación de logins a nivel de servidor con contraseñas seguras.
2. **`02_sp_insert_y_permisos_execute.sql`**: Mapeo de logins a usuarios de base de datos y asignación de roles (tanto fijos como personalizados).
3. **`03_pruebas_usuarios.sql`**: Batería de pruebas utilizando `EXECUTE AS LOGIN` para validar los permisos otorgados.
4. **`04_roles_lectura_por_tabla.sql`**: Implementación de un procedimiento almacenado con `EXECUTE AS OWNER` para permitir DML controlado sin permisos directos sobre tablas.

### Perfiles de usuario implementados

| Perfil | Login | Roles asignados | Permisos |
|--------|-------|-----------------|----------|
| **Administrador** | `trib_admin` | `db_owner` | Control total sobre la base de datos |
| **Solo Lectura** | `trib_ro` | `db_datareader`, `app_exec` | `SELECT` en todas las tablas + ejecución de SPs específicos |
| **Acceso Granular** | `trib_a` | `rol_lectura_ligas` (personalizado) | `SELECT` únicamente en `dbo.ligas` |

### Resultados de las pruebas de seguridad

Las pruebas realizadas en `03_pruebas_usuarios.sql` validaron exitosamente:

✅ **Lectura controlada**: `trib_ro` puede ejecutar `SELECT` en todas las tablas pero no puede realizar `INSERT`, `UPDATE` o `DELETE`.

✅ **Escritura encapsulada**: `trib_ro` puede insertar calificaciones únicamente a través del procedimiento almacenado `dbo.sp_calificacion_insertar`, sin tener permisos directos sobre `dbo.calificaciones`.

✅ **Acceso granular**: `trib_a` solo puede leer la tabla `dbo.ligas` y recibe errores de permiso al intentar acceder a otras tablas.

✅ **Separación de privilegios**: Cada usuario opera dentro de su contexto de seguridad sin posibilidad de escalar privilegios.

### Hallazgos clave del Módulo 1

- **Encapsulamiento efectivo**: La técnica `EXECUTE AS OWNER` demostró ser eficaz para permitir operaciones DML controladas sin comprometer la seguridad.
- **Granularidad flexible**: Los roles personalizados permiten implementar políticas de acceso muy específicas, imposibles de lograr solo con roles fijos del sistema.
- **Audibilidad**: El uso de procedimientos almacenados centraliza las operaciones críticas, facilitando el registro de auditoría y el control de cambios.
- **Escalabilidad**: El modelo de roles facilita la incorporación de nuevos perfiles de usuario sin modificar la estructura de tablas ni permisos existentes.

La documentación técnica completa, incluyendo el análisis de cada decisión de diseño y las respuestas a las preguntas guía del módulo, se encuentra en [`docs/modulo1-permisos.md`](modulo1-permisos.md).

## Carga representativa y consultas

- **Datos de ejemplo**: `script/carga_inicial.sql` inserta usuarios con contraseñas iniciales, ligas, equipos y un partido emblemático (River vs Boca), junto con interacciones asociadas (visualización, calificación, opinión, favorito y recordatorio).
- **Validación operativa**: [`script/verificacion.sql`](../script/verificacion.sql) ofrece consultas para comprobar integridad referencial (joins entre partidos y equipos, conteo de calificaciones/opiniones) y escenarios de negocio (partidos destacados vigentes).
- **Métricas rápidas**: [`script/conteo.sql`](../script/conteo.sql) resume cantidades por entidad para monitorear la carga.

Estos artefactos permiten reproducir la evidencia de funcionamiento y sirven de base para ensayos adicionales.

## Documentación complementaria

- **Diccionario de datos**: el detalle por tabla, campo y restricción se encuentra en [`docs/diccionario_datos.md`](diccionario_datos.md).
- **Guía de ejecución**: el [README](../README.md#cómo-ejecutar-los-scripts) explica el procedimiento recomendado para correr los scripts en SQL Server Management Studio o `sqlcmd`.
- **Material visual**: recursos gráficos en `assets/` (banner, badge e imagen DER) acompañan presentaciones y entregas.

---

| Anterior | Siguiente |
| --- | --- |
| [Capítulo III — Metodología](capitulo-3-metodologia.md) | [Capítulo V — Conclusiones](capitulo-5-conclusiones.md) |