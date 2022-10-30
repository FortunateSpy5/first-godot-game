extends Control

var hearts = 5 setget set_hearts
var max_hearts = 5 setget set_max_hearts

onready var heart_ui_full = $HeartUIFull
onready var heart_ui_empty = $HeartUIEmpty

func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	var _t = PlayerStats.connect("health_change", self, "set_hearts")

func set_hearts(value):
	hearts = value
	if heart_ui_full != null:
		heart_ui_full.rect_size.x = hearts * 15

func set_max_hearts(value):
	max_hearts = max(value, 1)
	if heart_ui_empty != null:
		heart_ui_empty.rect_size.x = max_hearts * 15


