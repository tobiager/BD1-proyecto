# Módulo 1 — Manejo de Permisos a Nivel de Usuarios de Base de Datos

**Base:** `tribuneros_bdi` (SQL Server)  
**Objetivos de Aprendizaje:**
- Comprender el manejo de permisos y roles en SQL Server.
- Aplicar permisos de lectura, escritura y ejecución para diferentes usuarios y roles.
- Implementar una capa de seguridad usando procedimientos almacenados para encapsular la lógica de negocio.

---

## Contenidos de esta carpeta
- `01_logins_y_usuarios.sql` — Crea logins/usuarios: `trib_admin` (db_owner) y `trib_ro` (db_datareader).
- `02_sp_insert_y_permisos_execute.sql` — Crea `dbo.sp_calificacion_insertar` y da **EXECUTE** a `trib_ro` vía rol `app_exec`.
- `03_pruebas_usuarios.sql` — Pruebas: `trib_ro` **no** puede `INSERT` directo, **sí** puede insertar vía SP.
- `04_roles_lectura_por_tabla.sql` — Crea `rol_lectura_ligas` (solo `SELECT` en `dbo.ligas`) y usuarios `trib_a`/`trib_b` para probar.
- `99_cleanup_demo.sql` *(opcional)* — Limpia objetos/usuarios de la demo.

> **Prerequisitos:** Ejecutar con un login con permisos de **sysadmin**; la BD `tribuneros_bdi` debe existir con tablas pobladas mínimamente (`ligas`, `partidos`, `usuarios`, `calificaciones`).
> Para las pruebas de login, la instancia de SQL Server debe estar configurada en **Modo de Autenticación Mixto** (SQL Server y Windows).

---

## Cómo ejecutar (paso a paso)
1. **Usuarios (admin y solo lectura)**  
   Ejecutar `01_logins_y_usuarios.sql`.  
   - `trib_admin` obtiene `db_owner`.  
   - `trib_ro` obtiene `db_datareader` (solo lectura).

2. **Procedimiento y permisos de ejecución**  
   Ejecutar `02_sp_insert_y_permisos_execute.sql`.  
   - Se crea `dbo.sp_calificacion_insertar` con `EXECUTE AS OWNER`.  
   - Se crea rol `app_exec` y se otorga `EXECUTE` al SP; `trib_ro` entra al rol.

3. **Pruebas de usuarios**  
   Ejecutar `03_pruebas_usuarios.sql`.  
   Guardar capturas de:
   - `SELECT` exitoso con `trib_ro`.  
   - **Error** al `INSERT` directo con `trib_ro` (“permission denied”).  
   - `INSERT` **exitoso vía SP** con `trib_ro`.  
   - `SELECT TOP` final mostrando las filas insertadas.

4. **Roles del DBMS por tabla**  
   Ejecutar `04_roles_lectura_por_tabla.sql`.  
   Guardar capturas de:
   - `trib_a` **leyendo** `dbo.ligas` (OK).
   - `trib_b` **fallando** al leer `dbo.ligas`.

5. *(Opcional)* **Limpieza**  
   Si necesitás volver el entorno atrás, correr `99_cleanup_demo.sql`.

---

## Qué se demuestra
- Un usuario de **solo lectura** (`db_datareader`) **no** puede ejecutar operaciones de modificación de datos (DML) directamente.  
- Con **procedimientos almacenados** (`EXECUTE AS OWNER`) y el permiso **EXECUTE**, un usuario puede realizar operaciones controladas (como `INSERT`) **sin** necesidad de tener permisos directos sobre las tablas subyacentes. Esto se conoce como "encapsulamiento de permisos".
- Los **roles personalizados** permiten un control de acceso granular, restringiendo permisos a **tablas específicas** (ej: `rol_lectura_ligas` solo puede hacer `SELECT` en `dbo.ligas`).

---

## Criterios de Evaluación (cómo lo cumplimos)
- **Precisión en la configuración de permisos y roles**  
  Roles de sistema (`db_owner`, `db_datareader`) + rol personalizado `rol_lectura_ligas` + rol `app_exec` para `EXECUTE`.
- **Pruebas de restricciones de acceso**  
  Scripts de pruebas con `EXECUTE AS LOGIN` mostrando casos **Permitido/Denegado**.
- **Documentación**  
  Este README + capturas en `/assets/modulo1-permisos-bd/` + conclusiones.

---

## Entregables
- **Scripts** (en `/script/modulo1-permisos/`):
  - `00_verificar_modo_mixto.sql`
  - `01_logins_y_usuarios.sql`
  - `02_sp_insert_y_permisos_execute.sql`
  - `03_pruebas_usuarios.sql`
  - `04_roles_lectura_por_tabla.sql`
  - `99_cleanup_demo.sql` (opcional)
- **Capturas** (en `/assets/modulo1-permisos-bd/`):

### Comprobación de modo mixto (Mixed SQL + Windows)
   ![Modulo Mixto](/assets/modulo1-permisos-bd/00_uth_mode_mixed.png) 

### Logins y usuarios
  ![Logins](/assets/modulo1-permisos-bd/01_logins_y_usuarios_ok.png) 

### Procedimiento y permisos de ejecución
  ![Permisos](/assets/modulo1-permisos-bd/02_sp_insert_y_grant_execute_ok.png) 

### Pruebas de usuarios
  ![Pruebas](/assets/modulo1-permisos-bd/03_trib_ro_select_ok_insert_error_sp_ok.png) 

### Roles del DBMS por tabla
  ![Roles](/assets/modulo1-permisos-bd/04_roles_lectura_ligas_trib_a_ok_trib_b_error.png)


- **Documento de conclusiones:** `CONCLUSIONES.md` (≈1 página) respondiendo:
  - ¿Qué permisos otorga `db_datareader`?
  - ¿Por qué `EXECUTE AS OWNER` + `GRANT EXECUTE` permiten DML sin dar permisos directos a tablas?
  - Ventajas de encapsular DML en Stored Procedures.
  - ¿Cuándo conviene usar un rol personalizado vs. roles fijos del sistema?

---

## Notas
- Cambiá las **contraseñas** de ejemplo por otras fuertes.  
- El SP de ejemplo usa `MAX(id)+1` para generar el ID. En un entorno de producción, es preferible usar columnas `IDENTITY` o `SEQUENCE` para evitar problemas de concurrencia y garantizar la unicidad de las claves.
- Si SSMS ejecuta solo la selección, asegurate de incluir los `DECLARE` en el mismo bloque cuando hagas pruebas.

| Anterior | Siguiente |
| --- | --- |
| [Capítulo V — Conclusiones](capitulo-5-conclusiones.md) | [Capítulo VI — Bibliografía](capitulo-6-bibliografia.md) |