-- Ejercicio 5

-- VISTA empleado_dist_20
	-- Con WITH CHECK OPTION sin importar LOCAL o CASCADE la actualizacion debe cumplir que id_distribuidor = 20

-- VISTA empleado_dist_2000
	-- LOCAL: la actualizacion debe cumplir que el sueldo del empleado sea mayor a 2000. Y si la vista empleado_dist_20 tiene un CHECK OPTION definido, entonces la actualizacion tambien debera cumplir que id_distribuidor = 20
	-- CASCADE: la actualizacion debe cumplir que el empleado tenga un sueldo mayor a 2000 y que pertenezca al distribuidor 20.

-- VISTA empleado_dist_20_70
	-- LOCAL: la actualizacion debe cumplir que el empleado haya nacido en la decada del 70, y como la vista subyacente empleado_dist_20 tiene un CHECK OPTION entonces tambien debe cumplir que su id_distribuidor sea 20.
	-- CASCADE: "