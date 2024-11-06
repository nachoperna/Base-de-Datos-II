-- a. Las personas que no están activas deben tener establecida una fecha de baja, la cual se debe controlar que sea al menos 6 meses posterior a la de su alta.
    -- Chequeo por la positiva.
    alter table persona add constraint check_fecha_baja
    check ((activo = true and fecha_baja is null)
               or
           (fecha_baja is not null
                and
            (age(fecha_baja, fecha_alta) >= interval'6 months')));
    -- Al ser solo un control de atributo, se puede utilizar un check de tupla como recurso mas restrictivo.
    -- Se requiere controlar que todas las personas esten activas o que no tenga cargada fecha de baja o que si esta cargada, que la diferencia con su fecha de alta sea mayor a 6 meses.

-- b. El importe de un comprobante debe coincidir con el total de los importes indicados en las líneas que lo conforman (si las tuviera).
    
    -- Restriccion declarativa en SQL estándar:
    create assertion ass_importeComprobante
    check (
        not exists (
            select 1
            from comprobante c
            join lineacomprobante l
            on c.id_comp = l.id_comp and c.id_tcomp = l.id_tcomp
            group by c.id_comp, c.id_tcomp, c.importe having c.importe != sum(l.importe * l.cantidad)
        )
    );
    -- El recurso declarativo mas restrictivo en SQL estándar en este caso es un Assertion con control de tablas.
    -- Se requiere controlar que ante una insercion en la linea de un comprobante, o actualizacion de su importe o cantidad, la suma total del importe de todas las lineas que contiene ese comprobante sea igual al importe del comprobante correspondiente.

    -- Implementacion en PostgreSQL:    
    create or replace trigger tr_ins_importeComprobante
    after insert on lineacomprobante
    for each row execute function fn_importeComprobante();

    create or replace trigger tr_act_importeComprobante
    after update of importe,cantidad on lineacomprobante
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
            if (tg_op = 'INSERT') then
                update comprobante set importe = importe + (new.importe * new.cantidad) where id_comp = new.id_comp and id_tcomp = new.id_tcomp; -- si se inserta una linea, entonces se actualiza el valor de importe correspondiente del comprobante sumandole el importe total de esa linea (importe*cantidad)
            else -- UPDATE
                update comprobante set importe = importe - (old.importe * old.cantidad) where id_comp = old.id_comp and id_tcomp = old.id_tcomp; -- le resta el monto de linea anterior
                update comprobante set importe = importe + (new.importe * new.cantidad) where id_comp = new.id_comp and id_tcomp = new.id_tcomp; -- le suma el nuevo monto de linea
            end if;
            return new; -- retorna new al ser un trigger before.
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
                return old; -- retorna old al ser un trigger after.
            end;
            $$ language 'plpgsql';
    
    -- FUNCIONA.

-- c. Las IPs asignadas a los equipos no pueden ser compartidas entre diferentes clientes.
    
    -- Restriccion declarativa en SQL estándar:
    alter table equipo add constraint chk_mismaIp
    check (not exists(select 1 from equipo e1
                             join equipo e2 on e1.ip = e2.ip
                             where e1.id_cliente is not null and e1.id_cliente != e2.id_cliente));
        -- Se requiere controlar que no exista en la tabla equipo 2 o mas tuplas con un id_cliente distinto y misma IP.

    -- Implementacion en PostgreSQL:
    create or replace trigger tr_ins_ipClientes
        before insert on equipo
        for each row execute function fn_ipClientes();
        -- Ante una insercion en EQUIPO se activa el trigger que controla la restriccion anterior.

    create or replace trigger tr_act_ipClientes
        before update of ip on equipo
        for each row execute function fn_ipClientes();
        -- Ante una actualizacion de IP se debe controlar que la nueva IP no sea igual a otra ya existente de un cliente distinto.

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