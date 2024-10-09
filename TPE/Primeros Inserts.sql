-- Orden de insercion para respetar FOREIGN KEYS:
	-- Persona -> Ciudad -> Barrio -> Dirección
	-- Ciente
	-- Rol -> Personal -> Lugar -> Turno
	-- Categoria -> servicio -> Equipo
	-- TipoComprobante -> comprobante -> LineaComprobante

INSERT INTO Lugar (id_lugar, nombre) VALUES
(1, 'Oficina Principal'),
(2, 'Sucursal Norte'),
(3, 'Sucursal Sur');

INSERT INTO Turno (id_turno, desde, hasta, dinero_inicio, dinero_fin, id_personal, id_lugar) VALUES
(1, NOW(), NOW() + INTERVAL '8 hours', 100.00, 200.00, 1, 1),
(2, NOW(), NOW() + INTERVAL '8 hours', 150.00, 250.00, 2, 1),
(3, NOW(), NOW() + INTERVAL '8 hours', 200.00, 300.00, 1, 2);

INSERT INTO TipoComprobante (id_tcomp, nombre, tipo) VALUES
(1, 'Venta', 'Factura'),
(2, 'Pago', 'Recibo'),
(3, 'Nota de Crédito', 'Remito');

INSERT INTO Servicio (id_servicio, nombre, periodico, costo, intervalo, tipo_intervalo, activo, id_cat) VALUES
(1, 'Internet Básico', TRUE, 100.00, 1, 'mes', TRUE, 1),
(2, 'Televisión Premium', TRUE, 200.00, 1, 'mes', TRUE, 2),
(3, 'Reparacion de equipo', FALSE, 150.00, 1, null, TRUE, 3);

INSERT INTO Rol (id_rol, nombre) VALUES
(1, 'Administrador'),
(2, 'Operador'),
(3, 'Soporte');

INSERT INTO Personal (id_personal, id_rol) VALUES
(1, 1),
(2, 2),
(3, 1);

INSERT INTO Persona (id_persona, tipo, tipodoc, nrodoc, nombre, apellido, fecha_nacimiento, fecha_alta, fecha_baja, CUIT, activo, mail, telef_area, telef_numero) VALUES
(1, 'Cliente', 'DNI', '12345678', 'Juan', 'Pérez', '1990-01-01', NOW(), NULL, '20-12345678-9', TRUE, 'juan@example.com', 11, 12345678),
(2, 'Cliente', 'DNI', '23456789', 'Ana', 'Gómez', '1985-02-02', NOW(), NULL, '20-23456789-0', TRUE, 'ana@example.com', 11, 23456789),
(3, 'Cliente', 'DNI', '34567890', 'Luis', 'Martínez', '1980-03-03', NOW(), NULL, '20-34567890-1', TRUE, 'luis@example.com', 11, 34567890);

INSERT INTO Equipo (id_equipo, nombre, MAC, IP, AP, id_servicio, id_cliente, fecha_alta, fecha_baja, tipo_conexion, tipo_asignacion) VALUES
(1, 'Router A', '00:1A:2B:3C:4D:5E', '192.168.1.1', 'AP1', 1, 1, NOW(), NULL, 'Inalámbrico', 'Estático'),
(2, 'Router B', '00:1A:2B:3C:4D:5F', '192.168.1.2', 'AP2', 2, 2, NOW(), NULL, 'Inalámbrico', 'Dinámico'),
(3, 'Router C', '00:1A:2B:3C:4D:5G', '192.168.1.3', 'AP3', 3, 3, NOW(), NULL, 'Alámbrico', 'Estático');

INSERT INTO Direccion (id_direccion, id_persona, calle, numero, piso, depto, id_barrio) VALUES
(1, 1, 'Av. Libertador', 100, 2, 'A', 1),
(2, 2, 'Calle Falsa', 200, 1, 'B', 2),
(3, 3, 'Calle Verdadera', 300, 0, NULL, 3);

INSERT INTO Comprobante (id_comp, id_tcomp, fecha, comentario, estado, fecha_vencimiento, id_turno, importe, id_cliente, id_lugar) VALUES
(1, 1, NOW(), 'Pago mensual', 'Pagado', NOW() + INTERVAL '365 days', 1, 100.00, 1, 1),
(2, 2, NOW(), 'Pago de servicio', 'Pendiente', NOW() + INTERVAL '365 days', 2, 200.00, 2, 1),
(3, 1, NOW(), 'Suscripción', 'Pagado', NOW() + INTERVAL '365 days', 1, 150.00, 3, 1);

INSERT INTO LineaComprobante (nro_linea, id_comp, id_tcomp, descripcion, cantidad, importe, id_servicio) VALUES
(1, 1, 1, 'Servicio de Internet', 1, 100.00, 1),
(2, 2, 2, 'Servicio de Televisión', 1, 200.00, 2),
(3, 3, 1, 'Servicio de Telefonía', 1, 150.00, 3);

INSERT INTO Cliente (id_cliente, saldo) VALUES
(1, 1500.000),
(2, 2500.000),
(3, 1000.000);

INSERT INTO Ciudad (id_ciudad, nombre) VALUES
(1, 'Napoli'),
(2, 'Ciudad B'),
(3, 'Ciudad C');

INSERT INTO Categoria (id_cat, nombre) VALUES
(1, 'Internet'),
(2, 'Televisión'),
(3, 'Telefonía');

INSERT INTO Barrio (id_barrio, nombre, id_ciudad) VALUES
(1, 'Centro', 1),
(2, 'Norte', 1),
(3, 'Sur', 2);
