# Informe: Implementación de Procedimientos Almacenados (SP) y Funciones Definidas por el Usuario (UDF)


### Resumen ejecutivo  
Este documento describe el diseño, implementación y pruebas de procedimientos almacenados (SP) y funciones definidas por el usuario (UDF) para la base de datos `tribuneros_bdi`. Se justifica su uso, se explican decisiones de diseño y se documentan pruebas reproducibles que comparan inserciones directas vs inserciones a través de SP. Los scripts fuente están disponibles en `script/tema1-procs-funciones`.

## 1. Introducción

Las bases de datos relacionales modernas requieren mecanismos para encapsular lógica de negocio, validar integridad y mejorar la mantenibilidad. Procedimientos y funciones almacenadas permiten centralizar reglas, reducir errores por duplicación de lógica y, en muchos escenarios, mejorar la seguridad y la trazabilidad de cambios. Este informe presenta una implementación práctica aplicada al dominio de opiniones sobre partidos deportivos y evalúa el coste/beneficio de usar SP frente a instrucciones SQL directas para inserciones.


## 2. Marco teórico (sintético y aplicado)

**Procedimientos almacenados (SP):** Rutinas en el motor que, al ejecutarse por primera vez, generan un **plan de ejecución cacheado** (reutilizable y recompilable). Permiten **encapsular lógica de negocio**, **reutilizar código**, **controlar permisos** (p. ej., `GRANT EXECUTE` / `EXECUTE AS`) y ejecutar **lógica transaccional** (`BEGIN/COMMIT/ROLLBACK` con manejo de errores).  
*Aplicado:* insertar, actualizar y borrar opiniones con validaciones (unicidad `(partido_id, usuario_id)`, FKs y ownership por `usuario_id`) bajo transacción.

**Funciones definidas por el usuario (UDF):** Devuelven **un valor** (escalares) o **una tabla** (table-valued). En T-SQL **no tienen efectos secundarios**: no pueden modificar tablas ni invocar SP. Las **iTVF (inline)** suelen ofrecer mejores estimaciones y rendimiento que las **mTVF (multi-statement)**.  
*Aplicado:* obtener `nombre_usuario`, calcular promedios y formatear resultados directamente en consultas.

**Consideraciones de rendimiento:** SP y UDF influyen en **planes** y **caché**. En SP puede aparecer **parameter sniffing**; se mitiga con `OPTION (RECOMPILE)`, captura de parámetros en variables locales o `OPTIMIZE FOR`. En SQL Server 2019+ algunas **UDF escalares** pueden **inlinarse**, reduciendo su sobrecarga. Para volúmenes altos, preferir enfoques **set-based**.

### Inserciones (INSERT) — teoría y aplicación (síntesis)

Las inserciones condicionan el diseño de los SP porque impactan integridad, concurrencia y planes. Principios clave:

- **Set-based vs por fila:** priorizar enfoques set-based (`INSERT ... SELECT` y **TVP** —*Table-Valued Parameters*, para enviar lotes*). Evitar ejecutar un SP por cada fila salvo casos OLTP unitarios con reglas específicas. *(Si se usa `MERGE`, que sea para upsert bien delimitado.)*
- **SP vs INSERT directo:** los SP aportan validaciones, transacción (`SET XACT_ABORT ON` + `TRY/CATCH`) y control de permisos; el overhead por invocación es marginal en lotes pequeños. Para cargas grandes, diseñar **SP set-based** o **TVP**.
- **Concurrencia e integridad:** FKs y UNIQUE generan lecturas/bloqueos; planificar **índices de soporte**. Si hay mucha lectura concurrente, considerar `SNAPSHOT/READ COMMITTED SNAPSHOT` según política.
- **Medición y optimización:** medir con `SET STATISTICS IO/TIME` y revisar el plan (seek vs scan, key lookups). En SP de insert, usar `SET NOCOUNT ON` y devolver la PK con `SCOPE_IDENTITY()`.


## 3. Implementación de Procedimientos Almacenados (≥3)

Se implementaron los siguientes procedimientos para la tabla `opiniones`:

