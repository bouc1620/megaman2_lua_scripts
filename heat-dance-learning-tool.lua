-- to be used during the Heat Man boss fight
-- displays 2 progress bars in the middle of the screen, first one counts down Heat Man's invincibility frames
-- second one counts down the current 30 frames delay before Heat Man's dash attack
-- also makes the player and the boss invulnerable

write_max_hp = function()
	memory.writebyte(0x06C0, 0x001C) -- refills Mega Man's HP
	memory.writebyte(0x06C1, 0x001C) -- refills Heat Man's HP
end

create_training_display = function()
	INVINCIBILITY_FRAME_COUNT = 20
	SINGLE_DELAY_FRAME_COUNT = 31
	PROGRESS_BAR_COLOR = "#FFFFFFAA"

	hit_registered = false
	curr_inv_frame = 0
	delay_count = 0
	last_delay_value = 0

	return function()
    -- comment out this function call to remove invulnerability
		write_max_hp()

		is_hit_frame = not hit_registered and memory.readbyte(0x00B4) == 0x0001
		if is_hit_frame then
			curr_inv_frame = INVINCIBILITY_FRAME_COUNT
		end

		curr_delay_value = memory.readbyte(0x00B2)
		if last_delay_value == 0 and curr_delay_value ~= 0 then
			delay_count = math.floor(curr_delay_value / SINGLE_DELAY_FRAME_COUNT)
		end
	
		hit_registered = hit_registered or memory.readbyte(0x00B4) == 0x0001
	
		delay_counter = hit_registered and math.ceil(memory.readbyte(0x00B2) / SINGLE_DELAY_FRAME_COUNT) or 0
		hit_registered = hit_registered and memory.readbyte(0x00B2) ~= 0x0001

		if hit_registered then
			gui.drawbox(138 - (math.floor(curr_inv_frame * 40 / INVINCIBILITY_FRAME_COUNT)), 100, 138, 105, PROGRESS_BAR_COLOR)
		else
			gui.drawbox(98, 100, 138, 105, PROGRESS_BAR_COLOR)
		end

		if hit_registered and curr_inv_frame == 0 then
			curr_delay = math.fmod(curr_delay_value, SINGLE_DELAY_FRAME_COUNT)
			gui.drawbox(158 - (math.floor(curr_delay * 60 / SINGLE_DELAY_FRAME_COUNT)), 107, 158, 112, PROGRESS_BAR_COLOR)
		else
			gui.drawbox(98, 107, 158, 112, PROGRESS_BAR_COLOR)
		end

		curr_inv_frame = math.max(curr_inv_frame - 1, 0)
		last_delay_value = curr_delay_value

    -- comment out this block if you wish to remove the delay counter over Heat Man
		if memory.readbyte(0x0421) >= 0x80 then
			local x = memory.readbyte(0x0441) * 256 + memory.readbyte(0x0461) - memory.readbyte(0x20) * 256 - memory.readbyte(0x1F)
			local y = memory.readbyte(0x04A1)
			gui.text(x, y, delay_counter)
		end
	end
end

emu.registerafter(create_training_display())