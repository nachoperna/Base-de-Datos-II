// Ejercicio 1
db.empleado.find({idJefe: null},
                        {
                        idEmpleado: 1,
                        nombre: 1,
                        apellido: 1,
                        idJefe: 1,
                        _id: 0
                            });

// Ejercicio 2
db.empleado.find({sueldo: {$gt: 1000}, porcComision: {$gt: 10}},
                            {
                            idEmpleado: 1,
                            sueldo: 1,
                            porcComision: 1,
                            _id: 0
                            });

// Ejercicio 3
db.empleado.find(
                            {
                            "tarea.sueldoMinimo": {$gt: 1000},
                            "tarea.sueldoMaximo": {$lt: 10000}
                            },
                            {
                            "tarea.idTarea": 1,
                            "tarea.sueldoMinimo": 1,
                            "tarea.sueldoMaximo": 1,
                            _id: 0
                            });

// Ejercicio 4
db.entrega.find({"renglonEntregas.cantidad": {$gt: 10}},
                 {
                 nroEntrega: 1,
                 "renglonEntregas.cantidad": 1
                 });

// Ejercicio 5
db.empleado.find({"departamento.ciudad.idCiudad": 41570}, {idEmpleado: 1, "departamento.ciudad.idCiudad": 1, sueldo: 1, _id: 0});
db.empleado.updateMany({"departamento.ciudad.idCiudad": 41570},
                        {$set: {sueldo: "sueldo" + ("sueldo" * 0.10)}});

// Ejercicio 6
db.empleado.aggregate([{$group: {_id: "$tarea.idTarea"}}, {$project: {_id: 0, "tareas": "$_id"}}]);

// Ejercicio 7
db.entrega.aggregate([{$group:
                            {
                            _id: "$idVideo",
                            "cantidad de entregas": {$count:{}}
                            }},
                       {$sort:
                            {
                            "cantidad de entregas": -1
                            }},
                       {$project:
                            {
                            _id: 0,
                            "idVideo": "$_id",
                            "cantidad de entregas": 1
                            }}]);

// Ejercicio 8
db.pelicula.aggregate([{$group:
                            {
                            _id: "$empresaProductora.codigoProductora",
                            "Cantidad de peliculas": {$count: {}}
                            }},
                       {$project:
                            {
                            "idEmpresa": "$_id",
                            "Cantidad de peliculas": 1,
                            _id: 0
                            }},
                       {$sort:
                            {
                            "Cantidad de peliculas": -1
                            }}]);

// Ejercicio 9
db.pelicula.aggregate([{$match:
                            {
                            genero: "infantil"
                            }},
                        {$group:
                            {
                            _id: "$genero",
                            "Cantidad peliculas infantiles": {$count: {}}
                            }},
                        {$limit : 5},
                        {$sort:
                            {
                            "Cantidad peliculas infantiles": -1
                            }},
                        {$project:
                            {
                            _id: 0,
                            "Genero": "$_id",
                            "Cantidad peliculas infantiles": 1,
                            "Nombre ciudad": "$empresaProductora.ciudad.nombreCiudad"
                            }}]);

// Ejercicio 10
db.empleado.find({porcComision: null, "tarea.sueldoMinimo": {$gt: 2000}}, {_id: 0, idEmpleado: 1, porcComision: 1, "tarea.sueldoMinimo": 1});
db.empleado.updateMany({porcComision: null, "tarea.sueldoMinimo": {$gt: 2000}}, {$set: {porcComision: 10}});
