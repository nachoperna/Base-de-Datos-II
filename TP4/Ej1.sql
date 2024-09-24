-- Ejercicio 1

-- Creacion de tablas
CREATE TABLE ARTICULO_TP4 (
    id_articulo varchar(10)  NOT NULL,
    descripcion varchar(30)  NOT NULL,
    precio decimal(8,2)  NOT NULL,
    peso decimal(5,2)  NULL,
    ciudad varchar(30)  NOT NULL,
    CONSTRAINT ARTICULOTP4_pk PRIMARY KEY (id_articulo)
);

CREATE TABLE ENVIO_TP4 (
    id_proveedor varchar(10)  NOT NULL,
    id_articulo varchar(10)  NOT NULL,
    cantidad int  NOT NULL,
    CONSTRAINT ENVIOTP4_pk PRIMARY KEY (id_proveedor,id_articulo)
);

CREATE TABLE PROVEEDOR_TP4 (
    id_proveedor varchar(10)  NOT NULL,
    nombre varchar(30)  NOT NULL,
    rubro varchar(15)  NOT NULL,
    ciudad varchar(30)  NOT NULL,
    CONSTRAINT PROVEEDORTP4_pk PRIMARY KEY (id_proveedor)
);

ALTER TABLE ENVIO_TP4 ADD CONSTRAINT ENVIO_ARTICULO
    FOREIGN KEY (id_articulo)
    REFERENCES ARTICULO_TP4 (id_articulo)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

ALTER TABLE ENVIO_TP4 ADD CONSTRAINT ENVIO_PROVEEDOR
    FOREIGN KEY (id_proveedor)
    REFERENCES PROVEEDOR_TP4 (id_proveedor)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- INSERCION DE TUPLAS
INSERT INTO PROVEEDOR_TP4 (id_proveedor, nombre, rubro, ciudad) VALUES
        ('P1', 'Proveedor1', 'RubroA', 'Tandil'),
        ('P2', 'Proveedor2', 'RubroA', 'Tandil'),
        ('P3', 'Proveedor3', 'RubroB', 'Tandil'),
        ('P4', 'Proveedor4', 'RubroC', 'Tandil'),
        ('P5', 'Proveedor5', 'RubroC', 'Tandil'),
        ('P6', 'Proveedor6', 'RubroA', 'Mar del Plata'),
        ('P7', 'Proveedor7', 'RubroB', 'Bahía Blanca'),
        ('P8', 'Proveedor8', 'RubroC', 'La Plata');

INSERT INTO ARTICULO_TP4 (id_articulo, descripcion, precio, peso, ciudad) VALUES
        ('A1', 'Articulo1', 120.50, 1.20, 'Tandil'),
        ('A2', 'Articulo2', 200.00, 2.30, 'Tandil'),
        ('A3', 'Articulo3', 500.00, 1.50, 'Mar del Plata'),
        ('A4', 'Articulo4', 750.75, 3.50, 'La Plata'),
        ('A5', 'Articulo5', 1000.00, 2.00, 'Bahía Blanca'),
        ('A6', 'Articulo6', 1350.50, 4.00, 'Tandil'),
        ('A7', 'Articulo7', 850.00, 2.75, 'Tandil'),
        ('A8', 'Articulo8', 2200.00, 5.00, 'Tandil');

INSERT INTO ENVIO_TP4 (id_proveedor, id_articulo, cantidad) VALUES
        ('P1', 'A1', 700), -- Entre 500 y 1000
        ('P2', 'A2', 600), -- Entre 500 y 1000
        ('P3', 'A3', 500), -- Entre 500 y 1000
        ('P4', 'A4', 800), -- Entre 500 y 1000
        ('P5', 'A5', 950), -- Entre 500 y 1000
        ('P6', 'A6', 400), -- Menores de 500
        ('P7', 'A7', 450), -- Menores de 500
        ('P8', 'A8', 300), -- Menores de 500
        ('P1', 'A6', 1200), -- Mayor a 1000
        ('P2', 'A8', 1500); -- Mayor a 1000

-- a.
	-- a.1
	create or replace view envios500
     as (select * from envio_tp4 where cantidad >= 500);
    
    select * from envio_tp4;
	select * from envios500;

	-- a.2
	create or replace view envios500_m
        as (select * from envios500 where cantidad < 1000);

    select * from envios500;
    select * from envios500_m;

    -- a.3
    create or replace view rubros_prov
        as (select id_proveedor, rubro, ciudad from proveedor_tp4 where lower(ciudad) = 'tandil');

    select * from rubros_prov;

    -- a.4
    create or replace view envios_prov
        as (select p.id_proveedor, p.nombre, sum(e.cantidad) from proveedor_tp4 p
            join envio_tp4 e using (id_proveedor)
            group by p.id_proveedor
            order by p.id_proveedor);

    select * from envio_tp4;
    select * from envios_prov;

-- b.
	-- Vista envios500 es automaticamente actualizable segun el estandar SQL.
	-- Vista envios500_m es automaticamente actualizable segun el estandar SQL.
	-- Vista rubros_prov es automaticamente actualizable segun el estandar SQL.
	-- Vista envios_prov NO es automaticamente actualizable segun el estandar SQL, porque tiene una funcion de agregacion en el select.

-- c.
	select * from envios500;
    update envios500 set cantidad = cantidad - 1;
    -- proveedor P3 ya no deberia estar incluido en la vista al actualizar con una cantidad = 499
    select * from envios500;
    select * from envio_tp4;

    select * from envios500_m;
    -- vemos que el proveedor P3 que antes tenia cantidad=500 ya no aparece en esta vista al estar basada en envios500.
    update envios500_m set cantidad = cantidad + 1;
    select * from envios500_m;
    select * from envio_tp4;

    select * from rubros_prov;
    update rubros_prov set rubro = 'prueba' where id_proveedor = 'P1';
    -- este update deberia actualizar el rubro de p1 con ciudad tandil en la tabla proveedor tambien.
    select * from rubros_prov;
    select * from proveedor_tp4;
    -- funciona. Ahora restituimos el valor previo
    update rubros_prov set rubro = 'RubroA' where id_proveedor = 'P1';

    select * from envios_prov;
    -- no deberia dejar actualizar al tener una funcion de agregacion
    update envios_prov set nombre = 'Prov1' where id_proveedor = 'P1';
    -- efectivamente no deja actualizar
