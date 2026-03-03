-- evento para generar reporte mensual de pagos pendientes

SET GLOBAL event_scheduler = ON;

DELIMITER $$

DROP EVENT IF EXISTS ev_reporte_pagos_pendientes $$

CREATE EVENT ev_reporte_pagos_pendientes
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP + INTERVAL 1 MINUTE
DO
BEGIN
    -- mes anterior (YYYY-MM)
    SET @periodo := DATE_FORMAT(CURDATE() - INTERVAL 1 MONTH, '%Y-%m');

    -- borrar reporte del mismo mes para no duplicar
    DELETE FROM reporte_pagos_pendientes
    WHERE periodo = @periodo;

    -- insertar contratos de arriendo con deuda
    INSERT INTO reporte_pagos_pendientes
        (periodo, contrato_id, propiedad_id, cliente_id,
        canon_mensual_snapshot, total_pagado, deuda)
    SELECT
    @periodo,
    c.contrato_id,
    c.propiedad_id,
    c.cliente_id,
    a.canon_mensual,
    COALESCE(SUM(p.valor), 0),
    GREATEST(a.canon_mensual - COALESCE(SUM(p.valor), 0), 0)
    FROM contrato c
    JOIN contrato_arriendo a ON a.contrato_id = c.contrato_id
    LEFT JOIN pago p
        ON p.contrato_id = c.contrato_id
    AND p.periodo = @periodo
    WHERE c.contrato_estado_id = 1  -- solo contratos activos
    GROUP BY c.contrato_id, c.propiedad_id, c.cliente_id, a.canon_mensual
    HAVING deuda > 0;
END $$

DELIMITER ;

-- ver el reporte después de 1 minuto
SELECT * FROM reporte_pagos_pendientes ORDER BY reporte_id DESC;