-- Trigger 1 auditoría de cambio de estado de propiedad

DELIMITER $$

DROP TRIGGER IF EXISTS trg_aud_cambio_estado_propiedad $$
CREATE TRIGGER trg_aud_cambio_estado_propiedad
AFTER UPDATE ON propiedad
FOR EACH ROW
BEGIN
    
    IF OLD.propiedad_estado_id <> NEW.propiedad_estado_id THEN
        INSERT INTO aud_propiedad_estado
        (propiedad_id, estado_anterior_id, estado_nuevo_id, usuario_mysql)
        VALUES
        (NEW.propiedad_id, OLD.propiedad_estado_id, NEW.propiedad_estado_id, CURRENT_USER());
    END IF;
END $$

DELIMITER ;


-- ejemplo, cambiar propiedad 1 a Arrendada estado id = 2 y luego consultar la tabla de auditoría para ver el registro del cambio
UPDATE propiedad
SET propiedad_estado_id = 2
WHERE propiedad_id = 1;

SELECT * FROM aud_propiedad_estado ORDER BY aud_id DESC;




-- Trigger 2 auditoría de nuevo contrato

DELIMITER $$
DROP TRIGGER IF EXISTS trg_aud_nuevo_contrato $$
CREATE TRIGGER trg_aud_nuevo_contrato
AFTER INSERT ON contrato
FOR EACH ROW
BEGIN
    INSERT INTO aud_contrato (contrato_id, evento, usuario_mysql)
    VALUES (NEW.contrato_id, 'INSERT', CURRENT_USER());
END $$

DELIMITER ;

-- para usar toca crear un contrato de prueba 
INSERT INTO contrato (contrato_tipo_id, contrato_estado_id, propiedad_id, cliente_id, agente_id, fecha_firma)
VALUES (1, 1, 2, 1, 1, '2026-03-01');

SELECT * FROM aud_contrato ORDER BY aud_id DESC;

