# Informe: Manejo de Transacciones y Transacciones Anidadas

## Resumen ejecutivo

Este documento describe el diseño, implementación y pruebas de procedimientos almacenados que utilizan transacciones explícitas, transacciones anidadas y puntos de guardado (SAVE TRANSACTION) en la base de datos `tribuneros_bdi`. Se justifica el uso de transacciones, se explican las decisiones de diseño y se documentan pruebas que demuestran el comportamiento correcto de commits y rollbacks. Los scripts fuente están disponibles en `script/tema2-transacciones`.

---

## 1. Introducción

Las transacciones son fundamentales para mantener la integridad y consistencia de los datos en bases de datos relacionales. Una transacción agrupa múltiples operaciones en una unidad atómica que se ejecuta completamente o se revierte por completo. Este informe presenta una implementación práctica de transacciones explícitas y anidadas aplicada al dominio de una plataforma de opiniones sobre partidos deportivos.

### 1.1 Objetivos del proyecto

- Implementar procedimientos almacenados con manejo robusto de transacciones
- Demostrar el uso de transacciones anidadas y puntos de guardado (SAVE TRANSACTION)
- Validar el comportamiento de COMMIT y ROLLBACK en diferentes escenarios
- Aplicar mejores prácticas de manejo de errores con TRY/CATCH

---

## 2. Marco teórico

### 2.1 Transacciones en SQL Server

Una **transacción** es una secuencia de operaciones que se ejecutan como una sola unidad lógica de trabajo. Las transacciones deben cumplir con las propiedades ACID:

- **Atomicidad**: Todas las operaciones se completan o ninguna se completa
- **Consistencia**: La base de datos pasa de un estado válido a otro estado válido
- **Aislamiento**: Las transacciones concurrentes no interfieren entre sí
- **Durabilidad**: Una vez confirmada, la transacción persiste incluso ante fallos del sistema

### 2.2 Transacciones explícitas

En SQL Server, las transacciones explícitas se controlan mediante:

- `BEGIN TRANSACTION` - Inicia una transacción explícita
- `COMMIT TRANSACTION` - Confirma todos los cambios realizados
- `ROLLBACK TRANSACTION` - Revierte todos los cambios realizados
- `SAVE TRANSACTION` - Crea un punto de guardado dentro de la transacción

### 2.3 Transacciones anidadas y @@TRANCOUNT

SQL Server **no soporta verdaderas transacciones anidadas**. Cuando se ejecuta `BEGIN TRANSACTION` dentro de otra transacción, simplemente incrementa el contador `@@TRANCOUNT`:

```sql
-- @@TRANCOUNT = 0 (sin transacción activa)
BEGIN TRANSACTION Txn1;  -- @@TRANCOUNT = 1
  BEGIN TRANSACTION Txn2;  -- @@TRANCOUNT = 2 (no es una transacción real)
  COMMIT TRANSACTION;      -- @@TRANCOUNT = 1 (solo decrementa)
COMMIT TRANSACTION;        -- @@TRANCOUNT = 0 (commit real)
```

**Comportamiento importante:**
- `COMMIT` solo decrementa `@@TRANCOUNT`
- Solo el último `COMMIT` (cuando `@@TRANCOUNT` llega a 0) confirma realmente los cambios
- `ROLLBACK` siempre pone `@@TRANCOUNT` en 0 y revierte **toda** la transacción

### 2.4 Puntos de guardado (SAVE TRANSACTION)

Los puntos de guardado permiten revertir parcialmente una transacción:

```sql
BEGIN TRANSACTION;
  INSERT INTO tabla1 VALUES (1);
  SAVE TRANSACTION SavePoint1;
  
  INSERT INTO tabla2 VALUES (2);  -- Esta operación puede fallar
  
  IF ERROR
    ROLLBACK TRANSACTION SavePoint1;  -- Solo revierte desde el savepoint
  
COMMIT TRANSACTION;  -- Confirma tabla1 pero no tabla2
```

### 2.5 Mejores prácticas

1. **SET XACT_ABORT ON**: Aborta automáticamente la transacción ante cualquier error
2. **SET NOCOUNT ON**: Mejora el rendimiento al suprimir mensajes de conteo
3. **Uso de TRY/CATCH**: Captura errores y ejecuta rollback apropiado
4. **Validaciones tempranas**: Verificar condiciones antes de iniciar operaciones DML
5. **Manejo explícito de @@TRANCOUNT**: Verificar que exista una transacción activa antes de hacer rollback

---

## 3. Implementación de procedimientos transaccionales

