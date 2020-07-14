extends Node

func skill_roll(success_rate, difficulty=1.0):
	var skill_roll = DiceGenerator.roll_dices(1, 100)
	if skill_roll < ceil(success_rate * (1.0/difficulty)):
		return true
	else:
		return false
	
	
func damage_roll(roll_code):
	var code_array = roll_code.split('D')
	var num_dice = int(code_array[0])
	var value_dice = int(code_array[1])
	var modifier = 0
	if '+' in code_array[1]:
		var code_array2 = code_array[1].split['+']
		modifier = int(code_array2[1])
		
	var damage_roll = DiceGenerator.roll_dices(num_dice, value_dice)
	return damage_roll + modifier
