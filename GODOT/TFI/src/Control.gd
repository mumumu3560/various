extends Control

@onready var text_field = $RichTextLabel

func _ready():
	
	var aaa = "[right]text[/righ]"
	text_field.text += aaa
	
	var bbb = "[left]test[/left]"
	text_field.text += bbb

"""
func _on_SendButton_pressed():
	var newMessage = chatInputField.text
	if newMessage != "":
		add_chat_message(newMessage, true)  # プレイヤーのメッセージを追加
		add_chat_message("相手のメッセージ", false)  # 相手のメッセージを追加
		chatInputField.text = ""
"""

"""
func add_chat_message(message: String, isPlayer: bool) -> void:
	var messageWithNewLine = message + "\n"  # 改行を追加
	
	
	#chatTextLabel.bbcode_text += [right]{messageWithNewLine}[/right]
	chatTextLabel.scroll_to_line(chatTextLabel.get_line_count() - 1)  # 最新メッセージまでスクロール
"""
