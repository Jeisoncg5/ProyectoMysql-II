-- 1) Funcion: comisión del agente en una venta

-- Calcula precio_venta × (comision_pct_aplicada / 100) usando contrato_venta.

USE inmobiliaria;

DELIMITER $$

DROP FUNCTION IF EXISTS fn_comision_venta $$
CREATE FUNCTION fn_comision_venta(p_contrato_id INT)
RETURNS DECIMAL(14,2)
READS SQL DATA
BEGIN
    DECLARE v_precio DECIMAL(14,2);
    DECLARE v_pct DECIMAL(5,2);

    SELECT precio_venta, comision_pct_aplicada
    INTO v_precio, v_pct
    FROM contrato_venta
    WHERE contrato_id = p_contrato_id;

    IF v_precio IS NULL OR v_pct IS NULL THEN
        RETURN 0.00;
    END IF;

    RETURN ROUND(v_precio * (v_pct / 100), 2);
END $$

DELIMITER ;

SELECT fn_comision_venta(1) AS comision;


-- 2) Funcion: deuda pendiente de un contrato de arriendo (por mes)

USE inmobiliaria;

DELIMITER $$

DROP FUNCTION IF EXISTS fn_deuda_arriendo_periodo $$
CREATE FUNCTION fn_deuda_arriendo_periodo(p_contrato_id INT, p_periodo CHAR(7))
RETURNS DECIMAL(14,2)
READS SQL DATA
BEGIN
    DECLARE v_deuda DECIMAL(14,2);

    SELECT GREATEST(a.canon_mensual - COALESCE(SUM(p.valor), 0), 0)
        INTO v_deuda
    FROM contrato_arriendo a
    LEFT JOIN pago p
        ON p.contrato_id = a.contrato_id
    AND p.periodo = p_periodo
    WHERE a.contrato_id = p_contrato_id
    GROUP BY a.canon_mensual;

    RETURN COALESCE(ROUND(v_deuda, 2), 0.00);
END $$

DELIMITER ;

SELECT fn_deuda_arriendo_periodo(3, '2026-03') AS deuda;



-- 3) Funcion: total de propiedades disponibles por tipo

-- Cuenta cuantas propiedades hay de un tipo (casa/apto/local) cuyo estado sea disponible


USE inmobiliaria;

DELIMITER $$

DROP FUNCTION IF EXISTS fn_total_disponibles_por_tipo $$
CREATE FUNCTION fn_total_disponibles_por_tipo(p_tipo_id INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_total INT;

    SELECT COUNT(*)
    INTO v_total
    FROM propiedad p
    JOIN propiedad_estado e
        ON e.propiedad_estado_id = p.propiedad_estado_id
    WHERE p.propiedad_tipo_id = p_tipo_id
        AND e.nombre = 'Disponible';

    RETURN v_total;
END $$

DELIMITER ;

SELECT fn_total_disponibles_por_tipo(1) AS disponibles;