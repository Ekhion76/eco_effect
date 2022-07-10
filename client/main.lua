local fxContainer = {}
local on

RegisterCommand('effect', function()

    SendNUIMessage({
        subject = 'OPEN'
    })

    if not on then

        on = true

        CreateThread(function()

            while on do Wait(0)

                if IsControlJustReleased(0, 38) then

                    SetNuiFocus(true, true)
                end
            end
        end)
    end
end)


RegisterNUICallback('showEffect', function(data, cb)

    stopEffect()
    msginf('stop effect', 1000)
    Citizen.Wait(100)

    effectHandler(data)

    msginf('Start effect: ' .. data.fxName, 5000)

    cb('ok')
end)

RegisterNUICallback('exit', function(data, cb)

    SetNuiFocus(false, false)

    if data and data.off then

        on = false
        stopEffect()
    end
    cb('ok')
end)

RegisterNUICallback('timeOfDay', function(data, cb)

    local command = data.timeOfDay == 'morning' and 'time 12' or 'time 1'
    ExecuteCommand(command)
    cb('ok')
end)


-- NPC
function effectHandler(data)

    local _PlayerPedId = PlayerPedId()

    local offset = GetEntityForwardVector(_PlayerPedId) * 6
    local pos = GetEntityCoords(_PlayerPedId)
    local heading = GetEntityHeading(_PlayerPedId)

    local x, y, xVector, yVector
    local forward = {}
    local xDistance = 4.0


    forward.x = math.sin(math.rad(heading + 90.0))
    forward.y = math.cos(math.rad(heading + 90.0))


    if not HasNamedPtfxAssetLoaded(data.asset) then
        RequestNamedPtfxAsset(data.asset)
        while not HasNamedPtfxAssetLoaded(data.asset) do
            Citizen.Wait(1)
        end
    end


    for i = 1, 3 do

        SetPtfxAssetNextCall(data.asset)

        x = pos.x - forward.x * (i - 2) * xDistance + offset.x
        y = pos.y + forward.y * (i - 2) * xDistance + offset.y

        local _, z = GetGroundZFor_3dCoord(x, y, pos.z, 0)


        local fx = StartParticleFxLoopedAtCoord(data.fxName, x, y, z, 0.0, 0.0, 0.0, 0.5 * i, false, false, false, false)
        SetParticleFxLoopedColour(fx, 1.0 + i, 3.0 - i, 1.0 + i, 0)
        --SetParticleFxLoopedAlpha(fx, 1.0)

        table.insert(fxContainer, fx)
    end
end


function stopEffect()

    for _, fxHandle in pairs(fxContainer) do

        StopParticleFxLooped(fxHandle, 0)
    end

    fxContainer = {}
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