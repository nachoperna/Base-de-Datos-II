-- a. 
/* Al ser invocado (una vez por mes), para todos los servicios que son periódicos, se deben
   generar e insertar los registros asociados a la/s factura/s correspondiente/s a los distintos
   clientes. Indicar si se deben proveer parámetros adicionales para su generación y, de ser así, cuales. */

create or replace procedure generarFacturas()
language 'plpgsql' as $$
    declare
        --idcliente int;
        --idservicio int;
        --costo_servicio numeric(18,3);
        --cantidad_servicio int;
        idtcomp int;
        idcomp int;
        cliente_servicio record;
    begin
        for cliente_servicio in(
            select p.id_persona, s.id_servicio, s.costo from persona p
            join equipo e on e.id_cliente = p.id_persona
            join servicio s on e.id_servicio = s.id_servicio
            where p.activo is true and s.activo is true and s.periodico is true
        ) loop

        if (cliente_servicio.id_persona is not null and cliente_servicio.id_servicio is not null) then -- comprobamos que no obtengamos datos fallidos
            -- Se obtiene un id de tipo de comprobante valido
            select id_tcomp+1 into idtcomp from tipocomprobante order by id_tcomp desc limit 1;
            -- Se genera el tipo de comprobante
            insert into tipocomprobante values (
                                                idtcomp,
                                                'Venta',
                                                'Factura'
                                               );

            -- Se obtiene un nuevo id de comprobante en continuacion con todos los que tiene el cliente
            select id_comp+1 into idcomp from comprobante where id_cliente = cliente_servicio.id_persona order by id_comp desc limit 1;
            -- Se genera el comprobante (importe=0 porque debe actualizarse automaticamente cuando se le agreguen lineas)
            insert into comprobante values (
                                            idcomp,
                                            idtcomp,
                                            now(),
                                            'Factura generada periodicamente',
                                            'Pendiente',
                                            now() + interval '30 days',
                                            null,
                                            0,
                                            cliente_servicio.id_persona,
                                            1
                                           );

            -- Se generan las lineas del comprobante creado
            insert into lineacomprobante values (
                                                 (select nro_linea+1 from lineacomprobante order by nro_linea limit 1),
                                                 idcomp,
                                                 idtcomp,
                                                 'Servicio de Internet',
                                                 1,
                                                 cliente_servicio.costo,
                                                 cliente_servicio.id_servicio
                                                );
            -- Deberia actualizarse automaticamente el valor de importe del comprobante correspondiente al insertar una linea.
        else
            raise exception 'Error en la carga de facturas de servicios periodicos';
        end if;
        end loop;
    end;
    $$;
   
-- b.
/* Al ser invocado entre dos fechas cualesquiera genere un informe de los empleados
(personal) junto con la cantidad de clientes distintos que cada uno ha atendido en tal periodo y
los tiempos promedio y máximo del conjunto de turnos atendidos en el periodo.*/

   create or replace function generarInformePersonal(inicio_periodo timestamptz, fin_periodo timestamptz)
      returns table (
         id_personal int,
         nombre_personal varchar(40),
         cantidad_clientes_atendidos bigint,
         desde timestamptz,
         hasta timestamptz,
         tiempo_promedio_turno interval,
         tiempo_maximo_turno interval
      )
      as $$
      begin
         return query
         (select p.id_personal, p1.nombre, count(distinct c.id_cliente), inicio_periodo, fin_periodo, avg(t.hasta - t.desde), max(t.hasta - t.desde)
          from personal p
              join persona p1 on p.id_personal = p1.id_persona
              join turno t on t.id_personal = p.id_personal
              join lugar l on l.id_lugar = t.id_lugar
              join comprobante c on l.id_lugar = c.id_lugar
          where t.desde >= inicio_periodo and t.hasta <= fin_periodo
          group by p.id_personal, p1.nombre
         );
      end;
      $$ language 'plpgsql';

      select * from generarInformePersonal(to_timestamp('2024-10-09 00:00:00', 'yyyy-mm-dd HH24:MI:SS'), now());
      