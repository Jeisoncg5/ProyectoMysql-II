


/* trigger 1 Crear un trigger que se active al actualizar el precio de una propiedad, registrando el cambio en una tabla auditoria_precios.
*/
DELIMITER $$
CREATE TRIGGER actualizacion_precio
AFTER UPDATE ON propiedades
FOR EACH ROW
BEGIN   
    IF NEW.precio <> OLD.precio THEN
        INSERT INTO auditoria_precios (propiedad_id, estado_anterior_id, estado_nuevo_id, fecha_cambio, clente)
        VALUES (OLD.propiedad_id, OLD.precio_venta, NEW.precio, NOW(), USER());
    END IF;
END$$
DELIMITER ;




/* Trigger 2: Crear un trigger que evite eliminar una propiedad si está asociada a un contrato activo, mostrando un mensaje de error personalizado.
*/

DELIMITER $$
CREATE TRIGGER propiedad_borrada
BEFORE DELETE ON propiedad
FOR EACH ROW
BEGIN
    DECLARE contrato_count INT;
    SELECT COUNT(*) INTO contrato_count
    FROM contratos
    WHERE propiedad_id = OLD.propiedad_id AND estado = 'activo';
    IF contrato_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar la propiedad   
porque está asociada a un contrato activo.';
    END IF;
END$$
DELIMITER ; 




/*Transacción: Simular un proceso de arriendo con transacciones (START TRANSACTION, COMMIT, ROLLBACK), donde se actualiza el estado de la propiedad y se registra el contrato.
*/
START TRANSACTION;
-- Supongamos que queremos arrendar la propiedad con ID 1 al cliente con ID 2 por un precio de 1000
UPDATE propiedades
SET estado = 'alquilada'
WHERE propiedad_id = 1;
INSERT INTO contratos (propiedad_id, cliente_id, fecha_inicio, fecha_fin, precio)
VALUES (1, 2, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 1 MONTH), 1000);
COMMIT;


/* Vista: Crear una vista llamada vista_resumen_propiedades que muestre:
nombre de la propiedad.
ciudad y estado.
precio.
nombre del agente
y si la propiedad está o no alquilada.
*/

CREATE VIEW vista_resumen_propiedades AS
SELECT p.nombre AS propiedad_nombre,
       CONCAT(p.ciudad, ', ', p.estado) AS ubicacion,
       p.precio,
       a.nombre AS agente_nombre,
       CASE
           WHEN c.estado = 'activo' THEN 'Sí'
           ELSE 'No'
       END AS alquilada
FROM propiedades p
JOIN agentes a ON p.agente_id = a.agente_id
LEFT JOIN contratos c ON p.propiedad_id = c.propiedad_id AND c.estado = 'activo';



/* Consulta final: Mostrar las 10 últimas modificaciones registradas en la tabla auditoria_precios (ORDER BY - DESC LIMIT 10).
*/

SELECT *
FROM auditoria_precios
ORDER BY fecha_cambio DESC
LIMIT 10;








