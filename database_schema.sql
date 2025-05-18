-- Script PostgreSQL para FleetGuard360 - Feature 1: Gestión de Conductores
-- Incluye autenticación en dos pasos (2FA) según historias de usuario HU1 y HU2

-- =============================================
-- TABLA: Conductor
-- Almacena información básica de los conductores
-- =============================================
CREATE TABLE Conductor (
    ID SERIAL PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Documento_Identidad VARCHAR(20) UNIQUE NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Telefono VARCHAR(15),
    Licencia VARCHAR(50) UNIQUE NOT NULL,
    Horas_Acumuladas_Semana INTEGER DEFAULT 0,
    Activo BOOLEAN DEFAULT TRUE,
    Fecha_Registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE Conductor IS 'Registro de conductores para el sistema FleetGuard360';
COMMENT ON COLUMN Conductor.Activo IS 'Baja lógica (false = eliminado) según HU12';

-- =============================================
-- TABLA: Usuario
-- Credenciales de acceso y configuración de seguridad
-- =============================================
CREATE TABLE Usuario (
    ID SERIAL PRIMARY KEY,
    Conductor_ID INTEGER UNIQUE NOT NULL,
    Username VARCHAR(50) UNIQUE NOT NULL,
    Password_Hash VARCHAR(255) NOT NULL,
    Rol VARCHAR(20) CHECK (Rol IN ('Admin', 'Conductor')) NOT NULL,
    Intentos_Fallidos INTEGER DEFAULT 0,
    Bloqueado_Hasta TIMESTAMP,
    Doble_Autenticacion BOOLEAN DEFAULT TRUE,  -- Nuevo campo para HU2
    Fecha_Ultimo_Login TIMESTAMP,
    
    FOREIGN KEY (Conductor_ID) REFERENCES Conductor(ID)
);

COMMENT ON TABLE Usuario IS 'Sistema de autenticación para conductores y administradores';
COMMENT ON COLUMN Usuario.Doble_Autenticacion IS 'Controla si requiere código por email (true) según HU2';
COMMENT ON COLUMN Usuario.Intentos_Fallidos IS 'Límite de 5 intentos antes de bloqueo (HU1)';

-- =============================================
-- TABLA: CódigoVerificación
-- Implementación de autenticación en dos pasos (HU2)
-- =============================================
CREATE TABLE CodigoVerificacion (
    ID SERIAL PRIMARY KEY,
    Usuario_ID INTEGER NOT NULL,
    Codigo CHAR(6) NOT NULL,
    Expiracion TIMESTAMP NOT NULL,
    Usado BOOLEAN DEFAULT FALSE,
    
    FOREIGN KEY (Usuario_ID) REFERENCES Usuario(ID)
);

COMMENT ON TABLE CodigoVerificacion IS 'Almacena códigos de 6 dígitos para 2FA por email (HU2)';
COMMENT ON COLUMN CodigoVerificacion.Expiracion IS 'Caduca a los 10 minutos según criterios de aceptación HU2';

-- =============================================
-- TABLA: Turno
-- Gestión de jornadas laborales (HU5)
-- =============================================
CREATE TABLE Turno (
    ID SERIAL PRIMARY KEY,
    Conductor_ID INTEGER NOT NULL,
    Ruta_ID INTEGER,  -- Referencia a tabla de rutas (simplificado para Feature 1)
    Fecha_Hora_Inicio TIMESTAMP NOT NULL,
    Fecha_Hora_Fin TIMESTAMP NOT NULL,
    Estado VARCHAR(20) CHECK (Estado IN ('Planificado', 'EnCurso', 'Finalizado', 'Cancelado')),
    
    FOREIGN KEY (Conductor_ID) REFERENCES Conductor(ID)
);

COMMENT ON TABLE Turno IS 'Control de turnos para conductores según normativa laboral';
COMMENT ON COLUMN Turno.Estado IS 'Estado del turno para flujo de trabajo (HU5)';

-- =============================================
-- TABLA: Alerta
-- Notificaciones del sistema (HU6)
-- =============================================
CREATE TABLE Alerta (
    ID SERIAL PRIMARY KEY,
    Turno_ID INTEGER,
    Tipo VARCHAR(20) CHECK (Tipo IN ('CambioTurno', 'JornadaExtendida', 'Incumplimiento')),
    Mensaje TEXT,
    Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Leida BOOLEAN DEFAULT FALSE,
    
    FOREIGN KEY (Turno_ID) REFERENCES Turno(ID)
);

COMMENT ON TABLE Alerta IS 'Alertas generadas por el sistema (límite de horas, cambios de turno)';

-- =============================================
-- Índices para mejorar rendimiento en búsquedas (HU4)
-- =============================================
CREATE INDEX idx_conductor_email ON Conductor(Email);
CREATE INDEX idx_conductor_documento ON Conductor(Documento_Identidad);
CREATE INDEX idx_turno_conductor ON Turno(Conductor_ID);