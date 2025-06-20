# Fleetguard feature 1 Database
### Descripción 
# Script SQL para FleetGuard360

Este archivo contiene el esquema de la base de PostgreSQL para la Feature 1 (Gestión de Conductores).

## Tablas principales
- `Conductor`: Datos de conductores.
- `Usuario`: Credenciales y autenticación.
- `Turno`: Asignación de jornadas.

## Ejecución
```bash
psql -U tu_usuario -d tu_basedatos -f fleetguard360_schema.sql
```

#### Esta seccion del repositorio está realizado por el quipo de bases de datos del proyecto fleetguard, para el codefactory20251-feqature1
#### está compuesto por el diagrama E-R y los script de generación y manipulación en postgreesql
 

## Diagrama E-R

```mermaid
---
config:
  theme: neo-dark
---
erDiagram
    USUARIO ||--o{ CONDUCTOR : "puede ser"
    USUARIO {
        int id PK
        string email UK
        string password_hash
        string rol
        datetime bloqueo_hasta
        int intentos_fallidos
    }
    CONDUCTOR ||--o{ TURNO : "tiene"
    CONDUCTOR ||--o{ LICENCIA : "posee"
    CONDUCTOR ||--o{ ALERTA : "recibe"
    CONDUCTOR {
        int id PK
        string nombre
        string documento_identidad UK
        string telefono
        int usuario_id FK
    }
    LICENCIA {
        int id PK
        string numero UK
        date fecha_expiracion
        int conductor_id FK
    }
    TURNO ||--o{ RUTA : "usa"
    TURNO {
        int id PK
        datetime inicio
        datetime fin
        int conductor_id FK
        int ruta_id FK
        string estado
    }
    RUTA {
        int id PK
        string nombre
        string origen
        string destino
    }
    NOTIFICACION ||--o{ TURNO : "relacionada"
    NOTIFICACION {
        int id PK
        string tipo
        string mensaje
        datetime fecha
        int turno_id FK
        bool leida
    }
    ALERTA {
        int id PK
        string tipo
        string descripcion
        datetime fecha
        int conductor_id FK
    }

```


## Actualizacion diagrama MER

