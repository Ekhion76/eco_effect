local active = false
local fx = 0
local adjust = { scale = 1.0, r = 1.0, g = 3.0, b = 2.0, a = 1.0 }

RegisterCommand('effect', function()
    SendNUIMessage({ subject = 'OPEN' })

    if not active then
        active = true

        DisableIdleCamera(true)
        SetPedCanPlayAmbientAnims(PlayerPedId(), false)

        CreateThread(function()
            while active do
                Wait(0)
                if IsControlJustReleased(0, 38) then -- E
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
    if fx ~= 0 then
        stopEffect()
        Wait(100)
    end

    effectHandler(data)
    msginf('Start effect: ' .. tostring(data.name), 2000)

    cb({ ok = true })
end)

RegisterNUICallback('exit', function(data, cb)
    SetNuiFocus(false, false)

    if data and data.stop then
        DisableIdleCamera(false)
        SetPedCanPlayAmbientAnims(PlayerPedId(), true)

        active = false
        stopEffect()
    end

    cb({ ok = true })
end)

RegisterNUICallback('timeOfDay', function(data, cb)
    local hour = tonumber(data and data.hour) or 12
    if hour < 0 then hour = 0 end
    if hour > 23 then hour = 23 end
    NetworkOverrideClockTime(hour, 0, 0)
    cb({ ok = true })
end)

RegisterNUICallback('changeFx', function(data, cb)
    if fx ~= 0 and data and data.name ~= nil then
        local name = tostring(data.name)
        local value = tonumber(data.value) or 0.0

        if name == 'scale' then
            adjust.scale = value
            SetParticleFxLoopedScale(fx, adjust.scale + 0.0)
        elseif name == 'a' then
            adjust.a = value
            SetParticleFxLoopedAlpha(fx, adjust.a + 0.0)
        else
            if name == 'r' then adjust.r = value end
            if name == 'g' then adjust.g = value end
            if name == 'b' then adjust.b = value end
            SetParticleFxLoopedColour(fx, adjust.r + 0.0, adjust.g + 0.0, adjust.b + 0.0, 0)
        end
    end

    cb({ ok = true })
end)

function effectHandler(data)
    if not data or not data.asset or not data.name then
        msginf('Invalid effect data', 1500)
        return
    end

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local offset = GetEntityForwardVector(ped) * 6.0

    if not HasNamedPtfxAssetLoaded(data.asset) then
        RequestNamedPtfxAsset(data.asset)
        while not HasNamedPtfxAssetLoaded(data.asset) do
            Wait(0)
        end
    end

    SetPtfxAssetNextCall(data.asset)

    local x = pos.x + offset.x
    local y = pos.y + offset.y
    local _, z = GetGroundZFor_3dCoord(x, y, pos.z, true)

    fx = StartParticleFxLoopedAtCoord(
            data.name,
            x, y, z,
            0.0, 0.0, 0.0,
            adjust.scale + 0.0,
            false, false, false, false
    )
    SetParticleFxLoopedColour(fx, adjust.r + 0.0, adjust.g + 0.0, adjust.b + 0.0, 0)
    SetParticleFxLoopedAlpha(fx, adjust.a + 0.0)
end

function stopEffect()
    if fx ~= 0 then
        StopParticleFxLooped(fx, true)
        fx = 0
        msginf('stop effect', 1000)
    end
end

function msginf(msg, duree)
    duree = duree or 500
    ClearPrints()
    SetTextEntry_2("STRING")
    AddTextComponentString(tostring(msg))
    DrawSubtitleTimed(duree, 1)
end

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    SetNuiFocus(false, false)
    DisableIdleCamera(false)
    SetPedCanPlayAmbientAnims(PlayerPedId(), true)
    stopEffect()
end)