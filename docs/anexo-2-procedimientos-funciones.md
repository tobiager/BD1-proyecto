# Anexo II — Procedimientos y Funciones Almacenadas

## Introducción

Este anexo documenta la implementación de procedimientos y funciones almacenadas en la base de datos Tribuneros, demostrando encapsulación de lógica de negocio, validaciones centralizadas, y reutilización de código.

## Objetivos

- Crear procedimientos almacenados para operaciones CRUD con validaciones
- Implementar funciones reutilizables para cálculos frecuentes
- Comparar eficiencia entre INSERT directo y procedimientos
- Demostrar ventajas de encapsular lógica en la base de datos
- Validar la integración con el sistema de seguridad (Anexo I)

## Procedimientos Almacenados

### 1. sp_InsertPartido

**Propósito**: Insertar un nuevo partido con validaciones completas de integridad de negocio.

**Parámetros**:
```sql
@id INT                    -- ID único (requerido)
@id_externo VARCHAR(80)    -- Código externo (opcional)
@liga_id INT               -- ID de liga (opcional, debe existir)
@temporada INT             -- Año de temporada (opcional)
@ronda VARCHAR(40)         -- Identificador de ronda (opcional)
@fecha_utc DATETIME2       -- Fecha y hora (requerido)
@estado VARCHAR(15)        -- Estado del partido (requerido)
@estadio VARCHAR(120)      -- Nombre de estadio (opcional)
@equipo_local INT          -- ID equipo local (requerido, debe existir)
@equipo_visitante INT      -- ID equipo visitante (requerido, debe existir)
@goles_local INT           -- Goles local (opcional, requerido si finalizado)
@goles_visitante INT       -- Goles visitante (opcional, requerido si finalizado)
```

**Validaciones Implementadas**:

1. **ID único**: El ID no debe existir en la tabla
2. **Equipos diferentes**: Local ≠ Visitante
3. **Equipo local existe**: Validar en tabla `equipos`
4. **Equipo visitante existe**: Validar en tabla `equipos`
5. **Liga existe**: Si se proporciona liga_id, debe existir
6. **Estado válido**: Debe ser uno de: programado, en_vivo, finalizado, pospuesto, cancelado
7. **Goles para finalizados**: Si estado='finalizado', ambos goles deben estar presentes
8. **Goles no negativos**: Los goles no pueden ser < 0

**Valores de Retorno**:
- `0`: Inserción exitosa
- `-1`: ID duplicado
- `-2`: Equipos iguales
- `-3`: Equipo local no existe
- `-4`: Equipo visitante no existe
- `-5`: Liga no existe
- `-6`: Estado inválido
- `-7`: Partido finalizado sin goles
- `-8`: Goles negativos
- `-99`: Error inesperado

**Ejemplo de Uso**:
```sql
EXEC dbo.sp_InsertPartido
    @id = 100001,
    @liga_id = 1,
    @temporada = 2024,
    @ronda = 'Fecha 15',
    @fecha_utc = '2024-05-20 20:00:00',
    @estado = 'programado',
    @estadio = 'Monumental',
    @equipo_local = 1,
    @equipo_visitante = 2,
    @goles_local = NULL,
    @goles_visitante = NULL;
```

### 2. sp_UpdatePartido

**Propósito**: Actualizar datos de un partido existente con validaciones.

**Parámetros**:
```sql
@id INT                -- ID del partido (requerido)
@estado VARCHAR(15)    -- Nuevo estado (opcional)
@goles_local INT       -- Nuevos goles local (opcional)
@goles_visitante INT   -- Nuevos goles visitante (opcional)
@estadio VARCHAR(120)  -- Nuevo estadio (opcional)
```

**Validaciones Implementadas**:

1. **Partido existe**: El ID debe existir en la tabla
2. **Estado válido**: Si se proporciona, debe ser válido
3. **Goles no negativos**: Los goles no pueden ser < 0
4. **Goles para finalizados**: Al marcar como finalizado, verificar que ambos goles estén presentes (combinando valores existentes y nuevos)

