-- =====================================================
-- BOLT - Script de creación de la base de datos (MySQL 8+)  |  Versión 2
-- Esquema de seguridad: usuario, rol, permisos y las tablas
-- intermedias usuario_rol y rol_permiso (relaciones N:M).
-- Se eliminan las tablas por rol (administrador, instructor, tic, seguridad):
-- sus atributos propios pasan a usuario como columnas opcionales.
-- =====================================================

DROP DATABASE IF EXISTS bolt;
CREATE DATABASE bolt CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bolt;

-- =====================================================
-- 1. USUARIOS, ROLES Y PERMISOS
-- =====================================================
CREATE TABLE usuario (
    id_usuario  INT AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(80)  NOT NULL,
    apellido    VARCHAR(80)  NOT NULL,
    documento   VARCHAR(20)  NOT NULL UNIQUE,
    correo      VARCHAR(120) NOT NULL UNIQUE,
    telefono    VARCHAR(20),
    contrasena  VARCHAR(255) NOT NULL,           -- almacenar hash, nunca texto plano
    estado      VARCHAR(20)  NOT NULL DEFAULT 'activo',
    -- Atributos que antes vivían en las tablas por rol (opcionales según el rol):
    turno       VARCHAR(30)  NULL,               -- Seguridad
    es_tecnica  BOOLEAN      NULL,               -- TIC
    ficha       VARCHAR(20)  NULL,               -- Instructor
    jornada     VARCHAR(30)  NULL                -- Instructor
) ENGINE=InnoDB;

