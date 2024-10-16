-- a. 
/* Al ser invocado (una vez por mes), para todos los servicios que son periódicos, se deben
   generar e insertar los registros asociados a la/s factura/s correspondiente/s a los distintos
   clientes. Indicar si se deben proveer parámetros adicionales para su generación y, de ser así, cuales. */

create or replace procedure generarFacturas()
language 'plpgsql' as $$
    declare -- se declaran variables necesarias para guardar los datos de subconsultas internas de la funcion
        idtcomp int;
        idcomp int;
        nrolinea int;
        cliente_servicio record; -- variable necesaria para guardar los registros de todos los clientes activos, con servicios activos y periodicos,  y recorrerlos para generar sus facturas.
    begin
        for cliente_servicio in(
            select p.id_persona, s.id_servicio, s.costo from persona p
            join equipo e on e.id_cliente = p.id_persona
            join servicio s on e.id_servicio = s.id_servicio
            where p.activo is true and s.activo is true and s.periodico is true
        ) loop -- se recorre la variable que contiene una fila por cliente activo con servicio activo y periodico

        if (cliente_servicio.id_persona is not null and cliente_servicio.id_servicio is not null) then -- comprobamos que no obtengamos datos fallidos. Quedo innecesaria de una implementacion anterior
            -- Se obtiene un id de tipo de comprobante valido y se guarda en la variable declarada para organizar la funcion.
            select id_tcomp+1 into idtcomp from tipocomprobante order by id_tcomp desc limit 1;
            -- Se genera el tipo de comprobante
            if (idtcomp is null) then -- significa que no hay tipos de comprobantes cargados en el sistema.
                idtcomp = 1; -- se carga el primer tipo comprobante
            end if;
            insert into tipocomprobante values (
                                                idtcomp,
                                                'Venta',
                                                'Factura' -- todos comprobantes de tipo factura
                                               );

            -- Se obtiene un nuevo id de comprobante en continuacion con todos los que tiene el cliente y se guarda en la variable declarada para organizar la funcion.
            select id_comp+1 into idcomp from comprobante where id_cliente = cliente_servicio.id_persona order by id_comp desc limit 1;
            -- Se genera el comprobante (importe=0 porque debe actualizarse automaticamente cuando se le agreguen lineas)
            if (idcomp is null) then -- significa que no hay comprobantes cargados en el sistema.
                idcomp = 1; -- se carga el primer comprobante
            end if;
            insert into comprobante values (
                                            idcomp,
                                            idtcomp,
                                            now(),
                                            'Factura generada periodicamente',
                                            'Pendiente',
                                            now() + interval '30 days', -- vencimiento en 30 dias (mensual)
                                            null,
                                            0,
                                            cliente_servicio.id_persona,
                                            1 -- lugar default
                                           );

            -- Se obtiene un nro_linea valido y se guarda en la variable declarada para organizar la funcion.
            select nro_linea+1 into nrolinea from lineacomprobante where id_comp = idcomp and id_tcomp = idtcomp order by nro_linea limit 1;
            if (nrolinea is null) then -- significa que no hay lineas cargadas en nuestro comprobante.
                nrolinea = 1; -- se carga la primera linea
            end if;
            -- Se generan las lineas del comprobante creado
            insert into lineacomprobante values (
                                                 nrolinea,
                                                 idcomp,
                                                 idtcomp,
                                                 'Servicio de Internet',
                                                 1,
                                                 cliente_servicio.costo,
                                                 cliente_servicio.id_servicio
                                                );
            -- Se actualiza automaticamente el valor del importe del comprobante creado correspondiente.
        else
            raise exception 'Error en la carga de facturas de servicios periodicos';
        end if;
        end loop; -- se terminan de generar las facturas
    end;
    $$;
   
-- b.
/* Al ser invocado entre dos fechas cualesquiera genere un informe de los empleados
(personal) junto con la cantidad de clientes distintos que cada uno ha atendido en tal periodo y
los tiempos promedio y máximo del conjunto de turnos atendidos en el periodo.*/

   create or replace function generarInformePersonal(inicio_periodo timestamptz, fin_periodo timestamptz)
      returns table ( -- como se debe devolver un informe (en formato tabla), se decide crear una funcion que retorne una tabla virtual con los requisitos pedidos.
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
         return query -- se retorna la consulta que completa la tabla virtual que retorna la funcion
         (select p.id_personal, p1.nombre, count(distinct c.id_cliente), inicio_periodo, fin_periodo, avg(t.hasta - t.desde), max(t.hasta - t.desde) -- se calcula cantidad de clientes distintos, promedio de duracion de turnos y tiempo maximo de duracion de turnos.
          from personal p
              join persona p1 on p.id_personal = p1.id_persona
              join turno t on t.id_personal = p.id_personal
              join lugar l on l.id_lugar = t.id_lugar
              join comprobante c on l.id_lugar = c.id_lugar
          where t.desde >= inicio_periodo and t.hasta <= fin_periodo -- satisface el periodo de tiempo de turno ingresado por el usuario
          group by p.id_personal, p1.nombre -- se agrupan los datos por personal para calcular las funciones de agregacion de sus turnos.
         );
      end;
      $$ language 'plpgsql';
      