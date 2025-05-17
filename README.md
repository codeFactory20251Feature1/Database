# Database
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

