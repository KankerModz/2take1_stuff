if not menu.is_trusted_mode_enabled(8) then
    menu.notify("Http trusted mode required for:\nAuto-Updater", "VPN/Proxy Check", 10)
    return
end

local vpncheck = {}
vpncheck.dir = utils.get_appdata_path("PopstarDevs\\2Take1Menu\\scripts\\vpncheck\\", "")
vpncheck.parent = menu.add_feature("VPN/Proxy Options", "parent", 0).id
vpncheck.event = nil

function vpncheck:notify(plr, num, str, var)
    if num == 1 then
        menu.notify(plr .. " is using a VPN/Proxy\nVPN: " .. (str or "Unknown"), "VPN/Proxy Check")
    elseif num == 2 then
        menu.notify(plr .. " is not using a VPN/Proxy", "VPN/Proxy Check")
    elseif num == 3 then
        menu.notify("Invalid IP Address", "VPN/Proxy Check", 4)
    elseif num == 4 then
        if var == 1 then
            menu.notify("Reached maximum limit for today (change API or your IP)", "VPN/Proxy Check (proxycheck.io)", 4)
        else
            menu.notify("Reached maximum limit of requests in a minute (45/min)", "VPN/Proxy Check (ip-api.com)", 4)
        end
    end
end

function vpncheck:func(pid, api, onlyTrue)
    if not network.is_session_started() then
        menu.notify("Please join online", "VPN/Proxy Check", 10)
        return
    end
    if not player.is_player_valid(pid) then
        return
    end
    vpncheck.pIp = player.get_player_ip(pid)
    vpncheck.pIp = string.format("%i.%i.%i.%i", vpncheck.pIp >> 24 & 255, vpncheck.pIp >> 16 & 255, vpncheck.pIp >> 8 & 255, vpncheck.pIp & 255)
    if api == 0 then
        local statusCode, response = web.get("https://proxycheck.io/v2/" .. vpncheck.pIp .. "?vpn=1")
        if response:find("ok") then
            if response:find([["proxy": "no"]]) then
                if not onlyTrue then
                    vpncheck:notify(player.get_player_name(pid), 2)
                end
            elseif response:find([["proxy": "yes"]]) then
                if response:find("name") then
                    vpncheck:notify(player.get_player_name(pid), 1, response:match("\"name\":%s+\"([^\"]+)\","))
                else
                    vpncheck:notify(player.get_player_name(pid), 1)
                end
            end
        elseif response:find("error") then
            if not onlyTrue then
                vpncheck:notify(player.get_player_name(pid), 3)
            end
        elseif response:find("denied") or response == nil then
            vpncheck:notify(player.get_player_name(pid), 4, nil, 4)
        else
            vpncheck:notify(player.get_player_name(pid), 4, nil, 1)
        end
    else
        local statusCode, response = web.get("http://ip-api.com/json/" .. vpncheck.pIp .. "?fields=147456")
        if response:find("success") then
            if response:find("true") then
                    vpncheck:notify(player.get_player_name(pid), 1)
            elseif response:find("false") then
                if not onlyTrue then
                    vpncheck:notify(player.get_player_name(pid), 2)
                end
            end
        elseif response:find("fail") then
            if not onlyTrue then
                vpncheck:notify(player.get_player_name(pid), 3)
            end
        elseif statusCode == "429" or response == nil then
            vpncheck:notify(player.get_player_name(pid), 4, nil, 2)
        end
    end
end

-- settings
function vpncheck:updateSettings()
    local file = io.open(vpncheck.dir .. "\\config.lua", "w")
    file:write("return {"..tostring(vpncheck.joinCheck.on)..","..vpncheck.api.value.."}")
    file:close()
end

vpncheck.api = menu.add_feature("VPN/Proxy Check API:", "autoaction_value_str", vpncheck.parent, function()
    vpncheck:updateSettings()
end)
vpncheck.api:set_str_data({ "proxycheck.io", "ip-api.com" })

vpncheck.joinCheck = menu.add_feature("Check on player join", "toggle", vpncheck.parent, function(f)
    vpncheck:updateSettings()
    if f.on then
        vpncheck.event = event.add_event_listener("player_join", function(event)
            if event.player ~= player.player_id() then
                vpncheck:func(event.player, 1, true) -- force use ip-api proxy as it only has per minute limits and not per day
            end
        end)
    end
    if not f.on then
        event.remove_event_listener("player_join", vpncheck.event)
    end
end)

-- load settings
if utils.file_exists(vpncheck.dir .. "\\config.lua") then
    local settings = dofile(vpncheck.dir .. "\\config.lua")
    vpncheck.joinCheck.on = settings[1]
    vpncheck.api.value = settings[2]
else
    utils.make_dir(vpncheck.dir)
    vpncheck:updateSettings()
end

menu.add_player_feature("VPN/Proxy Check", "action", 0, function(f, pid)
    vpncheck:func(pid, vpncheck.api.value)
end)
