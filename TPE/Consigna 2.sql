-- a. 
/* Al ser invocado (una vez por mes), para todos los servicios que son periódicos, se deben
   generar e insertar los registros asociados a la/s factura/s correspondiente/s a los distintos
   clientes. Indicar si se deben proveer parámetros adicionales para su generación y, de ser así, cuales. */

-- Utilizamos funciones de secuencia para generar los id_comp de Comprobante y nro_linea de LineaComprobante
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

create or replace procedure generarFacturas() -- procedimiento a llamar para generar las facturas cuando la empresa lo requiera
language 'plpgsql' as $$
    begin
        with nuevo_comprobante as -- variable a usar para poder utilizar los datos del comprobante actual insertado en las lineas que se insertaran del mismo
            (insert into comprobante (id_comp, id_tcomp, fecha, comentario, estado, fecha_vencimiento, id_turno, importe, id_cliente, id_lugar)
                select
                    (nextval('idComp')), -- proximo valor de secuencia
                    1, -- id_tcomp asociado a los comprobantes de tipo "Factura"
                    now(),
                    'Factura generada periodicamente',
                    'Pendiente',
                    now() + interval'1 month', -- vencimiento dentro de un mes al ser una factura periodica
                    null, -- turno nulo
                    0, -- importe 0, se actualizara automaticamente luego al insertar sus lineas gracias a las funciones implementadas en la consigna 1b
                    clientes.cliente,
                    1 -- lugar = 1 por default.
                from (select distinct p.id_persona as cliente from persona p -- para obtener el id_cliente al que se esta generando el comprobante lo obtenemos de la siguiente consulta donde obtenemos todos los clientes DISTINTOS que esten activos, tengan un servicio activo y sea periodico.
                            join equipo e on e.id_cliente = p.id_persona
                            join servicio s on e.id_servicio = s.id_servicio
                            where p.activo is true and s.activo is true and s.periodico is true) as clientes -- tagueamos la consulta
                returning id_comp, id_cliente) -- retornamos el id del comprobante y el id del cliente para poder usarlo en la insercion de las lineas de comprobantes asociadas a ese comprobante.

            insert into lineacomprobante (nro_linea, id_comp, id_tcomp, descripcion, cantidad, importe, id_servicio) 
            select
                nextval('nrolinea'), -- proximo valor de secuencia
                id_comp, -- idcomp correspondiente al comprobante recien insertado
                1, -- id_tcomp asociado a los comprobantes de tipo "Factura"
                'Servicio',
                consulta.cant, -- cantidad del servicio contratado
                consulta.importe, -- importe del servicio contratado
                consulta.id_servicio -- id del servicio contratado
            from nuevo_comprobante -- utilizamos esta variable como base para obtener el id_comp e insertarlo en la linea
            join (select s.costo as importe, e.id_cliente as idcliente, s.id_servicio, count(*) as cant 
                  from equipo e
                  join servicio s on e.id_servicio = s.id_servicio
                  group by e.id_cliente, s.id_servicio) as consulta -- como no podemos obtener el importe del servicio, su id y la cantidad correspondiente de la consulta anterior que usamos para insertar en Comprobante (al necesitar filtrar SOLO por clientes distintos), tenemos que generar otra consulta donde obtenemos el importe del servicio, su cantidad y su id.
                on nuevo_comprobante.id_cliente = consulta.idcliente; -- aca comprobamos que solo obtengamos el importe de los servicios y su cantidad correspondiente del cliente al que acabamos de generar su comprobante.
                -- en esta consulta obtenemos las cantidades correspondientes al agrupar todos los servicios del cliente correspondiente en la tabla EQUIPO y calcularles su cantidad. Ejemplo: si el cliente 1 tiene 2 servicios con la misma ID en la tabla Equipo, entonces en lineacomprobante se inserta una vez ese servicio con cantidad = 2
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
      
    select * from generarinformepersonal(to_timestamp('01-01-2000', 'DD-MM-YYYY H24:MI:SS'), now());
    -- Ejemplo de llamado.