**Comportamiento**: Solo actualiza los campos que se proporcionan (no NULL). Los campos NULL se ignoran y mantienen su valor actual.

**Valores de Retorno**:
- `0`: Actualización exitosa
- `-1`: Partido no existe
- `-2`: Estado inválido
- `-3`: Goles negativos
- `-4`: Finalizado sin ambos goles
- `-99`: Error inesperado

**Ejemplo de Uso**:
```sql
-- Actualizar resultado de partido finalizado
EXEC dbo.sp_UpdatePartido
    @id = 100001,
    @estado = 'finalizado',
    @goles_local = 3,
    @goles_visitante = 1;
```

### 3. sp_DeletePartido

**Propósito**: Eliminar un partido de forma lógica o física.

**Parámetros**:
```sql
@id INT                    -- ID del partido (requerido)
@eliminacion_fisica BIT    -- 0=lógica, 1=física (default: 0)
```

**Validaciones Implementadas**:

1. **Partido existe**: El ID debe existir en la tabla

**Comportamiento**:

- **Eliminación Lógica** (`@eliminacion_fisica = 0`):
  - Cambia el estado del partido a 'cancelado'
  - Mantiene el registro en la tabla
  - Preserva relaciones con otras tablas
  - Recomendado para mantener histórico

- **Eliminación Física** (`@eliminacion_fisica = 1`):
  - Ejecuta DELETE del registro
  - Elimina en cascada registros relacionados (calificaciones, opiniones, favoritos, etc.)
  - **ADVERTENCIA**: Pérdida permanente de datos

**Valores de Retorno**:
- `0`: Eliminación exitosa
- `-1`: Partido no existe
- `-99`: Error inesperado

**Ejemplo de Uso**:
```sql
-- Eliminación lógica (recomendada)
EXEC dbo.sp_DeletePartido @id = 100001, @eliminacion_fisica = 0;

-- Eliminación física (usar con precaución)
EXEC dbo.sp_DeletePartido @id = 100002, @eliminacion_fisica = 1;
```

## Funciones Almacenadas

### 1. fn_CalcularEdad

**Propósito**: Calcular la edad en años a partir de una fecha de nacimiento.

**Parámetros**:
```sql
@fecha_nacimiento DATETIME2
```

**Retorno**: `INT` (edad en años)

**Lógica**:
- Calcula diferencia de años entre fecha de nacimiento y hoy
- Ajusta si aún no cumplió años en el año actual (mes y día)
- Considera años bisiestos y cambios de mes

**Ejemplo de Uso**:
```sql
-- Calcular edad de usuario nacido el 15 de mayo de 1990
SELECT dbo.fn_CalcularEdad('1990-05-15') AS edad;
-- Retorna: 34 (en 2024)

-- Usar en consulta
SELECT 
    p.nombre_mostrar,
    u.fecha_nacimiento,
    dbo.fn_CalcularEdad(u.fecha_nacimiento) AS edad_actual
FROM usuarios u
INNER JOIN perfiles p ON u.id = p.usuario_id;
```

### 2. fn_ObtenerPromedioCalificaciones

**Propósito**: Calcular el promedio de calificaciones de un partido.

**Parámetros**:
```sql
@partido_id INT
```

**Retorno**: `DECIMAL(3,2)` (promedio entre 0.00 y 5.00)

**Lógica**:
- Promedia los puntajes (1-5) de todas las calificaciones del partido
- Retorna 0.00 si no hay calificaciones

**Ejemplo de Uso**:
```sql
-- Obtener promedio de calificaciones del partido 1
SELECT dbo.fn_ObtenerPromedioCalificaciones(1) AS promedio_calificacion;
-- Retorna: 4.25

-- Listar partidos ordenados por mejor calificación
SELECT 
    p.id,
    p.ronda,
    dbo.fn_ObtenerPromedioCalificaciones(p.id) AS promedio,
    COUNT(c.id) AS total_calificaciones
FROM partidos p
LEFT JOIN calificaciones c ON p.id = c.partido_id
WHERE p.estado = 'finalizado'
GROUP BY p.id, p.ronda
ORDER BY promedio DESC;
```

