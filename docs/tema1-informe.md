# Informe: Implementación de Procedimientos y Funciones

## 1. Introducción

Este informe detalla la implementación de procedimientos almacenados (SP) y funciones definidas por el usuario (UDF) en la base de datos `tribuneros_bdi`. El objetivo es encapsular la lógica de negocio, mejorar la seguridad, optimizar el rendimiento y facilitar la reutilización de código.

Se han desarrollado SPs para las operaciones CRUD (Crear, Leer, Actualizar, Borrar) sobre la tabla `opiniones` y funciones escalares para realizar cálculos y formatear datos relevantes del dominio.


## 2. Procedimientos Almacenados

Los procedimientos almacenados son bloques de código SQL precompilados que se guardan en la base de datos. Ofrecen ventajas como:
- **Seguridad:** Permiten a los usuarios ejecutar operaciones complejas sin darles permisos directos sobre las tablas.
- **Rendimiento:** El plan de ejecución se almacena en caché, reduciendo el tiempo de compilación en llamadas sucesivas.
- **Abstracción:** Ocultan la complejidad de las tablas subyacentes y centralizan la lógica de negocio.

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


## 3. Funciones Definidas por el Usuario (UDF)

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

La incorporación de procedimientos almacenados y funciones es un paso fundamental para la madurez del proyecto. Proporciona una capa de abstracción robusta que protege la integridad de los datos y simplifica el desarrollo de la capa de aplicación, al tiempo que ofrece mecanismos para optimizar consultas complejas.