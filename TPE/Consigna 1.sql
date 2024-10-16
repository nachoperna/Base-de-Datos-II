-- a. Las personas que no están activas deben tener establecida una fecha de baja, la cual se debe controlar que sea al menos 6 meses posterior a la de su alta.
    -- Chequeo por la positiva.
    alter table persona add constraint check_fecha_baja
    check ((activo = true and fecha_baja is null)
               or
           (fecha_baja is not null
                and
            ((extract(year from age(fecha_baja, fecha_alta)) >= 1)
                 or
             (extract(month from age(fecha_baja, fecha_alta)) >= 6))));
        -- Chequea que todas las personas esten activas o que no tenga cargada fecha de baja o que si esta cargada, que la diferencia con su fecha de alta sea mayor a 6 meses.

    -- FUNCIONA

-- b. El importe de un comprobante debe coincidir con el total de los importes indicados en las líneas que lo conforman (si las tuviera).
    
    -- Restriccion declarativa en SQL estándar:
    create assertion ass_importeComprobante
    check (
        not exists (
            select 1
            from comprobante c
            JOIN lineacomprobante l
            on c.id_comp = l.id_comp and c.id_tcomp = l.id_tcomp
            group by c.id_comp, c.id_tcomp, c.importe having c.importe != sum(l.importe * l.cantidad)
        )
    );

    -- Implementacion en PostgreSQL:    
    create or replace trigger tr_importeComprobante
    after insert or update on lineacomprobante
    for each row execute function fn_importeComprobante();

    create or replace function fn_importeComprobante()
    returns trigger as $$
        begin
            if (exists(select 1 from lineacomprobante l join comprobante c using(id_comp, id_tcomp)
                        where l.id_comp = old.id_comp and l.id_tcomp = old.id_tcomp
                        group by c.importe having c.importe != sum(l.importe * l.cantidad))) then
                raise exception 'No puede insertarse la linea porque no coincide el IMPORTE TOTAL con la suma de todas las lineas de los comprobantes';
            else
                raise notice 'Linea insertada correctamente';
            end if;
            return old;
        end;
        $$ language 'plpgsql';

    -- Justificacion de ambas implementaciones: se debe comprobar que no exista ningun caso que no cumpla la condicion de la consigna, donde ningun IMPORTE TOTAL de Comprobante debe ser distinto de la suma de los importes de todas las lineas que lo componen.

    -- Triggers para la correcta insercion de una linea en un comprobante.
    create or replace trigger tr_ins_linea
        before insert or update on lineacomprobante
        for each row execute function fn_actLineaComprobante();

    create or replace function fn_actLineaComprobante()
        returns trigger as $$
            begin
                if (exists(select 1 from comprobante where id_comp = new.id_comp and id_tcomp = new.id_tcomp)
                    and exists(select 1 from servicio where id_servicio = new.id_servicio)) then -- idservicio puede ser nulo en lineacomprobante no entiendo por que pero lo chequeo igual
                    if (tg_op = 'INSERT') then
                        update comprobante set importe = importe + (new.importe * new.cantidad) where id_comp = new.id_comp and id_tcomp = new.id_tcomp;
                    else -- UPDATE
                        if (exists(select 1 from lineacomprobante where nro_linea = new.nro_linea and id_comp = new.id_comp and id_tcomp = new.id_tcomp and id_servicio = new.id_servicio)) then
                            update comprobante set importe = importe - (old.importe * old.cantidad) where id_comp = old.id_comp and id_tcomp = old.id_tcomp; -- le resta el monto de linea anterior
                            update comprobante set importe = importe + (new.importe * new.cantidad) where id_comp = new.id_comp and id_tcomp = new.id_tcomp; -- le suma el nuevo monto de linea
                        else
                            raise exception 'No existe una linea con esos id';
                        end if;
                    end if;
                else
                    raise exception 'No existe un comprobante o servicio con esos id';
                end if;
                return new;
            end;
            $$ language 'plpgsql';
    -- FUNCIONA.
    
    create or replace trigger tr_del_LineaComprobante
        after delete on lineacomprobante
        for each row execute function fn_del_LineaComprobante();

    create or replace function fn_del_LineaComprobante()
        returns trigger as $$
            begin
                update comprobante set importe = importe - (old.importe * old.cantidad) where id_comp = old.id_comp and id_tcomp = old.id_tcomp; -- se le resta el importe de la linea eliminada al comprobante al que pertenece esa linea.
                return old;
            end;
            $$ language 'plpgsql';
    -- FUNCIONA.

-- c. Las IPs asignadas a los equipos no pueden ser compartidas entre diferentes clientes.
    
    -- Restriccion declarativa en SQL estándar:
    create assertion ass_ipClientes
        check(not exists(select 1 from equipo e1
                         join equipo e2 on e1.ip = e2.ip
                         where e1.id_cliente is not null and e1.id_cliente != e2.id_cliente));

    -- Implementacion en PostgreSQL:
    create or replace trigger tr_ipClientes
        before insert or update of ip on equipo
        for each row execute function fn_ipClientes();

    create or replace function fn_ipClientes()
    returns trigger as $$
        begin
            if (exists(select 1 from equipo where id_cliente is not null and id_cliente != new.id_cliente and ip = new.ip)) then
                if (tg_op = 'INSERT') then
                    raise exception 'No puede insertarse la IP porque otro cliente ya la tiene asignada';
                else
                    raise exception 'No puede actualizarse la IP porque otro cliente ya la tiene asignada';
                end if;
            end if;
            return new;
        end;
        $$ language 'plpgsql';

    -- Justificacion de ambas implementaciones: se debe comprobar que no exista en la tabla Equipo ningun cliente diferente al dueño de la IP que tenga la misma direccion IP que se quiere insertar o modificar.
    -- FUNCIONA