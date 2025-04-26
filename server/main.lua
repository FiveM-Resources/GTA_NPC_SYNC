local CreatedPeds = {}

-- Debug to see all the data shared ...
-- for _, shop in ipairs(Shared_Config.Shops) do
--   print(shop.label, shop.coords)
-- end


RegisterServerEvent("gta:pedSync:findPedNetId")
AddEventHandler("gta:pedSync:findPedNetId", function(shop_data)
  local src = source
  local pedId = shop_data.id

  local pedData = {
    id = shop_data.id,
    model = shop_data.ped.model,
    coords = shop_data.ped.coords,
    label = shop_data.label
  }

  if not CreatedPeds[pedId] then
    CreatedPeds[pedId] = "creating"
    TriggerClientEvent("gta:pedSync:createPed", src, pedData)
  elseif type(CreatedPeds[pedId]) == "number" then
    TriggerClientEvent("gta:pedSync:updatePedNetID", src, CreatedPeds[pedId], CreatedPeds[pedId])
  else
    print(("[⚠️] PED %s in creation %s"):format(pedId, src))
  end
end)

RegisterNetEvent("gta:pedSync:playAnim", function(pedNetId, dict, anim)
  TriggerClientEvent("gta:pedSync:playAnimAll", -1, pedNetId, dict, anim)
end)

RegisterServerEvent("gta:pedSync:registerCreatedPed")
AddEventHandler("gta:pedSync:registerCreatedPed", function(pedId, netId)
  if CreatedPeds[pedId] == "creating" then
    CreatedPeds[pedId] = netId
    print(("✅ PED %s register with NetID %s"):format(pedId, netId))
  end
end)
