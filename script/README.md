# Scripts SQL - Tribuneros BD1

Este directorio contiene todos los scripts SQL del proyecto, organizados por funcionalidad y complejidad.

## Estructura de Directorios

```
script/
├── 00_Maestro_Ejecucion.sql          # Script maestro que ejecuta todo en orden
├── Cap09_Seguridad/                   # Anexo I: Seguridad y Permisos
│   ├── 01_Configuracion_Usuarios.sql
│   ├── 02_Configuracion_Roles.sql
│   └── 03_Pruebas_Permisos.sql
├── Cap10_Procedimientos_Funciones/    # Anexo II: SPs y Funciones
│   ├── 01_Procedimientos_Almacenados.sql
│   ├── 02_Funciones_Almacenadas.sql
│   └── 03_Pruebas_Comparativas.sql
└── Cap11_Indices/                     # Anexo III: Optimización
    ├── 01_Carga_Masiva.sql
    ├── 02_Pruebas_Performance.sql
    └── 03_Resultados_Analisis.sql
```

## Scripts Base (Directorio `script/`)

Estos scripts están en el directorio raíz `script/` del proyecto:

1. **creacion.sql** - Crea la base de datos y todas las tablas
2. **carga_inicial.sql** - Inserta datos representativos
3. **verificacion.sql** - Valida integridad de datos
4. **conteo.sql** - Verifica volúmenes cargados

## Guía de Ejecución

### Opción 1: Ejecución Automática (Recomendada para Desarrollo)

```sql
-- Desde el directorio raíz del proyecto
:r scripts/00_Maestro_Ejecucion.sql
```

Este script ejecuta automáticamente:
- Creación del esquema
- Carga de datos iniciales
- Procedimientos y funciones
- Verificaciones

Los anexos opcionales (seguridad y carga masiva) requieren ejecución manual.

### Opción 2: Ejecución Manual por Fases

#### Fase 1: Implementación Base (Requerida)

```sql
-- 1. Crear esquema
:r script/creacion.sql

-- 2. Cargar datos iniciales
:r script/carga_inicial.sql

-- 3. Verificar integridad
:r script/verificacion.sql

-- 4. Validar volúmenes
:r script/conteo.sql
```

#### Fase 2: Procedimientos y Funciones (Recomendada)

```sql
-- 1. Crear procedimientos almacenados
:r scripts/Cap10_Procedimientos_Funciones/01_Procedimientos_Almacenados.sql

-- 2. Crear funciones
:r scripts/Cap10_Procedimientos_Funciones/02_Funciones_Almacenadas.sql

-- 3. [Opcional] Ejecutar pruebas comparativas
:r scripts/Cap10_Procedimientos_Funciones/03_Pruebas_Comparativas.sql
```

#### Fase 3: Seguridad (Opcional)

**PREREQUISITO**: Configurar SQL Server en modo de autenticación mixta.

```sql
-- 1. Configurar usuarios
:r scripts/Cap09_Seguridad/01_Configuracion_Usuarios.sql

-- 2. Configurar roles
:r scripts/Cap09_Seguridad/02_Configuracion_Roles.sql

-- 3. Ejecutar pruebas de permisos
:r scripts/Cap09_Seguridad/03_Pruebas_Permisos.sql
```

#### Fase 4: Optimización con Índices (Opcional)

**ADVERTENCIA**: La carga masiva inserta 1,000,000+ registros y puede tardar 5-15 minutos.

```sql
-- 1. Carga masiva de datos (TARDA 5-15 MINUTOS)
:r scripts/Cap11_Indices/01_Carga_Masiva.sql

-- 2. Pruebas de performance con diferentes índices
:r scripts/Cap11_Indices/02_Pruebas_Performance.sql

-- 3. Análisis de resultados y consultas de diagnóstico
:r scripts/Cap11_Indices/03_Resultados_Analisis.sql
```

## Descripción Detallada de Scripts

### Anexo I: Seguridad y Permisos (Cap09_Seguridad)

#### 01_Configuracion_Usuarios.sql
- Verifica modo de autenticación mixto
- Crea usuarios: Admin_Usuario (db_owner) y LecturaSolo_Usuario (db_datareader)
- Asigna permisos diferenciados

#### 02_Configuracion_Roles.sql
- Crea rol personalizado RolLectura
- Configura permisos SELECT sobre partidos, equipos, ligas
- Crea usuarios: Usuario_ConRol y Usuario_SinRol
- Demuestra gestión de permisos mediante roles

#### 03_Pruebas_Permisos.sql
- 6 pruebas de validación de permisos
- Demuestra ownership chaining
- Valida principio de menor privilegio

**Ver documentación completa**: [docs/anexo-1-seguridad.md](../docs/anexo-1-seguridad.md)

### Anexo II: Procedimientos y Funciones (Cap10_Procedimientos_Funciones)

#### 01_Procedimientos_Almacenados.sql
- **sp_InsertPartido**: Insertar partidos con 8 validaciones
- **sp_UpdatePartido**: Modificar partidos con validaciones
- **sp_DeletePartido**: Eliminación lógica o física
- Otorga permisos EXECUTE a LecturaSolo_Usuario

#### 02_Funciones_Almacenadas.sql
- **fn_CalcularEdad**: Calcular edad desde fecha de nacimiento
- **fn_ObtenerPromedioCalificaciones**: Promedio de calificaciones de un partido
- **fn_ContarPartidosPorEstado**: Contar partidos por estado

