# Proyecto MySQL II (Sistema de Gestión Inmobiliaria)

**Autor:** Jeison Leonardo Cristancho Garcia  



Este proyecto crea una base de datos en **MySQL** para administrar:
- Propiedades (casas, apartamentos, locales) con su **estado** (Disponible / Arrendada / Vendida).
- Clientes interesados (arriendo o compra).
- Contratos (arriendo y venta).
- Historial de pagos.
- Auditoría con triggers (cambios de estado y registro de contratos).
- Roles/usuarios (admin, agente, contador).
- Evento mensual para generar un reporte de pagos pendientes.

---

## Requisitos
- MySQL 8.x .
- Permisos de admin/root para crear BD, roles y activar el scheduler de eventos.

---

## Archivos del proyecto
- `ModeloSql.sql` → Crea la BD, tablas y carga datos de ejemplo.
- `indexsdeModeloSql.sql` → Crea índices básicos para optimizar consultas.
- `Funciones.sql` → Crea 3 funciones (comisión, deuda por periodo, disponibles por tipo).
- `triggers.sql` → Crea triggers de auditoría (incluye pruebas al final).
- `Usuario.sql` → Crea roles y usuarios con permisos.
- `Evento.sql` → Crea el evento mensual del reporte (incluye consulta).
- `Consultas.sql` → Consultas para mostrar funcionamiento.

---

## Orden recomendado para ejecutar
1) `ModeloSql.sql`  
2) `indexsdeModeloSql.sql` 
3) `Funciones.sql`  
4) `triggers.sql` 
5) `Usuario.sql`  
6) `Evento.sql`  
7) `Consultas.sql`

---

## Explicación de tablas y decisiones de diseño (3FN)

### 1) Tablas de catálogo
Se usan para evitar repetir texto y mantener consistencia.

- **tipo_documento**: CC, TI, CE, etc.
- **propiedad_tipo**: Casa, Apartamento, Local.
- **propiedad_estado**: Disponible, Arrendada, Vendida.
- **contrato_tipo**: Arriendo / Venta.
- **contrato_estado**: Activo, Finalizado, Anulado.
- **pago_metodo**: Efectivo, Transferencia, Tarjeta.

------

### 2) Tablas principales
- **cliente**: datos del cliente (documento, contacto).
- **agente**: datos del agente + `% comisión` por defecto.
- **propiedad**: inmueble del portafolio (tipo, estado, dirección, precios).

------

### 3) Intereses (clientes interesados)
- **cliente_interes**: relación muchos-a-muchos entre cliente y propiedad.
  Permite registrar si el interés es para arriendo o venta, con fecha y observaciones.

------

### 4) Contratos
Se usa una tabla base y dos subtablas para no mezclar campos y evitar NULLs.

- **contrato**: lo común (propiedad, cliente, agente, tipo, estado, fecha firma).
- **contrato_arriendo**: lo de arriendo (canon, fechas, día de pago, depósito).
- **contrato_venta**: lo de venta (precio venta, fecha cierre, comisión aplicada).

------

### 5) Pagos (historial)
- **pago**: registra pagos con fecha, valor, método y **periodo** (`YYYY-MM`) para arriendos.

------

### 6) Auditoría (para triggers)
- **aud_propiedad_estado**: guarda cambios de estado de una propiedad (antes/después, fecha, usuario).
- **aud_contrato**: guarda el registro cuando se crea un contrato.

------

### 7) Reportes mensuales (para eventos programados)
- **reporte_pagos_pendientes**: tabla donde se guardan los resultados del evento mensual:
  periodo, contrato, cliente, propiedad, total pagado y deuda.

---

## Funciones (UDF)
En `Funciones.sql` se crean estas funciones:

1) **`fn_comision_venta(contrato_id)`**  
   Calcula la comisión de una venta usando `contrato_venta`:
   `precio_venta * (comision_pct_aplicada/100)`

2) **`fn_deuda_arriendo_periodo(contrato_id, 'YYYY-MM')`**  
   Calcula la deuda del mes:
   `canon_mensual - sum(pagos del periodo)` (si queda negativo devuelve 0).

3) **`fn_total_disponibles_por_tipo(tipo_id)`**  
   Cuenta propiedades en estado **Disponible** por tipo.

**Nota (con tus datos de ejemplo):**
- Arriendo principal: `contrato_id = 1`
- Venta principal: `contrato_id = 2`

---

## Triggers (auditoría)
En `triggers.sql`:

1) **`trg_aud_cambio_estado_propiedad`**  
   Se ejecuta cuando una propiedad cambia su estado y lo registra en `aud_propiedad_estado`.

2) **`trg_aud_nuevo_contrato`**  
   Se ejecuta al insertar un contrato y lo registra en `aud_contrato`.

> Nota: al final de `triggers.sql` hay pruebas (`UPDATE` / `INSERT` / `SELECT`).  
Si no quieres que se creen datos extra al ejecutar, comenta esas líneas.

---

## Roles y usuarios
En `Usuario.sql` se crean 3 roles:

- **rol_admin**: todo el control de la BD.
- **rol_agente**: clientes, propiedades, intereses y contratos (no pagos).
- **rol_contador**: pagos y consulta de reportes.

---

## Índices
En `indexsdeModeloSql.sql` se crean índices para que las consultas sean más rápidas:
- Propiedades por estado/tipo.
- Contratos por cliente/propiedad.
- Pagos por contrato/periodo.
- Reportes por periodo.

---

## Evento mensual (reporte de pagos pendientes)
En `Evento.sql` se activa el scheduler y se crea el evento `ev_reporte_pagos_pendientes`.

El evento:
- toma el periodo del **mes anterior** (`YYYY-MM`)
- borra el reporte de ese periodo (para no duplicar)
- inserta arriendos **activos** con deuda > 0

---

## Consultas para demostrar (evidencia)
En `Consultas.sql` hay consultas para mostrar:
- Propiedades disponibles.
- Totales disponibles por tipo (función).
- Intereses de clientes.
- Deuda por periodo (función).
- Comisión de venta (función).
- Reporte mensual.
- Auditoría (si agregas selects a las tablas aud).

---

