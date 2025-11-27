# Informe: Optimización de Consultas a Través de Índices

## Resumen ejecutivo

Este documento describe el diseño, implementación y pruebas de optimización de consultas a través de índices en la base de datos `tribuneros_bdi`. Se justifica el uso de índices y su eliminación, se explican las decisiones de diseño y se documentan pruebas que demuestran el consumo de tiempo de consultas con y sin índices. Los scripts fuente están disponibles en `script/tema2-indices`.

## 1. Introducción

Piense en un libro corriente: al final del libro hay un índice en el que puede localizar rápidamente la información del libro. El índice es una lista ordenada de palabras clave y, junto a cada palabra clave, hay un conjunto de números de página que redirigen a las páginas en las que aparece cada palabra clave. Este informe presenta el costo de realizar consultas con índices y sin índices en al menos 1 millón de registros, además de mostrar los tipos de índices existentes en SQL Server.

## 2. Marco teórico

### 2.1 Índices en SQL Server

Un **índice** es una estructura en disco o en memoria asociada con una tabla o vista que acelera la recuperación de filas de la tabla o vista. El diseño de los índices adecuados para una base de datos y su carga de trabajo es un acto de equilibrio complejo entre la velocidad de consulta, el costo de actualización de índices y el costo de almacenamiento. Los índices se pueden agregar, modificar y quitar sin afectar al diseño de la aplicación o el esquema de la base de datos. Por lo tanto, se debe experimentar con índices diferentes. Los tipos de índices que se pueden crear en SQL Server son:

- **Hash**: Con un índice hash, se accede a los datos a través de una tabla hash en memoria. Los índices hash utilizan una cantidad fija de memoria, que es una función del número de cubos.

```sql
CREATE NONCLUSTERED HASH INDEX IX_MiTabla_ID_Hash
ON MiTablaOptimized (ID)
WITH (BUCKET_COUNT = 1000); -- Crea un índice hash en la columna 'ID' de la tabla 'MiTablaOptimized' con 1000 cubos
```

❌ **NO se utiliza en cualquier caso:**
-  Los índices hash solo se pueden crear en tablas optimizadas para memoria. Significa que su implementación está ligada a la tecnología In-Memory OLTP de SQL Server, diseñada para un rendimiento excepcional en cargas de trabajo transaccionales de alto rendimiento.


- **Optimizado para memoria no agrupado**: Para los índices no agrupados optimizados para memoria, el consumo de memoria depende del número de filas y del tamaño de las columnas de clave de índice.

```sql
CREATE NONCLUSTERED INDEX IX_MiTabla_Columna1_Columna2
ON MiTablaOptimized (Columna1, Columna2); -- Crea un índice no agrupado en las columnas 'Columna1' y 'Columna2' de la tabla 'MiTablaOptimized'
```

- **Agrupado (Clustered)**: Un índice clúster ordena y almacena las filas de datos de la tabla o vista por orden en función de la clave del índice clúster. El índice clúster se implementa como una estructura de árbol b que admite la recuperación rápida de las filas a partir de los valores de las claves del índice clúster. Organiza los datos de la tabla por columna índice.

```sql
CREATE CLUSTERED INDEX CIX_nombre_empleado ON empleados (id_empleado); -- Crea un índice agrupado en la columna 'id_empleado' de la tabla 'empleados'
```

- **No Agrupado (Nonclustered)**: Los índices no clúster se pueden definir en una tabla o vista con un índice clúster o en un montón. Cada fila del índice no clúster contiene un valor de clave no agrupada y un localizador de fila. Este localizador apunta a la fila de datos del índice clúster o el montón que contiene el valor de clave. Las filas del índice se almacenan en el orden de los valores de clave de índice, pero no se garantiza que las filas de datos estén en ningún orden determinado a menos que se cree un índice agrupado en la tabla. Estructuras separadas que apuntan a filas.

```sql
CREATE INDEX IX_nombre_cliente ON nombre_tabla (cliente); -- Crea un índice no agrupado en la columna 'cliente' de la tabla 'nombre_tabla'
```

