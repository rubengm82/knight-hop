extends Label

@export var velocidad_caracteres: float = 0.01  # Tiempo entre cada carácter en segundos
@export var velocidad_palabras: float = 0.1     # Tiempo extra entre palabras
@export var iniciar_al_inicio: bool = true       # Si true, inicia automáticamente al _ready

var texto_completo: String = ""
var indice_caracter: int = 0
var temporizador: float = 0.0
var texto_actual: String = ""
var mostrando_texto: bool = false

func _ready() -> void:
	texto_completo = text
	text = ""
	texto_actual = ""
	indice_caracter = 0
	
	if iniciar_al_inicio:
		mostrando_texto = true

func _process(delta: float) -> void:
	if not mostrando_texto:
		return
	
	if indice_caracter < texto_completo.length():
		temporizador -= delta
		
		if temporizador <= 0:
			var caracter_actual = texto_completo[indice_caracter]
			texto_actual += caracter_actual
			text = texto_actual
			indice_caracter += 1
			
			# Añadir pausa extra después de puntuación
			if caracter_actual in [".", "!", "?", ",", "\n"]:
				temporizador = velocidad_caracteres * 10
			elif caracter_actual == " ":
				temporizador = velocidad_caracteres * 2
			else:
				temporizador = velocidad_caracteres
	else:
		mostrando_texto = false

# Función pública para iniciar el efecto
func iniciar_revelado() -> void:
	texto_completo = text if text != "" else texto_completo
	text = ""
	texto_actual = ""
	indice_caracter = 0
	mostrando_texto = true

# Función para mostrar todo el texto inmediatamente
func mostrar_todo() -> void:
	mostrando_texto = false
	text = texto_completo
	texto_actual = texto_completo
	indice_caracter = texto_completo.length()
