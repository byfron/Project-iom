extends Node

func roll_dices(num_dice, dice_size):
	var total_rolled = 0
	for n in num_dice:
		total_rolled += randi()%dice_size+1
	return total_rolled
