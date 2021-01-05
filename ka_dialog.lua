--- An example of the general summary for the file

local saved_dialog

--- Called from the functions that initalize dialogs  
-- @tparam userdata dialog The dialog object. Usually the first argument of the caller.
-- @usage
-- -- Given a dialog with '<init_func>my_dialogs.init_some_dialog</init_func>',
-- -- the intended usage inside your 'my_dialog.script' is the following:  
-- function init_some_dialog(dialog)  
--  ka_dialog.set_saved_dialog(dialog)  
-- -- the rest of code  
-- end  

function set_saved_dialog(dialog)
	saved_dialog = dialog
end


--- Adds dialog lines from a dialog initialized by a script.
-- @tparam string p_id ID of the dialog line. The first line added to a dialog MUST be and empty string (`''`).
-- @tparam number id ID of the phrases available when the line is selected or said by an NPC.
-- @tparam string phrase_id ID of the text to show with the line. Unlike XML dialogs, it can be literal text `("Hey bro, what's up")`. However, it's not recommended as all text should be defined in text XML files.
-- @tparam string-or-table cond One or more functions that must return true to show this dialog option.  
--  If only one condition is needed, then it must be the function name including the file it is contained in. For example `my_file.my_condition`.  
--  If more than one are needed, then it must be an array table with all functions that need to return true. For example `{"my_file.my_condition_1", "my_file.my_condition_2"}`.
-- @tparam string-or-table act One or more functions that will be executed when the line is selected or said by an NPC. Like `cond`, it must be either a string or a table array of strings.
-- @usage
-- -- Given a dialog with '<init_func>my_dialogs.init_some_dialog</init_func>'
-- -- inside my_dialog.script:
-- function init_some_dialog(dialog)
--  -- This line must always be called at the start of a dialog initialization.
--  ka_dialog.set_saved_dialog(dialog)
-- -- An NPC will say the line specified below, the player is be able to choose between all lines with id 0.
--  add_dialog("",0,"Blowout soon fellow stalker")
--  add_dialog(0,1,"When?") -- selecting this will make player say the text and npc say line id 1
--  add_dialog(0,2,"[punch him in the face]","somescript.is_player_low_reputation",{"somescript.make_talker_enemy","dialogs.break_dialog"}) -- this line will show as option only if the function "is_player_low_reputation" defined inside "somescript.script" returns true, if selected it will excute "somescript.make_talker_enemy" and "dialogs.break_dialog" in this order
--  add_dialog(0,3,"I don't have time for this, go away.", nil, "dialogs.break_dialog") -- selecting this will execute function "dialogs.break_dialog", 4th argument is nil because this line can always show
--  add_dialog(1,10,"NOW!", nil, "somescript.start_blowout") -- npc will say this if player selected the line that points to this one ("When?") and will execute the function "start_blowout" defined inside "somescript.script"
--  add_dialog(10,11,"Oh fuck.", nil, "dialogs.break_dialog") -- selecting this will execute function "dialogs.break_dialog"
-- end

function add_dialog(p_id,id,phrase_id,cond,act)
	if not ( saved_dialog ) then
		return
	end

	local phrase = saved_dialog:AddPhrase(phrase_id,tostring(id),tostring(p_id),-10000)
	if not ( phrase ) then
		return
	end

	--printf("phrase_id = %s",phrase_id)

	local phrase_script = phrase:GetPhraseScript()
	if ( cond ) then
		if ( type(cond) == "table" ) then
			for key, value in pairs(cond) do
				if (utils_data.findfunction(value,_G)) then
					phrase_script:AddPrecondition(value)
					--table.insert(cond_list,value)
				else
					printe("!ERROR dialog_manager | No such function exists '%s'",value)
				end
			end
		else
			if (utils_data.findfunction(cond,_G)) then
				phrase_script:AddPrecondition(cond)
				--table.insert(cond_list,value)
			else
				printe("!ERROR dialog_manager | No such function exists '%s'",cond)
			end
		end
	end

	if ( act ) then
		if ( type(act) == "table" ) then
			for key, value in pairs(act) do
				if (utils_data.findfunction(value,_G)) then
					phrase_script:AddAction(value)
				else
					printe("!ERROR dialog_manager | No such function exists '%s'",value)
				end
			end
		else
			if (utils_data.findfunction(act,_G)) then
				phrase_script:AddAction(act)
			else
				printe("!ERROR dialog_manager | No such function exists '%s'",act)
			end
		end
	end
	return phrase_script
end

--- Adds dialog lines with dynamic text, all arguments behave the same except `phrase_id`.
-- @tparam string p_id ID of the dialog line. The first line added to a dialog MUST be and empty string (`''`).
-- @tparam number id ID of the phrases available when the line is selected or said by an NPC.
-- @tparam string phrase_id The function returning the text in the dialog line.  
-- The name of the function must be together with the file it's in. For example, `my_file.npc_greeting_text`.  
-- The function must return a string. The returned string can be either literal text, which is not recommended, or a string ID defined in XML.
-- @tparam string-or-table cond One or more functions that must return true to show this dialog option.  
-- If only one condition is needed, then it must be the function name including the file it is contained in. For example `my_file.my_condition`.  
-- If more than one are needed, then it must be an array table with all functions that need to return true. For example `{"my_file.my_condition_1", "my_file.my_condition_2"}`.
-- @tparam string-or-table act One or more functions that will be executed when the line is selected or said by an NPC. Like `cond`, it must be either a string or a table array of strings.
-- given a dialog with "<init_func>my_dialogs.init_some_dialog</init_func>"
-- @usage
-- -- Given a dialog with '<init_func>my_dialogs.init_some_dialog</init_func>'
-- -- inside my_dialog.script:
-- function init_some_dialog(dialog)
--  This line must always be called at the start of a dialog initialization.
--  ka_dialog.set_saved_dialog(dialog)
-- -- NPC will say "Hello X" where X is the name the player set at game start
--  add_dialog("",0,"my_dialog.npc_greet")
--  -- the rest of code
-- end
-- function npc_greet()
--  return strformat('Hello %s.', alife():actor():character_name())
-- end
-- -- assuming the string "npc_greet" is defined in string XMLs as "Hello %s.", this will behave the same as above. 
-- -- However, if someone defines the same string in the russian XML files as "привет %s.", this dialog will show in Russian.
-- function npc_greet_proper()
--  return strformat(game.translate_string('npc_greet'), alife():actor():character_name())
-- end

function add_script_dialog(p_id,id,phrase_id,cond,act)
	local d = add_dialog(p_id,id,phrase_id,cond,act)
	if (d) then
		d:SetScriptText(phrase_id)
	end
end

