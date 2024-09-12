-- EJERCICIO 5
-- posible solucion: tabla nueva en mi esquema donde guarde id_empleado
-- id_departamento, id_distribuidor, "fecha_alta" en ese departamento,
-- "fecha_baja" y el "tiempo_promedio" se podria calcular vinculando la tabla
-- nueva con empleado y hacer la diferencia entre su alta y la fecha actual

-- SETEO
alter table empleado add column fecha_alta date not null default current_date;

create table his_empleado as (select id_empleado, id_departamento, id_distribuidor from empleado);

alter table his_empleado add column alta_depto date not null default current_date;
alter table his_empleado add column baja_depto date;

-- IMPLEMENTACION CON TRIGGER CONSTANCIA DE ACTUALIZACIONES
create or replace trigger tr_actEmpleado
    after insert or delete or update of id_empleado, id_distribuidor, id_departamento
    on empleado
    for each row execute function fn_actEmpleado();

create or replace function fn_actEmpleado()
returns trigger as $$
    begin
        update his_empleado set baja_depto = current_date -- todos los empleados que se ingresen, cambien de departamento o se eliminen se debe registrar su fecha de baja
                            where old.id_empleado = id_empleado;
        if (tg_op != 'DELETE') then
            insert into his_empleado values (new.id_empleado, new.id_departamento, new.id_distribuidor, current_date, null);
        end if;
        return new;
    end; $$ language 'plpgsql';

-- IMPLEMENTACION CON PROCEDURE CONSTANCIA DE ACTUALIZACIONES
create or replace procedure proc_actEmpleado()
language 'plpgsql' as $$
    begin

    end;
    $$;

-- IMPLEMENTACION TIEMPO EN EL SISTEMA Y TIEMPO EN DEPARTAMENTO
create or replace function mostrarTiempos()
returns table(id_empleado numeric(6,0), tiempo_en_sistema interval) as $$
begin
    return query
    select h.id_empleado, age(current_date, e.fecha_alta) as "Tiempo en sistema"
    from his_empleado h
    join empleado e using (id_empleado);
end;
$$ language plpgsql;

SELECT * FROM mostrarTiempos();

-- CHEQUEO CON TUPLAS
select empleado.id_empleado, id_distribuidor, id_departamento from empleado order by empleado.id_empleado desc limit 50;
insert into empleado values (35082, 'nacho', 'perna',20,0,null,null,null,34,1,495,1232,default);
select * from his_empleado where id_empleado = 35082;
delete from empleado where id_empleado = 35082;
delete from his_empleado;


	