extends Control

@onready var choice_list : ItemList = $Center/RoundEdges/RootRow/PaddingLeftPanel/LeftPanel/ChoicesList
@onready var add_popup: ConfirmationDialog = $AddChoicePopUp
@onready var remove_button: Button = $Center/RoundEdges/RootRow/PaddingRightPanel/RightPanel/RemoveButton
@onready var decide_button: Button = $Center/RoundEdges/RootRow/PaddingRightPanel/RightPanel/DecideButton
@onready var result_popup: AcceptDialog =$ResultPopUp

func _ready() -> void:
	$Center/RoundEdges/RootRow/PaddingRightPanel/RightPanel/AddButton.pressed.connect(_on_add_pressed)
	add_popup.submitted.connect(_on_choice_submitted)
	remove_button.pressed.connect(_on_remove)
	decide_button.pressed.connect(_on_decide)

func _on_add_pressed() -> void:
	add_popup.popup_centered()

#add to list
func _on_choice_submitted(option_text: String, weight: int) -> void:
	#string (int)
	var display := "%s (%d)" % [option_text, weight]
	choice_list.add_item(display)
	var index := choice_list.item_count - 1
	#store data as "text": string "weight": int
	#used for weight logic later
	choice_list.set_item_metadata(index, {"text": option_text, "weight": weight})

#remove from list
func _on_remove() -> void:
	var selected := choice_list.get_selected_items()
	# not selected do nothing
	if selected.is_empty():
		return
	choice_list.remove_item(selected[0])

func _on_decide() -> void:
	#checks if choice list is empty
	if choice_list.item_count == 0:
		return
		
	#total weight
	var tot_weight := 0
	for i in range(choice_list.item_count):
		var data: Dictionary =  choice_list.get_item_metadata(i)
		tot_weight = tot_weight + int(data.get("weight", 1))
	
	#ran num based on weight size
	var rng:= RandomNumberGenerator.new()
	rng.randomize()
	var roll := rng.randi_range(1, tot_weight)
	
	var weight_sum := 0
	#adds weight to total sum for each i
	for i in range(choice_list.item_count):
		var data: Dictionary = choice_list.get_item_metadata(i)
		weight_sum = weight_sum + int(data.get("weight", 1))
		
		#roll falls in range therefore winner
		if roll <= weight_sum:
			var winner:= str(data.get("text", ""))
			result_popup.dialog_text = "Winner: %s" % winner
			result_popup.popup_centered()
			return

#Enter key acts as if you pressed ADD button
func _unhandled_input(event) -> void:
	#checks for keyboard input and only runs on press not release. 
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER:
			if not add_popup.visible:
				_on_add_pressed()
