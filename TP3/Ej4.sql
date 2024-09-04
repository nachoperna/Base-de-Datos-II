-- EJERCICIO 4

CREATE TABLE HIS_ENTREGA {
	nro_registro int NOT NULL,
	fecha date NOT NULL,
	operacion varchar(15) NOT NULL,
	cant_reg_afectados int NULL,
	usuario varchar(30) NOT NULL,
	CONSTRAINT PK_HIS_ENTREGA PRIMARY KEY (nro_registro);
}

-- a.
	create function fn_actualizarHistorial()
	returns trigger as $$
	begin
		update HIS_ENTREGA (nro_registro, fecha, operacion, cant_reg_afectados, usuario)
		values (new.nro_registro, current_date, new.operacion, ?, ?)
		return new;
	end $$ language 'plpgsql';

	create trigger tr_actualizarHistorial
	after insert or update 
	ON ENTREGA, RENGLON_ENTREGA
	for each row execute function fn_actualizarHistorial();