Se implementaron 4 procedimientos almacenados que demuestran diferentes aspectos del manejo de transacciones:

### 3.1 sp_Registrar_Usuario_Completo

**Propósito:** Crear un usuario y su perfil en una transacción atómica.

**Características:**
- Transacción simple con dos operaciones (INSERT en `usuarios` e INSERT en `perfiles`)
- Si cualquier operación falla, se revierten ambas
- Usa `SET XACT_ABORT ON` para abortar automáticamente ante errores
- Manejo de errores con TRY/CATCH

**Parámetros:**
- `@usuario_id` (CHAR(36)): ID único del usuario
- `@correo` (VARCHAR(255)): Correo electrónico
- `@password` (VARCHAR(255)): Contraseña en texto plano (se hashea internamente)
- `@nombre_usuario` (VARCHAR(30)): Nombre de usuario único
- `@nombre_mostrar` (VARCHAR(60)): Nombre para mostrar (opcional)
- `@biografia` (VARCHAR(400)): Biografía del usuario (opcional)

**Ejemplo de uso:**
```sql
DECLARE @nuevo_id CHAR(36) = NEWID();

EXEC dbo.sp_Registrar_Usuario_Completo
  @usuario_id = @nuevo_id,
  @correo = 'usuario@example.com',
  @password = 'password123',
  @nombre_usuario = 'mi_usuario',
  @nombre_mostrar = 'Mi Usuario',
  @biografia = 'Fanático del fútbol';
```

### 3.2 sp_Calificar_y_Opinar

**Propósito:** Insertar una calificación y una opinión sobre un partido en una sola transacción.

**Características:**
- Validaciones previas (partido existe, está finalizado, usuario existe)
- Dos inserciones atómicas (calificación + opinión)
- Retorna los IDs generados como parámetros OUTPUT
- Si falla cualquier operación, se revierten ambas

**Parámetros:**
- `@partido_id` (INT): ID del partido
- `@usuario_id` (CHAR(36)): ID del usuario
- `@puntaje` (SMALLINT): Calificación de 1 a 5
- `@titulo` (VARCHAR(120)): Título de la opinión
- `@cuerpo` (VARCHAR(4000)): Contenido de la opinión
- `@tiene_spoilers` (SMALLINT): 1 si contiene spoilers, 0 si no
- `@calificacion_id` (INT OUTPUT): ID de la calificación creada
- `@opinion_id` (INT OUTPUT): ID de la opinión creada

**Ejemplo de uso:**
```sql
DECLARE @calif_id INT, @op_id INT;

EXEC dbo.sp_Calificar_y_Opinar
  @partido_id = 1,
  @usuario_id = 'user-guid-here',
  @puntaje = 5,
  @titulo = 'Partidazo',
  @cuerpo = 'Excelente partido de principio a fin',
  @tiene_spoilers = 1,
  @calificacion_id = @calif_id OUTPUT,
  @opinion_id = @op_id OUTPUT;
```

### 3.3 sp_Seguir_Equipo_Con_Recordatorios

**Propósito:** Agregar seguimiento a un equipo y crear recordatorios para sus próximos partidos.

**Características:**
- **Transacción anidada con SAVE TRANSACTION**
- Inserta el seguimiento del equipo (transacción externa)
- Itera sobre partidos futuros e inserta recordatorios (transacción interna)
- Si falla un recordatorio, revierte solo ese recordatorio (usa ROLLBACK TO SavePoint)
- El seguimiento del equipo y otros recordatorios se mantienen

**Parámetros:**
- `@usuario_id` (CHAR(36)): ID del usuario
- `@equipo_id` (INT): ID del equipo a seguir
- `@dias_anticipacion` (INT): Días antes del partido para enviar el recordatorio (default: 1)

**Ejemplo de uso:**
```sql
EXEC dbo.sp_Seguir_Equipo_Con_Recordatorios
  @usuario_id = 'user-guid-here',
  @equipo_id = 1,
  @dias_anticipacion = 2;
```

**Diagrama de flujo de transacciones:**
```
BEGIN TRANSACTION TxnPrincipal
  ├─ INSERT seguimiento_equipos ✓
  ├─ SAVE TRANSACTION SavePointRecordatorios
  │
  ├─ CURSOR sobre partidos futuros
  │   ├─ Partido 1: INSERT recordatorio ✓
  │   ├─ Partido 2: INSERT recordatorio ✗ (error)
  │   │   └─ ROLLBACK TO SavePointRecordatorios
  │   └─ Partido 3: INSERT recordatorio ✓
  │
COMMIT TRANSACTION TxnPrincipal
```

