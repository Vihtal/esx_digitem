ESX = nil
local Place = {}
local digging = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	CreateBlips()
end)

Citizen.CreateThread(function()
	Wait(5000) -- wait game load
	while true do			
		for k,v in pairs(Config.Digs) do
			local count = 0			
			if #Place == 0 then
				for i=1, (v.maxSpawn/3) do
					Wait(100)
					RandomSpawn(k, v.x, v.y, v.z, v.areaRange, v.markerColor[1], v.markerColor[2], v.markerColor[3])
				end
			else
				for i=1, #Place do				
					if Place[i].key == k then
						count = count + 1
					end		
				end
				if count == 0 then
					for i=1, (v.maxSpawn/3) do
						Wait(100)
						RandomSpawn(k, v.x, v.y, v.z, v.areaRange, v.markerColor[1], v.markerColor[2], v.markerColor[3])
					end					
				elseif count < v.maxSpawn then
					Wait(100)
					RandomSpawn(k, v.x, v.y, v.z, v.areaRange, v.markerColor[1], v.markerColor[2], v.markerColor[3])				
				end					
			end
		end	
		Wait(math.random(Config.SpawnWaitMin, Config.SpawnWaitMax))			
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		for k,v in pairs(Place) do
			local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
			local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, v.x, v.y, v.z)	
			if dist < 50 then
				DrawMarker(28, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.5, 0.5, 0.5, v.colorR, v.colorG, v.colorB, 200, false, false, 2, false, false, false, false)
			end
		end
		if digging then
			DisableViolentActions()
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		if not digging then
			for k,v in pairs(Place) do
				local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
				local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, v.x, v.y, v.z)
				
				if dist <= 1.3 then
					for i=1, #Config.Digs do
						if i == v.key then
							if #Config.Digs[i].digItem == 1 then
								hintToDisplay(_U("press_dig", Config.Digs[i].digItem[1][3]))	
							else
								hintToDisplay(_U("press_dig_random"))	
							end
							if IsControlJustReleased (0, 38) then		
								ESX.TriggerServerCallback("esx_dig:checkTool", function(hasItem)
									if hasItem then
										local playerPed = PlayerPedId()									
										TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_GARDENER_PLANT", 0, true)
										exports['progressBars']:startUI(10000, "Digging")
										digging = true
										Wait(Config.DigTime)
										ClearPedTasks(playerPed)
										digging = false
										TriggerServerEvent("esx_dig:startDig", Config.Digs[i].breakToolPercent, Config.Digs[i].digItem, Config.Digs[i].toolLabel, Config.Digs[i].needTool)
										table.remove(Place, k)
									else
										ESX.ShowNotification(_U("no_tools", Config.Digs[i].toolLabel))
									end
								end, Config.Digs[i].needTool)
							end
						end
					end
				end
			end
		end
	end
end)

function CreateBlips()
	for k,v in pairs(Config.Digs) do
		if v.blips then
			local bool = true			
			if bool then
				zoneblip = AddBlipForRadius(v.x,v.y,v.z, v.areaRange*25.0)
				SetBlipSprite(zoneblip, 1)
				SetBlipColour(zoneblip, 16)
				SetBlipAlpha(zoneblip, 120)	
				
				v.blip = AddBlipForCoord(v.x, v.y, v.z)
				SetBlipSprite(v.blip, 483)
				SetBlipDisplay(v.blip, 4)
				SetBlipColour(v.blip, 16)
				SetBlipScale(v.blip, 0.7)
				SetBlipAsShortRange(v.blip, true)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(v.blipName)
				EndTextCommandSetBlipName(v.blip)
				bool = false			
			end
		end
	end	
end

function RandomSpawn(key, x, y, z, areaRange, R, G, B)
	if R ~= nil and G ~= nil and B ~= nil then
		local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
		local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, x, y, z)	
		if dist < 500 then	-- prevent if map not loaded
			local isGoodPlace = true

			math.randomseed(GetGameTimer())
			local ranX = x+(math.random(-areaRange, areaRange))

			Citizen.Wait(100)

			math.randomseed(GetGameTimer())
			local ranY = y+(math.random(-areaRange, areaRange))

			local ranZ = GetCoordZ(ranX, ranY)
			if ranZ ~= nil then
				if #Place > 0 then
					for k,v in pairs(Place) do
						if v.key == key then
							if GetDistanceBetweenCoords(ranX,ranY,ranZ, v.x,v.y,v.z, true) < 5 then
								isGoodPlace = false
								break
							end
						end
					end
					if isGoodPlace then
						table.insert(Place, {key = key, x = ranX, y = ranY, z = ranZ, colorR = R, colorG = G, colorB = B})
					else
						RandomSpawn(key, x, y, areaRange)
					end
				else
					table.insert(Place, {key = key, x = ranX, y = ranY, z = ranZ, colorR = R, colorG = G, colorB = B})
				end
			else
				--print("not found ground coord Z")
			end
		end
	end
end

function GetCoordZ(x, y)
	local groundCheckHeights = { 40.0, 41.0, 42.0, 43.0, 44.0, 45.0, 46.0, 47.0, 48.0, 49.0, 50.0, 100.0, 150.0, 200.0, 250.0, 300.0, 350.0, 400.0, 450.0, 500.0 }

	for i, height in ipairs(groundCheckHeights) do
		local foundGround, z = GetGroundZFor_3dCoord(x, y, height)
		if foundGround then
			return z
		end
	end
	
	return nil
end

function DisableViolentActions()
	local playerPed = PlayerPedId()

	if disable_actions == true then
		DisableAllControlActions(0)
	end

	DisableControlAction(2, 37, true) -- disable weapon wheel (Tab)
	DisablePlayerFiring(playerPed,true) -- Disables firing all together if they somehow bypass inzone Mouse Disable
    DisableControlAction(0, 106, true) -- Disable in-game mouse controls
    DisableControlAction(0, 140, true)
	DisableControlAction(0, 141, true)
	DisableControlAction(0, 142, true)
	DisableControlAction(0, 77, true)
	DisableControlAction(0, 26, true)
	DisableControlAction(0, 36, true)	
	DisableControlAction(0, 45, true)
	DisableControlAction(0, 83, true)
	EnableControlAction(0, 249, true)

	if IsDisabledControlJustPressed(2, 37) then --if Tab is pressed, send error message
		SetCurrentPedWeapon(playerPed,GetHashKey("WEAPON_UNARMED"),true) -- if tab is pressed it will set them to unarmed (this is to cover the vehicle glitch until I sort that all out)
	end

	if IsDisabledControlJustPressed(0, 106) then --if LeftClick is pressed, send error message
		SetCurrentPedWeapon(playerPed,GetHashKey("WEAPON_UNARMED"),true) -- If they click it will set them to unarmed
	end
end

function hintToDisplay(text)
	SetTextComponentFormat("STRING")
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end