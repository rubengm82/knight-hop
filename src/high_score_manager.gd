class_name HighScoreManager
extends RefCounted

# HighScoreManager: Gestiona los records de tiempo (menor tiempo = mejor puntuacion)
# Usa SQLite para almacenar top 3 puntuaciones.

var db: SQLite

# Instancia singleton
static var instance: HighScoreManager = null

static func get_instance() -> HighScoreManager:
	if instance == null:
		instance = HighScoreManager.new()
	return instance

func _init():
	if instance != null:
		return
	instance = self
	db = SQLite.new()
	db.path = "res://database.sqlite"
	var success = db.open_db()
	if not success:
		push_error("No se pudo abrir la base de datos SQLite")
		return
	_create_table()
	_ensure_initial_records()

func _create_table() -> void:
	db.query("""
        CREATE TABLE IF NOT EXISTS highscores (
            rank INTEGER PRIMARY KEY CHECK (rank >= 1 AND rank <= 3),
            name TEXT NOT NULL,
            time INTEGER NOT NULL
        )
	""")

func _ensure_initial_records() -> void:
	db.query("SELECT COUNT(*) as cnt FROM highscores")
	var result = db.query_result
	if result.size() == 0 or result[0]["cnt"] == 0:
		_insert_initial_records()

func _insert_initial_records() -> void:
	db.query("INSERT INTO highscores (rank, name, time) VALUES (1, 'COM', 99999)")
	db.query("INSERT INTO highscores (rank, name, time) VALUES (2, 'COM', 99999)")
	db.query("INSERT INTO highscores (rank, name, time) VALUES (3, 'COM', 99999)")

# Guarda una nueva puntuacion si entra en el top 3 (menor tiempo)
func save_score(time: int) -> void:
	# Obtener los records actuales ordenados por tiempo ascendente
	db.query("SELECT rank, name, time FROM highscores ORDER BY time ASC")
	var rows = db.query_result
	var scores := []
	for row in rows:
		scores.append({ "rank": row["rank"], "name": row["name"], "time": row["time"] })
	# Asegurar que tenemos al menos 3 entradas (rellenar con COM 99999)
	while scores.size() < 3:
		scores.append({ "rank": scores.size() + 1, "name": "COM", "time": 99999 })
	# Si el nuevo tiempo no es mejor que el tercero, no hacer nada
	if time >= scores[2].time:
		return
	# Anadir nueva puntuacion (PLAYER = 'PLY') y reordenar
	scores.append({ "rank": 0, "name": "PLY", "time": time })
	scores.sort_custom(func(a: Dictionary, b: Dictionary): return a.time < b.time)
	if scores.size() > 3:
		scores = scores.slice(0, 3)
	# Reasignar ranks 1,2,3
	for i in range(scores.size()):
		scores[i]["rank"] = i + 1
	# Actualizar base de datos: borrar todo e insertar top 3
	db.query("DELETE FROM highscores")
	for sc in scores:
		db.query("INSERT INTO highscores (rank, name, time) VALUES (%d, '%s', %d)" % [sc["rank"], sc["name"], sc["time"]])


# Devuelve los top 3 scores ordenados por rank
func get_top_scores() -> Array:
	if db == null:
		return []
	db.query("SELECT name, time FROM highscores ORDER BY rank ASC LIMIT 3")
	var result = db.query_result
	var scores := []
	for row in result:
		scores.append({"name": row["name"], "time": row["time"]})
	return scores