### 3.4 sp_Transferir_Favoritos

**Propósito:** Copiar todos los favoritos de un usuario a otro.

**Características:**
- Validaciones de usuarios (origen y destino existen, no son el mismo)
- Opción de sobrescribir favoritos existentes del destino
- Evita duplicados al copiar
- Usa una sola transacción con múltiples operaciones DML

**Parámetros:**
- `@usuario_origen` (CHAR(36)): ID del usuario origen
- `@usuario_destino` (CHAR(36)): ID del usuario destino
- `@sobrescribir` (BIT): Si es 1, elimina favoritos existentes del destino (default: 0)

**Ejemplo de uso:**
```sql
EXEC dbo.sp_Transferir_Favoritos
  @usuario_origen = 'guid-usuario-1',
  @usuario_destino = 'guid-usuario-2',
  @sobrescribir = 0;
```

---

## 4. Ejemplos de transacciones anidadas

El archivo `02_transacciones_anidadas.sql` incluye 4 ejemplos didácticos:

### 4.1 SAVE TRANSACTION básico

Demuestra cómo crear puntos de guardado y revertir parcialmente:

```sql
BEGIN TRANSACTION TxnPrincipal;
  INSERT usuario;  -- Éxito
  
  SAVE TRANSACTION SavePoint1;
  INSERT seguimiento_equipo1;  -- Éxito
  
  SAVE TRANSACTION SavePoint2;
  INSERT seguimiento_equipo2;  -- Éxito
  
  SAVE TRANSACTION SavePoint3;
  INSERT seguimiento_equipo_inexistente;  -- Error
  ROLLBACK TO SavePoint3;  -- Solo revierte esta operación
  
COMMIT TRANSACTION;  -- Usuario + equipos 1 y 2 se confirman
```

### 4.2 Transacciones multinivel

Ilustra el comportamiento de `@@TRANCOUNT` con múltiples niveles:

```sql
BEGIN TRANSACTION Nivel1;  -- @@TRANCOUNT = 1
  BEGIN TRANSACTION Nivel2;  -- @@TRANCOUNT = 2
    BEGIN TRANSACTION Nivel3;  -- @@TRANCOUNT = 3
    COMMIT;  -- @@TRANCOUNT = 2 (solo decrementa)
  COMMIT;  -- @@TRANCOUNT = 1 (solo decrementa)
COMMIT;  -- @@TRANCOUNT = 0 (commit real)
```

### 4.3 Procesamiento batch con savepoints

Procesa un lote de registros, guardando los exitosos y registrando errores:

```sql
BEGIN TRANSACTION BatchPrincipal;
  CURSOR sobre registros
    SAVE TRANSACTION SaveBatchItem;
    TRY
      INSERT registro;
    CATCH
      ROLLBACK TO SaveBatchItem;
      -- Continúa con el siguiente registro
  COMMIT;  -- Confirma todos los registros exitosos
```

### 4.4 Demostración de @@TRANCOUNT

Muestra paso a paso cómo cambia el contador de transacciones.

---

## 5. Pruebas y validación

El Script 03 demuestra una transacción que incluye dos inserciones válidas.
Como ambas operaciones son correctas, la transacción se confirma (COMMIT) y el sistema muestra ‘Transacción confirmada correctamente’.

<img width="1363" height="640" alt="image" src="https://github.com/user-attachments/assets/tema3-transacciones/03.png" />

En esta prueba forzamos un error de duplicidad de clave primaria (insertando dos veces el ID 3001) dentro de una transacción. 
Como se observa en la captura, el sistema capturó el error mediante el bloque TRY-CATCH y ejecutó el ROLLBACK correctamente, 
asegurando que no se guarden datos inconsistentes.

<img width="1550" height="432" alt="image" src="https://github.com/user-attachments/assets/tema3-transacciones/04.png" />

### 5.1 Casos de éxito (03_pruebas_transacciones.sql)

Se ejecutaron 5 pruebas exitosas:

| Prueba | Descripción | Resultado |
|--------|-------------|-----------|
| 1 | Registrar usuario completo | ✓ Usuario y perfil creados |
| 2 | Calificar y opinar | ✓ Calificación y opinión creadas |
| 3 | Seguir equipo con recordatorios | ✓ Seguimiento + 3 recordatorios |
| 4 | Transferir favoritos | ✓ 5 favoritos copiados |
| 5 | Análisis de rendimiento | ✓ Métricas IO/TIME capturadas |

### 5.2 Casos de error (04_pruebas_rollback.sql)

Se ejecutaron 5 pruebas de rollback:

| Prueba | Descripción | Comportamiento esperado | Resultado |
|--------|-------------|-------------------------|-----------|
| 1 | Correo duplicado | ROLLBACK completo | ✓ Usuario no creado |
| 2 | Partido no finalizado | ROLLBACK completo | ✓ Calificación rechazada |
| 3 | Calificación duplicada | ROLLBACK de segunda calificación | ✓ Solo una calificación existe |
| 4 | Rollback parcial con savepoint | Usuario creado, equipo inválido rechazado | ✓ Usuario + equipo válido existen |
| 5 | Error crítico (división por 0) | ROLLBACK completo | ✓ Ningún dato persistido |

### 5.3 Resultados de pruebas de rollback parcial

**Escenario:** Crear usuario, seguir equipo válido, intentar seguir equipo inválido

**Código ejecutado:**
```sql
BEGIN TRANSACTION;
  INSERT usuario;  -- ✓
  SAVE TRANSACTION SavePoint1;
  INSERT seguir_equipo_valido;  -- ✓
  SAVE TRANSACTION SavePoint2;
  INSERT seguir_equipo_invalido;  -- ✗ (error)
  ROLLBACK TO SavePoint2;
COMMIT;
```

**Verificación:**
- ✓ Usuario existe
- ✓ Seguimiento de equipo válido existe
- ✓ Seguimiento de equipo inválido NO existe

### 5.4 Resultados de pruebas de rollback completo

**Escenario:** Error crítico durante transacción compleja

**Código ejecutado:**
```sql
BEGIN TRANSACTION;
  INSERT usuario;  -- ✓
  INSERT perfil;  -- ✓
  INSERT seguimiento;  -- ✓
  DECLARE @x INT = 1/0;  -- ✗ Error crítico
  -- ROLLBACK automático por SET XACT_ABORT ON
```

**Verificación:**
- ✓ Usuario NO existe (rollback exitoso)
- ✓ Perfil NO existe (rollback exitoso)
- ✓ Seguimiento NO existe (rollback exitoso)

---

## 6. Análisis de rendimiento

### 6.1 Impacto de transacciones explícitas

Se midió el rendimiento de operaciones con y sin transacciones explícitas:

| Operación | Sin transacción explícita | Con BEGIN/COMMIT | Diferencia |
|-----------|---------------------------|------------------|------------|
| INSERT simple | ~1 ms | ~1 ms | Despreciable |
| 3 INSERT relacionados | ~3 ms | ~3 ms | Despreciable |
| INSERT + validaciones | ~2 ms | ~2-3 ms | <1 ms |

**Conclusión:** El overhead de transacciones explícitas es mínimo para operaciones OLTP típicas. Los beneficios de atomicidad y manejo de errores superan el costo.

### 6.2 Lecturas lógicas (IO)

Mediciones con `SET STATISTICS IO ON`:

```
Procedimiento: sp_Registrar_Usuario_Completo
- Tabla usuarios: 2 lecturas lógicas
- Tabla perfiles: 2 lecturas lógicas
- Total: 4 lecturas lógicas
```

```
Procedimiento: sp_Calificar_y_Opinar
- Tabla partidos: 1 lectura lógica (validación)
- Tabla usuarios: 1 lectura lógica (validación)
- Tabla calificaciones: 3 lecturas lógicas (INSERT + índice único)
- Tabla opiniones: 3 lecturas lógicas (INSERT + índice único)
- Total: 8 lecturas lógicas
```

### 6.3 Optimizaciones aplicadas

1. **SET NOCOUNT ON**: Reduce el tráfico de red al suprimir mensajes "(N filas afectadas)"
2. **Validaciones tempranas**: Verificar condiciones antes de BEGIN TRANSACTION
3. **Índices únicos**: Mejoran la validación de duplicados
4. **SET XACT_ABORT ON**: Simplifica el manejo de errores

---

## 7. Decisiones de diseño

### 7.1 ¿Cuándo usar transacciones explícitas?

✅ **SÍ usar transacciones explícitas cuando:**
- Se ejecutan múltiples operaciones DML relacionadas
- Se requiere atomicidad (todo o nada)
- Se necesita revertir operaciones bajo ciertas condiciones
- Se implementa lógica de negocio compleja

❌ **NO es necesario para:**
- Una sola operación INSERT/UPDATE/DELETE (autocommit)
- Operaciones de solo lectura (SELECT)

### 7.2 ¿Cuándo usar SAVE TRANSACTION?

✅ **SÍ usar savepoints cuando:**
- Se procesa un lote de registros donde algunos pueden fallar
- Se quiere mantener operaciones exitosas ante errores parciales
- Se implementa lógica de "intento y continuar"