### 3. fn_ContarPartidosPorEstado

**Propósito**: Contar partidos en un estado específico.

**Parámetros**:
```sql
@estado VARCHAR(15)
```

**Retorno**: `INT` (cantidad de partidos)

**Estados válidos**: programado, en_vivo, finalizado, pospuesto, cancelado

**Ejemplo de Uso**:
```sql
-- Contar partidos finalizados
SELECT dbo.fn_ContarPartidosPorEstado('finalizado') AS partidos_finalizados;

-- Dashboard de estadísticas
SELECT 
    'Finalizados' AS categoria, 
    dbo.fn_ContarPartidosPorEstado('finalizado') AS cantidad
UNION ALL
SELECT 
    'Programados', 
    dbo.fn_ContarPartidosPorEstado('programado')
UNION ALL
SELECT 
    'En Vivo', 
    dbo.fn_ContarPartidosPorEstado('en_vivo')
UNION ALL
SELECT 
    'Cancelados', 
    dbo.fn_ContarPartidosPorEstado('cancelado');
```

## Pruebas Comparativas

### Metodología

El script `03_Pruebas_Comparativas.sql` realiza una comparación objetiva entre:
- **INSERT directo**: Insertar sin validaciones de negocio
- **Procedimiento almacenado**: Insertar con todas las validaciones

### Métricas Evaluadas

1. **Tiempo de ejecución**: Milisegundos para insertar 100 registros
2. **Overhead de validaciones**: Diferencia porcentual entre ambos métodos
3. **Garantías de integridad**: Validaciones aplicadas automáticamente

### Resultados Esperados

| Métrica | INSERT Directo | Procedimiento | Diferencia |
|---------|---------------|---------------|------------|
| Tiempo (100 registros) | 50-100 ms | 100-200 ms | +50-100 ms |
| Overhead | Baseline | 50-100% | — |
| Validaciones | 0 | 8 | +8 validaciones |
| Seguridad | Requiere permisos directos | Ownership chaining | Mayor control |

### Interpretación

El procedimiento almacenado es aproximadamente **50-100% más lento** debido a:
- 8 validaciones de negocio
- Manejo de errores con TRY-CATCH
- Transacciones explícitas
- Llamadas a otras tablas para validar FKs

**Sin embargo, los beneficios superan el overhead**:
- ✓ Integridad de datos garantizada
- ✓ Código reutilizable
- ✓ Mantenimiento centralizado
- ✓ Seguridad mejorada (ownership chaining)
- ✓ Auditoría más sencilla
- ✓ Prevención de estados inválidos

## Ventajas de Procedimientos y Funciones

### Ventajas de Procedimientos Almacenados

1. **Encapsulación de Lógica de Negocio**
   - Reglas centralizadas en la BD
   - Consistencia entre aplicaciones
   - Actualizaciones sin cambios en aplicaciones

2. **Validaciones Centralizadas**
   - Imposible insertar datos inválidos
   - Reglas aplicadas automáticamente
   - Menos bugs en aplicaciones cliente

3. **Seguridad Mejorada**
   - Ownership chaining
   - Control granular de permisos
   - Prevención de SQL injection
   - Auditoría simplificada

4. **Mantenimiento Simplificado**
   - Un solo lugar para cambiar lógica
   - Versionado de procedimientos
   - Rollback sencillo si hay problemas

5. **Transacciones Atómicas**
   - COMMIT/ROLLBACK automático
   - Estados consistentes garantizados
   - Manejo de errores robusto

### Ventajas de Funciones Almacenadas

1. **Reutilización de Código**
   - Cálculos complejos en un solo lugar
   - Usar en múltiples consultas y vistas
   - Consistencia en resultados

2. **Simplicidad de Consultas**
   - Lógica compleja encapsulada
   - Queries más legibles
   - Menos duplicación de código

