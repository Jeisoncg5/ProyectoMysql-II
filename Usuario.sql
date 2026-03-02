-- ROLES

CREATE ROLE 'rol_admin';
CREATE ROLE 'rol_agente';
CREATE ROLE 'rol_contador';

-- PERMISOS POR ROL

-- El admin puede hacer todo en la base de datos ya sea para gestionar usuarios, roles, o cualquier tabla
GRANT ALL PRIVILEGES ON inmobiliaria.* TO 'rol_admin';

-- El agente puede ver todo, y administrar clientes, propiedades, intereses y contratos
-- No le doy permisos de pagos al agente para eso creo el rol de contador

GRANT SELECT ON inmobiliaria.* TO 'rol_agente';
GRANT INSERT, UPDATE ON inmobiliaria.cliente          TO 'rol_agente';
GRANT INSERT, UPDATE ON inmobiliaria.propiedad        TO 'rol_agente';
GRANT INSERT, UPDATE ON inmobiliaria.cliente_interes  TO 'rol_agente';
GRANT INSERT, UPDATE ON inmobiliaria.contrato         TO 'rol_agente';
GRANT INSERT, UPDATE ON inmobiliaria.contrato_arriendo TO 'rol_agente';
GRANT INSERT, UPDATE ON inmobiliaria.contrato_venta    TO 'rol_agente';

-- El contador puede ver todo, y gestionar pagos ademas ver reportes
GRANT SELECT ON inmobiliaria.* TO 'rol_contador';
GRANT INSERT, UPDATE ON inmobiliaria.pago TO 'rol_contador';
-- El reporte lo llena el EVENT mensual entonces el contador solo lo puede consultar

-- CREAR USUARIOS Y ASIGNAR ROLES

CREATE USER 'admin_inmo'@'localhost'   IDENTIFIED BY 'Admin123!';
CREATE USER 'agente_inmo'@'localhost'  IDENTIFIED BY 'Agente123!';
CREATE USER 'contador_inmo'@'localhost' IDENTIFIED BY 'Contador123!';

GRANT 'rol_admin'    TO 'admin_inmo'@'localhost';
GRANT 'rol_agente'   TO 'agente_inmo'@'localhost';
GRANT 'rol_contador' TO 'contador_inmo'@'localhost';

-- Rol por defecto

SET DEFAULT ROLE 'rol_admin'    TO 'admin_inmo'@'localhost';
SET DEFAULT ROLE 'rol_agente'   TO 'agente_inmo'@'localhost';
SET DEFAULT ROLE 'rol_contador' TO 'contador_inmo'@'localhost';
