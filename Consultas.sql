-- Consulta: Listar todas las propiedades disponibles con su tipo, estado, dirección, canon sugerido y precio de venta, ordenadas por tipo y código interno.

SELECT p.codigo_interno, t.nombre AS tipo, e.nombre AS estado, p.direccion, p.canon_sugerido, p.precio_venta
FROM propiedad p
JOIN propiedad_tipo t  ON t.propiedad_tipo_id = p.propiedad_tipo_id
JOIN propiedad_estado e ON e.propiedad_estado_id = p.propiedad_estado_id
WHERE e.nombre = 'Disponible'
ORDER BY t.nombre, p.codigo_interno;

-- Consulta: Listar los contratos activos con el nombre del cliente, dirección de la propiedad, tipo de contrato, fecha de firma y canon mensual.
SELECT
    t.nombre AS tipo,
    fn_total_disponibles_por_tipo(t.propiedad_tipo_id) AS disponibles
FROM propiedad_tipo t
ORDER BY t.nombre;

-- Consulta: Listar los intereses registrados por los clientes, mostrando el nombre del cliente, código interno de la propiedad, tipo de contrato, fecha del interés y observaciones, ordenados por fecha de interés descendente.
SELECT c.nombre AS cliente, pr.codigo_interno AS propiedad, ct.nombre AS interes_en, i.fecha_interes, i.observaciones
FROM cliente_interes i
JOIN cliente c ON c.cliente_id = i.cliente_id
JOIN propiedad pr ON pr.propiedad_id = i.propiedad_id
JOIN contrato_tipo ct ON ct.contrato_tipo_id = i.contrato_tipo_id
ORDER BY i.fecha_interes DESC;


-- Consulta: Listar el reporte mensual de pagos pendientes, mostrando el periodo, nombre del cliente, dirección de la propiedad, canon mensual, total pagado y deuda, ordenados por periodo y cliente.
SELECT fn_deuda_arriendo_periodo(1, '2026-02') AS deuda_febrero;


-- Consulta: Comisión de una venta
SELECT fn_comision_venta(2) AS comision_contrato_2;

-- Consulta: Total de propiedades disponibles por tipo
SELECT * 
FROM reporte_pagos_pendientes
ORDER BY generado_en DESC, periodo DESC;