- **Almacén de columnas (Columnstore)**: Un índice columnar o de almacén de columnas almacena datos en formato de columna en lugar de en formato de fila. Funcionan correctamente para las cargas de trabajo de almacenamiento de datos que ejecutan principalmente cargas masivas y consultas de solo lectura. Se usan para aumentar hasta en diez veces el rendimiento de las consultas en relación con el almacenamiento tradicional orientado a filas, y hasta en siete veces la compresión de datos en relación con el tamaño de los datos sin comprimir.

```sql
CREATE COLUMNSTORE INDEX CSIX_Ventas ON Ventas; -- Crea un índice de almacén de columnas en la tabla 'Ventas'
```

- **Único (Unique)**: Un índice único se asegura de que la clave de índice no contenga valores duplicados y, por tanto, cada fila de la tabla o vista sea en cierta forma única. La unicidad puede ser una propiedad tanto de índices agrupados como de índices no agrupados. Garantiza que todos los valores son distintos.

```sql
CREATE UNIQUE INDEX UX_Email ON Usuarios (Email); -- Crea un índice único en la columna 'Email' de la tabla 'Usuarios'
```

- **Índice con columnas incluidas**: Índice no agrupado que se extiende para incluir columnas sin clave, además de las columnas de clave. Abarca varias columnas.

```sql
CREATE NONCLUSTERED INDEX IX_Pedidos_Fecha_Cliente
ON Pedidos (FechaPedido) -- Crea un índice no agrupado en la columna 'FechaPedido' de la tabla 'Pedidos'
INCLUDE (ClienteID, Total); -- Incluye las columnas 'ClienteID' y 'Total' en el índice
```

- **Índice en columnas calculadas**: Índice creado en una columna calculada. Mejora el rendimiento de las consultas que usan columnas calculadas en las cláusulas WHERE, JOIN y en las expresiones de ordenación.

```sql
CREATE INDEX IX_Productos_PrecioTotal
ON dbo.Productos (PrecioTotal); -- Crea un índice en la columna calculada 'PrecioTotal' de la tabla 'Productos'
```

- **Filtrada (Filtered)**: Índice no clúster optimizado, especialmente indicado para cubrir consultas que seleccionan de un subconjunto bien definido de datos. Utiliza un predicado de filtro para indizar una parte de las filas de la tabla. Un índice filtrado bien diseñado puede mejorar el rendimiento de las consultas y reducir los costos de almacenamiento del índice en relación con los índices de tabla completa, así como los costos de mantenimiento.

```sql
CREATE NONCLUSTERED INDEX index_name 
ON table_name (column1, column2, ...) -- Crea un índice no agrupado en las columnas especificadas
INCLUDE (column3, column4, ...) -- Opcional: columnas incluidas que no son clave
WHERE filter_predicate; -- La condición que define el subconjunto de filas
```

- **Espacial (Spatial)**: Un índice espacial permite realizar de forma más eficaz determinadas operaciones en objetos espaciales (datos espaciales) en una columna del tipo de datos de geometry. El índice espacial reduce el número de objetos a los que es necesario aplicar las operaciones espaciales, que son relativamente costosas.

```sql
CREATE SPATIAL INDEX index_name
ON table_name (spatial_column_name)
USING <GEOMETRY_AUTO_GRID | GEOGRAPHY_AUTO_GRID | GEOMETRY_GRID | GEOGRAPHY_GRID>
WITH (
    BOUNDING_BOX = (xmin, ymin, xmax, ymax), -- Solo para GEOMETRY
    GRIDS = (nivel1, nivel2, nivel3, nivel4), -- Opcional, para control manual de la rejilla
    CELLS_PER_OBJECT = n, -- Opcional
);
```

- **XML**: Representación dividida y persistente de los objetos binarios grandes (BLOB) XML de la columna de tipo de datos xml. Mejora el rendimiento de las consultas que acceden a datos XML. 

```sql
CREATE XML INDEX index_name 
ON table_name (xml_column_name)
USING PRIMARY XML INDEX; -- Crea un índice XML primario en la columna 'xml_column_name' de la tabla 'table_name'
```

- **Texto completo(Full-text)**: Un tipo especial de índice funcional basado en símbolos token que compila y mantiene el motor de texto completo de Microsoft para SQL Server. Proporciona la compatibilidad adecuada para búsquedas de texto complejas en datos de cadenas de caracteres.

