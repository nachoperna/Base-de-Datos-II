-- 1.a
	-- Controlar que los proveedores tengan registrado un telefono o un email.
	alter table proveedor add constraint chk_contacto
	check (telefono is not null or email is not null);
	-- se necesita realizar solamente un control a nivel atributo porque tanto el telefono como el email son parte de la misma tabla y solo debe controlarse sus valores individuales
-- 1.b
	-- Verificar que la cantidad total vendida de cada cosecha no exceda la cantidad cosechada de la misma
	create assertion check_cantidad_vendida
	check (not exists(
			select 1
			from venta v
			join cosecha c using(id_cultivo, nro_cosecha)
			group by v.id_cultivo, v.nro_cosecha having sum(v.cantidad_vendida) > c.cantidad_cosechada));
	-- se necesita un assertion porque es un control a nivel general al involucrar 2 tablas diferentes.

-- 1.c
	-- Para cada cultivo, los numeros de cosecha deben reflejar el orden cronologico de las fechas de cosecha, es decir, un numero de cosecha mayor se debe corresponder a una fecha de cosecha posterior para el mismo cultivo.
	alter table cosecha add constraint check_nrocosecha
	check (not exists(
			select 1
			from cosecha c1
			where exists(
				select 1
				from cosecha c2
				where c1.id_cultivo = c2.id_cultivo
					and c2.fecha_cosechada is after c1.fecha_cosechada 
					and c2.nro_cosecha <= c1.fecha_cosechada)));
	-- se necesita realizar un control a nivel de tupla por lo que se puede agregar una restriccion a la misma tabla siendo soportada por postgresql y no crear un assertion.
	-- controlamos que no exista en la tabla COSECHA una tupla que pertenezca al mismo cultivo que otra, con una fecha de cosecha psoterior y un numero de cosecha anterior para cumplir con la cronologia.

-- 2.a
	-- V1: que contenga los datos de los cultivos sembrados durante el corriente año que no registren inventario de productos adquiridos al proveedor 'AgroPlus'
	create view v1 as 
	select * from cultivo
	where extract(year from fecha_siembra) = extract(year from current_date)
		and id_cultivo in 
			(select id_cultivo
				from inventario
				join proveedor using (id_proveedor)
				where nombre <> 'AgroPlus');
	-- hay que cambiar IN por NOT IN y <> por = 
	-- incluye cultivos de este año que tienen inventarios de proveedores distintos de 'AgroPlus'
	-- es automaticamente actualizable en postgresql
	-- Justificacion: salvando el error de sintaxis <>, si bien el objetivo final se cumple porque es lo mismo un cultivo que no tenga inventario perteneciente a AgroPlus
	-- 	...a un cultivo que tenga un proveedor distinto a AgroPlus, no se cumple la sintaxis especifica de la consigna.

-- 2.b
	-- V2: que contenga para cada cosecha con al menos 3 ventas realizadas, el identificador de la cosecha, la cantidad total vendida y la fecha la ultima venta registrada.
	create view v2 as 
	select nro_cosecha, id_cultivo, sum(cantidad_vendida) as total_vendido, max(fecha_venta) as ultima_venta
	from venta
	group by nro_cosecha, id_cultivo having count(*) >= 3;
	-- c) calcula correctamente la cantidad total vendida y la fecha de la ultima venta regstrada por cada cosceha diferente.
	-- e) mediante la clausula HAVING se asegura que solo se incluyan cosechas con al menos 3 ventas realizadas
	-- j) no es automaticamente actualizable al incluir agrupamiento en su definicion.
	-- Justificacion: realiza lo pedido correctamente porque extrae la informacion directamente de la tabla VENTA, por lo tanto al agrupar por los identificadores de la cosecha nos estamos asegurando 
	-- ...de tener todas cosechas que hayan tenido al menos una venta y nos quedamos con las que aparezcan 3 veces o mas, sumando las cantidades de cada una y obteniendo la fecha mas reciente de todas

-- 2.c
	-- V3: que contenga los datos de los cultivos que han tenido el mayor promedio de cantidad vendida el año actual.
	create view v3 as
	(select c.*
		from cultivo c
		join venta v using (id_cultivo)
		group by c.id_cultivo having extract(year from v.fecha_venta) = extract(year from current_date)
		order by avg(v.cantidad_vendida) desc
	)
	with check option;

