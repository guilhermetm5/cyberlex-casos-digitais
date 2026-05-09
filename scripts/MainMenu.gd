extends Control


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.08, 0.15)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Painel central
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(560, 0)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 18)
	center.add_child(vbox)

	# Ícone
	var icon_lbl := Label.new()
	icon_lbl.text = "🔒"
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.add_theme_font_size_override("font_size", 60)
	vbox.add_child(icon_lbl)

	# Título
	var title := Label.new()
	title.text = "CyberLex"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", Color(0.2, 0.8, 1.0))
	vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Casos Digitais"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 22)
	subtitle.add_theme_color_override("font_color", Color(0.6, 0.7, 0.9))
	vbox.add_child(subtitle)

	var tagline := Label.new()
	tagline.text = "Investigue. Decida. Aprenda."
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tagline.add_theme_font_size_override("font_size", 15)
	tagline.add_theme_color_override("font_color", Color(0.4, 0.45, 0.65))
	vbox.add_child(tagline)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 24)
	vbox.add_child(spacer)

	var start_btn := Button.new()
	start_btn.text = "▶   Iniciar Investigação"
	start_btn.custom_minimum_size = Vector2(320, 52)
	start_btn.add_theme_font_size_override("font_size", 18)
	start_btn.pressed.connect(_on_start_pressed)
	vbox.add_child(start_btn)

	var about_btn := Button.new()
	about_btn.text = "ℹ   Sobre o Jogo"
	about_btn.custom_minimum_size = Vector2(320, 42)
	about_btn.add_theme_font_size_override("font_size", 15)
	about_btn.pressed.connect(_on_about_pressed)
	vbox.add_child(about_btn)

	var version := Label.new()
	version.text = "v0.1 MVP  —  Protótipo Educativo"
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	version.add_theme_font_size_override("font_size", 11)
	version.add_theme_color_override("font_color", Color(0.28, 0.28, 0.42))
	vbox.add_child(version)


func _on_start_pressed() -> void:
	GameManager.reset_game()
	GameManager.load_case("caso_01_phishing")
	GameManager.change_scene("res://scenes/CaseScreen.tscn")


func _on_about_pressed() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Sobre o CyberLex"
	dialog.dialog_text = (
		"CyberLex: Casos Digitais é um jogo educativo sobre Direito Cibernético.\n\n"
		+ "Você assumirá o papel de um Analista Jurídico-Digital responsável por\n"
		+ "investigar casos de crimes digitais e tomar decisões baseadas em:\n\n"
		+ "  • Leis brasileiras (LGPD, Marco Civil, Lei 12.737/2012)\n"
		+ "  • Boas práticas de segurança da informação\n"
		+ "  • Ética digital e preservação de provas\n\n"
		+ "Desenvolvido para jovens e profissionais das áreas jurídica e de TI."
	)
	add_child(dialog)
	dialog.popup_centered()
