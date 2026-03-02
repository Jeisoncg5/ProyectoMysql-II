# Proyecto Mysql II (Sistema de Gestión Inmobiliaria)

Jeison Leonardo Cristancho Garcia





## Explicacion de tablas y decisiones de diseño (3FN)

### 1) Tablas de catalogo 

- **tipo_documento**: guarda tipos como CC, TI, CE.
  un cliente siempre usa un tipo de documento válido; evita escribir “CC” muchas veces y permite cambios controlados.
- **propiedad_tipo**: casa, apartamento, local.
    el tipo es un dato “categoría” que se repite; se normaliza para consistencia.
- **propiedad_estado**: disponible, arrendada, vendida (u otros).
   es clave para el negocio y para el trigger de auditoría de cambio de estado.
- **contrato_tipo**: arriendo / venta.
   el sistema maneja dos tipos de contrato y se necesita diferenciarlos sin duplicar tablas completas.
- **contrato_estado**: activo, finalizado, anulado, etc.
   permite controlar el ciclo de vida de un contrato.
- **pago_metodo**: efectivo, transferencia, tarjeta…
   estandariza el registro del método de pago y evita valores escritos diferente.

------

### 2) Tablas principales

- **cliente**: almacena los datos del cliente (nombre, documento, contacto).
- **agente**: almacena la información del agente inmobiliario.
   el proyecto pide calcular comisión por venta y diferenciar roles.
- **propiedad**: representa cada inmueble del portafolio.
   se arrienda o se vende, tiene tipo y estado.
   Se relaciona con:
  - `propiedad_tipo` (para clasificar)
  - `propiedad_estado` (disponible/arrendada/vendida)
  - `agente` (agente responsable)

------

### 3) Intereses (clientes interesados)

- **cliente_interes**: registra que un cliente está interesado en una propiedad (para arriendo o venta).
   un cliente puede interesarse en varias propiedades y una propiedad puede interesarle a varios clientes
   Además permite guardar fecha y observaciones.

------

### 4) Contratos 

#### A) contrato 

- **contrato**: guarda lo común a cualquier contrato:
  - propiedad
  - cliente
  - agente
  - tipo de contrato
  - estado del contrato
  - fecha de firma

evita duplicar las mismas columnas en dos tablas separadas (una para venta y otra para arriendo).
 Así hay una sola forma de agregar “registro de contrato” y de relacionarlo con propiedad/cliente/agente.

#### B) contrato_arriendo (subtabla)

- **contrato_arriendo**
  - fecha inicio/fin
  - canon mensual
  - día de pago
  - depósito

estos campos no aplican a ventas.

#### C) contrato_venta (subtabla)

- **contrato_venta**
  - precio de venta
  - fecha de cierre
  - comisión aplicada

una venta tiene precio final y comisión.

------

### 5) Pagos (historial)

- **pago**
  - fecha
  - valor
  - método
  - periodo (YYYY-MM) opcional

------

### 6) Auditoría (mas que todo para que los triggers sean mas acordes)

- **aud_propiedad_estado**: registra cambios de estado de propiedades.
   el proyecto pide guardar historial cuando una propiedad cambia de disponible a arrendada/vendida.
   Aquí se guarda:
  - estado anterior
  - estado nuevo
  - fecha
  - usuario MySQL

------

### 7) Reportes mensuales (para eventos programados)

- **reporte_pagos_pendientes**: tabla donde se guardará el resultado del evento mensual.