```sql
CREATE FULLTEXT INDEX ON table_name (column_name LANGUAGE 'language_term')
KEY INDEX unique_index_name; -- Crea un índice de texto completo en la columna 'column_name' de la tabla 'table_name' utilizando el índice único 'unique_index_name' como clave
```

### 2.2 Costo y beneficios de los índices
El uso de índices en una base de datos tiene tanto costos como beneficios. A continuación, se describen algunos de ellos:

**Beneficios:**
- Búsqueda: Los índices en SQL nos ayudan a encontrar un registro o una lista de registros haciendo coincidir las condiciones de el WHERE. Puede ayudar a las consultas a buscar un valor específico o dentro de un rango de valores. Hace que la búsqueda sea más rápida, lo que en última instancia conduce a una mejora del rendimiento de la consulta. Declaraciones como SELECT, UPDATE y DELETE aprovechen al máximo los índices para aumentar la ejecución de la búsqueda.
- Ordenamiento: Utilizamos índices para ordenar conjuntos de datos. La base de datos encuentra el índice para evitar la clasificación durante la ejecución de la consulta. El orden se especifica mediante las palabras clave ASC y DESC para ascender y descender, respectivamente. La cláusula ORDER BY especifica campos únicos o múltiples para limitar la clasificación del conjunto de datos. 
- Unicidad: Los índices únicos ayudan a mantener la integridad de los datos al garantizar que no haya valores duplicados en una columna o combinación de columnas. Esto es especialmente útil para columnas que actúan como claves primarias o únicas.

**Costos:**
- Espacio de almacenamiento: Los índices requieren espacio adicional en disco para almacenar la estructura del índice. Cuantos más índices tenga una tabla, más espacio se necesitará.
- Ralentización de la modificación de datos: Los índices tienen una respuesta deficiente en el rendimiento de las declaraciones de modificación de datos como INSERT, UPDATE, o DELETE. Cada vez que una consulta solicita modificar los datos de la tabla, la base de datos se actualiza con el nuevo índice donde cambian los datos. Los índices nos ayudan a localizar los registros más rápido, lo que genera rendimientos de clasificación y búsqueda más rápidos. Por lo tanto, tener demasiados índices puede ayudarnos a encontrar los registros más rápido, pero afecta poco la velocidad de modificación de los datos.
- Complejidad de diseño: El diseño y la selección adecuados de índices pueden ser complejos y requieren un análisis cuidadoso de las consultas que se ejecutan con más frecuencia en la base de datos. Una elección incorrecta de índice puede provocar un rendimiento bajo.


### 2.3 Plan de Ejecución
Para poder ejecutar consultas, el motor de base de datos de SQL Server debe analizar la instrucción para determinar una manera eficaz de acceder a los datos necesarios y procesarlos. Este análisis se controla mediante un componente denominado **Optimizador de consultas**. La entrada al Optimizador de consultas consta de la consulta, el esquema de la base de datos (definiciones de tabla e índice) y las estadísticas de base de datos. El optimizador de consultas compila uno o varios planes de ejecución de consultas, a veces denominados planes de consulta o planes de ejecución. 
Los **planes de ejecución** muestran gráficamente los métodos de recuperación de datos elegidos por el optimizador de consultas de SQL Server. Los planes de ejecución representan el costo de ejecución de instrucciones y consultas específicas en SQL Server mediante iconos en lugar de la representación tabular generada por las instrucciones SET SHOWPLAN_ALL o SET SHOWPLAN_TEXT. Este enfoque gráfico resulta útil para comprender las características de rendimiento de una consulta. Los tipos de planes de ejecución son:

- **Plan de ejecución estimado**: Devuelve el plan compilado generado por el optimizador de consultas, en función de las estimaciones. Este es el plan de consulta que se almacena en la caché de planes. La generación del plan de ejecución estimado no ejecuta realmente la consulta o el lote y, por lo tanto, no contiene ninguna información en tiempo de ejecución, como métricas de uso de recursos reales o advertencias en tiempo de ejecución.

