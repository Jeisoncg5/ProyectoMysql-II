-- PROPIEDAD 

-- Para consultar propiedades disponibles y por tipo
CREATE INDEX idx_prop_estado ON propiedad(propiedad_estado_id);
CREATE INDEX idx_prop_tipo   ON propiedad(propiedad_tipo_id);

-- CONTRATO 

-- Para buscar contratos por cliente o por propiedad
CREATE INDEX idx_cont_cliente  ON contrato(cliente_id);
CREATE INDEX idx_cont_propiedad ON contrato(propiedad_id);

-- PAGO 

-- Para calcular deuda y generar reporte mensual (por contrato y mes)
CREATE INDEX idx_pago_contrato ON pago(contrato_id);
CREATE INDEX idx_pago_periodo  ON pago(periodo);

-- REPORTE MENSUAL 

-- Para consultar reportes por mes
CREATE INDEX idx_rep_periodo ON reporte_pagos_pendientes(periodo);