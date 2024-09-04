-- EJERCICIO 2 (todos los incisos del ej4 tp2)
-- a.
	create or replace function fn_volHorasCoord()
	returns trigger as $$
	    begin
	        if (exists(SELECT 1 FROM voluntario v
	                    JOIN voluntario c ON v.id_coordinador = c.nro_voluntario
	                    WHERE v.horas_aportadas > c.horas_aportadas)) then
	            raise exception 'El voluntario no puede aportar mas horas que su coordinador';
	        end if;
	        return new;
	end $$ language 'plpgsql';

	create or replace trigger tr_volHorasCoord
	    before insert or update of horas_aportadas
	    ON voluntario
	    for each statement execute function fn_volHorasCoord();

-- b.
	create function fn_cantHorasPermitidas()
	returns trigger as $$
	    begin
	    if (exists(SELECT 1 FROM voluntario v
	                JOIN tarea t USING (id_tarea)
	                WHERE v.horas_aportadas > t.max_horas OR v.horas_aportadas < t.min_horas)) then
	        raise exception 'Las horas aportadas por el voluntario estan fuera del rango permitido por su tarea';
	    end if;
	    return new;
	    end $$ language 'plpgsql';

	create trigger tr_cantHorasPermitidas
	    before insert or update of horas_aportadas
	    ON voluntario
	    for each statement execute function fn_cantHorasPermitidas();

-- c.
	create function fn_mismaTarea()
	returns trigger as $$
	    begin
	        if (exists(SELECT 1 FROM voluntario v
	                    JOIN voluntario c ON v.id_coordinador = c.nro_voluntario
	                    WHERE v.id_tarea != c.id_tarea)) then
	            raise exception 'El voluntario no realiza la misma tarea que su coordinador';
	        end if;
	        return new;
	    end $$ language 'plpgsql';

	create trigger tr_mismaTarea
	    before insert or update of id_tarea
	    on voluntario
	    for each statement execute function fn_mismaTarea();

-- d.
	create function fn_cambioInstitucion()
	returns trigger as $$
	    begin
	        if (exists(SELECT COUNT(*) FROM voluntario v
	                            JOIN historico h USING (nro_voluntario)
	                            WHERE v.id_institucion != h.id_institucion AND extract(year from age(current_date, h.fecha_inicio)) >= 3
	                            GROUP BY v.nro_voluntario HAVING COUNT(*) >= 3)) then
	            raise exception 'El voluntario no puede cambiar de institucion mas de 3 veces por año';
	        end if;
	    end $$ language 'plpgsql';

	create trigger tr_cambioInstitucion
	    before insert or update of id_institucion
	    on voluntario
	    for each statement execute function fn_cambioInstitucion();