3. **Optimización del Motor**
   - SQL Server puede optimizar funciones
   - Caché de resultados (en algunos casos)
   - Planes de ejecución eficientes

4. **Mantenibilidad**
   - Cambiar cálculo en un solo lugar
   - Actualizar sin modificar queries
   - Testing simplificado

## Desventajas y Consideraciones

### Desventajas de Procedimientos

1. **Overhead de Performance**: 50-100% más lento que INSERT directo
2. **Complejidad**: Más difícil de depurar que SQL simple
3. **Portabilidad**: Sintaxis específica de SQL Server
4. **Versioning**: Requiere estrategia de versionado

### Desventajas de Funciones

1. **Limitaciones**:
   - Funciones escalares pueden ser lentas en grandes datasets
   - No pueden modificar datos (INSERT/UPDATE/DELETE)
   - No pueden usar procedimientos almacenados

2. **Performance**:
   - Funciones escalares en WHERE pueden ser lentas
   - Considerar funciones de tabla inline para mejor rendimiento

## Integración con Seguridad (Anexo I)

Los procedimientos almacenados se integran perfectamente con el sistema de seguridad:

```sql
-- LecturaSolo_Usuario no puede insertar directamente
INSERT INTO partidos (...) VALUES (...); -- ERROR: Permission denied

-- Pero SÍ puede ejecutar el procedimiento (ownership chaining)
EXEC sp_InsertPartido @id = 100001, ...; -- ÉXITO
```

Esto permite:
- Control granular de operaciones
- Validaciones aplicadas siempre
- Auditoría centralizada
- Seguridad sin sacrificar funcionalidad

## Mejores Prácticas Implementadas

1. **Parámetros Nombrados**: Usar `@nombre` para claridad
2. **TRY-CATCH**: Manejo de errores robusto en todos los SPs
3. **Transacciones Explícitas**: BEGIN TRAN / COMMIT / ROLLBACK
4. **Validaciones Tempranas**: Fallar rápido si datos inválidos
5. **Códigos de Retorno**: Valores específicos para cada tipo de error
6. **Comentarios**: Documentar validaciones y lógica compleja
7. **SET NOCOUNT ON**: Evitar mensajes innecesarios
8. **Nombres Descriptivos**: sp_*, fn_* para identificar tipo

## Casos de Uso

### Escenario 1: Aplicación Web
- La app llama `sp_InsertPartido` para crear partidos
- Validaciones garantizadas sin código en la app
- Si reglas cambian, solo actualizar SP

### Escenario 2: Importación Masiva
- ETL llama procedimientos para cada registro
- Validaciones aplicadas a todos los datos
- Transacciones garantizan consistencia

### Escenario 3: Reportes y Analytics
- Funciones simplifican cálculos complejos
- Reutilizar en múltiples reportes
- Consistencia en métricas

## Conclusiones

La implementación de procedimientos y funciones almacenadas proporciona:

- ✓ Integridad de datos garantizada mediante validaciones
- ✓ Encapsulación de lógica de negocio
- ✓ Reutilización de código y cálculos
- ✓ Seguridad mejorada mediante ownership chaining
- ✓ Mantenimiento centralizado y simplificado
- ✓ Base sólida para auditoría y compliance

El overhead de performance (50-100%) es **ampliamente justificado** por las garantías de integridad, seguridad y mantenibilidad que proporcionan.

## Referencias

- [Stored Procedures (Database Engine)](https://docs.microsoft.com/en-us/sql/relational-databases/stored-procedures/stored-procedures-database-engine)
- [User-Defined Functions](https://docs.microsoft.com/en-us/sql/relational-databases/user-defined-functions/user-defined-functions)
- [TRY...CATCH (Transact-SQL)](https://docs.microsoft.com/en-us/sql/t-sql/language-elements/try-catch-transact-sql)
- [Ownership Chains](https://docs.microsoft.com/en-us/sql/relational-databases/security/ownership-and-user-schema-separation)