#### 03_Pruebas_Comparativas.sql
- Compara INSERT directo vs procedimientos (100 registros)
- Mide overhead de validaciones
- Demuestra ventajas de ownership chaining
- Pruebas de UPDATE y DELETE

**Ver documentación completa**: [docs/anexo-2-procedimientos-funciones.md](../docs/anexo-2-procedimientos-funciones.md)

### Anexo III: Optimización con Índices (Cap11_Indices)

#### 01_Carga_Masiva.sql
- Inserta 1,000,000+ registros de partidos
- Distribución: 5 años (2020-2024)
- Tiempo estimado: 5-15 minutos
- Genera dataset realista para pruebas

#### 02_Pruebas_Performance.sql
- **Prueba 1**: Sin índice adicional (baseline)
- **Prueba 2**: Índice no agrupado simple
- **Prueba 3**: Índice covering (con INCLUDE)
- Captura planes de ejecución y métricas de IO
- Compara rendimiento de las tres estrategias

#### 03_Resultados_Analisis.sql
- Interpreta resultados de pruebas
- Consultas de diagnóstico (DMVs)
- Análisis de fragmentación
- Recomendaciones de mantenimiento
- Scripts de monitoreo

**Ver documentación completa**: [docs/anexo-3-indices.md](../docs/anexo-3-indices.md)

## Características de los Scripts

### Manejo de Errores

Todos los procedimientos implementan TRY-CATCH:

```sql
BEGIN TRY
    BEGIN TRANSACTION;
    -- Operaciones
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    -- Propagar error
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
```

### Validaciones

Los procedimientos incluyen validaciones exhaustivas:
- Existencia de registros
- Integridad referencial
- Reglas de negocio
- Rangos válidos

### Documentación

Todos los scripts incluyen:
- Comentarios explicativos
- Mensajes PRINT de progreso
- Documentación inline de validaciones
- Ejemplos de uso

### Idempotencia

Los scripts pueden ejecutarse múltiples veces:
- Verifican existencia antes de DROP
- Limpian datos de pruebas anteriores
- No fallan si ya existen objetos

## Requerimientos del Sistema

- **Motor**: SQL Server 2016 o superior
- **Espacio en disco**: 
  - Base: ~50 MB
  - Con carga masiva: ~1-2 GB
- **Memoria RAM**: Mínimo 2 GB
- **Tiempo de ejecución**:
  - Base: 1-2 minutos
  - Con carga masiva: 5-15 minutos adicionales

## Prerrequisitos

### Para Scripts Base
- SQL Server instalado y corriendo
- Permisos para crear base de datos
- SSMS o Azure Data Studio

### Para Anexo I (Seguridad)
- Modo de autenticación mixto habilitado
- Permisos de administrador del servidor
- Reinicio del servicio SQL Server tras cambio de modo

### Para Anexo III (Índices)
- Suficiente espacio en disco (~2 GB)
- Paciencia (5-15 minutos para carga masiva)
- SQL Server Management Studio para ver planes de ejecución

## Solución de Problemas

### Error: "Database already exists"
```sql
-- Eliminar base de datos existente
USE master;
DROP DATABASE IF EXISTS tribuneros_bdi;
```

### Error: "Login mode not supported"
Configurar modo mixto:
1. SSMS → Propiedades del servidor → Seguridad
2. Seleccionar "Modo de autenticación de SQL Server y Windows"
3. Reiniciar servicio SQL Server

### Error: "Insufficient disk space"
Para pruebas sin carga masiva, omitir Anexo III:
```sql
-- Ejecutar solo scripts base y procedimientos
-- Omitir Cap11_Indices/
```

### Error: "Timeout expired"
Aumentar timeout en SSMS:
1. Tools → Options → Query Execution
2. Aumentar "Execution timeout" a 600 segundos

## Limpieza

Para eliminar completamente la base de datos:

```sql
USE master;
GO

-- Cerrar conexiones existentes
ALTER DATABASE tribuneros_bdi SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- Eliminar base de datos
DROP DATABASE tribuneros_bdi;
GO

-- Eliminar logins de prueba (si existen)
DROP LOGIN IF EXISTS Admin_Usuario;
DROP LOGIN IF EXISTS LecturaSolo_Usuario;
DROP LOGIN IF EXISTS Usuario_ConRol;
DROP LOGIN IF EXISTS Usuario_SinRol;
GO
```

## Contribución

Al modificar scripts, seguir estas convenciones:

1. **Comentarios**: Documentar secciones y validaciones
2. **Mensajes PRINT**: Informar progreso al usuario
3. **Manejo de errores**: Usar TRY-CATCH en procedimientos
4. **Idempotencia**: Verificar existencia antes de crear/eliminar
5. **Formato**: Indentar consistentemente (2 espacios)

## Recursos Adicionales

- [Diccionario de Datos](../docs/diccionario_datos.md)
- [Anexo I: Seguridad](../docs/anexo-1-seguridad.md)
- [Anexo II: Procedimientos](../docs/anexo-2-procedimientos-funciones.md)
- [Anexo III: Índices](../docs/anexo-3-indices.md)
- [README Principal](../README.md)

## Contacto y Soporte

Para preguntas o problemas:
1. Revisar documentación en `/docs`
2. Consultar comentarios inline en scripts
3. Revisar issues del repositorio

---

**Última actualización**: Octubre 2025 
**Versión**: 2.0 (con anexos técnicos)  
**Licencia**: MIT
