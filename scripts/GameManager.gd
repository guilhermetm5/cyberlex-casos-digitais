extends Node

var current_case_data: Dictionary = {}
var score: Dictionary = {
	"juridica": 100,
	"investigacao": 100,
	"provas": 100,
	"etica": 100,
	"risco": 100
}
var decisions_made: Array = []
var current_question_index: int = 0


func reset_game() -> void:
	score = {
		"juridica": 100,
		"investigacao": 100,
		"provas": 100,
		"etica": 100,
		"risco": 100
	}
	decisions_made = []
	current_question_index = 0


func load_case(case_id: String) -> Dictionary:
	var file := FileAccess.open("res://data/cases.json", FileAccess.READ)
	if not file:
		push_error("Falha ao abrir cases.json")
		return {}
	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(json_string) != OK:
		push_error("Erro ao parsear JSON: " + json.get_error_message())
		return {}

	var data = json.get_data()
	for case_data in data["cases"]:
		if case_data["id"] == case_id:
			current_case_data = case_data
			return case_data
	return {}


func apply_decision_effects(effects: Dictionary) -> void:
	for key in effects:
		if score.has(key):
			score[key] = clampi(score[key] + effects[key], 0, 100)


func get_final_grade() -> String:
	var total := 0
	for key in score:
		total += score[key]
	var avg := total / score.size()

	if avg >= 85:
		return "A"
	elif avg >= 70:
		return "B"
	elif avg >= 55:
		return "C"
	elif avg >= 40:
		return "D"
	else:
		return "F"


func change_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