- **Plan de ejecución real**: Devuelve el plan compilado más su contexto de ejecución. Estará disponible una vez finalizada la ejecución de la consulta. Este plan incluye información en tiempo de ejecución real, como advertencias de ejecución, y en versiones más recientes del motor de base de datos, el tiempo transcurrido y la CPU utilizados durante la ejecución.

## 3. Diseño e implementación

Se implementó un script para realizar una carga masiva:

### 3.1 01-carga_inicial.sql

**Propósito:** Cargar datos masivos para las tablas: Ligas (50 registros), Equipos (500 registros) y Partidos (1.000.000 registros).

**Características:**
- Inserción controlada mediante WHILE: Controla la secuencia de IDs para permitir ejecuciones múltiples.
- País asignado de manera cíclica: Usa CASE para generar 10 países diferentes.
- Campos generados: nombre, país, slug, id_externo, creado_en.
- Idempotente: Si se vuelve a ejecutar, continúa desde el último ID.
- Inserción con asignación automática de liga: Usa la fórmula cíclica:
```sql
@min_liga + ((@equipo - @ultimo_equipo - 1) % (@max_liga - @min_liga + 1))
```
- URLs realistas para escudos: https://escudos.tribuneros.com/{id}.png
- Muestra progreso cada 100 registros

**Buenas practicas aplicadas**
- Script totalmente idempotente: No rompe si se ejecuta múltiples veces.
- Carga por lotes en lugar de fila por fila: Muchísimo más eficiente.
- Eliminación temporal de índice para mejorar velocidad: Técnica estándar de ETL.
- Control exacto de IDENTITY manual: Útil para migraciones o importaciones.
- Fechas en formato DATETIME2(0) para mayor rendimiento.
- Evita valores inválidos en foreign keys (fk): Liga, equipos, equipos distintos, etc.


### 3.2 02-busqueda_sin_indice.sql

**Propósito:** Medir rendimiento real de consultas sin un índice en la columna fecha_utc, justo después de haber cargado millones de partidos.

**Consulta 1: Búsqueda por período de fecha**

```sql
PRINT 'Consulta 1: Partidos en 2023';
SELECT COUNT(*) AS total_partidos_2023
FROM dbo.partidos
WHERE fecha_utc >= '2023-01-01' AND fecha_utc < '2024-01-01';
```

- **características:**
- Es una consulta de rango por fecha, típica para verificar el impacto de un índice.
- Sin índice, SQL Server realizará: Table Scan sobre millones de filas.
- Evalúa rendimiento para filtros simples.

**Consulta 2: Búsqueda específica con JOINs**

```sql
SELECT 
    p.id,
    p.fecha_utc,
    CASE p.estado 
        WHEN 0 THEN 'Programado'
        WHEN 1 THEN 'En Vivo'
        WHEN 2 THEN 'Finalizado'
        WHEN 3 THEN 'Pospuesto'
        ELSE 'Cancelado'
    END AS estado_texto,
    el.nombre AS equipo_local,
    ev.nombre AS equipo_visitante,
    p.goles_local,
    p.goles_visitante
FROM dbo.partidos p
INNER JOIN dbo.equipos el ON p.equipo_local = el.id
INNER JOIN dbo.equipos ev ON p.equipo_visitante = ev.id
WHERE p.fecha_utc >= '2024-01-01' 
  AND p.fecha_utc < '2024-04-01'
  AND p.estado = 2;  -- finalizado
```

- **características:**
- Filtrado por fecha + estado.
- Selección de columnas descriptivas.
- Traducción de estado con CASE.
- Dos JOINs con tabla equipos.
- Recupera datos de texto (equipos) y datos numéricos (goles).

**Consulta 3: Agregación mensual**

```sql
SELECT 
    YEAR(fecha_utc) AS anio,
    MONTH(fecha_utc) AS mes,
    COUNT(*) AS total_partidos,
    SUM(CASE WHEN estado = 2 THEN 1 ELSE 0 END) AS finalizados
FROM dbo.partidos
WHERE fecha_utc >= '2023-01-01' AND fecha_utc < '2024-01-01'
GROUP BY YEAR(fecha_utc), MONTH(fecha_utc)
ORDER BY anio, mes;
```

