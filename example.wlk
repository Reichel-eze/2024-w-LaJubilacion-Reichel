// PRIMERA PARTE: LAS INVITACIONES

/*
Los roles de jefe, desarrollador e infraestructura son excluyentes y no cambian con el tiempo. 
Lo que sí puede cambiar es cuál es el personal a cargo de un jefe. Puede haber empleados sin jefes o con más de un jefe.
*/

class Empleado {
  //const jefes = []  // Puede haber empleados sin jefes o con más de un jefe. 
  const lenguajesAprendidos = [] 
  //var experiencia

  // 2) Hacer que cualquier empleado aprenda a programar en un lenguaje de programación.
  method aprenderLenguaje(lenguaje) {
    lenguajesAprendidos.add(lenguaje)
  }

  // 3) Saber si un empleado está invitado al festejo.
  method estaInvitado() = self.esCopado() or self.puedeSerInvitado() // cualquier persona copada esta invitada

  method puedeSerInvitado() // metodo abstracto

  method sabeProgramarEnWollok() = lenguajesAprendidos.contains(wolok)

  method sabeProgramarEnAlgunLenguajeAntiguo() = lenguajesAprendidos.any({lenguaje => lenguaje.esAntiguo()}) 
  method sabeProgramarEnAlgunLenguajeModerno() = lenguajesAprendidos.any({lenguaje => lenguaje.esModerno()}) 
  
  //method sabeProgramarEnAlgunLenguajeX() = lenguajesAprendidos.any({lenguaje => self.algunX()}) 
  //method algunAntiguo(lenguaje) = lenguaje.esAntiguo()
  //method algunModerno(lenguaje) = lenguaje.esModerno()

  method esCopado() // metodo abstracto

  // el número coincide con la cantidad de lenguajes modernos que maneja la persona
  method mesaCorrespondiente() = self.cantidadLenguajesModernos()
 
  method cantidadLenguajesModernos() = lenguajesAprendidos.filter({lenguaje => lenguaje.esModerno()}).size()

  // Los asistentes regalan efectivo, cada uno da un monto de $1.000 por cada lenguaje de programación moderno que conozca
  method montoQueRegala() = 1000 * self.cantidadLenguajesModernos()
}

class Lenguaje {
  const anioCreacion

  method esModerno() = anioCreacion >= 2000
  method esAntiguo() = !self.esModerno()
}

const wolok = new Lenguaje(anioCreacion = 2017)

class Jefe inherits Empleado {
  const personal = []

  // 1) Permitir que un jefe tome a su cargo a un empleado. 
  method tomarASuCargo(empleado) {
    personal.add(empleado)
  }

  method soloGenteCopada() = personal.all({persona => persona.esCopado()})

  override method puedeSerInvitado() = self.sabeProgramarEnAlgunLenguajeAntiguo() and self.soloGenteCopada()

  // ¿ un jefe no es copado?
  override method esCopado() = false

  // salvo para los jefes que les corresponde la mesa 99
  override method mesaCorrespondiente() = 99

  // Los jefes regalan adicionalmente $1.000 por cada empleado a cargo suyo.
  override method montoQueRegala() = super() + 1000 * personal.size()


}

class Desarrollador inherits Empleado {
  
  override method puedeSerInvitado() = self.sabeProgramarEnWollok() or self.sabeProgramarEnAlgunLenguajeAntiguo() 

  override method esCopado() = self.sabeProgramarEnAlgunLenguajeAntiguo() and self.sabeProgramarEnAlgunLenguajeModerno()
}

class Infraestructurra inherits Empleado {
  var experiencia

  override method puedeSerInvitado() = lenguajesAprendidos.size() >= 5

  override method esCopado() = experiencia > 10
}

object acmeSA {
  const personalDeLaEmpresa = []

  // 4) Obtener la lista de invitados para el festejo considerando a todo el personal de la empresa.
  method listaDeInvitados() = personalDeLaEmpresa.filter({persona => persona.estaInvitado()})

  method cantidadInvitados() = self.listaDeInvitados().size()
}

// SEGUNDA PARTE: LA FIESTA
object fiesta {
  const costoFijo = 200000
  const costoFijoXPersona = 5000
  const invitados = acmeSA.listaDeInvitados()
  const asistencias = []

  // 1) Registrar la asistencia de una persona al evento, asegurando que esté invitada
  method recibirPersona(persona) {
    self.verificarInvitacion(persona)
    self.registrarAsistencia(persona)
  }

  method verificarInvitacion(persona){
    if(!invitados.contains(persona))
      throw new DomainException(message="La persona NO fue invitada a la fiesta")
  }

  method registrarAsistencia(persona){
    asistencias.add(new Asistencia(empleado = persona, numeroDeMesa = persona.mesaCorrespondiente()))
  }

  // 2) Calcular el balance de la fiesta, que es la diferencia entre el importe recibido por regalos y el costo. 
  method balance() = self.importeRegalos() - self.costo()

  method importeRegalos() = asistencias.sum({asistencia => asistencia.montoRegalado()})

  method costo() = costoFijo + costoFijoXPersona * self.cantidadDeAsistentes()

  method cantidadDeAsistentes() = asistencias.size()

  // 3) Saber si la fiesta fue un éxito, que se cumple si el balance fue positivo y 
  // todos los invitados asistieron al evento.

  method fueUnExito() = self.balancePositivo() and self.todosAsistieron()

  method balancePositivo() = self.balance() > 0

  method todosAsistieron() = self.cantidadDeAsistentes() == acmeSA.cantidadInvitados()

  // 4) Saber cuál fue la mesa con más asistentes. 
  method mesaConMasAsistentes() = self.mesas().max({mesa => self.mesas().ocurrencesOf(mesa)}) // 2dos) busco la mesa que mas ocurrencias tenga en la lista de mesas (que mas se repita)

  method mesas() = asistencias.map({asistencia => asistencia.numeroDeMesa()})                 // 1ero) obtengo una lista de numeros de mesas
}

// registro de asistencias..
class Asistencia {
  const empleado
  const numeroDeMesa

  method montoRegalado() = empleado.montoQueRegala() 

  method numeroDeMesa() = numeroDeMesa
}

// Para analizar: 
// ¿Podría tener un jefe a su cargo a otro jefe? 
// ¿Qué cambios implicaría hacer en la solución para contemplar dicho caso? ¿Qué situaciones se deberían evitar?

/*
Si, un jefe podria tener a cargo un jefe porque todos los jefes heredan de la clase empleado, es decir, un jefe es si 
mismo es un empleado, por lo tanto como un jefe tiene empleados a su cargo, entonces dichos empleados podrian ser jefes.

Como esta hecho el codigo ya se podria hacer eso!!

*/
