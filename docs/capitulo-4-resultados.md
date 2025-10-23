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

|  Anterior | Siguiente  |
| --- | --- |
| [Capítulo III — Metodología](capitulo-3-metodologia.md) | [Capítulo V — Conclusiones](capitulo-5-conclusiones.md) |
