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
	method articulo(){
		return articulo
	}
	method mejorOfertaSubasta(){
		return mejorOfertaExistente
	}
	
}
class SubastaEspecial inherits Subasta{
	var cantMaxOfertas
	var ofertasRecibidas = 0
	constructor(nombreVendedor,articuloAVender,precioDeBase,diaFinalizacion,mesFinalizacion,anioFinalizacion,cantOfertas) = super(nombreVendedor,articuloAVender,precioDeBase,diaFinalizacion,mesFinalizacion,anioFinalizacion){
		cantMaxOfertas = cantOfertas
		}
	override method recibirOfertaDe(unaOferta){
		if (super(unaOferta) && unaOferta.antiguedadOferente()>2 && unaOferta.oferenteGanador() ){
			listaOfertas.add(unaOferta)
			mejorOfertaExistente = unaOferta.monto()
			ofertasRecibidas += 1
		if (ofertasRecibidas>=	cantMaxOfertas){
			self.cerrarSubastasA(fechaFinalizacion)
			}
		}
	}
	
}

class SubastaRapida inherits Subasta{
	var montoAAlcanzar
	constructor(nombreVendedor,articuloAVender,precioDeBase,diaFinalizacion,mesFinalizacion,anioFinalizacion,monto) = super(nombreVendedor,articuloAVender,precioDeBase,diaFinalizacion,mesFinalizacion,anioFinalizacion){
		montoAAlcanzar = monto
		}
		override method recibirOfertaDe(unaOferta){
		if (super(unaOferta) ){
			listaOfertas.add(unaOferta)
			mejorOfertaExistente = unaOferta.monto()
		if (mejorOfertaExistente >=	montoAAlcanzar){
			self.cerrarSubastasA(fechaFinalizacion)
			}
		}
	}
}
	
	class EstadoSubastaAbierta{
	method cerrarSubasta(subasta,fecha){
		if (subasta.fechaFinalizacion() >= fecha){
			subasta.estado(new EstadoSubastaCerrado())
			subasta.cobrarAVendedor()
			subasta.obtenerOferenteGanador(subasta).sumar1AContadorDeSubastasGanadas()
			subasta.obtenerOferentes().map({oferta => oferta.sumar1AContadorDeSubastasParticipadas()})
			subastasCerradas.agregarSubastaCerrada(subasta)
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
	
object subastasCerradas{
	var listaSubastasCerradas = []
	method agregarSubastaCerrada(subasta){
		listaSubastasCerradas.add(subasta)
	}
	method precioPromedioDe(unProducto){
		var listaSubastasCerradasPorArticulo
		listaSubastasCerradasPorArticulo = listaSubastasCerradas.filter({subasta => subasta.articulo() == unProducto})
		return listaSubastasCerradasPorArticulo.sum({subasta => subasta.mejorOfertaSubasta()})/listaSubastasCerradas.size()
	}
}	

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
	method antiguedadOferente(){
		return oferente.antiguedad()
	}
	method oferenteGanador(){
		return oferente.ganoAlMenosUnaVez()
	}
}

class Usuario{
	var nombre
	var deuda
	var contadorSubastasGanadas = 0
	var contadorSubastasQueParticipo = 0
	var antiguedad
	constructor(nombreVendedor,aantiguedad){
		nombre = nombreVendedor
		antiguedad = aantiguedad
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
	method esLoser(){
		return contadorSubastasGanadas<=0 and contadorSubastasQueParticipo>=1
	}
	method antiguedad(){
		return antiguedad
	}
	method ganoAlMenosUnaVez(){
		return contadorSubastasGanadas>=1
			
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