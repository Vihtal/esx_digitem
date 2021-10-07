Original author is MIN01
Edit by Vihtal


changed it a bit for clam digging/watermelons. with english items and added a chance to get a pearl from a clam as a usable item. 1/5 chance atm you can changed if needed in server side

REQUIRMENTS: using ESX V1 Final, and needs mythic_notify unless you change it to your notfication system, also added progressBars so remove if like in client side

personally use the clams to sell to a store or open them for a chance of pearl to sell for more cash! also added watermelons into my esx basic needs to give
both thirst and hunger, since the food is OP you have to farm them instead of buying, just some ideas for RP! Png's included that i use for my inventory also
enjoy!!


ESX BASIC NEEDS CODE IF YOU WANT TO ADD WATERMELON AS A FOOD ITEM! COULDNT FIND A WATERMELON PROP SO JUST USING HAMBURGER FOR NOW

CLIENT SIDE:

RegisterNetEvent('esx_basicneeds:onEatwatermelon')
AddEventHandler('esx_basicneeds:onEatwatermelon', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'prop_cs_burger_01'
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 18905)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)

			ESX.Streaming.RequestAnimDict('mp_player_inteat@burger', function()
				TaskPlayAnim(playerPed, 'mp_player_inteat@burger', 'mp_player_int_eat_burger_fp', 8.0, -8, -1, 49, 0, 0, 0, 0)

				Citizen.Wait(3000)
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

	end
end)

SERVER SIDE:

ESX.RegisterUsableItem('watermelon', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('watermelon', 1)

	TriggerClientEvent('esx_status:add', source, 'thirst', 200000)
	TriggerClientEvent('esx_status:add', source, 'hunger', 200000)
	TriggerClientEvent('esx_basicneeds:onEatwatermelon', source)
	TriggerClientEvent('esx:showNotification', 'You ate a watermelon')
end)