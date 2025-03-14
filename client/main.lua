ESX = exports.es_extended.getSharedObject() -- Compatible con todas las versiones de ESX/modificadas o no
local spawn = true
local promisaobj = promise.new()

CreateThread(function()
    while spawn do
        Wait(45000) -- Ajustar el tiempo que suele tardar en spawnear el Personaje
        if ComprobarSancion() then
            spawn = false
            TriggerServerEvent('fiveevo:server:positivo')
        end
    end
end)

ComprobarSancion = function()
    ESX.TriggerServerCallback('fiveevo:server:resolve', function(data) 
        promisaobj:resolve(data)
       end)
       return Citizen.Await(promisaobj)
end