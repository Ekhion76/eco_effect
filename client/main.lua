local active
local fx = 0
local adjust = { scale = 1, r = 1, g = 3, b = 2, a = 1 }

RegisterCommand('effect', function()

    SendNUIMessage({
                       subject = 'OPEN'
                   })

    if not active then

        active = true

        DisableIdleCamera(true)
        SetPedCanPlayAmbientAnims(PlayerPedId(), false)
        SetResourceKvp("idleCam", "off")

        CreateThread(function()

            while active do
                Wait(0)

                if IsControlJustReleased(0, 38) then

                    SetNuiFocus(true, true)
                end
            end
        end)
    end
end)

RegisterNUICallback('nuiSync', function(data, cb)

    cb(adjust)
end)

RegisterNUICallback('showEffect', function(data, cb)

    if fx and fx ~= 0 then

        stopEffect()
        msginf('stop effect', 1000)
        Citizen.Wait(100)
    end

    effectHandler(data)

    msginf('Start effect: ' .. data.name, 5000)

    cb('ok')
end)

RegisterNUICallback('exit', function(data, cb)

    SetNuiFocus(false, false)

    if data and data.stop then

        DisableIdleCamera(false)
        SetPedCanPlayAmbientAnims(PlayerPedId(), true)
        SetResourceKvp("idleCam", "on")

        active = false
        stopEffect()
    end

    cb('ok')
end)

RegisterNUICallback('timeOfDay', function(data, cb)

    ExecuteCommand('time ' .. data.hour)
    cb('ok')
end)

RegisterNUICallback('changeFx', function(data, cb)

    if fx and fx ~= 0 then

        adjust[data.name] = data.value

        if data.name == 'scale' then

            SetParticleFxLoopedScale(fx, adjust['scale'] + 0.0)
        elseif data.name == 'a' then

            SetParticleFxLoopedAlpha(fx, adjust['a'] + 0.0)
        else

            SetParticleFxLoopedColour(fx, adjust['r'] + 0.0, adjust['g'] + 0.0, adjust['b'] + 0.0, 0)
        end
    end

    cb('ok')
end)

-- NPC
function effectHandler(data)

    local _PlayerPedId = PlayerPedId()

    local offset = GetEntityForwardVector(_PlayerPedId) * 6
    local pos = GetEntityCoords(_PlayerPedId)

    if not HasNamedPtfxAssetLoaded(data.asset) then

        RequestNamedPtfxAsset(data.asset)
        while not HasNamedPtfxAssetLoaded(data.asset) do
            Citizen.Wait(1)
        end
    end

    SetPtfxAssetNextCall(data.asset)

    local x = pos.x + offset.x
    local y = pos.y + offset.y
    local _, z = GetGroundZFor_3dCoord(x, y, pos.z, 0)

    fx = StartParticleFxLoopedAtCoord(data.name, x, y, z, 0.0, 0.0, 0.0, adjust['scale'] + 0.0, false, false, false, false)
    SetParticleFxLoopedColour(fx, adjust['r'] + 0.0, adjust['g'] + 0.0, adjust['b'] + 0.0, 0)
    SetParticleFxLoopedAlpha(fx, adjust['a'] + 0.0)
end

function stopEffect()

    StopParticleFxLooped(fx, 0)

    fx = 0
    msginf('stop effect', 2000)
end

function msginf(msg, duree)

    duree = duree or 500
    ClearPrints()
    SetTextEntry_2("STRING")
    AddTextComponentString(msg)
    DrawSubtitleTimed(duree, 1)
end

function print_r(t)

    print(json.encode(t, { indent = true }))
end
