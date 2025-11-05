# Tema 4: Vistas y vistas indexadas en SQL Server  


---

## 1. Introducción teórica

Una **vista** en SQL Server es un objeto que guarda una consulta predefinida y devuelve un conjunto de resultados como si fuera una tabla virtual.  
Permite:

- Encapsular lógica de selección y presentación.  
- Simplificar el acceso a subconjuntos de columnas.  
- Aislar a la aplicación de los cambios estructurales en las tablas base.

Una **vista indexada (indexed view)**, en cambio, es una vista cuyo resultado se **materializa físicamente** mediante un índice.  
A diferencia de una vista normal, almacena los datos pre-calculados en disco y el motor puede usarlos directamente, mejorando el rendimiento de lecturas frecuentes.  
El costo está en que cada operación DML (INSERT/UPDATE/DELETE) sobre las tablas base debe mantener ese índice sincronizado.

> **Referencias aplicadas**  
> - Microsoft Docs – [Create Indexed Views](https://learn.microsoft.com/es-es/sql/relational-databases/views/create-indexed-views?view=sql-server-ver17)  
> - SQLShack – [SQL Server Indexed Views](https://www.sqlshack.com/sql-server-indexed-views/)  
> - Red-Gate / Simple-Talk – [SQL Server Indexed Views: The Basics](https://www.red-gate.com/simple-talk/databases/sql-server/learn/sql-server-indexed-views-the-basics/)

---

## 2. Contexto del modelo (`partidos`)

La tabla `dbo.partidos` almacena la información de los encuentros de fútbol.  
Campos relevantes según el diccionario de datos:

| Columna | Tipo | Descripción |
|----------|------|-------------|
| `id` | INT (PK) | Identificador del partido |
| `liga_id` | INT (FK) | Liga o torneo |
| `equipo_local`, `equipo_visitante` | INT (FK) | Equipos participantes |
| `fecha_utc` | DATETIME2(0) | Fecha y hora |
| `temporada` | SMALLINT | Año o temporada |
| `estado` | TINYINT | 0 = pendiente, 1 = jugado, etc. |
| `goles_local`, `goles_visitante` | SMALLINT | Resultado |

Consultas típicas del sistema:
- Listar partidos por liga y fecha.  
- Calcular estadísticas por liga y temporada (cantidad, fechas mínima / máxima).

---

## 3. Vista simple para CRUD – `vw_partidos_basicos`

**Definición resumida**
```sql
CREATE VIEW dbo.vw_partidos_basicos AS
SELECT id, liga_id, fecha_utc, equipo_local, equipo_visitante, estado, temporada
FROM dbo.partidos;
```

**Motivación**
- Exponer solo columnas necesarias para operaciones CRUD.  
- Mantenerla *actualizable* (sin JOIN ni GROUP BY).  

**Operaciones realizadas**
```sql
-- INSERT de pruebas
INSERT INTO dbo.vw_partidos_basicos (id, liga_id, fecha_utc, equipo_local, equipo_visitante, estado, temporada)
VALUES (9000, 1, SYSDATETIME(), 1, 2, 0, 2025);

-- UPDATE (cambiar estado)
UPDATE dbo.vw_partidos_basicos SET estado = 1 WHERE id = 9000;

-- DELETE de registros de prueba
DELETE FROM dbo.vw_partidos_basicos WHERE id BETWEEN 9000 AND 9004;
```

Se verificó que los cambios aplicados a través de la vista se reflejan directamente en la tabla `partidos`.  
El script es idempotente porque usa el rango 9000–9009 reservado para pruebas, facilitando el rollback.

---

## 4. Vista indexada – diseño y justificación

**Objetivo:** acelerar consultas de resumen frecuentes (“cantidad de partidos por liga y año”).

**Definición:**
```sql
CREATE VIEW dbo.vw_partidos_por_liga_y_anio
WITH SCHEMABINDING
AS
SELECT
    p.liga_id,
    YEAR(p.fecha_utc) AS anio,
    COUNT_BIG(*) AS cantidad_partidos
FROM dbo.partidos AS p
GROUP BY p.liga_id, YEAR(p.fecha_utc);
```

**Índice clustered único:**
```sql
CREATE UNIQUE CLUSTERED INDEX IX_vw_partidos_por_liga_y_anio
    ON dbo.vw_partidos_por_liga_y_anio (liga_id, anio);
```

**Requisitos cumplidos**
- `WITH SCHEMABINDING` y nombres de dos partes (`dbo.partidos`).  
- Uso de `COUNT_BIG` (único permitido para vistas indexadas con agregados).  
- Opciones SET obligatorias activadas:  
  `ANSI_NULLS ON`, `QUOTED_IDENTIFIER ON`, `ANSI_PADDING ON`, `ANSI_WARNINGS ON`, `CONCAT_NULL_YIELDS_NULL ON`, `NUMERIC_ROUNDABORT OFF`, `ARITHABORT ON`.

**Justificación práctica**  
Según Microsoft Docs, las vistas indexadas son útiles para materializar resultados agregados que se consultan frecuentemente.  
SQLShack y Red-Gate destacan que conviene aplicarlas cuando las lecturas son mucho más frecuentes que las modificaciones, como ocurre con estadísticas históricas de partidos.

---

## 5. Pruebas de rendimiento

### Configuración
```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
```
Se ejecutaron dos bloques comparativos:

| Bloque | Descripción |
|---------|--------------|
| **A** | Consulta directa sobre `dbo.partidos` (agrupa por liga y año). |
| **B** | Consulta equivalente leyendo desde `dbo.vw_partidos_por_liga_y_anio`. |

---

### a) Bloque A – sin vista indexada
Antes de crear la vista, la consulta:
```sql
SELECT p.liga_id, YEAR(p.fecha_utc) AS anio, COUNT(*) AS cantidad_partidos
FROM dbo.partidos AS p
GROUP BY p.liga_id, YEAR(p.fecha_utc)
ORDER BY p.liga_id, anio;
```
- Plan: `Clustered Index Scan (Clustered)` sobre `dbo.partidos`, seguido de `Sort` y `Stream Aggregate`.  
- El motor recorre toda la tabla y agrupa manualmente.  

![Plan Bloque A](/assets/tema4-vistas/Plan_BloqueA.png)

---

### b) Bloque B – con vista indexada
Tras crear la vista y su índice:
```sql
SELECT v.liga_id, v.anio, v.cantidad_partidos
FROM dbo.vw_partidos_por_liga_y_anio AS v
ORDER BY v.liga_id, v.anio;
```
- Plan: `Clustered Index Scan (ViewClustered)` sobre `IX_vw_partidos_por_liga_y_anio`.  
- No existen operaciones de agregación: lee el resultado ya materializado.  

![Plan Bloque B](/assets/tema4-vistas/Plan_BloqueB.png)

---

### c) Comparación visual (Showplan Comparison)

En la comparación de planes se observa:

| Característica | Bloque A (sin vista) | Bloque B (con vista indexada) |
|-----------------|----------------------|--------------------------------|
| Fuente de datos | `dbo.partidos` | `vw_partidos_por_liga_y_anio` |
| Operador principal | Clustered Index Scan (Clustered) | Clustered Index Scan (ViewClustered) |
| Operadores extra | Sort + Stream Aggregate | ninguno |
| Costo estimado | más alto | más bajo |
| Lecturas lógicas (Statistics IO) | > tabla base completa | menor (usa índice materializado) |

![Comparación de planes](/assets/tema4-vistas/ComparacionAvsB.png)

### d) Observaciones del comportamiento del optimizador
Una vez creada la vista indexada, SQL Server es capaz de **reutilizarla automáticamente** incluso si la consulta se escribe sobre la tabla base.  
Esto se comprobó porque, al volver a ejecutar el Bloque A con la vista ya creada, el plan de ejecución también mostraba un `Clustered Index Scan (ViewClustered)`.

---

## 6. Script de rollback – `04_rollback_tema4.sql`

**Propósito:** restaurar el estado inicial del proyecto eliminando todas las creaciones del Tema 4.  

El script:
1. Elimina el índice `IX_vw_partidos_por_liga_y_anio` si existe.  
2. Elimina las vistas `vw_partidos_por_liga_y_anio` y `vw_partidos_basicos`.  
3. Borra los registros de prueba (ID 9000 – 9009).  

```sql
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_vw_partidos_por_liga_y_anio')
    DROP INDEX IX_vw_partidos_por_liga_y_anio ON dbo.vw_partidos_por_liga_y_anio;
DROP VIEW IF EXISTS dbo.vw_partidos_por_liga_y_anio;
DROP VIEW IF EXISTS dbo.vw_partidos_basicos;
DELETE FROM dbo.partidos WHERE id BETWEEN 9000 AND 9009;
```

El rollback se probó verificando que las cuentas de registros antes y después dieran cero en los IDs de prueba.

---

## 7. Conclusiones

- La vista simple (`vw_partidos_basicos`) facilita operaciones CRUD seguras y controladas.  
- La vista indexada (`vw_partidos_por_liga_y_anio`) demostró mejor rendimiento en consultas de agregación repetidas.  
- El plan de ejecución se simplifica y las lecturas lógicas disminuyen significativamente.  
- SQL Server puede reutilizar automáticamente el índice de la vista para consultas equivalentes sobre la tabla base, sin que el usuario la llame directamente.  

**Trade-offs:**  
- Mayor costo de mantenimiento en operaciones DML.  
- Reglas estrictas para definir vistas indexadas (SCHEMABINDING, COUNT_BIG, determinismo).  

**Aplicación en Tribuneros:**  
- Puede utilizarse para reportes de rendimiento de ligas o dashboards de temporadas.  
- Mejora la eficiencia de consultas estadísticas sin afectar la capa de aplicación.

---

## 8. Referencias bibliográficas

1. **Microsoft Docs** – Create Indexed Views  
   <https://learn.microsoft.com/es-es/sql/relational-databases/views/create-indexed-views?view=sql-server-ver17>  
2. **SQLShack** – SQL Server Indexed Views  
   <https://www.sqlshack.com/sql-server-indexed-views/>  
3. **Red-Gate / Simple-Talk** – SQL Server Indexed Views: The Basics  
   <https://www.red-gate.com/simple-talk/databases/sql-server/learn/sql-server-indexed-views-the-basics/>

