class Subasta{
	var usuarioVendedor
	var articulo
	var precioBase
	var fechaFinalizacion
	var listaOfertas = []
	var mejorOfertaExistente = 0
	var estadoSubasta = new EstadoSubastaAbierta()
	
	constructor(nombreVendedor,articuloAVender,precioDeBase,diaFinalizacion,mesFinalizacion,anioFinalizacion){
		usuarioVendedor = nombreVendedor
		articulo = articuloAVender
		precioBase = precioDeBase
		fechaFinalizacion = new Date(diaFinalizacion,mesFinalizacion,anioFinalizacion)
	}
	
	method recibirOfertaDe(unaOferta){
		if (estadoSubasta.estaAbierta() and (unaOferta.monto() > mejorOfertaExistente)){
			listaOfertas.add(unaOferta)
			mejorOfertaExistente = unaOferta.monto()
		}
	}
	method cobrarAVendedor(){
		usuarioVendedor.modificarDeuda(articuloAVender.comisionACobrar(mejorOfertaExistente))
}
	method estado(nuevoEstado){
		estadoSubasta = nuevoEstado
	}

	method cerrarSubastasA(unaFecha){
		estadoSubasta.cerrarSubasta(self,unaFecha)
	}
	
	method obtenerOferentes(){
		listaOfertas.map({oferta => oferta.oferente()})
	}
	method obtenerOferenteGanador(){
		return self.ofertas().max({oferta1 => oferta1.monto()}).oferente()
	}
	method ofertas(){
		return listaOfertas
	}
	
	
}
	class EstadoSubastaAbierta{
	method cerrarSubasta(subasta,fecha){
		if (subasta.fechaFinalizacion() >= fecha){
			subasta.estado(new EstadoSubastaCerrado())
			subasta.cobrarAVendedor()
			subasta.obtenerOferenteGanador(subasta).sumar1AContadorDeSubastasGanadas()
			subasta.obtenerOferentes().map({oferta => oferta.sumar1AContadorDeSubastasParticipadas()})
			}
	}
	method estaAbierta(){
		return true
	}
	method esGanador(subasta,oferta){
		error.throwWithMessage("La subasta esta abierta, no hay ganadores todavia!!")
	}
	
}
	
	class EstadoSubastaCerrado{
		method cerrarSubasta(subasta,fecha){
			error.throwWithMessage("La subasta ya se encuentra cerrada!!")
	}
	method estaAbierta(){
		return false
	}
	method esGanador(subasta,oferta){
		return oferta == subasta.ofertas().max({oferta1 => oferta1.monto()})
	}
	
}
	

/*
	method cerrarSubastasA(unaFecha){
		if (unaFecha > fechaFinalizacion){
			subastaAbierta = false	
			self.cobrarAVendedor()
		}
	}
	  
	method obtenerOferentes(){
		listaOfertas.map({oferta => oferta.oferente()})
	}
	method esGanador(usuario){
		if (!subastaAbierta){
			listaOfertas.filter()
		}
	}
}
	


*/
class Oferta{
	var oferente
	var monto
	var fecha
	constructor (nombreOferente,montoOfertado,dia,mes,anio){
		oferente = nombreOferente
		monto = montoOfertado
		fecha = new Date (dia,mes,anio)
	}
	method monto(){
		return monto
	}
	method oferente(){
		return oferente
	}
	method sumar1aContadorDeSubastasGanadas(){
		oferente.sumar1aContadorDeSubastasGanadas()
	}
	method sumar1AContadorDeSubastasParticipadas(){
		oferente.sumar1aContadorDeSubastasGanadas()
	}
}



class Usuario{
	var nombre
	var deuda
	var contadorSubastasGanadas = 0
	var contadorSubastasQueParticipo = 0
	constructor(nombreVendedor){
		nombre = nombreVendedor
		}
	method modificarDeuda(deudaAIncrementar){
		deuda += deudaAIncrementar
	
	}
	method sumar1AContadorDeSubastasGanadas(){
		contadorSubastasGanadas = contadorSubastasGanadas + 1
	}
	method sumar1aContadorDeSubastasGanadas(){
		contadorSubastasQueParticipo = contadorSubastasQueParticipo + 1
	}
	method esGanador(subasta){
		return subasta.obtenerOferenteGanador() == self
	}
	method esLooser(){
		return contadorSubastasGanadas<=0 and contadorSubastasQueParticipo>=1
	}
}

class Articulo{
	var nombre
	var tipo
	constructor(nombreArticulo,tipoDeArticulo){
		nombre = nombreArticulo
		tipo = tipoDeArticulo
	}
	method descontarComision(monto){
		return 10.max(monto*0.5)
	}
}

class ArticuloInmueble inherits Articulo{
	override method descontarComision(monto){
		return 1000
	}
}
class ArticuloAutomotor inherits Articulo{
	override method descontarComision(monto){
		return 500
	}
}

class ArticuloComputacion inherits Articulo{
	override method descontarComision(monto){
		return monto*0.1
	}
}