-- 3.a
	create or replace procedure llenarTabla()
	language plpgsql as $$
	begin
		insert into cultivos_agricultor (id_agricultor, nombre, fecha_registro, cantidad_cultivos, fecha_ultima_siembra) values 
			(select a.id_agricultor, a.nombre, a.fecha_registro, coalesce(count(c.id_agricultor), 0), max(c.fecha_siembra)
				from agricultor a
				join cultivo c using (id_agricultor)
				group by a.id_agricultor
			);
	end $$;

	call llenarTabla();

	-- La solucion planteada inserta en la tabla cultivos_agricultor a traves de una query que toma los datos basicos del agricultor
	-- ... desde la tabla AGRICULTOR y calcula la cantidad de cultivos que tiene mediante un ensamble con cultivo contabilizando la cantidad
	-- ... de veces en las que aparece ese agricultor en la tabla y marcando un 0 si no aparece. Tambien se calcula la fecha maxima (la mas reciente)
	-- ... gracias a la agrupacion que se hace POR AGRICULTOR en la tabla CULTIVO.

-- 3,b
	-- Los eventos criticos a controlar son la insercion de un nuevo agricultor, la insercion de un nuevo cultivo de un agricultor, 
	-- ... la eliminacion de un agricultor y la eliminacion de un cultivo de un agricultor.

	create or replace trigger tr_insAgricultor
	after insert on agricultor
	for each row execute function fn_insAgricultor();

	create or replace trigger tr_insCultivo
	after insert on cultivo
	for each row execute function fn_insCultivo();

	create or replace trigger tr_delCultivo
	after delete on agricultor
	for each row execute function fn_delAgricultor();

	create or replace trigger tr_delCultivo
	after delete on cultivo
	for each row execute function fn_delCultivo();	

	create or replace function fn_insAgricultor()
	returns trigger as $$
	begin
		insert into cultivos_agricultor values (new.id_agricultor, new.nombre, current_date, 0, null);
		return new;
	end $$ language plpgsql;

	create or replace function fn_insCultivo()
	returns trigger as $$
	begin
		update cultivos_agricultor 
			set cantidad_cultivos = cantidad_cultivos+1
				and fecha_ultima_siembra = now()
			where new.id_agricultor is not null
				and id_agricultor = new.id_agricultor;
		return new;
	end $$ language plpgsql;

	-- Al insertar un nuevo agricultor en la base, se le crea una entrada en la tabla cultivos_agricultor pero con 0 cultivos hasta registrar uno.
	-- Cuando se inserta un cultivo en el sistema, todos los agricultores van a estar registrados en la tabla cultivos_agricultor, por lo que solo se debe 
	-- ... buscar ese agricultor e incrementar su cantidad de cultivos en 1 por cada cultivo ingresado, junto con la fecha de siembra actual.

-- 5.
	-- Para optimizar la consulta emplearia el indice:
		create index idx_indice on venta(fecha_venta, cantidad_vendida);
	-- porque son las unicas dos condiciones que se deben cumplir para retornar una tupla en nuestra consulta y tener el acceso a esos atributos optimizado es clave para el tiempo de respuesta.
	-- El DBMS para recuperar los datos de la consulta primero filtra las tuplas de la tabla VENTA segun la condicion de atributos establecida de esa tabla,
	-- ... y luego con esa filtracion, realiza los ensambles con las demas tablas a traves de las claves de cada una para mostrar la informacion solicitada.

-- 7.
	create user alice, bob, charlie;
	create role managers, analysts;
	grant managers to alice;
	grant analysts to bob;

	grant select, update on cosecha to alice;
	grant select on venta to analysts;
	grant insert on agricultor to managers;
	grant all on venta to bob with grant option;
	grant select on cosecha, agricultor to charlie;

	-- a. SI
	-- b. SI
	-- c. NO
	-- d. NO
	-- e. NO

	revoke select on cosecha from charlie;
	revoke insert on agricultor from managers;
	grant delete on venta to alice;

	-- a. SI
	-- b. SI
	-- c. SI
	-- d. NO

	grant analysts to alice;
	revoke select on venta from analysts;

	-- a. NO
	-- b. SI
	-- c. NO
	-- d. NO (alice sigue conservando permiso de UPDATE y DELETE sobre VENTA)

	revoke grant option for all on venta from bob;

	-- a. SI
	-- b. NO
	-- c. NO
	-- d. NO