### `dbo.sp_Insertar_Opinion`
- **Propósito:** Inserta una nueva opinión, validando que el usuario no haya opinado previamente sobre el mismo partido.
- **Parámetros:** `@partido_id`, `@usuario_id`, `@titulo`, `@cuerpo`, `@publica`, `@tiene_spoilers`.
- **Salida:** `@opinion_id` (el ID de la nueva fila).

**Ejemplo de uso:**
```sql
DECLARE @nueva_opinion_id INT;
EXEC dbo.sp_Insertar_Opinion
    @partido_id = 1,
    @usuario_id = '44444444-4444-4444-4444-444444444444',
    @titulo = 'Visto desde la neutralidad',
    @cuerpo = 'Un partido que quedará en la historia del fútbol sudamericano.',
    @publica = 1,
    @tiene_spoilers = 0,
    @opinion_id = @nueva_opinion_id OUTPUT;

SELECT * FROM dbo.opiniones WHERE id = @nueva_opinion_id;
```

### `dbo.sp_Modificar_Opinion`
- **Propósito:** Actualiza el contenido de una opinión existente.
- **Parámetros:** `@opinion_id`, `@usuario_id` (para seguridad), `@titulo`, `@cuerpo`, `@publica`, `@tiene_spoilers`.
- **Lógica de seguridad:** Solo el usuario que creó la opinión puede modificarla.

**Ejemplo de uso:**
```sql
EXEC dbo.sp_Modificar_Opinion
    @opinion_id = 1, -- ID de la opinión de 'tobiager'
    @usuario_id = '11111111-1111-1111-1111-111111111111',
    @titulo = 'La gloria eterna en Madrid (editado)',
    @cuerpo = 'Partidazo histórico. River campeón con autoridad. 3-1 y a casa. Inolvidable.',
    @publica = 1,
    @tiene_spoilers = 1;
```

### `dbo.sp_Borrar_Opinion`
- **Propósito:** Elimina una opinión de la base de datos.
- **Parámetros:** `@opinion_id`, `@usuario_id` (para seguridad).
- **Lógica de seguridad:** Solo el usuario que creó la opinión puede borrarla.

**Ejemplo de uso:**
```sql
-- Suponiendo que la opinión con ID 101 fue creada por el usuario '1111...'
EXEC dbo.sp_Borrar_Opinion
    @opinion_id = 101,
    @usuario_id = '11111111-1111-1111-1111-111111111111';
```

### Procedimientos de prueba
![Procedimientos almacenados](/assets/tema1-procs-funciones/06_pruebas_procedimientos.png)  


## 4. Implementación de Funciones Definidas por el Usuario (UDF)

Las funciones son rutinas que aceptan parámetros, realizan una acción y devuelven un resultado. A diferencia de los procedimientos, las funciones **deben devolver un valor** y pueden ser utilizadas directamente en sentencias `SELECT`.

### `dbo.fn_ObtenerNombreUsuario(@usuario_id)`
- **Propósito:** Devuelve el `nombre_usuario` a partir de su `usuario_id`. Simplifica las consultas al evitar un `JOIN` con la tabla `perfiles`.
- **Ejemplo de uso:**
  ```sql
  SELECT
    titulo,
    cuerpo,
    dbo.fn_ObtenerNombreUsuario(usuario_id) AS autor
  FROM dbo.opiniones
  WHERE partido_id = 1;
  ```

### `dbo.fn_CalcularPuntajePromedioPartido(@partido_id)`
- **Propósito:** Calcula y devuelve el puntaje promedio que los usuarios le dieron a un partido.
- **Ejemplo de uso:**
  ```sql
  SELECT
    p.id,
    eq_local.nombre AS local,
    eq_visit.nombre AS visitante,
    dbo.fn_CalcularPuntajePromedioPartido(p.id) AS puntaje_promedio
  FROM dbo.partidos p
  JOIN dbo.equipos eq_local ON p.equipo_local = eq_local.id
  JOIN dbo.equipos eq_visit ON p.equipo_visitante = eq_visit.id;
  ```

