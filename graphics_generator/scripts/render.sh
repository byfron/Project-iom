#bin/bash!
blender ../big_scenes/character_liam.blend  --python render_character.py -b
python3 compose_sprite_sheet.py
