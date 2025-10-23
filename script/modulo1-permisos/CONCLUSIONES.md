# Conclusiones del Módulo 1: Manejo de Permisos en Base de Datos


## 1. Introducción y Metodología de Trabajo

En este módulo, nuestro grupo abordó el diseño e implementación de un modelo de seguridad para la base de datos `tribuneros_bdi`. El objetivo principal fue aplicar el **principio de menor privilegio**, asegurando que cada usuario tuviera únicamente los permisos estrictamente necesarios para realizar sus tareas.

Para lograrlo, trabajamos de forma colaborativa siguiendo un enfoque modular:

1.  **Definición de Casos de Uso:** Identificamos los perfiles de usuario necesarios (administrador, aplicación de solo lectura, etc.).
2.  **Creación de Scripts Secuenciales:** Desarrollamos scripts SQL (`01` a `04`) que construyen progresivamente el modelo de seguridad, facilitando su ejecución y comprensión.
3.  **Validación y Pruebas:** Creamos scripts de prueba (`03` y `04`) que utilizan `EXECUTE AS LOGIN` para simular el comportamiento de cada usuario y verificar que las restricciones de seguridad funcionan como se espera.
4.  **Documentación:** Consolidamos los hallazgos en este documento y en el `README.md` del módulo.

A continuación, se detallan las respuestas a las preguntas clave que guiaron nuestro trabajo.

---

## 2. Análisis Técnico y Respuestas

### ¿Qué permisos otorga `db_datareader`?

El rol fijo de base de datos `db_datareader` otorga permisos de **solo lectura (`SELECT`) sobre todas las tablas y vistas de usuario** dentro de una base de datos específica.

En nuestra implementación, asignamos este rol al usuario `trib_ro`. Como demostramos en el script `03_pruebas_usuarios.sql`, esto le permitió ejecutar consultas `SELECT` con éxito, pero le impidió realizar operaciones de modificación de datos (DML) como `INSERT`, `UPDATE` o `DELETE`. Es un rol ideal para usuarios o aplicaciones que solo necesitan consumir información, como sistemas de reportería o APIs de consulta.

### ¿Por qué `EXECUTE AS OWNER` + `GRANT EXECUTE` permiten DML sin dar permisos directos a tablas?

Esta combinación es la clave del **encapsulamiento de permisos** y es una de las prácticas de seguridad más importantes en SQL Server. Funciona de la siguiente manera:

1.  **`GRANT EXECUTE`**: Al usuario `trib_ro` (a través del rol `app_exec`) solo se le concede el permiso para *ejecutar* el procedimiento almacenado `dbo.sp_calificacion_insertar`. El usuario no tiene ningún permiso sobre la tabla `dbo.calificaciones`.

2.  **`WITH EXECUTE AS OWNER`**: Esta cláusula en la definición del procedimiento almacenado instruye a SQL Server para que, durante la ejecución del SP, cambie temporalmente el contexto de seguridad. En lugar de ejecutar el código con los permisos del usuario que lo llama (`trib_ro`), lo ejecuta con los permisos del **dueño del procedimiento** (en este caso, `dbo`, que es `db_owner`).

El resultado es que un usuario con privilegios muy limitados puede realizar una operación de escritura de forma **controlada, segura y auditable**, ya que solo puede hacerlo a través de la lógica definida en el procedimiento. Una vez que el SP finaliza, los permisos del usuario vuelven a ser los originales.

### Ventajas de encapsular DML en Stored Procedures

Basado en lo anterior, las ventajas de esta técnica son significativas:

- **Seguridad (Principio de Menor Privilegio):** Los usuarios no necesitan permisos directos sobre las tablas. Esto reduce drásticamente la superficie de ataque, ya que no pueden realizar operaciones DML arbitrarias.
- **Abstracción de la Lógica de Negocio:** La lógica para insertar, actualizar o eliminar datos (validaciones, generación de IDs, auditoría) está centralizada en el SP. Si la lógica cambia, solo se modifica el SP, sin necesidad de cambiar los permisos de los usuarios o el código de la aplicación.
- **Rendimiento:** Los procedimientos almacenados tienen planes de ejecución cacheados, lo que generalmente resulta en un mejor rendimiento que las consultas SQL ad-hoc enviadas desde una aplicación.
- **Prevención de Inyección SQL:** Al usar parámetros, los SPs son inherentemente más seguros contra ataques de inyección SQL en comparación con la construcción de consultas dinámicas en la capa de aplicación.

### ¿Cuándo conviene usar un rol personalizado vs. roles fijos del sistema?

La elección depende del nivel de granularidad que se necesite:

- **Roles Fijos del Sistema (`db_datareader`, `db_owner`):** Son convenientes para escenarios "todo o nada". Por ejemplo, si un usuario necesita leer **todas** las tablas de la base de datos, `db_datareader` es perfecto. Son rápidos de asignar y su comportamiento es bien conocido.

- **Roles Personalizados (`rol_lectura_ligas`):** Son indispensables cuando se requiere un **control de acceso granular y específico**. En nuestro proyecto, creamos `rol_lectura_ligas` para permitir que el usuario `trib_a` pudiera leer *únicamente* la tabla `dbo.ligas` y ninguna otra. Esto sería imposible de lograr con `db_datareader`.

**En resumen:** se deben usar roles personalizados siempre que el principio de menor privilegio exija restringir el acceso a un subconjunto específico de objetos (tablas, vistas, SPs) en lugar de a toda la base de datos.

---

## 3. Conclusión General

El trabajo realizado en este módulo nos permitió validar un modelo de seguridad robusto y escalable. Hemos demostrado que es posible otorgar acceso funcional a los usuarios sin comprometer la seguridad de los datos, utilizando una combinación de roles fijos, roles personalizados y la encapsulación de lógica en procedimientos almacenados.

Estas técnicas no son solo un ejercicio académico; son la base para construir aplicaciones seguras y mantenibles en el mundo real. La implementación en el proyecto **Tribuneros** asegura que la capa de datos esté protegida desde su diseño inicial.