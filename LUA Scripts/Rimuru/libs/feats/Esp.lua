local function RGBAToInt(Red, Green, Blue, Alpha)
    Alpha = Alpha or 255
    return ((Red & 0x0ff) << 0x00) | ((Green & 0x0ff) << 0x08) |
               ((Blue & 0x0ff) << 0x10) | ((Alpha & 0x0ff) << 0x18)
end

local function Get_Distance_Between_Coords(first, second)
    local x = second.x - first.x
    local y = second.y - first.y
    local z = second.z - first.z
    return math.sqrt(x * x + y * y + z * z)
end

local function drawHeart(x, y, w, h) --Stole from my cod source, made by soul
    scriptdraw.draw_line(v2(x + (w / 100 * 0), y + (h / 100 * 45)), v2(x + (w / 100 * 10), y + (h / 100 * 18)), 1, RGBAToInt(255, 0, 0, 255))
    scriptdraw.draw_line(v2(x + (w / 100 * 100), y + (h / 100 * 45)), v2(x + (w / 100 * 90), y + (h / 100 * 18)), 1, RGBAToInt(255, 0, 0, 255))
    scriptdraw.draw_line(v2(x + (w / 100 * 10), y + (h / 100 * 18)), v2(x + (w / 100 * 30), y + (h / 100 * 9)), 1, RGBAToInt(255, 0, 0, 255))
    scriptdraw.draw_line(v2(x + (w / 100 * 90), y + (h / 100 * 18)), v2(x + (w / 100 * 70), y + (h / 100 * 9)), 1, RGBAToInt(255, 0, 0, 255))
    scriptdraw.draw_line(v2(x + (w / 100 * 30), y + (h / 100 * 9)), v2(x + (w / 100 * 50), y + (h / 100 * 20)), 1, RGBAToInt(255, 0, 0, 255))
    scriptdraw.draw_line(v2(x + (w / 100 * 70), y + (h / 100 * 9)), v2(x + (w / 100 * 50), y + (h / 100 * 20)), 1, RGBAToInt(255, 0, 0, 255))
    scriptdraw.draw_line(v2(x + (w / 100 * 0), y + (h / 100 * 45)), v2(x + (w / 100 * 50), y + (h / 100 * 93)), 1, RGBAToInt(255, 0, 0, 255))
    scriptdraw.draw_line(v2(x + (w / 100 * 100), y + (h / 100 * 45)), v2(x + (w / 100 * 50), y + (h / 100 * 93)), 1, RGBAToInt(255, 0, 0, 255))
end

local function drawShaderOutline(x, y, w, h, outlineColour, insideColour)
	ui.draw_rect(x, y, w, 0.003, outlineColour.r, outlineColour.g, outlineColour.b, outlineColour.a)
	ui.draw_rect(x-w/2, y+h/2, 0.003, h+0.003,  outlineColour.r, outlineColour.g, outlineColour.b, outlineColour.a) --left
	ui.draw_rect(x+w/2, y+h/2, 0.003, h+0.003,  outlineColour.r, outlineColour.g, outlineColour.b, outlineColour.a) -- right
	ui.draw_rect(x, y+h, w, 0.003,  outlineColour.r, outlineColour.g, outlineColour.b, outlineColour.a) 

    ui.draw_rect(x, y+h/2, w, h,  insideColour.r, insideColour.g, insideColour.b, insideColour.a) 
end

local function espBones(bone, bone1, id)
    local boneRet, bonePos = ped.get_ped_bone_coords(player.get_player_ped(id), bone, v3(0,0,0))
    local boneRet1, bonePos1 = ped.get_ped_bone_coords(player.get_player_ped(id), bone1, v3(0,0,0))

    if boneRet and boneRet1 then
        local w2sRet, w2sPos= graphics.project_3d_coord(bonePos)
        local w2sRet1, w2sPos1 = graphics.project_3d_coord(bonePos1)
        
        if w2sRet and w2sRet1 then
            w2sPos.x = w2sPos.x/graphics.get_screen_width()
            w2sPos.y = w2sPos.y/graphics.get_screen_height()
    
            w2sPos1.x = w2sPos1.x/graphics.get_screen_width()
            w2sPos1.y = w2sPos1.y/graphics.get_screen_height()

            scriptdraw.draw_line(w2sPos, w2sPos1, 1, 2)
        end
    end
end

local function Draw_ped(feat)
    if type(feat) == "number" then
    return HANDLER_POP
end
local ped = ped.get_all_peds()
for i =1, #ped do
    if entity.is_entity_a_ped(ped[i]) then
        local EDim1, EDim2 = entity.get_entity_model_dimensions(ped[i])
        local pos = entity.get_entity_coords(ped[i])
        -- local vec1 = entity.get_entity_forward_vector(ped[i]) * 0.1
        -- local vec2 = entity.get_entity_forward_vector(ped[i]) * -0.1
        
        -- local rot = entity.get_entity_rotation(ped[i])
        
        
        -- EDim1 = (EDim1 + vec2) - rot
        -- EDim2 = (EDim2 + vec1) + rot
        EDim1 = EDim1 + v3(-0.25,-0.25,-0.25)
        EDim2 = EDim2 + v3(0.25,0.25,700.00)
        if player.get_player_from_ped(ped[i]) ~= player.player_id() then
            GTA_Natives.DRAW_BOX(pos.x + EDim1.x, pos.y + EDim1.y, pos.z + EDim1.z, pos.x + EDim2.x, pos.y + EDim2.y, pos.z  + EDim2.z, 255, 50, 50, 100)
            
        end
    end
end

end

function esp(type)
    local bones = {31086, 14201, 52301}
    for i=0, 32 do
        if i ~= player.player_id() then
            if player.is_player_valid(i) and player.get_player_health(i) > 0 then                
            
                if type == 0 then
                    ui.draw_line(player.get_player_coords(player.player_id()), player.get_player_coords(i), 255, 0, 255, 255)
                end
                
                if type == 1 then
                    for k=1, #bones do
                       espBones(bones[k], bones[k], i)
                    end
                end

                if type == 2 then
                    local pos = player.get_player_coords(i)
                    
                    local dist = Get_Distance_Between_Coords(player.get_player_coords(player.player_id()), player.get_player_coords(i))
                    local multplr = dist > 1 and  -1 or 6.17757 / distance

                    local rtrtn, screenPos = graphics.project_3d_coord(pos)

                    if rtrtn then
                        local espX = graphics.get_screen_width() * screenPos.x
                        local espY = graphics.get_screen_height() * screenPos.y



                        drawShaderOutline(espX - (62.5 * multplr), espY - (175.0 * multplr), 0.05, 0.05, {r= 255, b=0, g=255, a=255}, {r= 0, b=0, g=0, a=100})                    
                    end


                end
            end
        end
    end
end