### `dbo.fn_FormatearResultadoPartido(@partido_id)`
- **Propósito:** Devuelve una cadena de texto con el resultado final de un partido (ej: "3 - 1") o "vs" si el partido no ha finalizado.
- **Ejemplo de uso:**
  ```sql
  SELECT
    p.id,
    dbo.fn_FormatearResultadoPartido(p.id) AS resultado
  FROM dbo.partidos p;
  ```

### Funciones de prueba
![Funciones de prueba](/assets/tema1-procs-funciones/05_pruebas_funciones.png)  


## 4) Pruebas y comparativa de rendimiento

Se ejecutaron dos lotes (3 inserciones):

- `03_datos_insert_directo.sql` — **INSERT** directo  
- `04_datos_insert_via_sp.sql` — **3× `EXEC dbo.sp_Insertar_Opinion`**

Con `SET STATISTICS IO ON; SET STATISTICS TIME ON;` en SSMS.

### 4.1 Métricas observadas (de *Messages*)

| Método                         | `usuarios` LReads | `partidos` LReads | `opiniones` LReads | **Total LReads** | CPU (ms) | Elapsed (ms) |
|-------------------------------|------------------:|------------------:|-------------------:|-----------------:|---------:|-------------:|
| **INSERT directo (03_)**      | 6                 | 6                 | 18                 | **30**           | ≈0       | ≈0           |
| **Vía SP (04_) · 3 EXEC**     | 6                 | 6                 | 18                 | **30**           | picos 0–18 | picos 17–18  |

### Insert Directo
![DIRECTO](/assets/tema1-procs-funciones/03_datos_insert_directo.png)

### Instert Via SP
![VIA SP](/assets/tema1-procs-funciones/04_datos_insert_via_sp.png) 
**Lectura:** el costo de IO es **equivalente** (30 lecturas lógicas) en ambos enfoques. El SP muestra picos aislados de tiempo por llamada, sin impacto significativo a esta escala.

**Motivo técnico**
- Lecturas en `usuarios` y `partidos` por **verificación de FK**.  
- Lecturas en `opiniones` por **INSERT** + **unicidad** (`UQ (partido_id, usuario_id)`).  
- SP por fila vs `INSERT` por lote: para este tamaño, el **total** es similar.

**Conclusión de rendimiento**
- La **sobrecarga del SP es marginal** y compensa con **validaciones + transacción** (mejor **calidad de datos** y **reglas centralizadas**).
- Para **cargas masivas**, preferir SP **set-based** (p. ej., **Table-Valued Parameter**).

---

## 5. Conclusión

- SP y UDF aportan una capa de abstracción y control que mejora la calidad de los datos y la seguridad de la aplicación.  
- El coste de IO observado en pruebas pequeñas puede ser comparable entre inserciones directas y vía SP; el SP introduce una sobrecarga temporal por ejecución individual, relevancia según la escala.  
- Para producción: usar SP para encapsular lógica crítica; diseñar SP set-based o TVP para cargas masivas.  


## 6. Referencias (y uso específico)

- Microsoft Docs — Stored Procedures (SQL Server): https://learn.microsoft.com/es-es/sql/relational-databases/stored-procedures/stored-procedures-database-engine?view=sql-server-ver17  
  - Se usó para: patrones de creación, permisos y comportamiento del motor con SP.  
- Microsoft Docs — User-Defined Functions (SQL Server): https://learn.microsoft.com/es-es/sql/relational-databases/user-defined-functions/user-defined-functions?view=sql-server-ver17  
  - Se usó para: límites y recomendaciones sobre UDF, opciones de binding y rendimiento.  
- SQLShack — Funciones frente a Procedimientos Almacenados en SQL Server: https://www.sqlshack.com/es/funciones-frente-a-los-procedimientos-almacenados-en-sql-server/  
  - Se usó para: discusión práctica de cuándo elegir SP vs UDF.  
- W3Schools — Stored Procedures (introducción): https://www.w3schools.com/sql/sql_stored_procedures.asp  
  - Se usó para: ejemplos introductorios y sintaxis básica.

