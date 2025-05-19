--functions
function press(port,field)
	manager.machine.ioport.ports[port].fields[field]:set_value(1)
end

function release(port,field)
	manager.machine.ioport.ports[port].fields[field]:clear_value()
end

function pressrelease(port,field,time)
	time = time or 1/60
	press(port,field)
	emu.wait(time)
	release(port,field)
end

function keycode_pressed(t)
	input=manager.machine.input
	return input:code_pressed(input:code_from_token("KEYCODE_"..t))
end

function advance_tape()
	press(":CONTROLKEYS","FUNC")
	pressrelease(":COL0","J")
	release(":CONTROLKEYS","FUNC")

	manager.machine.cassettes:at(1):play()
	emu.wait(interval)
	manager.machine.cassettes:at(1):stop()
end

function play_game()
	press(":CONTROLKEYS","FUNC")
	emu.wait(7/30)
	pressrelease(triggerport,triggerfield)
	emu.wait(5/30)
	release(":CONTROLKEYS","FUNC")

	print("Starting Track: ".. step .. " of " .. steps)
	advance_tape()

	step = step + 1
	
	while(step <= steps) do
		if keycode_pressed("RSHIFT") then
			print("Starting Track: " .. step .. " of " .. steps)
			if format == "album" then
				advance_tape() 
			else 
				if tapename == "PictureMate_" then
				 	tr = string.format("%02d",step)
				else
				 	tr = string.format("%01d",step)
				end
				
				manager.machine.images:at(1):load("roms/a2600_compumate_cass/pm.zip/bin/" .. tapename .. tr .. ".bin") 
				advance_tape() 
			end
			step = step + 1
		elseif keycode_pressed("ESC") then
			manager.machine.cassettes:at(1):stop()
			break
		end 
		emu.wait(1/60)
	end
	if step > steps then
		print "End of Tape"
	end
end

--load
preload = 1
while (manager.machine.images:at(1).exists == false) do
	preload = 0
	while (true) do
		if keycode_pressed("TAB") then
			while(manager.machine.images:at(1).exists == false) do
				emu.wait(1/60)
			end
			break
		elseif keycode_pressed("ESC") then
			breakpoint  = 1
			break					
		end 
		emu.wait(1/60)
	end
	if breakpoint == 1 then
		break
	end	
end

--set parameters
if manager.machine.images:at(1).loaded_through_softlist == true then
	trackname = manager.machine.images:at(1).software_longname
else
	trackname = manager.machine.images:at(1).filename
end

if trackname == nil then
	trackname = "0"
end

t2 = string.gsub(trackname, "_c", "c")
if string.find(t2, "_", init, pattern) ~= nill then
	format = "track"
	if string.find(trackname, "Picture", init, pattern) ~= nill then		
		step = string.sub (t2, string.find(t2, "_") + 1, string.find(t2, "_") + 2) + 0
	else
		step = string.sub (t2, string.find(t2, "_") + 2, string.find(t2, "_") + 2) + 0	
	end
else
	format = "album"
	step = 1
end

if string.find(trackname, "Picture", init, pattern) ~= nill then
	interval = 968/30
	triggerport = ":COL6"
	triggerfield = "."
	tapename = "PictureMate_"
	steps = 22
else 
	interval = 805/30
	triggerport = ":COL0"
	triggerfield = "M"
	if string.find(trackname, "Side A", init, pattern) or string.find(trackname, "_A", init, pattern) ~= nill then  
		steps = 5
		tapename = "SongMate_A"
	else
		steps = 6
		tapename = "SongMate_B"
	end 
end

--set environment
if breakpoint ~= 1 then
	if preload == 1 then
		play_game()
	else
		i = 2
		while(i > 0) do
			while(true) do
				if keycode_pressed("TAB") then
					i = 0
					break
				elseif keycode_pressed("ESC") then
					while keycode_pressed("ESC") do
						emu.wait(1/60)
					end
					i = i - 1
					break
				end 
				emu.wait(1/60)
			end
		end

		while(true) do
			if keycode_pressed("RSHIFT") then
				play_game()
				break
			elseif keycode_pressed("ESC") then					
				break
			end 
			emu.wait(1/60)
		end	
	end
end