- **características:**
- Agregación por año y mes.
- Requiere leer todas las filas del año completo.
- SUM de estados finalizados (técnica de conteo condicional).
- Ordenamiento al final.

### 3.3 03-crear_indice_repetir_consultas.sql

**Propósito:** Crear un índice en la columna fecha_utc de la tabla partidos y medir cuánto tarda en crearse.

**Creación del índice:**

```sql
CREATE INDEX IX_partidos_fecha ON dbo.partidos(fecha_utc);
```

**Características:** Un índice sobre fecha_utc permite que SQL Server:
- Pueda buscar por rango de fechas usando Index Seek.
- Mejore de forma muy importante las consultas como:

**Consulta 1: Búsqueda por período de fecha**

```sql
SELECT COUNT(*) AS total_partidos_2023
FROM dbo.partidos
WHERE fecha_utc >= '2023-01-01' AND fecha_utc < '2024-01-01';
```

- **características:**
- Es una consulta de rango por fecha, típica para verificar el impacto de un índice.
- Sin índice, SQL Server realizará: Table Scan sobre millones de filas.
- Evalúa rendimiento para filtros simples.

**Consulta 2: Búsqueda específica con JOINs**

```sql
SELECT 
    p.id,
    p.fecha_utc,
    CASE p.estado 
        WHEN 0 THEN 'Programado'
        WHEN 1 THEN 'En Vivo'
        WHEN 2 THEN 'Finalizado'
        WHEN 3 THEN 'Pospuesto'
        ELSE 'Cancelado'
    END AS estado_texto,
    el.nombre AS equipo_local,
    ev.nombre AS equipo_visitante,
    p.goles_local,
    p.goles_visitante
FROM dbo.partidos p
INNER JOIN dbo.equipos el ON p.equipo_local = el.id
INNER JOIN dbo.equipos ev ON p.equipo_visitante = ev.id
WHERE p.fecha_utc >= '2024-01-01' 
  AND p.fecha_utc < '2024-04-01'
  AND p.estado = 2;
```

- **características:**
- Filtrado por fecha + estado.
- Selección de columnas descriptivas.
- Traducción de estado con CASE.
- Dos JOINs con tabla equipos.
- Recupera datos de texto (equipos) y datos numéricos (goles).

**Consulta 3: Agregación mensual**

```sql
SELECT 
    YEAR(fecha_utc) AS anio,
    MONTH(fecha_utc) AS mes,
    COUNT(*) AS total_partidos,
    SUM(CASE WHEN estado = 2 THEN 1 ELSE 0 END) AS finalizados
FROM dbo.partidos
WHERE fecha_utc >= '2023-01-01' AND fecha_utc < '2024-01-01'
GROUP BY YEAR(fecha_utc), MONTH(fecha_utc)
ORDER BY anio, mes;
```

- **características:**
- Agregación por año y mes.
- Requiere leer todas las filas del año completo.
- SUM de estados finalizados (técnica de conteo condicional).
- Ordenamiento al final.

### 3.4 04-indice_compuesto.sql

**Propósito:** Optimiza aún más las consultas usando un índice compuesto con columnas incluidas.

**Eliminar índice simple si existe** 
Esto se hace porque: Solo podés crear un índice con un nombre determinado una sola vez. Y porque ahora se va a reemplazar con uno mejor.

```sql
DROP INDEX IX_partidos_fecha ON dbo.partidos;
```

**Eliminar índice compuesto si ya existía**
Esto evita errores al recrearlo.

```sql
DROP INDEX IX_partidos_fecha_compuesto ON dbo.partidos;
```

**Crear el índice compuesto optimizado**
La consulta queda COMPLETAMENTE cubierta por el índice.

```sql
CREATE INDEX IX_partidos_fecha_compuesto 
ON dbo.partidos(fecha_utc, estado)
INCLUDE (equipo_local, equipo_visitante, goles_local, goles_visitante);
```

**Consulta 1: Búsqueda por período de fecha**

```sql
SELECT COUNT(*) AS total_partidos_2023
FROM dbo.partidos
WHERE fecha_utc >= '2023-01-01' 
  AND fecha_utc < '2024-01-01'
  AND estado = 2;
```

