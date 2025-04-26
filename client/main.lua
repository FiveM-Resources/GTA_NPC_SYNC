CreateThread(function()
  for _, shop in ipairs(Shared_Config.Shops) do
    local blip = AddBlipForCoord(shop.coords.x, shop.coords.y, shop.coords.z)

    SetBlipSprite(blip, 52)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 2)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(shop.label)
    EndTextCommandSetBlipName(blip)
  end
end)

local CurrentTargetShopId = nil

CreateThread(function()
  while true do
    local playerCoords = GetEntityCoords(PlayerPedId())

    if CurrentTargetShopId then
      local currentShop = nil
      for _, shop in pairs(Shared_Config.Shops) do
        if shop.id == CurrentTargetShopId then
          currentShop = shop
          break
        end
      end

      if currentShop then
        local distToCurrent = #(playerCoords - currentShop.coords)

        if distToCurrent > 10.0 then
          print(("Out of the zone %s"):format(CurrentTargetShopId))

          -- Reset
          Client_Config.PedNetID = nil
          CurrentTargetShopId = nil
        end
      end
    else
      for _, shop in pairs(Shared_Config.Shops) do
        local dist = #(playerCoords - shop.coords)
        if dist < 10.0 then
          CurrentTargetShopId = shop.id
          TriggerServerEvent("gta:pedSync:findPedNetId", shop)
          print(("In Zone %s"):format(shop.label))
          break
        end
      end
    end

    Wait(500)
  end
end)


CreateThread(function()
  while true do
    if IsControlJustReleased(0, 38) and Client_Config.PedNetID and NetworkDoesEntityExistWithNetworkId(Client_Config.PedNetID) then
      local ped = NetToPed(Client_Config.PedNetID)

      if DoesEntityExist(ped) then
        NetworkRequestControlOfNetworkId(Client_Config.PedNetID)
        NetworkRequestControlOfEntity(ped)

        TriggerServerEvent("gta:pedSync:playAnim", Client_Config.PedNetID, "gestures@m@standing@casual", "gesture_hello")
      else
        print("⚠️ No PED Found")
      end
    end
    Wait(0)
  end
end)


RegisterCommand("tp", function()
  local playerPed = PlayerPedId()
  local blip = GetFirstBlipInfoId(8)

  if DoesBlipExist(blip) then
    local coord = GetBlipInfoIdCoord(blip)
    local x, y = coord.x, coord.y

    local z = 0.0
    for i = 0, 1000 do
      RequestCollisionAtCoord(x, y, i + 0.0)
      Wait(1)
      local foundGround, groundZ = GetGroundZFor_3dCoord(x, y, i + 0.0, false)
      if foundGround then
        z = groundZ + 1.0
        break
      end
    end

    SetEntityCoords(playerPed, x, y, z, false, false, false, true)
    print("🚀 Teleported to the waypoint !")
  else
    print("❌ No waypoint found.")
  end
end, false)


-- Etape 1 Voir si on est proche de la zone
-- Si c'est le cas on demande a charger le ped 2 choix s'oppose :
-- La premiere le ped n'est pas créer alors on le créer
-- Le second le ped est créer alors on le charge
