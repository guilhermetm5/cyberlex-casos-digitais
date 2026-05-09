extends Control

const SCORE_COLORS := {
	"juridica": Color(0.2, 0.5, 1.0),
	"investigacao": Color(0.2, 0.85, 0.45),
	"provas": Color(0.9, 0.7, 0.1),
	"etica": Color(0.75, 0.25, 0.9),
	"risco": Color(1.0, 0.3, 0.3),
}
const SCORE_LABELS := {
	"juridica": "Jurídico",
	"investigacao": "Investigação",
	"provas": "Provas",
	"etica": "Ética",
	"risco": "Risco",
}

var case_data: Dictionary = {}
var questions: Array = []
var current_question_index: int = 0
var answered_correctly: Array = []
var current_phase: String = "intro"

var content_label: RichTextLabel
var action_container: VBoxContainer
var phase_indicator: Label
var score_bars: Dictionary = {}


func _ready() -> void:
	case_data = GameManager.current_case_data
	if case_data.is_empty():
		push_error("Nenhum caso carregado!")
		return
	questions = case_data.get("perguntas", [])
	_build_ui()
	_show_intro()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.08, 0.15)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var main_vbox := VBoxContainer.new()
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 0)
	add_child(main_vbox)

	# --- Cabeçalho ---
	var header := ColorRect.new()
	header.color = Color(0.07, 0.11, 0.20)
	header.custom_minimum_size = Vector2(0, 64)
	main_vbox.add_child(header)

	var header_hbox := HBoxContainer.new()
	header_hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	header_hbox.add_theme_constant_override("separation", 12)
	header.add_child(header_hbox)

	var back_btn := Button.new()
	back_btn.text = "← Menu"
	back_btn.custom_minimum_size = Vector2(90, 0)
	back_btn.pressed.connect(_on_back_pressed)
	header_hbox.add_child(back_btn)

	var title_lbl := Label.new()
	title_lbl.text = case_data.get("titulo", "Caso")
	title_lbl.add_theme_font_size_override("font_size", 19)
	title_lbl.add_theme_color_override("font_color", Color(0.2, 0.8, 1.0))
	title_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(title_lbl)

	phase_indicator = Label.new()
	phase_indicator.custom_minimum_size = Vector2(140, 0)
	phase_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	phase_indicator.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	phase_indicator.add_theme_font_size_override("font_size", 13)
	phase_indicator.add_theme_color_override("font_color", Color(0.45, 0.65, 0.45))
	header_hbox.add_child(phase_indicator)

	# --- Área de conteúdo ---
	var content_hbox := HBoxContainer.new()
	content_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_theme_constant_override("separation", 0)
	main_vbox.add_child(content_hbox)

	# Painel esquerdo — narrativa + ações
	var left_panel := PanelContainer.new()
	left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_hbox.add_child(left_panel)

	var left_vbox := VBoxContainer.new()
	left_vbox.add_theme_constant_override("separation", 10)
	left_panel.add_child(left_vbox)

	content_label = RichTextLabel.new()
	content_label.bbcode_enabled = true
	content_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_label.add_theme_font_size_override("normal_font_size", 15)
	left_vbox.add_child(content_label)

	action_container = VBoxContainer.new()
	action_container.add_theme_constant_override("separation", 8)
	left_vbox.add_child(action_container)

	# Painel direito — indicadores
	var right_bg := ColorRect.new()
	right_bg.color = Color(0.06, 0.10, 0.18)
	right_bg.custom_minimum_size = Vector2(190, 0)
	content_hbox.add_child(right_bg)

	var score_vbox := VBoxContainer.new()
	score_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	score_vbox.add_theme_constant_override("separation", 14)
	right_bg.add_child(score_vbox)

	var score_title := Label.new()
	score_title.text = "INDICADORES"
	score_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_title.add_theme_font_size_override("font_size", 13)
	score_title.add_theme_color_override("font_color", Color(0.45, 0.45, 0.65))
	score_vbox.add_child(score_title)

	for key in SCORE_LABELS:
		var ind_vbox := VBoxContainer.new()
		ind_vbox.add_theme_constant_override("separation", 3)
		score_vbox.add_child(ind_vbox)

		var lbl := Label.new()
		lbl.text = SCORE_LABELS[key]
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", SCORE_COLORS[key])
		ind_vbox.add_child(lbl)

		var bar := ProgressBar.new()
		bar.max_value = 100
		bar.value = 100
		bar.custom_minimum_size = Vector2(0, 16)
		bar.modulate = SCORE_COLORS[key]
		score_bars[key] = bar
		ind_vbox.add_child(bar)


func _clear_actions() -> void:
	for child in action_container.get_children():
		child.queue_free()


func _show_intro() -> void:
	current_phase = "intro"
	phase_indicator.text = "Introdução"

	var text := "[b][color=#33ccff]CONTEXTO DO CASO[/color][/b]\n\n"
	text += case_data.get("descricao", "") + "\n\n"
	text += "[color=#9999bb]" + case_data.get("contexto", "") + "[/color]"
	content_label.text = text

	_clear_actions()
	var btn := Button.new()
	btn.text = "Analisar Evidências  →"
	btn.custom_minimum_size = Vector2(0, 48)
	btn.add_theme_font_size_override("font_size", 16)
	btn.pressed.connect(_show_evidence)
	action_container.add_child(btn)


