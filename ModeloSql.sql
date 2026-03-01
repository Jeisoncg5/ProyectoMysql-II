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