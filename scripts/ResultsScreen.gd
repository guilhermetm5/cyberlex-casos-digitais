extends Control

const GRADE_COLORS := {
	"A": Color(0.2, 1.0, 0.45),
	"B": Color(0.35, 0.8, 1.0),
	"C": Color(1.0, 0.82, 0.2),
	"D": Color(1.0, 0.5, 0.1),
	"F": Color(1.0, 0.22, 0.22),
}
const GRADE_DESC := {
	"A": "Analista Exemplar — Excelente domínio do Direito Cibernético!",
	"B": "Analista Proficiente — Bom conhecimento, continue aprendendo.",
	"C": "Analista em Desenvolvimento — Revise os conceitos e tente novamente.",
	"D": "Analista Iniciante — Estude mais sobre as leis e boas práticas.",
	"F": "Analista Aprendiz — Não desista! Revise e tente de novo.",
}
const GRADE_TIPS := {
	"A": "Você está pronto para desafios mais complexos! Aguarde o Caso 02.",
	"B": "Revise os feedbacks das decisões e foque na preservação de provas digitais.",
	"C": "Estude sobre a Lei 12.737/2012 e os procedimentos de resposta a incidentes.",
	"D": "Recomendamos reler sobre LGPD e cadeia de custódia digital antes de tentar novamente.",
	"F": "Recomendamos reler sobre LGPD e cadeia de custódia digital antes de tentar novamente.",
}


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.08, 0.15)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(700, 0)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 16)
	center.add_child(vbox)

	# Título
	var title := Label.new()
	title.text = "RESULTADO FINAL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color(0.2, 0.8, 1.0))
	vbox.add_child(title)

	# Nota grande
	var grade := GameManager.get_final_grade()
	var grade_lbl := Label.new()
	grade_lbl.text = grade
	grade_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	grade_lbl.add_theme_font_size_override("font_size", 100)
	grade_lbl.add_theme_color_override("font_color", GRADE_COLORS.get(grade, Color.WHITE))
	vbox.add_child(grade_lbl)

	# Descrição da nota
	var desc := Label.new()
	desc.text = GRADE_DESC.get(grade, "")
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.add_theme_font_size_override("font_size", 17)
	desc.add_theme_color_override("font_color", Color(0.8, 0.82, 0.92))
	vbox.add_child(desc)

	# Grid de scores
	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 6)
	vbox.add_child(grid)

	var score_names := {
		"juridica": "Jurídico",
		"investigacao": "Investigação",
		"provas": "Provas",
		"etica": "Ética",
		"risco": "Risco",
	}
	for key in score_names:
		var col := VBoxContainer.new()
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.add_theme_constant_override("separation", 4)
		grid.add_child(col)

		var name_lbl := Label.new()
		name_lbl.text = score_names[key]
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 13)
		col.add_child(name_lbl)

		var val_lbl := Label.new()
		val_lbl.text = str(GameManager.score[key]) + "%"
		val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		val_lbl.add_theme_font_size_override("font_size", 22)
		val_lbl.add_theme_color_override("font_color", _score_color(GameManager.score[key]))
		col.add_child(val_lbl)

	# Dica
	var tip_panel := PanelContainer.new()
	vbox.add_child(tip_panel)

	var tip_lbl := RichTextLabel.new()
	tip_lbl.bbcode_enabled = true
	tip_lbl.text = "[center][b][color=#ffcc44]Dica:[/color][/b]  " + GRADE_TIPS.get(grade, "") + "[/center]"
	tip_lbl.custom_minimum_size = Vector2(0, 52)
	tip_lbl.add_theme_font_size_override("normal_font_size", 14)
	tip_panel.add_child(tip_lbl)

	# Botões
	var btn_hbox := HBoxContainer.new()
	btn_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_hbox.add_theme_constant_override("separation", 20)
	vbox.add_child(btn_hbox)

	var retry_btn := Button.new()
	retry_btn.text = "↺   Tentar Novamente"
	retry_btn.custom_minimum_size = Vector2(210, 50)
	retry_btn.add_theme_font_size_override("font_size", 16)
	retry_btn.pressed.connect(_on_retry_pressed)
	btn_hbox.add_child(retry_btn)

	var menu_btn := Button.new()
	menu_btn.text = "⌂   Menu Principal"
	menu_btn.custom_minimum_size = Vector2(210, 50)
	menu_btn.add_theme_font_size_override("font_size", 16)
	menu_btn.pressed.connect(func(): GameManager.change_scene("res://scenes/MainMenu.tscn"))
	btn_hbox.add_child(menu_btn)


func _score_color(value: int) -> Color:
	if value >= 80:
		return Color(0.2, 1.0, 0.4)
	elif value >= 60:
		return Color(0.6, 0.9, 0.2)
	elif value >= 40:
		return Color(1.0, 0.82, 0.2)
	elif value >= 20:
		return Color(1.0, 0.5, 0.1)
	else:
		return Color(1.0, 0.22, 0.22)


func _on_retry_pressed() -> void:
	GameManager.reset_game()
	GameManager.load_case("caso_01_phishing")
	GameManager.change_scene("res://scenes/CaseScreen.tscn")