func _show_evidence() -> void:
	current_phase = "evidence"
	phase_indicator.text = "Evidências"

	var evidencias: Array = case_data.get("evidencias", [])
	var text := "[b][color=#33ccff]EVIDÊNCIAS COLETADAS[/color][/b]\n\n"

	for ev in evidencias:
		text += "[b][color=#ffcc44]◆  " + ev.get("tipo", "") + "[/color][/b]\n"
		text += "[color=#99aacc][code]" + ev.get("conteudo", "") + "[/code][/color]\n\n"

	content_label.text = text

	_clear_actions()
	var btn := Button.new()
	btn.text = "Iniciar Investigação  (%d decisões)  →" % questions.size()
	btn.custom_minimum_size = Vector2(0, 48)
	btn.add_theme_font_size_override("font_size", 16)
	btn.pressed.connect(_show_next_question)
	action_container.add_child(btn)


func _show_next_question() -> void:
	if current_question_index >= questions.size():
		_show_conclusion()
		return

	current_phase = "question"
	var q: Dictionary = questions[current_question_index]
	phase_indicator.text = "Decisão %d/%d" % [current_question_index + 1, questions.size()]

	var text := "[b][color=#33ccff]DECISÃO %d DE %d[/color][/b]\n\n" % [
		current_question_index + 1, questions.size()
	]
	text += "[b][color=#ffffff]" + q.get("texto", "") + "[/color][/b]\n\n"
	text += "[color=#556677]Analise as evidências e escolha a melhor ação:[/color]"
	content_label.text = text

	_clear_actions()
	var opcoes: Array = q.get("opcoes", [])
	for i in opcoes.size():
		var opt: Dictionary = opcoes[i]
		var btn := Button.new()
		btn.text = "%s)  %s" % [char(65 + i), opt.get("texto", "")]
		btn.custom_minimum_size = Vector2(0, 44)
		btn.add_theme_font_size_override("font_size", 14)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.pressed.connect(_on_option_selected.bind(opt.duplicate()))
		action_container.add_child(btn)


func _on_option_selected(option: Dictionary) -> void:
	var is_correct: bool = option.get("correto", false)
	var feedback: String = option.get("feedback", "")
	var effects: Dictionary = option.get("efeitos", {})

	GameManager.apply_decision_effects(effects)
	_animate_score_bars()

	answered_correctly.append(is_correct)
	current_question_index += 1

	var q: Dictionary = questions[current_question_index - 1]
	var text := "[b][color=#33ccff]DECISÃO %d — FEEDBACK[/color][/b]\n\n" % current_question_index

	if is_correct:
		text += "[b][color=#44ff88]✓  DECISÃO CORRETA![/color][/b]\n\n"
	else:
		text += "[b][color=#ff5555]✗  DECISÃO INADEQUADA[/color][/b]\n\n"

	text += "[color=#ddddff]" + feedback + "[/color]\n\n"
	text += "[color=#445566]Pergunta: " + q.get("texto", "") + "[/color]"
	content_label.text = text

	_clear_actions()
	var next_text := (
		"Próxima Decisão  →" if current_question_index < questions.size()
		else "Ver Conclusão  →"
	)
	var btn := Button.new()
	btn.text = next_text
	btn.custom_minimum_size = Vector2(0, 48)
	btn.add_theme_font_size_override("font_size", 16)
	btn.pressed.connect(_show_next_question)
	action_container.add_child(btn)


func _animate_score_bars() -> void:
	for key in score_bars:
		var tween := create_tween()
		tween.tween_property(score_bars[key], "value", GameManager.score[key], 0.4)


func _show_conclusion() -> void:
	current_phase = "conclusion"
	phase_indicator.text = "Conclusão"

	var conclusao: Dictionary = case_data.get("conclusao", {})
	var correct_count: int = answered_correctly.count(true)

	var text := "[b][color=#33ccff]CASO ENCERRADO[/color][/b]\n\n"
	text += conclusao.get("texto", "") + "\n\n"
	text += "[b][color=#ffcc44]Referências Legais:[/color][/b]\n"
	text += "[color=#9aaabb]" + conclusao.get("lei_referencia", "") + "[/color]\n\n"
	text += "[color=#556677]Decisões corretas: %d / %d[/color]" % [correct_count, questions.size()]
	content_label.text = text

	_clear_actions()
	var btn := Button.new()
	btn.text = "Ver Resultado Final  →"
	btn.custom_minimum_size = Vector2(0, 48)
	btn.add_theme_font_size_override("font_size", 16)
	btn.pressed.connect(func(): GameManager.change_scene("res://scenes/ResultsScreen.tscn"))
	action_container.add_child(btn)


func _on_back_pressed() -> void:
	GameManager.change_scene("res://scenes/MainMenu.tscn")
