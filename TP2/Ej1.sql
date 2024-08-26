-- a) 
	-- RIR R1
	ALTER TABLE INSTALACION ADD CONSTRAINT FK_INSTALACION_CLIENTE
		FOREIGN KEY (Zona, NroC) REFERENCES CLIENTE (Zona, NroC)
		ON DELETE CASCADE
		ON UPDATE RESTRICT;

	-- RIR R2
	ALTER TABLE INSTALACION ADD CONSTRAINT FK_INSTALACION_SERVICIO
		FOREIGN KEY (idServ) REFERENCES SERVICIO (idServ)
		ON DELETE RESTRICT
		ON UPDATE RESTRICT;

	-- RIR R3
	ALTER TABLE REFERENCIA ADD CONSTRAINT FK_REFERENCIA_SERVICIO
		FOREIGN KEY (idServ) REFERENCES SERVICIO (idServ)
		ON DELETE RESTRICT
		ON UPDATE CASCADE;

	-- RIR R4
	ALTER TABLE REFERENCIA ADD CONSTRAINT FK_REFERENCIA_CLIENTE
		FOREIGN KEY (Zona, NroC) REFERENCES CLIENTE (Zona, NroC)
		ON DELETE RESTRICT
		ON UPDATE SET NULL;

-- b)
	-- i)
		delete from Cliente where NroC= 1;
		-- Procede porque la condicion matchea con la tabla referenciada CLIENTE Y la tabla que referencia INSTALACION
		-- que tiene accion referencial CASCADE. La tabla REFERENCIA tiene accion referencial RESTRICT pero no tiene el atributo NroC=1
		-- por lo que no influye.

	-- ii)
		delete from Cliente where Zona= ‘C’;
		-- No procede porque el valor de atributo coincide en todas las tablas que referencian a CLIENTE y la tabla REFERENCIA tiene
		-- accion referencial RESTRICT por lo que no permite eliminar tuplas.

	-- iii)
		update Instalacion set IdServ= 55 where IdServ= 22; 
		-- Procede porque se cumple la condicion dentro de la tabla INSTALACION y es una tabla que referencia, por lo que
		-- puede cambiar sus valores sin problemas.

	-- iv)
		update Cliente set Zona = ‘Z’ where Zona =  ‘C’;
		-- No procede porque si bien el atributo de condicion se encuentra en las tablas que referencian INSTALACION y REFERENCIA
		-- La tabla INSTALACION tiene accion referencial RESTRICT para la modificiacion, por lo que no se pueden modificar sus valores

-- c) Indique cuáles de las siguientes operaciones serían aceptadas/rechazadas por el DBMS, según se considere match: i) simple, ii) parcial, o iii) full para la RIR R4:
	-- i)
		insert into Referencia values (11, ‘Costo’, B, null);
		-- MATCH SIMPLE: aceptada, porque al menos un valor de la foreign key es null.
		-- MATCH PARTIAL: aceptada, porque el valor no nulo de la FK coincide con un valor de la PK.
		-- MATCH FULL: rechazada, porque la tupla no es toda null ni hace referencia a la PK completa.

	-- ii)
		insert into Referencia values (22, ‘Reclamo’, null, null);
		-- MATCH SIMPLE: aceptada, porque al menos un valor de la FK es null.
		-- MATCH PARTIAL: rechazada, porque no hay valores no nulos en la FK.
		-- MATCH FULL: aceptada, porque la tupla de la FK es null.

	-- iii)
		insert into Referencia values (33, ‘Calidad’, A, 3);
		-- MATCH SIMPLE: rechazada, porque ningun valor de la FK es null.
		-- MATCH PARTIAL: aceptada, porque el valor Zona = A y NroC = 3 coinciden con valores en la PK referenciada.
		-- MATCH FULL: aceptada, porque hace referencia a la PK completa.

	-- iv) 
		insert into Referencia values (11, ‘Reclamo’, null, 3);
		-- MATCH SIMPLE: aceptada, porque al menos un valor de la FK es null.
		-- MATCH PARTIAL: aceptada, porque el valor NroC = 3 coincide con un valor en la PK referenciada.
		-- MATCH FULL: rechazada, porque la tupla referenciada no es nula ni referencia a la PK completa.
