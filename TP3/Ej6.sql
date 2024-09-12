-- EJERCICIO 6
-- IMPLEMENTACION
    -- cambio de tarea en voluntario
    create or replace trigger tr_cambioTarea
        after update of id_tarea
        on voluntario
        for each row execute function fn_cambioTarea();

        create or replace function fn_cambioTarea()
        returns trigger as $$
            begin
                update voluntario set horas_aportadas = 0 where nro_voluntario = old.nro_voluntario;
                return new;
            end $$ language 'plpgsql';

    -- cambio de horas aportadas en voluntario
    create or replace trigger tr_cambioHoras
	before update of horas_aportadas
	on voluntario
	for each row execute function fn_cambioHoras();

	create or replace function fn_cambioHoras()
	returns trigger as $$
		begin
		    raise notice 'horas nuevas = %, horas viejas = %', new.horas_aportadas, old.horas_aportadas;
			if (new.horas_aportadas > (old.horas_aportadas * 0.1)) then
			    raise exception 'No se puede actualizar las horas aportadas porque son mayores que el 10%% del valor anterior';
            end if;
			return new;
		end $$ language 'plpgsql';

-- TESTEO
    -- eleccion de voluntario a elegir para el test
    select nro_voluntario, id_tarea, horas_aportadas from voluntario
    order by nro_voluntario desc
    limit 10;
    -- nro_voluntario = 216 para el cambio de tarea
    -- nro_voluntario = 215 para el cambio de horas aportadas
    update voluntario set id_tarea = 'OT_NEW' where nro_voluntario = 216;
    update voluntario set horas_aportadas = 900 where nro_voluntario = 215;