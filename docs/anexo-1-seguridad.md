# Anexo I — Seguridad y Gestión de Permisos en SQL Server

## Introducción

Este anexo documenta la implementación de seguridad a nivel de usuarios y roles en la base de datos Tribuneros, demostrando los principios de seguridad en SQL Server: autenticación, autorización, y el principio de menor privilegio.

## Objetivos

- Configurar el servidor SQL en modo de autenticación mixto
- Implementar permisos a nivel de usuario
- Implementar permisos a nivel de rol
- Demostrar el concepto de "ownership chaining" (cadena de propiedad)
- Validar que los permisos funcionen correctamente

## Prerrequisitos

### Configuración del Servidor

Para ejecutar estos scripts, el servidor SQL Server debe estar configurado en **modo de autenticación mixto** (Windows + SQL Server):

1. Abrir SQL Server Management Studio (SSMS)
2. Conectar al servidor
3. Click derecho en el servidor → Propiedades
4. Sección "Seguridad" → Modo de autenticación del servidor
5. Seleccionar "Modo de autenticación de SQL Server y Windows"
6. Reiniciar el servicio SQL Server

## Estructura de Scripts

### Script 1: Configuración de Usuarios
**Archivo**: `01_Configuracion_Usuarios.sql`

Este script crea dos usuarios con diferentes niveles de permisos:

#### Admin_Usuario
- **Login**: Admin_Usuario
- **Contraseña**: Admin123! (cambiar en producción)
- **Rol**: db_owner
- **Permisos**: Control total sobre la base de datos
  - SELECT, INSERT, UPDATE, DELETE sobre todas las tablas
  - CREATE, ALTER, DROP de objetos
  - EXECUTE sobre procedimientos y funciones
  - Administración de seguridad

#### LecturaSolo_Usuario
- **Login**: LecturaSolo_Usuario
- **Contraseña**: Lectura123! (cambiar en producción)
- **Rol**: db_datareader
- **Permisos**:
  - SELECT sobre todas las tablas
  - EXECUTE sobre procedimientos específicos (agregado en Cap 10)
  - NO puede insertar, actualizar o eliminar directamente

### Script 2: Configuración de Roles
**Archivo**: `02_Configuracion_Roles.sql`

Este script demuestra la gestión de permisos mediante roles personalizados:

#### RolLectura (Rol personalizado)
- **Tipo**: Database Role
- **Permisos**:
  - SELECT sobre tabla `partidos`
  - SELECT sobre tabla `equipos`
  - SELECT sobre tabla `ligas`
  - Sin acceso a otras tablas (usuarios, calificaciones, opiniones, etc.)

#### Usuario_ConRol
- **Login**: Usuario_ConRol
- **Contraseña**: ConRol123!
- **Rol**: RolLectura
- **Permisos**: Heredados del rol (SELECT sobre partidos, equipos, ligas)

#### Usuario_SinRol
- **Login**: Usuario_SinRol
- **Contraseña**: SinRol123!
- **Rol**: Ninguno (solo public)
- **Permisos**: Ninguno sobre tablas específicas

### Script 3: Pruebas de Permisos
**Archivo**: `03_Pruebas_Permisos.sql`

Este script valida que los permisos configurados funcionan correctamente mediante una serie de pruebas:

#### Pruebas Realizadas

1. **Admin_Usuario - INSERT Directo**: ✓ Debe funcionar
2. **LecturaSolo_Usuario - INSERT Directo**: ✗ Debe fallar (sin permiso)
3. **LecturaSolo_Usuario - SELECT**: ✓ Debe funcionar
4. **Usuario_ConRol - SELECT en Tablas Permitidas**: ✓ Debe funcionar (partidos, equipos, ligas)
5. **Usuario_ConRol - SELECT en Tabla NO Permitida**: ✗ Debe fallar (usuarios)
6. **Usuario_SinRol - SELECT**: ✗ Debe fallar (sin permisos)

## Conceptos Clave

### Ownership Chaining (Cadena de Propiedad)

Uno de los conceptos más importantes demostrados en este anexo es el **ownership chaining**. Este mecanismo permite que un usuario sin permisos directos sobre una tabla pueda modificar datos a través de un procedimiento almacenado.

**Ejemplo**:
- `LecturaSolo_Usuario` tiene permiso `db_datareader` (solo lectura)
- NO puede ejecutar INSERT directo en la tabla `partidos`
- SÍ puede ejecutar el procedimiento `sp_InsertPartido` (con permiso EXECUTE)
- El procedimiento inserta en `partidos` usando los permisos de su propietario (dbo)
- Resultado: inserción exitosa sin permisos directos sobre la tabla

**Ventajas**:
- Control granular de acceso
- Validaciones de negocio centralizadas
- Auditoría mejorada (todos los cambios pasan por SPs)
- Prevención de SQL injection