CREATE TABLE rol (
    id_rol      INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol  VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE permisos (
    id_permisos    INT AUTO_INCREMENT PRIMARY KEY,
    nombre_permiso VARCHAR(80) NOT NULL UNIQUE,
    descripcion    VARCHAR(255),
    modulo         VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

-- Usuario N:M Rol
CREATE TABLE usuario_rol (
    id_usuario INT NOT NULL,
    id_rol     INT NOT NULL,
    PRIMARY KEY (id_usuario, id_rol),
    CONSTRAINT fk_ur_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_ur_rol FOREIGN KEY (id_rol)
        REFERENCES rol(id_rol) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Rol N:M Permisos
CREATE TABLE rol_permiso (
    id_rol      INT NOT NULL,
    id_permisos INT NOT NULL,
    PRIMARY KEY (id_rol, id_permisos),
    CONSTRAINT fk_rp_rol FOREIGN KEY (id_rol)
        REFERENCES rol(id_rol) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_rp_permisos FOREIGN KEY (id_permisos)
        REFERENCES permisos(id_permisos) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- Roles base del sistema
INSERT INTO rol (nombre_rol, descripcion) VALUES
    ('Administrador', 'Gestiona usuarios, ambientes, servicios y reportes'),
    ('Instructor',    'Registra solicitudes, hace seguimiento y consulta reportes'),
    ('TIC',           'Atiende solicitudes asignadas y actualiza estados'),
    ('Seguridad',     'Valida y cierra ambientes y solicitudes');

-- =====================================================
-- 2. CATÁLOGOS: AMBIENTE Y SERVICIO
-- =====================================================
CREATE TABLE ambiente (
    id_ambiente INT AUTO_INCREMENT PRIMARY KEY,
    numero      VARCHAR(20)  NOT NULL,
    nombre      VARCHAR(100) NOT NULL,
    ubicacion   VARCHAR(150) NOT NULL,
    capacidad   INT NOT NULL CHECK (capacidad > 0),
    descripcion VARCHAR(255),
    estado      VARCHAR(20) NOT NULL DEFAULT 'disponible'
) ENGINE=InnoDB;

CREATE TABLE servicio (
    id_servicio     INT AUTO_INCREMENT PRIMARY KEY,
    nombre_servicio VARCHAR(100) NOT NULL UNIQUE,
    descripcion     VARCHAR(255),
    estado          VARCHAR(20) NOT NULL DEFAULT 'activo'
) ENGINE=InnoDB;

-- =====================================================
-- 3. SOLICITUD Y SUS RELACIONES
-- =====================================================
-- Usuario (con rol Instructor) 1 --registra--> N Solicitud
CREATE TABLE solicitud (
    id_solicitud INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario   INT NOT NULL,
    fecha        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    descripcion  TEXT NOT NULL,
    prioridad    VARCHAR(20) NOT NULL DEFAULT 'media',
    estado       VARCHAR(20) NOT NULL DEFAULT 'pendiente',
    CONSTRAINT fk_solicitud_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Solicitud N:M Ambiente (corresponde)
CREATE TABLE solicitud_ambiente (
    id_solicitud INT NOT NULL,
    id_ambiente  INT NOT NULL,
    PRIMARY KEY (id_solicitud, id_ambiente),
    CONSTRAINT fk_sa_solicitud FOREIGN KEY (id_solicitud)
        REFERENCES solicitud(id_solicitud) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_sa_ambiente FOREIGN KEY (id_ambiente)
        REFERENCES ambiente(id_ambiente) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Solicitud N:M Servicio (solicita)
CREATE TABLE solicitud_servicio (
    id_solicitud INT NOT NULL,
    id_servicio  INT NOT NULL,
    PRIMARY KEY (id_solicitud, id_servicio),
    CONSTRAINT fk_ss_solicitud FOREIGN KEY (id_solicitud)
        REFERENCES solicitud(id_solicitud) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_ss_servicio FOREIGN KEY (id_servicio)
        REFERENCES servicio(id_servicio) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Solicitud 1 --adjunta--> N Evidencias
CREATE TABLE evidencia_solicitud (
    id_evidencia INT AUTO_INCREMENT PRIMARY KEY,
    id_solicitud INT NOT NULL,
    ruta_archivo VARCHAR(255) NOT NULL,
    fecha_carga  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_evsol_solicitud FOREIGN KEY (id_solicitud)
        REFERENCES solicitud(id_solicitud) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- 4. NOVEDAD DE AMBIENTE
-- =====================================================
-- Ambiente 1 --tiene--> N Novedad ; Usuario 1 --reporta--> N Novedad
CREATE TABLE novedad_ambiente (
    id_novedad  INT AUTO_INCREMENT PRIMARY KEY,
    id_ambiente INT NOT NULL,
    id_usuario  INT NOT NULL,
    fecha       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    descripcion TEXT NOT NULL,
    estado      VARCHAR(20) NOT NULL DEFAULT 'abierta',
    CONSTRAINT fk_novedad_ambiente FOREIGN KEY (id_ambiente)
        REFERENCES ambiente(id_ambiente) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_novedad_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE evidencia_novedad (
    id_evidencia INT AUTO_INCREMENT PRIMARY KEY,
    id_novedad   INT NOT NULL,
    ruta_archivo VARCHAR(255) NOT NULL,
    fecha_carga  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_evnov_novedad FOREIGN KEY (id_novedad)
        REFERENCES novedad_ambiente(id_novedad) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- 5. ASIGNACIÓN Y SEGUIMIENTO
-- =====================================================
-- Solicitud 1 --genera--> N Asignacion (permite reasignar)
-- Usuario (Administrador) 1 --asigna--> N Asignacion
-- Usuario (TIC o Seguridad) 1 --atiende--> N Asignacion
CREATE TABLE asignacion (
    id_asignacion      INT AUTO_INCREMENT PRIMARY KEY,
    id_solicitud       INT NOT NULL,
    id_usuario_asigna  INT NOT NULL,
    id_usuario_atiende INT NOT NULL,
    fecha_asignacion   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_asignacion  VARCHAR(20) NOT NULL DEFAULT 'activa',
    CONSTRAINT fk_asig_solicitud FOREIGN KEY (id_solicitud)
        REFERENCES solicitud(id_solicitud) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_asig_asigna FOREIGN KEY (id_usuario_asigna)
        REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_asig_atiende FOREIGN KEY (id_usuario_atiende)
        REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Asignacion 1 --produce--> N Seguimiento ; Usuario 1 --realiza--> N Seguimiento
CREATE TABLE seguimiento (
    id_seguimiento  INT AUTO_INCREMENT PRIMARY KEY,
    id_asignacion   INT NOT NULL,
    id_usuario      INT NOT NULL,
    fecha           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_anterior VARCHAR(20),
    estado_nuevo    VARCHAR(20) NOT NULL,
    comentario      TEXT,
    CONSTRAINT fk_seg_asignacion FOREIGN KEY (id_asignacion)
        REFERENCES asignacion(id_asignacion) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_seg_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================
-- 6. NOTIFICACIÓN
-- =====================================================
-- Usuario 1 --recibe--> N Notificacion ; Solicitud 1 --origina--> N Notificacion (opcional)
CREATE TABLE notificacion (
    id_notificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario      INT NOT NULL,
    id_solicitud    INT NULL,
    fecha           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    mensaje         VARCHAR(255) NOT NULL,
    estado          VARCHAR(20) NOT NULL DEFAULT 'no_leida',
    tipo            VARCHAR(30) NOT NULL,
    CONSTRAINT fk_notif_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_notif_solicitud FOREIGN KEY (id_solicitud)
        REFERENCES solicitud(id_solicitud) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

DELIMITER //

CREATE TRIGGER validar_asignacion_bi
BEFORE INSERT ON asignacion
FOR EACH ROW
BEGIN
    DECLARE v_es_admin INT DEFAULT 0;
    DECLARE v_es_atendedor INT DEFAULT 0;
    DECLARE v_asignaciones_activas INT DEFAULT 0;

    SELECT COUNT(*) INTO v_es_admin
    FROM usuario_rol ur
    JOIN rol r ON r.id_rol = ur.id_rol
    WHERE ur.id_usuario = NEW.id_usuario_asigna
      AND r.nombre_rol = 'Administrador';

    IF v_es_admin = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Quien asigna debe tener el rol Administrador';
    END IF;

    SELECT COUNT(*) INTO v_es_atendedor
    FROM usuario_rol ur
    JOIN rol r ON r.id_rol = ur.id_rol
    WHERE ur.id_usuario = NEW.id_usuario_atiende
      AND r.nombre_rol IN ('TIC', 'Seguridad');

    IF v_es_atendedor = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Quien atiende debe tener el rol TIC o Seguridad';
    END IF;

    IF NEW.estado_asignacion = 'activa' THEN
        SELECT COUNT(*) INTO v_asignaciones_activas
        FROM asignacion
        WHERE id_solicitud = NEW.id_solicitud
          AND estado_asignacion = 'activa';

        IF v_asignaciones_activas > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'La solicitud ya tiene una asignacion activa';
        END IF;
    END IF;
END//


CREATE TRIGGER registrar_asignacion_ai
AFTER INSERT ON asignacion
FOR EACH ROW
BEGIN
    DECLARE v_estado_anterior VARCHAR(20);

    IF NEW.estado_asignacion = 'activa' THEN
        SELECT estado INTO v_estado_anterior
        FROM solicitud
        WHERE id_solicitud = NEW.id_solicitud;

        UPDATE solicitud
        SET estado = 'asignada'
        WHERE id_solicitud = NEW.id_solicitud;

        INSERT INTO seguimiento (
            id_asignacion,
            id_usuario,
            estado_anterior,
            estado_nuevo,
            comentario
        )
        VALUES (
            NEW.id_asignacion,
            NEW.id_usuario_asigna,
            v_estado_anterior,
            'asignada',
            'Asignacion creada automaticamente'
        );
    END IF;
END//

DELIMITER ;


-- BOLT: datos de prueba integrales
-- Ejecutar DESPUES del script de creación del esquema.
-- Este archivo está pensado para ejecutarse una sola vez sobre una base recién creada.
USE bolt;

START TRANSACTION;

-- 1. Permisos y asignación de permisos a roles
INSERT INTO permisos (nombre_permiso, descripcion, modulo) VALUES
    ('usuarios.gestionar', 'Crear y administrar usuarios', 'usuarios'),
    ('solicitudes.crear', 'Registrar solicitudes', 'solicitudes'),
    ('solicitudes.consultar', 'Consultar solicitudes', 'solicitudes'),
    ('solicitudes.asignar', 'Asignar y reasignar solicitudes', 'solicitudes'),
    ('solicitudes.atender', 'Atender solicitudes asignadas', 'solicitudes'),
    ('ambientes.gestionar', 'Administrar ambientes y novedades', 'ambientes'),
    ('reportes.consultar', 'Consultar reportes del sistema', 'reportes');

INSERT INTO rol_permiso (id_rol, id_permisos)
SELECT r.id_rol, p.id_permisos
FROM rol r
CROSS JOIN permisos p
WHERE r.nombre_rol = 'Administrador';

INSERT INTO rol_permiso (id_rol, id_permisos)
SELECT r.id_rol, p.id_permisos
FROM rol r
CROSS JOIN permisos p
WHERE (r.nombre_rol = 'Instructor'
       AND p.nombre_permiso IN ('solicitudes.crear', 'solicitudes.consultar', 'ambientes.gestionar'))
   OR (r.nombre_rol = 'TIC'
       AND p.nombre_permiso IN ('solicitudes.consultar', 'solicitudes.atender'))
   OR (r.nombre_rol = 'Seguridad'
       AND p.nombre_permiso IN ('solicitudes.consultar', 'solicitudes.atender', 'ambientes.gestionar'));

-- 2. Usuarios de prueba. Clave común: ClaveDemo-2026
INSERT INTO usuario
    (nombre, apellido, documento, correo, telefono, contrasena, turno, es_tecnica, ficha, jornada)
VALUES
    ('Ana', 'Admin', 'TEST-ADM-001', 'admin.prueba@ejemplo.com', '3000000001', SHA2('ClaveDemo-2026', 256), NULL, NULL, NULL, NULL),
    ('Luis', 'Tecnico', 'TEST-TIC-001', 'tic.prueba@ejemplo.com', '3000000002', SHA2('ClaveDemo-2026', 256), NULL, TRUE, NULL, NULL),
    ('Marta', 'Instructor', 'TEST-INS-001', 'instructor.prueba@ejemplo.com', '3000000003', SHA2('ClaveDemo-2026', 256), NULL, NULL, 'FIC-2026-01', 'Diurna'),
    ('Carlos', 'Seguridad', 'TEST-SEG-001', 'seguridad.prueba@ejemplo.com', '3000000004', SHA2('ClaveDemo-2026', 256), 'Diurno', NULL, NULL, NULL);

SET @id_admin = (SELECT id_usuario FROM usuario WHERE documento = 'TEST-ADM-001');
SET @id_tic = (SELECT id_usuario FROM usuario WHERE documento = 'TEST-TIC-001');
SET @id_instructor = (SELECT id_usuario FROM usuario WHERE documento = 'TEST-INS-001');
SET @id_seguridad = (SELECT id_usuario FROM usuario WHERE documento = 'TEST-SEG-001');

INSERT INTO usuario_rol (id_usuario, id_rol)
SELECT @id_admin, id_rol FROM rol WHERE nombre_rol = 'Administrador';
INSERT INTO usuario_rol (id_usuario, id_rol)
SELECT @id_tic, id_rol FROM rol WHERE nombre_rol = 'TIC';
INSERT INTO usuario_rol (id_usuario, id_rol)
SELECT @id_instructor, id_rol FROM rol WHERE nombre_rol = 'Instructor';
INSERT INTO usuario_rol (id_usuario, id_rol)
SELECT @id_seguridad, id_rol FROM rol WHERE nombre_rol = 'Seguridad';

-- 3. Catálogos de ambientes y servicios
INSERT INTO ambiente (numero, nombre, ubicacion, capacidad, descripcion, estado) VALUES
    ('A-101', 'Aula de sistemas 1', 'Bloque A, primer piso', 30, 'Aula con equipos de cómputo', 'disponible'),
    ('A-205', 'Aula de formación 2', 'Bloque A, segundo piso', 25, 'Ambiente para formación técnica', 'disponible'),
    ('T-010', 'Taller de mantenimiento', 'Bloque técnico', 18, 'Espacio de prácticas y soporte', 'disponible');

INSERT INTO servicio (nombre_servicio, descripcion) VALUES
    ('Soporte de computador', 'Revisión y soporte técnico de equipos'),
    ('Mantenimiento de software', 'Instalación y actualización de software'),
    ('Revisión de ambiente', 'Inspección de condiciones del ambiente'),
    ('Soporte audiovisual', 'Revisión de proyector, audio y pantalla');

SET @ambiente_a101 = (SELECT id_ambiente FROM ambiente WHERE numero = 'A-101');
SET @ambiente_a205 = (SELECT id_ambiente FROM ambiente WHERE numero = 'A-205');
SET @ambiente_t010 = (SELECT id_ambiente FROM ambiente WHERE numero = 'T-010');
SET @servicio_pc = (SELECT id_servicio FROM servicio WHERE nombre_servicio = 'Soporte de computador');
SET @servicio_software = (SELECT id_servicio FROM servicio WHERE nombre_servicio = 'Mantenimiento de software');
SET @servicio_ambiente = (SELECT id_servicio FROM servicio WHERE nombre_servicio = 'Revisión de ambiente');
SET @servicio_av = (SELECT id_servicio FROM servicio WHERE nombre_servicio = 'Soporte audiovisual');

-- 4. Solicitudes de ejemplo: dos asignadas y una pendiente
INSERT INTO solicitud (id_usuario, descripcion, prioridad, estado) VALUES
    (@id_instructor, 'El computador del ambiente A-101 no enciende', 'alta', 'pendiente'),
    (@id_instructor, 'Se requiere instalar el software de diseño en varios equipos', 'media', 'pendiente'),
    (@id_instructor, 'El proyector del aula A-205 no muestra imagen', 'alta', 'pendiente');

SET @solicitud_pc = (
    SELECT id_solicitud FROM solicitud
    WHERE id_usuario = @id_instructor AND descripcion = 'El computador del ambiente A-101 no enciende'
    ORDER BY id_solicitud DESC LIMIT 1
);
SET @solicitud_software = (
    SELECT id_solicitud FROM solicitud
    WHERE id_usuario = @id_instructor AND descripcion = 'Se requiere instalar el software de diseño en varios equipos'
    ORDER BY id_solicitud DESC LIMIT 1
);
SET @solicitud_proyector = (
    SELECT id_solicitud FROM solicitud
    WHERE id_usuario = @id_instructor AND descripcion = 'El proyector del aula A-205 no muestra imagen'
    ORDER BY id_solicitud DESC LIMIT 1
);

INSERT INTO solicitud_servicio (id_solicitud, id_servicio) VALUES
    (@solicitud_pc, @servicio_pc),
    (@solicitud_software, @servicio_software),
    (@solicitud_proyector, @servicio_av);

INSERT INTO solicitud_ambiente (id_solicitud, id_ambiente) VALUES
    (@solicitud_pc, @ambiente_a101),
    (@solicitud_software, @ambiente_t010),
    (@solicitud_proyector, @ambiente_a205);

INSERT INTO evidencia_solicitud (id_solicitud, ruta_archivo) VALUES
    (@solicitud_pc, '/evidencias/solicitudes/equipo-a101.jpg'),
    (@solicitud_proyector, '/evidencias/solicitudes/proyector-a205.jpg');

-- 5. Novedades de ambiente y sus evidencias
INSERT INTO novedad_ambiente (id_ambiente, id_usuario, descripcion, estado) VALUES
    (@ambiente_a205, @id_instructor, 'Una lámpara del aula presenta intermitencia', 'abierta'),
    (@ambiente_t010, @id_seguridad, 'Se encontró una silla en mal estado', 'en_revision');

SET @novedad_lampara = (
    SELECT id_novedad FROM novedad_ambiente
    WHERE id_ambiente = @ambiente_a205
      AND descripcion = 'Una lámpara del aula presenta intermitencia'
    ORDER BY id_novedad DESC LIMIT 1
);
SET @novedad_silla = (
    SELECT id_novedad FROM novedad_ambiente
    WHERE id_ambiente = @ambiente_t010
      AND descripcion = 'Se encontró una silla en mal estado'
    ORDER BY id_novedad DESC LIMIT 1
);

INSERT INTO evidencia_novedad (id_novedad, ruta_archivo) VALUES
    (@novedad_lampara, '/evidencias/novedades/lampara-a205.jpg'),
    (@novedad_silla, '/evidencias/novedades/silla-t010.jpg');

-- 6. Asignaciones activas: los triggers actualizan las solicitudes y crean seguimiento
INSERT INTO asignacion (id_solicitud, id_usuario_asigna, id_usuario_atiende)
VALUES (@solicitud_pc, @id_admin, @id_tic);
SET @asignacion_pc = LAST_INSERT_ID();

INSERT INTO asignacion (id_solicitud, id_usuario_asigna, id_usuario_atiende)
VALUES (@solicitud_proyector, @id_admin, @id_seguridad);
SET @asignacion_proyector = LAST_INSERT_ID();

-- Seguimientos adicionales posteriores a los que crean automáticamente los triggers
INSERT INTO seguimiento
    (id_asignacion, id_usuario, estado_anterior, estado_nuevo, comentario)
VALUES
    (@asignacion_pc, @id_tic, 'asignada', 'en_proceso', 'Se inició el diagnóstico del equipo.'),
    (@asignacion_proyector, @id_seguridad, 'asignada', 'en_revision', 'Se verificará la conexión y el cableado del proyector.');

-- 7. Notificaciones vinculadas a usuarios y solicitudes
INSERT INTO notificacion (id_usuario, id_solicitud, mensaje, estado, tipo) VALUES
    (@id_instructor, @solicitud_pc, 'La solicitud de soporte del equipo A-101 fue asignada a TIC.', 'no_leida', 'asignacion'),
    (@id_tic, @solicitud_pc, 'Tienes una nueva solicitud asignada: equipo A-101.', 'no_leida', 'asignacion'),
    (@id_instructor, @solicitud_proyector, 'La solicitud del proyector A-205 fue asignada a Seguridad.', 'no_leida', 'asignacion'),
    (@id_admin, NULL, 'Los datos de prueba de BOLT fueron cargados.', 'no_leida', 'sistema');

COMMIT;

-- Comprobación rápida de los datos cargados
SELECT s.id_solicitud, s.descripcion, s.prioridad, s.estado,
       CONCAT(u.nombre, ' ', u.apellido) AS instructor,
       a.estado_asignacion,
       CONCAT(t.nombre, ' ', t.apellido) AS persona_que_atiende
FROM solicitud s
JOIN usuario u ON u.id_usuario = s.id_usuario
LEFT JOIN asignacion a ON a.id_solicitud = s.id_solicitud
                       AND a.estado_asignacion = 'activa'
LEFT JOIN usuario t ON t.id_usuario = a.id_usuario_atiende
WHERE s.id_solicitud IN (@solicitud_pc, @solicitud_software, @solicitud_proyector)
ORDER BY s.id_solicitud;





