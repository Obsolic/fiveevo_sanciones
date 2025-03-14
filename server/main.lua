ESX = exports.es_extended.getSharedObject()

-- Pendiente de añadir la funcion de mirar la SQL para recoger el motivo y las pruebas
-- Añadir el callback de comprobar si tiene sanción existente
-- Añadir funcion para enviar webhooks
--------------------------
------- @Callbacks -------
--------------------------

ESX.RegisterServerCallback('fiveevo:server:resolve', function(source,cb)
  local tienesancion = false
  local xPlayer = ESX.GetPlayerFromId(source)
  MySQL.Async.fetchScalar(
    "SELECT pendiente FROM sanciones WHERE identifier = @identifier",
    {
        ["@identifier"] = xPlayer.getIdentifier()
    },
    function(results)
      if results == 1 then
        tienesancion = true
        cb(tienesancion)
    end
    end)
  --  cb(tienesancion)
end)

--------------------------
------- @Commandos -------
--------------------------

RegisterCommand("sancionar",function(source, args, rawCommand)
  if source ~= 0 then
      local xPlayer = ESX.GetPlayerFromId(source)
      for k, v in pairs(Config.Allowed) do
          if xPlayer.getGroup() == v then
              if args[1] ~= nil and args[2] ~= nil and args[3] ~= nil then
                  local identifiersancionado = args[1]
                  local motivosancion = args[2]
                  local video = args[3]
                  local nombreadmin = GetPlayerName(source)
                  TriggerClientEvent("esx:showNotification", source, "Sancion apuntada correctamente.") -- Modificar si existe otro sistema de Notificaciones
                 CacheFilesToDiscord(Config.Logs['apuntarsancion'], string.format('El administrador %s apuntó una sanción correctamente\n\n```Administrador:%s\nLicencia Sancionada:%s\nMotivo:%s\nPruebas de la sanción:%s```',nombreadmin,nombreadmin,identifiersancionado,motivosancion,video),'**APUNTAR SANCIÓN**')
                --  LogPonerSancion(source, identifiersancionado, motivosancion, video, 10181046)
                  MySQL.Async.execute(
                      "INSERT INTO sanciones (identifier, motivo, admin, video, pendiente) VALUES (@identifier, @motivo, @admin, @video, @pendiente)",
                      {
                          ["@identifier"] = args[1],
                          ["@motivo"] = args[2],
                          ["@admin"] = nombreadmin,
                          ["@video"] = args[3],
                          ["@pendiente"] = 1
                      })
              end
          end
      end
  end
end,false)


RegisterCommand("quitarsancion",function(source, args, rawCommand)
  local name = GetPlayerName(source)
  if source ~= 0 then
      local xPlayer = ESX.GetPlayerFromId(source)
      for k, v in pairs(Config.Allowed) do
          if xPlayer.getGroup() == v then
              if args[1] ~= nil then
                  local identifiersancionado = args[1]
                  TriggerClientEvent("esx:showNotification", source, "Sancion eliminada correctamente.") -- Modificar si existe otro sistema de Notificaciones
                 CacheFilesToDiscord(Config.Logs['quitarsancion'],string.format('El administrador %s retiro una sanción\n\n ```Nombre del administrador: %s\nLicencia retirada:%s```', name, name, args[1]), '**RETIRAR SANCIÓN**')
                  MySQL.Async.execute(
                      "DELETE from sanciones WHERE identifier = @identifier",
                      {
                          ["@identifier"] = args[1]
                      })
              end
          end
      end
  end
end,false)


----------------------------------------
--------- @Positivo en Sancion ---------
----------------------------------------
RegisterNetEvent('fiveevo:server:positivo', function()
CacheFilesPositivo(source)
end)

CacheFilesPositivo = function(source)
  local PlayerSource = source
  local xPlayer = ESX.GetPlayerFromId(PlayerSource)
  local name = GetPlayerName(PlayerSource)
  for k, v in ipairs(GetPlayerIdentifiers(PlayerSource)) do
    if string.sub(v, 1, string.len("discord:")) == "discord:" then
        discord = v
    end
end

local discord1
if not discord then
    discord1 = "Unknown"
else
    discord1 = discord
end

local userdiscord = "<@" .. discord1:gsub("discord:", "") .. ">"

if userdiscord ~= "Unknown" then
    userdiscord = userdiscord
    else 
    userdiscord = 'Unknown'
end  
MySQL.Async.fetchAll(
    "SELECT motivo,admin,video FROM sanciones WHERE identifier = @identifier",
    {
        ["@identifier"] = xPlayer.getIdentifier()
    },
    function(result)
      for i = 1, #result, 1 do
        CacheFilesToDiscord(Config.Logs['tienesancion'],string.format('El jugador %s esta IC y tiene una sanción pendiente\n\n```Identificador del usuario: %s\nMotivo: %s\nSanción puesta por: %s\nPruebas de la sanción: %s```\n\n Usuario de discord: %s',name,xPlayer.getIdentifier(), result[i].motivo, result[i].admin, result[i].video, userdiscord), "Usuario detectado con sanción pendiente dentro del servidor")
      end
    end)
end


--------------------------
-------- @Strings --------
--------------------------

CacheFilesToDiscord = function(wb,msg,title)

      local connect = {
        {
            ["color"] = 10181046,
            ["title"] = title,
            ["description"] = msg,
            ["footer"] = {
                ["text"] = ""
            },
        }
        }
    PerformHttpRequest(wb, function(err, text, headers)end,"POST",json.encode({username = "FiveEvo Sancion System", avatar_url = "https://cdn.discordapp.com/embed/avatars/5.png", embeds = connect}),{["Content-Type"] = "application/json"})
end