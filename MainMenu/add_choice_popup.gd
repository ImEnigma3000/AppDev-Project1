extends ConfirmationDialog

signal submitted(option_text: String, weight: int)

#onready only fetches node once popup is ready
@onready var option_input: LineEdit = $DialogLayout/OptionInput
@onready var weight_input: LineEdit = $DialogLayout/WeightInput
@onready var weight_error: AcceptDialog = $DialogLayout/WeightErrorPopUp

func _ready() -> void:
	confirmed.connect(_on_confirmed)
	canceled.connect(_on_canceled)
	about_to_popup.connect(_focus_input)
	
func _on_confirmed() -> void:
	#strip edges del white spaces
	var option_text := option_input.text.strip_edges()
	
	if option_text.is_empty():
		return
		
	#weight handler
	var weight_text := weight_input.text.strip_edges()
	var weight := 1
		
	#blank = 1
	if weight_text.is_empty():
		weight = 1
	else:
	# not int show error
		if not weight_text.is_valid_int():
			_show_weight_error()
			return

	# checks for neg 
		weight = int(weight_text)
		if weight < 1:
			_show_weight_error()
			return
	
	#exit correctly
	emit_signal("submitted", option_text, weight)
	option_input.clear()
	weight_input.clear()
	hide()
	
func _on_canceled() -> void:
	option_input.clear()
	weight_input.clear()
	hide()
	
func _focus_input() -> void:
	await get_tree().process_frame
	option_input.grab_focus()

#Enter key acts as confirm - got func from signals list
func _on_option_input_text_submitted(_new_text: String) -> void:
	_on_confirmed()

func _on_weight_input_text_submitted(_new_text: String) -> void:
	_on_confirmed()
	
func _show_weight_error() -> void:
	weight_error.popup_centered()
	weight_input.grab_focus()
