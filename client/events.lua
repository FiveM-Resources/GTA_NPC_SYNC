RegisterNetEvent("gta:pedSync:createPed")
AddEventHandler("gta:pedSync:createPed", function(ped_data)
  local model = GetHashKey(ped_data.model)

  RequestModel(model)
  while not HasModelLoaded(model) do
    Wait(10)
  end

  local ped = CreatePed(4, model, ped_data.coords.x, ped_data.coords.y, ped_data.coords.z - 1.0,
    ped_data.coords.w,
    true, true)

  local pedNetId = PedToNet(ped)
  SetNetworkIdCanMigrate(pedNetId, true)
  SetEntityInvincible(ped, true)
  SetBlockingOfNonTemporaryEvents(ped, true)
  FreezeEntityPosition(ped, true)
  NetworkRegisterEntityAsNetworked(ped)

  Client_Config.PedNetID = pedNetId

  TriggerServerEvent("gta:pedSync:registerCreatedPed", ped_data.id, Client_Config.PedNetID)

  print(("🧍 PED created at %s"):format(ped_data.label))
end)

RegisterNetEvent("gta:pedSync:playAnimAll", function(pedNetId, dict, anim)
  local ped = NetToPed(pedNetId)

  if DoesEntityExist(ped) and NetworkDoesEntityExistWithNetworkId(pedNetId) then
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end

    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, 1000, 49, 0, false, false, false)
    print("👋 Animation synchronized for all")
  end
end)

RegisterNetEvent("gta:pedSync:updatePedNetID")
AddEventHandler("gta:pedSync:updatePedNetID", function(ped_id, net_id)
  if net_id == "creating" then
    print(("⏳ PED %s is still in creation mode, please wait."):format(ped_id))
    return
  end

  if net_id and NetworkDoesEntityExistWithNetworkId(net_id) then
    local ped = NetToPed(net_id)
    if DoesEntityExist(ped) then
      print("Syncrhonized net id", net_id)
      Client_Config.Peds[ped_id] = ped
      Client_Config.PedNetID = net_id
      print(("✅ PED synchronized for %s with NetID %s"):format(ped_id, net_id))
    end
  else
    print(("❌ NetID not found %s"):format(ped_id))
  end
end)