**Consulta 2: Búsqueda específica con JOINs**

```sql
SELECT 
    p.id,
    p.fecha_utc,
    CASE p.estado 
        WHEN 0 THEN 'Programado'
        WHEN 1 THEN 'En Vivo'
        WHEN 2 THEN 'Finalizado'
        WHEN 3 THEN 'Pospuesto'
        ELSE 'Cancelado'
    END AS estado_texto,
    el.nombre AS equipo_local,
    ev.nombre AS equipo_visitante,
    p.goles_local,
    p.goles_visitante
FROM dbo.partidos p
INNER JOIN dbo.equipos el ON p.equipo_local = el.id
INNER JOIN dbo.equipos ev ON p.equipo_visitante = ev.id
WHERE p.fecha_utc >= '2024-01-01' 
  AND p.fecha_utc < '2024-04-01'
  AND p.estado = 2;
```

**Consulta 3: Agregación mensual**

```sql
SELECT 
    DATEFROMPARTS(YEAR(fecha_utc), MONTH(fecha_utc), 1) AS periodo,
    COUNT(*) AS total_partidos,
    SUM(CASE WHEN estado = 2 THEN 1 ELSE 0 END) AS finalizados
FROM dbo.partidos
WHERE fecha_utc >= '2023-01-01' 
  AND fecha_utc < '2024-01-01'
GROUP BY DATEFROMPARTS(YEAR(fecha_utc), MONTH(fecha_utc), 1)
ORDER BY periodo;
```

- **características:**
- Agregación por año y mes (periodo).
- Requiere leer todas las filas del año completo.
- SUM de estados finalizados (técnica de conteo condicional).
- Ordenamiento al final.

## 4. Pruebas de rendimiento

### 4.1 Comparación de los costos estimados

**Consulta 1: Búsqueda por período de fecha**
**Plan sin índice**
- - La consulta obliga al motor a realizar un table scan.
- - Esto implica leer todas las filas de la tabla, independientemente del filtro.
- - Lecturas lógicas: 12031 páginas. Es el escenario más costoso y menos eficiente.
- - Tiempo CPU: 186ms.
- - Costo estimado del subárbol: 10.9483

**Plan con índice simple**
- - El motor puede realizar un index seek o index scan, según el filtro y la selectividad.
- - Gran mejora respecto al scan completo (más del 95% respecto al escenario sin índice.).
- - Lecturas lógicas: 295 páginas. Se reduce drásticamente la cantidad de páginas leídas.
- - Tiempo CPU: 56ms.
- - Costo estimado del subárbol: 0.467661

**Plan con índice compuesto (fecha_utc, estado)**
- - Más específica al añadir el filtro AND estado = 2.
- - Costo ligeramente superior al simple.
- - Lecturas lógicas: 496 páginas. Menos que sin indice pero, más que con indice simple.
- - Tiempo CPU: 29ms.
- - Costo estimado del subárbol: 0.620147


**Consulta 2: Búsqueda específica con JOINs**
**Plan sin índice**
- - Alto costo. Necesita leer toda o una gran parte de la tabla.
- - Tiempo CPU: 226ms.
- - Costo estimado del subárbol: 11.6674

**Plan con índice simple**
- - El índice no fue aprovechado eficientemente para la operación.
- - El índice simple solo en fecha_utc obligó al optimizador a realizar una operación ineficiente para obtener la columna estado
- - Tiempo CPU: 338ms.
- - Costo estimado del subárbol: 11.6677

**Plan con índice compuesto (fecha_utc, estado)**
- - Logra una reducción masiva del costo de tiempo estimado (una reducción de más del 85%).
- - Permite al motor procesar la consulta leyendo solo el índice, sin tener que ir a buscar datos a la tabla base.
- - El número de páginas leídas desde el disco/caché (lecturas lógicas) se reduce drásticamente
- - Tiempo CPU: 89ms.
- - Costo estimado del subárbol: 0.560479
 

**Consulta 3: Agregación mensual**
**Plan sin índice**
- - Alto costo. Necesita leer toda o una gran parte de la tabla.
- - Tiempo CPU: 226ms.
- - Costo estimado del subárbol: 11.9698

