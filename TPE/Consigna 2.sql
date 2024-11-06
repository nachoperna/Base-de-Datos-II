-- a. 
/* Al ser invocado (una vez por mes), para todos los servicios que son periódicos, se deben
   generar e insertar los registros asociados a la/s factura/s correspondiente/s a los distintos
   clientes. Indicar si se deben proveer parámetros adicionales para su generación y, de ser así, cuales. */

create sequence idComp
    start with 1
    increment by 1
    minvalue 1
    cycle;

create sequence nrolinea
    start with 1
    increment by 1
    minvalue 1
    cycle;

create or replace procedure generarFacturas()
language 'plpgsql' as $$
    begin
        with nuevo_comprobante as
            (insert into comprobante (id_comp, id_tcomp, fecha, comentario, estado, fecha_vencimiento, id_turno, importe, id_cliente, id_lugar)
                select
                    (nextval('idComp')),
                    1,
                    now(),
                    'Factura generada periodicamente',
                    'Pendiente',
                    now() + interval'1 month',
                    null,
                    0,
                    clientes.cliente,
                    1
                from (select distinct p.id_persona as cliente from persona p
                            join equipo e on e.id_cliente = p.id_persona
                            join servicio s on e.id_servicio = s.id_servicio
                            where p.activo is true and s.activo is true and s.periodico is true) as clientes
                returning id_comp, id_cliente)

            insert into lineacomprobante (nro_linea, id_comp, id_tcomp, descripcion, cantidad, importe, id_servicio)
            SELECT
                nextval('nrolinea'),
                id_comp,
                1,
                'Servicio',
                consulta.cant,
                consulta.importe,
                consulta.id_servicio
            from nuevo_comprobante
            join (select s.costo as importe, e.id_cliente as idcliente, s.id_servicio, count(*) as cant
                  from equipo e
                  join servicio s on e.id_servicio = s.id_servicio
                  group by e.id_cliente, s.id_servicio) as consulta
                on nuevo_comprobante.id_cliente = consulta.idcliente;
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
      