```mermaid
---
config:
  theme: redux
---
erDiagram
    USUARIO ||--o{ CONDUCTOR : "puede_ser"
    USUARIO ||--o{ AUDITORIA_LOGIN : "registra"
    USUARIO ||--o{ SESION : "tiene"
    USUARIO {
        BIGINT id PK
        VARCHAR email UK "NOT NULL"
        VARCHAR password_hash "NOT NULL"
        ENUM rol "admin,conductor,supervisor"
        TIMESTAMP bloqueo_hasta "NULL"
        INTEGER intentos_fallidos "DEFAULT 0"
        TIMESTAMP fecha_creacion "DEFAULT NOW()"
        TIMESTAMP fecha_actualizacion "DEFAULT NOW()"
        BOOLEAN activo "DEFAULT true"
    }
    CONDUCTOR ||--o{ TURNO : "asignado_a"
    CONDUCTOR ||--o{ LICENCIA : "posee"
    CONDUCTOR ||--o{ EVALUACION : "recibe"
    CONDUCTOR {
        BIGINT id PK
        VARCHAR nombre "NOT NULL"
        VARCHAR documento_identidad UK "NOT NULL"
        VARCHAR telefono "NOT NULL"
        VARCHAR direccion
        DATE fecha_nacimiento
        ENUM estado_civil "soltero,casado,viudo,divorciado"
        BIGINT usuario_id FK "NOT NULL"
        TIMESTAMP fecha_contratacion "DEFAULT NOW()"
        DECIMAL salario_base "DECIMAL(10,2)"
        BOOLEAN activo "DEFAULT true"
    }
    LICENCIA {
        BIGINT id PK
        VARCHAR numero UK "NOT NULL"
        ENUM categoria "A1,A2,B1,B2,B3,C1,C2,C3"
        DATE fecha_expedicion "NOT NULL"
        DATE fecha_vencimiento "NOT NULL"
        VARCHAR entidad_expedidora
        BIGINT conductor_id FK "NOT NULL"
        BOOLEAN activa "DEFAULT true"
    }
    RUTA ||--o{ TURNO : "utilizada_en"
    RUTA ||--o{ PARADA : "contiene"
    RUTA {
        BIGINT id PK
        VARCHAR nombre UK "NOT NULL"
        VARCHAR origen "NOT NULL"
        VARCHAR destino "NOT NULL"
        TEXT descripcion
        DECIMAL distancia_km "DECIMAL(8,2)"
        INTEGER tiempo_estimado_minutos
        DECIMAL tarifa_base "DECIMAL(8,2)"
        BOOLEAN activa "DEFAULT true"
        TIMESTAMP fecha_creacion "DEFAULT NOW()"
    }
    PARADA {
        BIGINT id PK
        VARCHAR nombre "NOT NULL"
        VARCHAR direccion "NOT NULL"
        DECIMAL latitud "DECIMAL(10,8)"
        DECIMAL longitud "DECIMAL(11,8)"
        INTEGER orden_secuencia "NOT NULL"
        INTEGER tiempo_parada_minutos "DEFAULT 5"
        BIGINT ruta_id FK "NOT NULL"
    }
    TURNO ||--o{ NOTIFICACION : "genera"
    TURNO ||--o{ INCIDENCIA : "puede_tener"
    TURNO {
        BIGINT id PK
        DATETIME inicio "NOT NULL"
        DATETIME fin "NOT NULL"
        ENUM estado "programado,en_curso,completado,cancelado"
        TEXT observaciones
        BIGINT conductor_id FK "NOT NULL"
        BIGINT ruta_id FK "NOT NULL"
        DECIMAL horas_trabajadas "GENERATED ALWAYS AS (TIMESTAMPDIFF(MINUTE, inicio, fin)/60.0)"
        TIMESTAMP fecha_creacion "DEFAULT NOW()"
        BIGINT creado_por FK "NOT NULL"
    }
    NOTIFICACION {
        BIGINT id PK
        ENUM tipo "cambio_turno,alerta_velocidad,llegada_parada,vencimiento_licencia,incidencia"
        VARCHAR asunto "NOT NULL"
        TEXT mensaje "NOT NULL"
        TIMESTAMP fecha_envio "DEFAULT NOW()"
        BOOLEAN leida "DEFAULT false"
        ENUM prioridad "baja,media,alta,critica"
        BIGINT turno_id FK
        BIGINT conductor_id FK
        JSON metadata
    }
    INCIDENCIA {
        BIGINT id PK
        ENUM tipo "retraso,accidente,vehiculo_danado,conducta_inadecuada,otros"
        VARCHAR titulo "NOT NULL"
        TEXT descripcion "NOT NULL"
        ENUM gravedad "leve,moderada,grave,critica"
        TIMESTAMP fecha_incidencia "NOT NULL"
        BIGINT turno_id FK "NOT NULL"
        BIGINT reportado_por FK "NOT NULL"
        ENUM estado "reportada,en_revision,resuelta,cerrada"
        TEXT resolucion
    }
    AUDITORIA_LOGIN {
        BIGINT id PK
        BIGINT usuario_id FK "NOT NULL"
        TIMESTAMP fecha_intento "DEFAULT NOW()"
        VARCHAR ip_address
        VARCHAR user_agent
        BOOLEAN exitoso "NOT NULL"
        VARCHAR motivo_fallo
    }
    SESION {
        BIGINT id PK
        BIGINT usuario_id FK "NOT NULL"
        VARCHAR token_jwt "NOT NULL"
        TIMESTAMP fecha_inicio "DEFAULT NOW()"
        TIMESTAMP fecha_expiracion "NOT NULL"
        VARCHAR ip_address
        BOOLEAN activa "DEFAULT true"
    }
    EVALUACION {
        BIGINT id PK
        BIGINT conductor_id FK "NOT NULL"
        DATE fecha_evaluacion "NOT NULL"
        DECIMAL puntaje "DECIMAL(3,2) CHECK (puntaje >= 0 AND puntaje <= 10)"
        TEXT observaciones
        BIGINT evaluado_por FK "NOT NULL"
        ENUM tipo "mensual,semestral,anual,extraordinaria"
    }


```