❌ **NO usar si:**
- Cualquier error debe revertir toda la transacción
- La lógica es simple (no hay operaciones parciales)

### 7.3 SET XACT_ABORT ON vs TRY/CATCH

**Recomendación:** Usar **ambos** para máxima robustez:

```sql
SET XACT_ABORT ON;  -- Aborta automáticamente la transacción
BEGIN TRY
  BEGIN TRANSACTION;
    -- Operaciones
  COMMIT TRANSACTION;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;
  -- Manejo del error (log, RAISERROR, etc.)
END CATCH
```

---

## 8. Lecciones aprendidas

### 8.1 Transacciones "anidadas" en SQL Server

SQL Server **NO soporta verdaderas transacciones anidadas**. `BEGIN TRANSACTION` dentro de otra transacción solo incrementa `@@TRANCOUNT`. Para rollback parcial, se debe usar `SAVE TRANSACTION`.

### 8.2 ROLLBACK siempre es completo (excepto con savepoints)

`ROLLBACK TRANSACTION` **siempre** revierte toda la transacción, independientemente del nivel de anidamiento. Solo `ROLLBACK TO savepoint` permite rollback parcial.

### 8.3 COMMIT debe balancearse con BEGIN

Cada `BEGIN TRANSACTION` debe tener su correspondiente `COMMIT` o `ROLLBACK`. En caso de error, verificar `@@TRANCOUNT > 0` antes de hacer rollback.

### 8.4 Validaciones tempranas mejoran el rendimiento

Realizar validaciones (EXISTS, estado, permisos) antes de `BEGIN TRANSACTION` reduce el tiempo de bloqueo y mejora la concurrencia.

---

## 9. Conclusiones

1. **Las transacciones explícitas son esenciales** para mantener la integridad de datos en operaciones complejas. El overhead de rendimiento es despreciable comparado con los beneficios de atomicidad.

2. **SAVE TRANSACTION es una herramienta poderosa** para implementar lógica de recuperación parcial, especialmente útil en procesamiento por lotes.

3. **El patrón SET XACT_ABORT + TRY/CATCH** proporciona el manejo de errores más robusto para procedimientos almacenados transaccionales.

4. **SQL Server no soporta verdaderas transacciones anidadas**, pero `@@TRANCOUNT` y savepoints permiten implementar lógica de rollback selectivo.

5. **Las pruebas exhaustivas** de casos de éxito y error son fundamentales para validar el comportamiento transaccional correcto.

---

## 10. Referencias

- **Microsoft Docs - Transacciones (Motor de base de datos)**  
  https://learn.microsoft.com/es-es/sql/t-sql/language-elements/transactions-transact-sql  
  *Uso:* Sintaxis de BEGIN TRANSACTION, COMMIT, ROLLBACK y SAVE TRANSACTION

- **Microsoft Docs - TRY...CATCH (Transact-SQL)**  
  https://learn.microsoft.com/es-es/sql/t-sql/language-elements/try-catch-transact-sql  
  *Uso:* Patrones de manejo de errores en procedimientos almacenados

- **Microsoft Docs - SET XACT_ABORT (Transact-SQL)**  
  https://learn.microsoft.com/es-es/sql/t-sql/statements/set-xact-abort-transact-sql  
  *Uso:* Comportamiento de aborto automático de transacciones

- **SQLShack - Understanding SQL Server Transaction Isolation Levels**  
  https://www.sqlshack.com/understanding-sql-server-transaction-isolation-levels/  
  *Uso:* Niveles de aislamiento y su impacto en concurrencia

- **Red Gate - SQL Server Transaction Handling**  
  https://www.red-gate.com/simple-talk/databases/sql-server/t-sql-programming-sql-server/sql-server-transactions/  
  *Uso:* Mejores prácticas y patrones comunes de transacciones

---

## Apéndice: Orden de ejecución de scripts

Para reproducir el proyecto completo, ejecutar los scripts en este orden:

1. `01_procedimientos_transaccionales.sql` - Crear los 4 procedimientos almacenados
2. `02_transacciones_anidadas.sql` - Ejecutar ejemplos didácticos
3. `03_pruebas_transacciones.sql` - Ejecutar casos de éxito
4. `04_pruebas_rollback.sql` - Ejecutar casos de error
5. `05_limpieza.sql` - Eliminar procedimientos y datos de prueba

**Nota:** Asegurarse de que la base de datos `tribuneros_bdi` tenga datos iniciales (ligas, equipos, partidos) antes de ejecutar las pruebas.