**Plan con índice simple**
- - El índice simple es insuficiente e incluso perjudicial.
- - Se tuvo que realizar una operación costosa conocida como Key Lookup (Búsqueda de clave) por cada fila que cumplía el criterio de fecha.
- - Tiempo CPU: 338ms.
- - Costo estimado del subárbol: 11.9706

**Plan con índice compuesto (fecha_utc, estado)**
- - Logra una reducción masiva del costo de tiempo estimado.
- - Tiempo CPU: 89ms.
- - Costo estimado del subárbol: 1.72421

## 5. Conclusiones finales sobre índices

**"Consulta 1: Búsqueda por período de fecha"**
La indexación en la columna de filtro de rango (fecha_utc) es el factor más importante para optimizar la Consulta 1, reduciendo el costo en más del 95% al permitir un Index Seek en lugar de un Clustered Index Scan. El índice simple demostró ser el más eficiente para esta consulta específica de conteo por rango.

**Consulta 2: Búsqueda específica con JOINs**
Para consultas con múltiples condiciones de filtro (como rango de fechas y valor específico, y que requieren columnas adicionales en el SELECT), la creación de un Índice de Cobertura (Covering Index) que incluya las columnas de filtro y las columnas de la proyección (SELECT) es la estrategia más efectiva para optimizar el rendimiento. El índice compuesto optimizado logra esto, superando con creces tanto a la versión sin índice como a la versión con un índice simple.

**Consulta 3: Agregación mensual**
Para consultas que utilizan un rango de fechas en la cláusula WHERE junto con una función de agregación que depende de otras columnas (como estado), un índice compuesto que cubra al menos las columnas de filtro y las columnas de agregación (incluida la columna que se agrupa) es crucial. El índice IX_partidos_fecha_compuesto demuestra ser el más efectivo para este tipo de consulta, permitiendo un Index Seek y un procesamiento de datos más rápido directamente desde el índice.
  
## 6. Referencias

- **Microsoft Docs - Indexes**  
https://learn.microsoft.com/es-es/sql/relational-databases/indexes/indexes?view=sql-server-ver17 

- **Microsoft Docs - Guía de diseño y arquitectura de índices**  
https://learn.microsoft.com/es-es/sql/relational-databases/sql-server-index-design-guide?view=sql-server-ver17

- **Microsoft Docs - Directrices de diseño de índices hash optimizados para memoria**  
https://learn.microsoft.com/es-es/sql/relational-databases/sql-server-index-design-guide view=sql-server-ver17#memory-optimized-hash-index-design-guidelines

- **Microsoft Docs - Información general sobre el plan de ejecución**  
https://learn.microsoft.com/es-es/sql/relational-databases/performance/execution-plans?view=sql-server-ver17

- **Microsoft Docs - Mostrar y guardar planes de ejecución**  
https://learn.microsoft.com/es-es/sql/relational-databases/performance/display-and-save-execution-plans?view=sql-server-ver17

- **Microsoft Docs - Guardar un plan de ejecución en formato XML**  
https://learn.microsoft.com/es-es/sql/relational-databases/performance/save-an-execution-plan-in-xml-format?view=sql-server-ver17

- **Microsoft Docs - Comparación y análisis de los planes de ejecución**  
https://learn.microsoft.com/es-es/sql/relational-databases/performance/compare-and-analyze-execution-plans?view=sql-server-ver17&source=recommendations
---

## Apéndice: Orden de ejecución de scripts

Para reproducir el proyecto completo, ejecutar los scripts en este orden:

1. `01-carga_inicial.sql` - Crear los datos masivos (ligas, equipos, partidos)
2. `02-busqueda_sin_indice.sql` - Medir consultas sin índice
3. `03-crear_indice_repetir_consultas.sql` - Crear índice simple y repetir consultas
4. `04-indice_compuesto.sql` - Crear índice compuesto y repetir consultas
5. `05-conteo_de_datos.sql` - Realizar conteo final de datos (opcional)
6. `06-limpieza_datos.sql` - Eliminar todos los registros e índices (opcional)

**Nota:** Asegurarse de que la base de datos `tribuneros_bdi` tenga datos iniciales (ligas, equipos, partidos) antes de ejecutar las búsquedas.
