-- a. Listar los tipos de intervalos y la cantidad de servicios que hay de cada tipo
	db.servicio.aggregate([{$group:
                        {
                            _id:"$tipoIntervalo", "Cantidad de servicios":{$count:{}}}},
                        {$project:
                        {
                            _id: 0,
                            tipoIntervalo: "$_id",
                            "Cantidad de servicios": 1
                        }}]);

-- b. 
/* 
	Para cada uno de los clientes que haya tenido un total de facturación superior a 250, listar el identificador del cliente, el total de facturación
 	y la cantidad de comprobantes, ordenando descendentemente por el total.
*/

	db.comprobante.aggregate([{$group:
                            {
                            _id:"$cliente.idCliente",
                            "Total facturacion": {$sum: "$importe"},
                            "Cantidad comprobantes": {$count: {}}
                            }},
                          {$match:
                            {
                            "Total facturacion": {$gt: 250} // gt = greater than
                            }},
                          {$sort:
                            {
                            "Total facturacion": -1 // -1 = orden descendente
                            }},
                          {$project:
                            {
                            _id: 0,
                            "idCliente": "$_id",
                            "Total facturacion": 1,
                            "Cantidad comprobantes": 1
                            }}]);