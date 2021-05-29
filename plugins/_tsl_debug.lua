--TomSL Debug Plugin
--If you have received this, it was in mistake, and leftover from the project I did for you, whoever you are, I have no mind if you use it but it's highly specialized and a waste of a if call if you don't have the debug config registered anyway.

                --if you somehow think this is a backdoor i will fucking stab you.
if GetHostName() ~= 'secret' then return end
PLUGIN.name = 'TomSL Hax'
PLUGIN.author = 'TomSL / ZeMysticalTaco'
PLUGIN.description = 'lololol'
--I felt like making a fancy Debug system.
local f = string.format

ix.debug = {}
ix.debug.colors = {}
function ix.debug.BrandString(str)
    return '[TomSLogs] ' .. str
end

--[[
5/15/2021
I really, tried for 4 hours to get this to parse multiple keywords fit together.
ie keyword is 'ONE'
so 'ONETWOTHREE, ONE would be highlighted and everything is their color or a different one
that's all fine and dandy and works but if two identical strings match it gets fucky, and i suppose i could write some magic logic but
i haven't slept in 2 days and i'm lazy.
]]
function ix.debug.ParseString(oldString, ...)
    local formatString = string.format( oldString, ... )
    local expString = string.Explode( ' ', formatString ) --due to the way we're formatting this (uungo)
    table.insert( expString, '\n' )

    for k, v in pairs( expString ) do
        if not string.EndsWith( v, ' ' ) then
            expString[ k ] = expString[ k ] .. ' '
        end
    end
    table.insert(expString, 4, color_white)
    local expString_copy = table.Copy( expString )
    local nIndex = 0

    for k, v in pairs( expString_copy ) do
        if type( v ) ~= 'string' then continue end

        for k2, v2 in pairs( ix.debug.colors ) do
            local st, en, str = string.find(v, v2[1])
            if st and en + 1 ~= v:len() then
                local bNewIndex = k + nIndex

                local subStr = string.sub(v, st, en)
                --1 is left, 2 is right
                local explodeStr = string.Split(v, subStr)
                expString[bNewIndex] = subStr

                local ind = table.insert( expString, bNewIndex, v2[ 2 ] )
                table.insert(expString, ind + 2, explodeStr[2])
                table.insert( expString, bNewIndex + 2, color_white )
                nIndex = nIndex + 3
            elseif st then
                local bNewIndex = k + nIndex
                table.insert( expString, bNewIndex, v2[ 2 ] )
                table.insert( expString, bNewIndex + 2, color_white )
                nIndex = nIndex + 2
            end
                
            
        end
    end

    return expString
end

function ix.debug.Log(str, ...)
    local parsedStr = ix.debug.ParseString(str, ...)
    return MsgC(Color(160,50,65), '[TomSLogs] ', color_white, unpack(parsedStr))
end

function ix.debug.AddKeyword(pattern, color)
    assert(IsColor(color), 'argument #2 of AddKeyword must be a color.')
    table.insert(ix.debug.colors, {pattern, color})
end


--carryover from iter1
local logColors = {
    {'(faction%[%g+])',Color(255,81,0)},
    {'(rank%[%g+])', Color(255,255, 0)},
    {'(role%[%g+])', Color(0,255,0)},
    {'(roles%[%g+])', Color(0,255,0)},
    {'(member%[%g+])', Color(255,0,255)}
}

for k, v in pairs(logColors) do
    ix.debug.AddKeyword(v[1], v[2])
end

ix.debug.AddKeyword('(CRITICAL)', Color(251, 20, 20))
ix.debug.AddKeyword('(WARNING)', Color(251, 255, 20))
                            --x+] <--- the character after + is the stopping point
ix.debug.AddKeyword('(actor%[%g+])', Color(12,215,20))
ix.debug.AddKeyword('(scripted_object%[%g+])', Color(215,144,12))
ix.debug.AddKeyword('(INFO)', Color(13,36,207))
ix.debug.AddKeyword('(seconds%[%g+])', Color(128,215,255))
ix.debug.AddKeyword('(minutes%[%g+])', Color(128,255,156))
ix.debug.AddKeyword('(hours%[%g+])', Color(158,255,128))
ix.debug.AddKeyword('(days%[%g+])', Color(189,255,128))
concommand.Add( 'scsp_debug_colorlist', function( )
    for k, v in pairs( ix.debug.colors ) do
        MsgC( 'Testing Color: ', v[ 2 ], v[ 1 ] .. ' \n' )
    end
end )
qd = ix.debug.Log
//TSL
qd('actor[npc_combine_s[eas()]_kills is gay')


--LINE HELPER

local function hookTo(element, func)
    if not IsValid(element) or element and element.Hooked then return end
    //TSL
qd('Paintover Here %s', element.PaintOver)
    if element.PaintOver then
    local oldPaint = element.PaintOver

    element.PaintOver = function(s, w, h)
        oldPaint(s, w, h)
        func(s, w, h)
    end
else
    element.PaintOver = function(s, w, h)
        func(s, w, h)
    end
end

    element.Hooked = true
end
hook.Add('HUDPaint', 'tsl.drawmxy', function()
end)

hook.Add('PostDrawHUD', 'tsl.drawmxy', function()
end)
hook.Add('CreateMove', 'tsl.lineclick', function(player, button)

end)
local lxy = {
    x = 0,
    y = 0,
    x2 = 0,
    y2 = 0
}

hook.Add('InputMouseApply', 'tsl.setxy', function(cmd, xy, ang)
end)
hook.Add('Think', 'tsl.hooktopan', function()
    if SERVER then return end
    if not ix.gui.factions then return end
    if not ix.gui.factions.characterPanel then return end
    hookTo(ix.gui.factions.characterPanel, function(s, w, h)
        local x, y = s:CursorPos()
        

        
        local bSet = input.IsMouseDown(MOUSE_LEFT)
        if input.IsKeyDown(KEY_LSHIFT) then return end
        local tbl = {
            [MOUSE_LEFT] = {'x', 'x'},
            [MOUSE_RIGHT] = {'y', 'y'},
            [MOUSE_4] = {'x2', 'x'},
            [MOUSE_5] = {'y2', 'y'},

        }
        local vcd = {
            xc = x,
            yc = y  
        }
        for k, v in pairs(tbl) do
            if input.IsMouseDown(k) then
                lxy[v[1]] = vcd[v[2]..'c']
            end
        end 
        --print(lxy.x, lxy.y, lxy.y2, lxy.x2)
        draw.DrawText(f('x:%s\ny:%s\nx2:%s\ny2:%s', lxy.x, lxy.y, lxy.y2, lxy.x2), 'DebugFixed', x + 25, y, color_white, TEXT_ALIGN_LEFT)
        if lxy.x == 0 then return end
        surface.SetDrawColor(color_white)
        surface.DrawLine(lxy.x, lxy.y, lxy.y2, lxy.x2)
    end)
end)