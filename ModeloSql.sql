DROP DATABASE IF EXISTS inmobiliaria;
CREATE DATABASE inmobiliaria;
USE inmobiliaria;

-- Catalogos 
CREATE TABLE tipo_documento (
    tipo_documento_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE propiedad_tipo (
    propiedad_tipo_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE propiedad_estado (
    propiedad_estado_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL UNIQUE
) ;

CREATE TABLE contrato_tipo (
    contrato_tipo_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE contrato_estado (
    contrato_estado_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE pago_metodo (
    pago_metodo_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL UNIQUE
);

-- Cliente y agente 
CREATE TABLE cliente (
    cliente_id INT AUTO_INCREMENT PRIMARY KEY,
    tipo_documento_id INT NOT NULL,
    nro_documento VARCHAR(30) NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    telefono VARCHAR(30),
    email VARCHAR(120),
    direccion VARCHAR(200),
    UNIQUE (tipo_documento_id, nro_documento),
    FOREIGN KEY (tipo_documento_id) REFERENCES tipo_documento(tipo_documento_id)
) ENGINE=InnoDB;

CREATE TABLE agente (
    agente_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    telefono VARCHAR(30),
    email VARCHAR(120),
    comision_default_pct DECIMAL(5,2) NOT NULL DEFAULT 0.00
);

-- Propiedad 
CREATE TABLE propiedad (
    propiedad_id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_interno VARCHAR(30) NOT NULL UNIQUE,
    propiedad_tipo_id INT NOT NULL,
    propiedad_estado_id INT NOT NULL,
    agente_id INT NULL,
    direccion VARCHAR(200) NOT NULL,
    barrio VARCHAR(120),
    area_m2 DECIMAL(10,2),
    precio_venta DECIMAL(14,2),
    canon_sugerido DECIMAL(14,2),
    FOREIGN KEY (propiedad_tipo_id) REFERENCES propiedad_tipo(propiedad_tipo_id),
    FOREIGN KEY (propiedad_estado_id) REFERENCES propiedad_estado(propiedad_estado_id),
    FOREIGN KEY (agente_id) REFERENCES agente(agente_id)
);

-- Intereses 
CREATE TABLE cliente_interes (
    interes_id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    propiedad_id INT NOT NULL,
    contrato_tipo_id INT NOT NULL,
    fecha_interes DATE NOT NULL,
    observaciones VARCHAR(300),
    FOREIGN KEY (cliente_id) REFERENCES cliente(cliente_id),
    FOREIGN KEY (propiedad_id) REFERENCES propiedad(propiedad_id),
    FOREIGN KEY (contrato_tipo_id) REFERENCES contrato_tipo(contrato_tipo_id)
);

-- Contratos 
CREATE TABLE contrato (
    contrato_id INT AUTO_INCREMENT PRIMARY KEY,
    contrato_tipo_id INT NOT NULL,
    contrato_estado_id INT NOT NULL,
    propiedad_id INT NOT NULL,
    cliente_id INT NOT NULL,
    agente_id INT NOT NULL,
    fecha_firma DATE NOT NULL,
    FOREIGN KEY (contrato_tipo_id) REFERENCES contrato_tipo(contrato_tipo_id),
    FOREIGN KEY (contrato_estado_id) REFERENCES contrato_estado(contrato_estado_id),
    FOREIGN KEY (propiedad_id) REFERENCES propiedad(propiedad_id),
    FOREIGN KEY (cliente_id) REFERENCES cliente(cliente_id),
FOREIGN KEY (agente_id) REFERENCES agente(agente_id)
);

-- Contrato arriendo
CREATE TABLE contrato_arriendo (
    contrato_id INT PRIMARY KEY,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NULL,
    canon_mensual DECIMAL(14,2) NOT NULL,
    dia_pago TINYINT NOT NULL,
    deposito DECIMAL(14,2) DEFAULT 0.00,
    FOREIGN KEY (contrato_id) REFERENCES contrato(contrato_id)
);

--  Contrato venta 
CREATE TABLE contrato_venta (
    contrato_id INT PRIMARY KEY,
    fecha_cierre DATE NULL,
    precio_venta DECIMAL(14,2) NOT NULL,
    comision_pct_aplicada DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    FOREIGN KEY (contrato_id) REFERENCES contrato(contrato_id)
);

-- Pagos 
CREATE TABLE pago (
    pago_id INT AUTO_INCREMENT PRIMARY KEY,
    contrato_id INT NOT NULL,
    fecha_pago DATE NOT NULL,
    valor DECIMAL(14,2) NOT NULL,
    pago_metodo_id INT NOT NULL,
    periodo CHAR(7),
    referencia VARCHAR(80),
    FOREIGN KEY (contrato_id) REFERENCES contrato(contrato_id),
    FOREIGN KEY (pago_metodo_id) REFERENCES pago_metodo(pago_metodo_id)
);

--  Auditoria
CREATE TABLE aud_propiedad_estado (
    aud_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    propiedad_id INT NOT NULL,
    estado_anterior_id INT NOT NULL,
    estado_nuevo_id INT NOT NULL,
    fecha_cambio TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_mysql VARCHAR(100) NOT NULL,
    FOREIGN KEY (propiedad_id) REFERENCES propiedad(propiedad_id),
    FOREIGN KEY (estado_anterior_id) REFERENCES propiedad_estado(propiedad_estado_id),
    FOREIGN KEY (estado_nuevo_id) REFERENCES propiedad_estado(propiedad_estado_id)
);

CREATE TABLE aud_contrato (
    aud_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    contrato_id INT NOT NULL,
    evento VARCHAR(20) NOT NULL,
    fecha_evento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_mysql VARCHAR(100) NOT NULL,
    FOREIGN KEY (contrato_id) REFERENCES contrato(contrato_id)
);

--  Reporte mensual
CREATE TABLE reporte_pagos_pendientes (
    reporte_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    periodo CHAR(7) NOT NULL,
    contrato_id INT NOT NULL,
    propiedad_id INT NOT NULL,
    cliente_id INT NOT NULL,
    canon_mensual_snapshot DECIMAL(14,2) NOT NULL,
    total_pagado DECIMAL(14,2) NOT NULL,
    deuda DECIMAL(14,2) NOT NULL,
    generado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (contrato_id) REFERENCES contrato(contrato_id),
    FOREIGN KEY (propiedad_id) REFERENCES propiedad(propiedad_id),
    FOREIGN KEY (cliente_id) REFERENCES cliente(cliente_id)
);

-- INSERTS Y DATOS DE PRUEBA


INSERT INTO tipo_documento (tipo_documento_id, nombre) VALUES
(1, 'CC'),
(2, 'TI'),
(3, 'CE');

INSERT INTO propiedad_tipo (propiedad_tipo_id, nombre) VALUES
(1, 'Casa'),
(2, 'Apartamento'),
(3, 'Local');

INSERT INTO propiedad_estado (propiedad_estado_id, nombre) VALUES
(1, 'Disponible'),
(2, 'Arrendada'),
(3, 'Vendida');

INSERT INTO contrato_tipo (contrato_tipo_id, nombre) VALUES
(1, 'Arriendo'),
(2, 'Venta');

INSERT INTO contrato_estado (contrato_estado_id, nombre) VALUES
(1, 'Activo'),
(2, 'Finalizado'),
(3, 'Anulado');

INSERT INTO pago_metodo (pago_metodo_id, nombre) VALUES
(1, 'Efectivo'),
(2, 'Transferencia'),
(3, 'Tarjeta');


INSERT INTO agente (agente_id, nombre, telefono, email, comision_default_pct) VALUES
(1, 'Laura Rojas', '3001112233', 'laura@inmo.com', 3.00),
(2, 'Carlos Pérez', '3002223344', 'carlos@inmo.com', 2.50);


INSERT INTO cliente (cliente_id, tipo_documento_id, nro_documento, nombre, telefono, email, direccion) VALUES
(1, 1, '10101010', 'Ana Gómez', '3105551111', 'ana@gmail.com', 'Cra 10 # 20-30'),
(2, 1, '20202020', 'Juan Díaz', '3105552222', 'juan@gmail.com', 'Cll 50 # 8-12');


INSERT INTO propiedad (
    propiedad_id, codigo_interno, propiedad_tipo_id, propiedad_estado_id, agente_id,
    direccion, barrio, area_m2, precio_venta, canon_sugerido
) VALUES
(1, 'P-001', 1, 1, 1, 'Cra 15 # 90-20', 'Chicó', 180.00, 650000000.00, 3000000.00),
(2, 'P-002', 2, 2, 1, 'Cll 72 # 11-45', 'Chapinero', 75.00, 350000000.00, 1800000.00),
(3, 'P-003', 3, 3, 2, 'Av 19 # 100-10', 'Cedritos', 40.00, 300000000.00, 2500000.00);

INSERT INTO cliente_interes (interes_id, cliente_id, propiedad_id, contrato_tipo_id, fecha_interes, observaciones) VALUES
(1, 1, 2, 1, '2026-01-20', 'Quiere arriendo desde febrero'),
(2, 2, 1, 2, '2026-02-10', 'Interesado en compra (pregunta por parqueadero)');

INSERT INTO contrato (
    contrato_id, contrato_tipo_id, contrato_estado_id, propiedad_id, cliente_id, agente_id, fecha_firma
) VALUES
(1, 1, 1, 2, 1, 1, '2026-01-25');

INSERT INTO contrato_arriendo (
    contrato_id, fecha_inicio, fecha_fin, canon_mensual, dia_pago, deposito
) VALUES
(1, '2026-02-01', '2027-01-31', 1800000.00, 5, 1800000.00);

INSERT INTO contrato (
    contrato_id, contrato_tipo_id, contrato_estado_id, propiedad_id, cliente_id, agente_id, fecha_firma
) VALUES
(2, 2, 2, 3, 2, 2, '2026-02-15');

INSERT INTO contrato_venta (
    contrato_id, fecha_cierre, precio_venta, comision_pct_aplicada
) VALUES
(2, '2026-02-28', 300000000.00, 2.50);

INSERT INTO pago (pago_id, contrato_id, fecha_pago, valor, pago_metodo_id, periodo, referencia) VALUES
(1, 1, '2026-02-05', 1000000.00, 2, '2026-02', 'TRX-0001');

INSERT INTO agente (nombre, telefono, email, comision_default_pct) VALUES
('María Torres', '3003334455', 'maria@inmo.com', 3.50),
('Andrés Luna',  '3004445566', 'andres@inmo.com', 2.00);

INSERT INTO cliente (tipo_documento_id, nro_documento, nombre, telefono, email, direccion) VALUES
((SELECT tipo_documento_id FROM tipo_documento WHERE nombre='CC' LIMIT 1), '30303030', 'Sofía Ramírez', '3105553333', 'sofia@gmail.com', 'Cra 7 # 45-10'),
((SELECT tipo_documento_id FROM tipo_documento WHERE nombre='CC' LIMIT 1), '40404040', 'Miguel Castro', '3105554444', 'miguel@gmail.com', 'Cll 80 # 15-20'),
((SELECT tipo_documento_id FROM tipo_documento WHERE nombre='CE' LIMIT 1), 'CE-5050',  'Valentina Ruiz', '3105555555', 'vale@gmail.com', 'Av 68 # 20-33');


INSERT INTO propiedad
(codigo_interno, propiedad_tipo_id, propiedad_estado_id, agente_id, direccion, barrio, area_m2, precio_venta, canon_sugerido)
VALUES
('P-004',
    (SELECT propiedad_tipo_id FROM propiedad_tipo WHERE nombre='Apartamento' LIMIT 1),
    (SELECT propiedad_estado_id FROM propiedad_estado WHERE nombre='Disponible' LIMIT 1),
    (SELECT agente_id FROM agente WHERE email='maria@inmo.com' LIMIT 1),
    'Cll 63 # 9-22', 'Chapinero', 62.50, 280000000.00, 1700000.00),

('P-005',
    (SELECT propiedad_tipo_id FROM propiedad_tipo WHERE nombre='Casa' LIMIT 1),
    (SELECT propiedad_estado_id FROM propiedad_estado WHERE nombre='Disponible' LIMIT 1),
    (SELECT agente_id FROM agente WHERE email='andres@inmo.com' LIMIT 1),
    'Cra 30 # 12-40', 'Teusaquillo', 145.00, 520000000.00, 2600000.00),

('P-006',
    (SELECT propiedad_tipo_id FROM propiedad_tipo WHERE nombre='Local' LIMIT 1),
    (SELECT propiedad_estado_id FROM propiedad_estado WHERE nombre='Disponible' LIMIT 1),
    (SELECT agente_id FROM agente WHERE email='maria@inmo.com' LIMIT 1),
    'Av 13 # 60-05', 'Chapinero', 35.00, 210000000.00, 2200000.00),

('P-007',
    (SELECT propiedad_tipo_id FROM propiedad_tipo WHERE nombre='Apartamento' LIMIT 1),
    (SELECT propiedad_estado_id FROM propiedad_estado WHERE nombre='Disponible' LIMIT 1),
    (SELECT agente_id FROM agente WHERE email='andres@inmo.com' LIMIT 1),
    'Cll 147 # 12-15', 'Cedritos', 80.00, 390000000.00, 2000000.00);

INSERT INTO cliente_interes (cliente_id, propiedad_id, contrato_tipo_id, fecha_interes, observaciones)
VALUES
(
    (SELECT cliente_id FROM cliente WHERE nro_documento='30303030' LIMIT 1),
    (SELECT propiedad_id FROM propiedad WHERE codigo_interno='P-004' LIMIT 1),
    (SELECT contrato_tipo_id FROM contrato_tipo WHERE nombre='Arriendo' LIMIT 1),
    '2026-02-20',
    'Quiere mudarse en marzo'
),
(
    (SELECT cliente_id FROM cliente WHERE nro_documento='40404040' LIMIT 1),
    (SELECT propiedad_id FROM propiedad WHERE codigo_interno='P-005' LIMIT 1),
    (SELECT contrato_tipo_id FROM contrato_tipo WHERE nombre='Venta' LIMIT 1),
    '2026-02-25',
    'Pregunta por financiación'
),
(
    (SELECT cliente_id FROM cliente WHERE nro_documento='CE-5050' LIMIT 1),
    (SELECT propiedad_id FROM propiedad WHERE codigo_interno='P-006' LIMIT 1),
    (SELECT contrato_tipo_id FROM contrato_tipo WHERE nombre='Arriendo' LIMIT 1),
    '2026-02-26',
    'Quiere usarlo como oficina'
);


INSERT INTO contrato (contrato_tipo_id, contrato_estado_id, propiedad_id, cliente_id, agente_id, fecha_firma)
VALUES
(
    (SELECT contrato_tipo_id FROM contrato_tipo WHERE nombre='Arriendo' LIMIT 1),
    (SELECT contrato_estado_id FROM contrato_estado WHERE nombre='Activo' LIMIT 1),
    (SELECT propiedad_id FROM propiedad WHERE codigo_interno='P-004' LIMIT 1),
    (SELECT cliente_id FROM cliente WHERE nro_documento='30303030' LIMIT 1),
    (SELECT agente_id FROM agente WHERE email='maria@inmo.com' LIMIT 1),
    '2026-03-05'
);

INSERT INTO contrato_arriendo (contrato_id, fecha_inicio, fecha_fin, canon_mensual, dia_pago, deposito)
VALUES
(
    (SELECT c.contrato_id
    FROM contrato c
    JOIN propiedad pr ON pr.propiedad_id = c.propiedad_id
    WHERE pr.codigo_interno='P-004' AND c.fecha_firma='2026-03-05'
    ORDER BY c.contrato_id DESC LIMIT 1),
    '2026-03-10', '2027-03-09', 1700000.00, 5, 1700000.00
);

INSERT INTO contrato (contrato_tipo_id, contrato_estado_id, propiedad_id, cliente_id, agente_id, fecha_firma)
VALUES
(
    (SELECT contrato_tipo_id FROM contrato_tipo WHERE nombre='Venta' LIMIT 1),
    (SELECT contrato_estado_id FROM contrato_estado WHERE nombre='Finalizado' LIMIT 1),
    (SELECT propiedad_id FROM propiedad WHERE codigo_interno='P-005' LIMIT 1),
    (SELECT cliente_id FROM cliente WHERE nro_documento='40404040' LIMIT 1),
    (SELECT agente_id FROM agente WHERE email='andres@inmo.com' LIMIT 1),
    '2026-03-08'
);

INSERT INTO contrato_venta (contrato_id, fecha_cierre, precio_venta, comision_pct_aplicada)
VALUES
(
    (SELECT c.contrato_id
    FROM contrato c
    JOIN propiedad pr ON pr.propiedad_id = c.propiedad_id
    WHERE pr.codigo_interno='P-005' AND c.fecha_firma='2026-03-08'
    ORDER BY c.contrato_id DESC LIMIT 1),
    '2026-03-20', 520000000.00, 2.00
);


INSERT INTO pago (contrato_id, fecha_pago, valor, pago_metodo_id, periodo, referencia)
VALUES
(
    (SELECT c.contrato_id FROM contrato c
    JOIN propiedad pr ON pr.propiedad_id=c.propiedad_id
    WHERE pr.codigo_interno='P-004' AND c.fecha_firma='2026-03-05'
    ORDER BY c.contrato_id DESC LIMIT 1),
    '2026-03-12', 1700000.00,
    (SELECT pago_metodo_id FROM pago_metodo WHERE nombre='Transferencia' LIMIT 1),
    '2026-03', 'TRX-P004-0001'
),
(
    (SELECT c.contrato_id FROM contrato c
    JOIN propiedad pr ON pr.propiedad_id=c.propiedad_id
    WHERE pr.codigo_interno='P-004' AND c.fecha_firma='2026-03-05'
    ORDER BY c.contrato_id DESC LIMIT 1),
    '2026-04-05', 800000.00,
    (SELECT pago_metodo_id FROM pago_metodo WHERE nombre='Transferencia' LIMIT 1),
    '2026-04', 'TRX-P004-0002'
);