### Principio de Menor Privilegio

Cada usuario tiene únicamente los permisos necesarios para realizar su trabajo:

- **Admin_Usuario**: Control total (solo para administradores)
- **LecturaSolo_Usuario**: Solo lectura + procedimientos específicos
- **Usuario_ConRol**: Solo consulta de datos públicos (partidos, equipos)
- **Usuario_SinRol**: Sin acceso (caso de prueba)

## Resultados Esperados

### Matriz de Permisos

| Usuario | SELECT partidos | INSERT partidos | EXECUTE sp_InsertPartido | SELECT usuarios |
|---------|----------------|-----------------|-------------------------|-----------------|
| Admin_Usuario | ✓ | ✓ | ✓ | ✓ |
| LecturaSolo_Usuario | ✓ | ✗ | ✓ | ✓ |
| Usuario_ConRol | ✓ | ✗ | ✗ | ✗ |
| Usuario_SinRol | ✗ | ✗ | ✗ | ✗ |

### Salida de Pruebas

Cuando se ejecuta `03_Pruebas_Permisos.sql`, se espera ver:

```
PRUEBA 1: Admin_Usuario - INSERT DIRECTO
RESULTADO: ÉXITO - Admin_Usuario puede insertar directamente.

PRUEBA 2: LecturaSolo_Usuario - INSERT DIRECTO
RESULTADO: CORRECTO - Permiso denegado (esperado).
Mensaje: The INSERT permission was denied on the object 'partidos'...

PRUEBA 3: LecturaSolo_Usuario - SELECT
RESULTADO: ÉXITO - LecturaSolo_Usuario puede leer datos.
Partidos en la base de datos: X

[... más pruebas ...]
```

## Mejores Prácticas Implementadas

1. **Contraseñas Complejas**: Aunque simplificadas para pruebas, se recomienda usar contraseñas más seguras en producción.

2. **CHECK_POLICY = OFF**: Desactivado para simplicidad en pruebas. En producción, activar las políticas de contraseñas.

3. **Roles Personalizados**: Preferir roles personalizados sobre permisos directos para facilitar administración.

4. **Procedimientos Almacenados**: Usar SPs para operaciones de escritura mejora seguridad y control.

5. **Auditoría**: Considerar implementar triggers de auditoría en operaciones sensibles.

## Casos de Uso

### Escenario 1: Aplicación Web de Lectura
- Usuario de la aplicación: `LecturaSolo_Usuario`
- La aplicación muestra partidos y estadísticas
- Los usuarios pueden insertar calificaciones (vía SP)
- No pueden modificar directamente las tablas base

### Escenario 2: Panel de Administración
- Usuario administrador: `Admin_Usuario`
- Acceso completo para mantenimiento
- Crear/modificar/eliminar cualquier dato
- Configurar estructura de BD

### Escenario 3: API Pública
- Usuario API: `Usuario_ConRol` con `RolLectura`
- Expone solo datos públicos (partidos, equipos, ligas)
- No expone datos sensibles (usuarios, emails)
- Control granular de información expuesta

## Limpieza y Mantenimiento

Para eliminar los usuarios y roles de prueba:

```sql
-- Eliminar usuarios de BD
DROP USER IF EXISTS Admin_Usuario;
DROP USER IF EXISTS LecturaSolo_Usuario;
DROP USER IF EXISTS Usuario_ConRol;
DROP USER IF EXISTS Usuario_SinRol;

-- Eliminar logins de servidor
DROP LOGIN IF EXISTS Admin_Usuario;
DROP LOGIN IF EXISTS LecturaSolo_Usuario;
DROP LOGIN IF EXISTS Usuario_ConRol;
DROP LOGIN IF EXISTS Usuario_SinRol;

-- Eliminar rol personalizado
DROP ROLE IF EXISTS RolLectura;
```

## Conclusiones

La implementación de seguridad mediante usuarios y roles en SQL Server proporciona:

- ✓ Control granular de acceso a datos
- ✓ Separación de responsabilidades
- ✓ Cumplimiento del principio de menor privilegio
- ✓ Flexibilidad mediante ownership chaining
- ✓ Base para auditoría y compliance

Este enfoque es fundamental para proteger datos sensibles y cumplir con regulaciones como GDPR, HIPAA u otras normativas de protección de datos.

## Referencias

- [SQL Server Security Best Practices](https://docs.microsoft.com/en-us/sql/relational-databases/security/sql-server-security-best-practices)
- [Ownership Chains](https://docs.microsoft.com/en-us/sql/relational-databases/security/ownership-and-user-schema-separation)
- [Database-Level Roles](https://docs.microsoft.com/en-us/sql/relational-databases/security/authentication-access/database-level-roles)
