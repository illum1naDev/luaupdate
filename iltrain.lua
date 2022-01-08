script_name('Train bot for Arizona-RP')
script_version("1.5")
script_author("illum1na")

--LIBS
local imgui = require 'imgui'
local encoding = require 'encoding'
local vector = require 'vector3d'
local zxc = require 'lib.samp.events'
local fa = require 'fAwesome5'
local inicfg = require 'inicfg'
local notf = import 'imgui_notf.lua'
local effil = require("effil")
local updateid
local ffi = require('ffi')

encoding.default = 'CP1251'
u8 = encoding.UTF8

--VARIBALES
local menu = 'list'
local window, window_stats, crash = imgui.ImBool(false), imgui.ImBool(false), imgui.ImBool(false)

local control = {
    start = false,
    selectMode = imgui.ImInt(1),
    kd = 0,
    startTp = false,
    nop = false,
    stats = imgui.ImBool(false),
    step = 0,
    autoTake = imgui.ImBool(false),
    selectMarker = imgui.ImInt(1),
    setCirclesEat = imgui.ImInt(0),
    autoEat = imgui.ImBool(false),
    eat = imgui.ImInt(0),
    eatSelect = {u8'Êàðòîôåëü-Ôðè', u8'Ñýíäâè÷', u8'Áóðãåð', u8'Êðûëûøêè', u8'Ïèööà', u8'Êóðèöà ñ ñàëàòîì', u8'Êîìïëåêñíûé Îáåä'},
    autoOff = imgui.ImBool(false),
    telegramNotf = imgui.ImBool(false),
    reversal = imgui.ImBool(false),
    blinking = imgui.ImBool(false),
    autoExit = imgui.ImBool(false)
}

local stats = {
    profit = 0,
    circles = 0,
    casket = 0,
    jobTime = 0,
    circlesEat = 0,
}

local bots = {
    legit = {
        time = os.clock(),
        dist = -1,
        retur = {x = 0, y = 0, z = 0},
    },
    rage = {
        pos = {0, 0, 0},
    }
}

ffi.cdef [[
    typedef int BOOL;
    typedef unsigned long HANDLE;
    typedef HANDLE HWND;
    typedef int bInvert;
 
    HWND GetActiveWindow(void);

    BOOL FlashWindow(HWND hWnd, BOOL bInvert);
    BOOL ShowWindow(HWND hWnd, BOOL bInvert);
]]

--FILES, CONFIG

if not doesDirectoryExist('moonloader/config/TrainBot') then
	createDirectory('moonloader/config/TrainBot')
end

local mainIni = inicfg.load({
    Telegram =
    {
        chat_id = '',
        token = '',
    },
    Bot = {
        dist = 5,
        speed = 30,
        stop = 17,
    }
}, 'TrainBot.ini')
if not doesFileExist("moonloader/config/TrainBot/TrainBot.ini") then inicfg.save(mainIni, "TrainBot/TrainBot.ini") end
inik = inicfg.load(nil, 'TrainBot/TrainBot')

buffer_token = imgui.ImBuffer(''..inik.Telegram.token, 128)
buffer_chatid = imgui.ImBuffer(''..inik.Telegram.chat_id, 128)
distTp = imgui.ImInt(inik.Bot.dist)
speedTp = imgui.ImInt(inik.Bot.speed)
stopLvl = imgui.ImInt(inik.Bot.stop)

chat_id = inik.Telegram.chat_id
token = inik.Telegram.token

--MAIN

function main()
    while not isSampAvailable() do wait(200) end
	
	local lastver = update():getLastVersion()
	if thisScript().version ~= lastver then
		sampRegisterChatCommand('trupdate', function()
			update():download()
		end)
		sampAddChatMessage('Âûøëî îáíîâëåíèå ñêðèïòà ('..thisScript().version..' -> '..lastver..'), ââåäèòå /trupdate äëÿ îáíîâëåíèÿ!', -1)
	end
	
    imgui.Process = false
    getLastUpdate()
    hwin = ffi.C.GetActiveWindow()

    sampRegisterChatCommand('train', function()
        window.v = not window.v
    end)

    sampRegisterChatCommand('spos', function()
        local x, y, z = getCharCoordinates(PLAYER_PED)
        setClipboardText(x..', '..y..', '..z)
    end)

    lua_thread.create(get_telegram_updates)
    while true do
        wait(0)
        imgui.Process = window.v or window_stats.v or crash.v
        if not control.start then
            stats.jobTime = os.time()
        end
        if control.start then
            if control.selectMode.v == 1 and isCharInAnyTrain(PLAYER_PED) then
                local speed = getCarSpeed(storeCarCharIsInNoSave(PLAYER_PED)) * 3.67
                local x, y, z = getCharCoordinates(PLAYER_PED)
                local gas = true
                local tormoz = false

                if bots.legit.time < os.clock() then
                    rdist = getDistanceBetweenCoords3d(x, y, z, bots.legit.retur.x, bots.legit.retur.y, bots.legit.retur.z)
                    bots.legit.time = os.clock() + 1
                    maxSpeed = math.random(100, 120)
                    bots.legit.retur.x, bots.legit.retur.y, bots.legit.retur.z = x, y, z
                end

                bots.legit.dist = getDistanceBetweenCoords3d(x, y, z, blipX, blipY, blipZ)
                local distt = speed / math.random(5, 12)
                local stop = distt * rdist
                local stopp = bots.legit.dist - stop / 1.2


                if 2 >= stopp then
                    gas = false 
                    tormoz = true
                end

                if gas and speed < maxSpeed then 
                    writeMemory(12006520, 1, 255, false)
                end

                if tormoz then 
                    writeMemory(12006516, 1, 255, false)
                end
            end 
            if control.autoTake.v and not isCharInAnyTrain(PLAYER_PED) then
                if control.step == 1 then
                    BeginToPoint(-2097.04, 514.95, 1487.69, 0.7, -255, false)
                    if control.setCirclesEat.v ~= stats.circlesEat or control.setCirclesEat.v == 0 then
                        if control.selectMarker.v == 1 then
                            BeginToPoint(-2102, 513.01, 1487.69, 0.7, -255, false)
                            control.step = 2
                        else
                            BeginToPoint(-2100.99, 512.81, 1487.69, 0.7, -255, false)
                            BeginToPoint(-2102.17, 506.95, 1487.69, 0.7, -255, false)
                            control.step = 2
                        end 
                    elseif control.setCirclesEat.v == stats.circlesEat and control.autoEat.v then
                        BeginToPoint(-2097.25, 515.16, 1487.69, 0.7, -255, false) 
                        BeginToPoint(-2097.19, 512.02, 1487.69, 0.7, -255, false)
                        control.step = 0
                    end 
                elseif control.step == 2 then
                    for i = 0, 5 do
                        setGameKeyState(21, 255)
                        wait(300)
                    end
                elseif control.step == 3 then
                    if control.selectMarker.v == 1 then
                        BeginToPoint(-2102.21, 512.94, 1487.69, 0.7, -255, false)
                        control.step = 2
                    else
                        BeginToPoint(-2100.44, 512.24, 1487.69, 0.7, -255, false)
                        BeginToPoint(-2102.19, 506.8, 1487.69, 0.7, -255, false)
                        control.step = 2
                    end
                elseif control.step == 4 then
                    if control.selectMarker.v == 1 then
                        BeginToPoint(-2262.57, 510.25, 1487.69, 0.7, -255, false)
                        BeginToPoint(-2263.05, 507.08, 1487.69, 0.7, -255, false)
                        control.step = 2
                    else
                        BeginToPoint(-2260.71, 514.24, 1487.69, 0.7, -255, false)
                        BeginToPoint(-2263.38, 512.92, 1487.69, 0.7, -255, false)
                        control.step = 2
                    end
                end
            end
        end
    end
end



--SUBSIDIARY
function update()
    local raw = 'https://raw.githubusercontent.com/illum1naDev/luaupdate/main/trbot_update.json'
    local dlstatus = require('moonloader').download_status
    local requests = require('requests')
    local f = {}
    function f:getLastVersion()
        local response = requests.get(raw)
        if response.status_code == 200 then
            return decodeJson(response.text)['lastver']
        else
            return 'UNKNOWN'
        end
    end
    function f:download()
        local response = requests.get(raw)
        if response.status_code == 200 then
            downloadUrlToFile(decodeJson(response.text)['dlurl'], thisScript().path, function (id, status, p1, p2)
                print('Ñêà÷èâàþ '..decodeJson(response.text)['dlurl']..' â '..thisScript().path)
                if status == dlstatus.STATUSEX_ENDDOWNLOAD then
                    sampAddChatMessage('Ñêðèïò îáíîâëåí, ïåðåçàãðóçêà...', -1)
                    thisScript():reload()
                end
            end)
        else
            sampAddChatMessage('Îøèáêà, íåâîçìîæíî óñòàíîâèòü îáíîâëåíèå, êîä: '..response.status_code, -1)
        end
    end
    return f
end


function get_timer(time)
    local jobsTime = os.time() - time
	return string.format("%s:%s:%s", string.format("%s%s", (tonumber(os.date("%H", jobsTime)) < tonumber(os.date("%H", 0)) and 24 + tonumber(os.date("%H", jobsTime)) - tonumber(os.date("%H", 0)) or tonumber(os.date("%H", jobsTime)) - tonumber(os.date("%H", 0))) < 10 and 0 or "", tonumber(os.date("%H", jobsTime)) < tonumber(os.date("%H", 0)) and 24 + tonumber(os.date("%H", jobsTime)) - tonumber(os.date("%H", 0)) or tonumber(os.date("%H", jobsTime)) - tonumber(os.date("%H", 0))), os.date("%M", jobsTime), os.date("%S", jobsTime))
end

function onReceivePacket(id)
    if id == 33 then
        control.start = false
        control.step = 0
        if control.telegramNotf.v then
            sendTelegramNotification('Ïîòåðÿíî ñîåäèíåíèå ñ ñåðâåðîì')
        end
    elseif id == 32 then
        control.start = false
        control.step = 0
        if control.telegramNotf.v then
            sendTelegramNotification('Ñåðâåð çàêðûë ñîåäèíåíèå')
        end
    end
end

-- onReceiveRpc = function(id, bs)
--     if id == 107 then
--         local marker = raknetBitStreamReadInt8(bs)
--         local x, y, z = raknetBitStreamReadFloat(bs), raknetBitStreamReadFloat(bs), raknetBitStreamReadFloat(bs)
--         sampAddChatMessage(x..' '..y..' '..z, -1)
--             if control.selectMode.v == 1 then
--                 blipX, blipY, blipZ = x, y, z
--             end
--             if control.selectMode.v == 2 then
--                 mx, my, mz = getCharCoordinates(PLAYER_PED)
--                 control.kd = control.kd + 1
--                 if control.kd == 1 then
--                     charPosX, charPosY, charPosZ = mx, my, mz
--                     blipX, blipY, blipZ = x, y, z 
--                 else 
--                     charPosX, charPosY, charPosZ = bots.rage.pos[1], bots.rage.pos[2], bots.rage.pos[3]
--                     blipX, blipY, blipZ = x, y, z
--                 end
--                 bots.rage.pos = {x, y, z}
--                 if control.startTp and control.start then
--                     teleport(blipX, blipY, blipZ)
--                 end
--             end
--     end
-- end

function zxc.onSetMapIcon(iconId, p, typ, color, style)
	local x,y,z = getCharCoordinates(playerPed)
	local dist = getDistanceBetweenCoords3d(x, y, z, p.x, p.y, p.z)
	if dist > 500 and style == 3 and iconId == 0 then
		if control.selectMode.v == 1 then
            blipX, blipY, blipZ = p.x, p.y, p.z
        end
        if control.selectMode.v == 2 then
            mx, my, mz = getCharCoordinates(PLAYER_PED)
            control.kd = control.kd + 1
            if control.kd == 1 then
                charPosX, charPosY, charPosZ = mx, my, mz
                blipX, blipY, blipZ = p.x, p.y, p.z
            else 
                charPosX, charPosY, charPosZ = bots.rage.pos[1], bots.rage.pos[2], bots.rage.pos[3]
                blipX, blipY, blipZ = p.x, p.y, p.z
            end
            bots.rage.pos = {p.x, p.y, p.z}
            if control.startTp and control.start then
                teleport(blipX, blipY, blipZ)
            end
        end
	end
end

zxc.onShowDialog = function(dialogId, style, title, button1, button2, text)
    if control.autoTake.v then
        if title:find("Ðåãèñòðàöèÿ íà ðåéñ") and not text:find("îñâîáîäèòü") then 
            sampSendDialogResponse(dialogId, 1, -1, -1)
            return false
        elseif title:find("Ðåãèñòðàöèÿ íà ðåéñ") and text:find("îñâîáîäèòü") then 
            sampSendDialogResponse(dialogId, 0, -1, -1)
            return false
        elseif title:find("Âñå ðåéñû çàíÿòû") and text:find("æèâîé î÷åðåäè") then 
            sampSendDialogResponse(dialogId, 0, -1, -1)
            return false
        elseif title:find("Âñå ðåéñû çàíÿòû") or text:find("Ñåé÷àñ âñå ðàáî÷èå ìåñòà íà ðåéñàõ çàíÿòû") then
            control.step = 2
            sampSendDialogResponse(dialogId, 0, -1, -1)
            return false
        end
    end
    if control.autoEat.v then
        if title:find("Âûáåðèòå åäó") then
            if control.eat.v == 0 then
                sampSendDialogResponse(dialogId, 1, 0, nil)
            elseif control.eat.v == 1 then
                sampSendDialogResponse(dialogId, 1, 1, nil)
            elseif control.eat.v == 2 then
                sampSendDialogResponse(dialogId, 1, 2, nil)
            elseif control.eat.v == 3 then
                sampSendDialogResponse(dialogId, 1, 3, nil)
            elseif control.eat.v == 4 then
                sampSendDialogResponse(dialogId, 1, 4, nil)
            elseif control.eat.v == 5 then
                sampSendDialogResponse(dialogId, 1, 5, nil)
            elseif control.eat.v == 6 then
                sampSendDialogResponse(dialogId, 1, 6, nil)
            end 
            return false
        end 
    end
    if dialogId == 15039 then
        if control.autoOff.v then
            control.start = false
            control.step = 0
            control.startTp = false
            control.nop = false
        end
        if control.telegramNotf.v then
            sendTelegramNotification('Ïîäîçðåíèå íà àäìèíà: '..text)
        end
        if control.reversal.v then
            ffi.C.ShowWindow(hwin, 3)
        end
        if control.blinking.v then
            ffi.C.FlashWindow(hwin, 3)
        end
        if control.autoExit.v then
            sampProcessChatInput('/q')
            sendTelegramNotification('Âûøåë')
        end
    end
end

zxc.onDisplayGameText = function(style, type, text)
    if text:find("Streak") and control.start then
        if control.selectMode.v == 2 then
            control.nop = true
            control.startTp = true
            teleport(blipX, blipY, blipZ)
        end
    end
end

zxc.onServerMessage = function(color, text)
    if text:find('\'Ëàðåö ñ ïðåìèåé\'.') then
        stats.casket = stats.casket + 1
    end
    if text:find('Çàðàáîòàíî çà ðåéñ: (%d+)') then
        if control.selectMode.v == 2 then
            lua_thread.create(function()
                wait(3000)
                control.nop = false
                control.startTp = false
                control.kd = 0
            end)
        end
        stats.profit = stats.profit + 75000
        stats.circles = stats.circles + 1
        stats.circlesEat = stats.circlesEat + 1
        control.step = 1
    end
    if text:find('äîïîëíèòåëüíóþ çàðïëàòó: $(%d+)') then
        stats.profit = stats.profit + 75000
    end
    if text:find('Âû âçÿëè') or text:find('Âû íå ãîëîäíû!') then
        control.step = 3
        stats.circlesEat = 0
    end
    if text:find('àäìèíèñòðàòîð') or text:find('îòâåòèë âàì') or text:find('Àäìèíèñòðàòîð (.+) îòâåòèë âàì%:') or text:find('%(%( Àäìèíèñòðàòîð (.+)%[%d+%]%:') or text:find('%(%( àäìèíèñòðàòîð .+%[(%d+)%]%:') then
        if control.autoOff.v then
            control.start = false
            control.step = 0
            control.startTp = false
            control.nop = false
        end
        if control.telegramNotf.v then
            sendTelegramNotification('Ïîäîçðåíèå íà àäìèíà: '..text)
        end
        if control.reversal.v then
            ffi.C.ShowWindow(hwin, 3)
        end
        if control.blinking.v then
            ffi.C.FlashWindow(hwin, 3)
        end
        if control.autoExit.v then
            sampProcessChatInput('/q')
            sendTelegramNotification('Âûøåë')
        end
    end
end

--RAGE BOT

teleport = function(x, y, z)
    local data = samp_create_sync_data('vehicle')
    
    lua_thread.create(function()
        while true do wait(speedTp.v)
            if isCharInAnyTrain(PLAYER_PED) then
                vectorX, vectorY, vectorZ = x - charPosX, y - charPosY, z - charPosZ

                vec = vector(vectorX, vectorY, vectorZ)
                vec:normalize()

                charPosX = charPosX + vec.x * distTp.v
                charPosY = charPosY + vec.y * distTp.v
                charPosZ = charPosZ + vec.z * distTp.v

                data.moveSpeed.x = -0.06
                data.moveSpeed.y = -0.06
                data.moveSpeed.z = -0.06
                
                data.position.x = charPosX 
                data.position.y = charPosY
                data.position.z = charPosZ

                data.send()

                if getDistanceBetweenCoords2d(data.position.x, data.position.y, x, y) < 5 then
                    data.position = {x, y, z}
                    data.moveSpeed = {0, 0, 0}
                    data.send()
                    break
                end
            end
        end
    end)
end

zxc.onSendVehicleSync = function(data)
    if control.nop then
        return false
    end
end

function samp_create_sync_data(sync_type, copy_from_player)
    local ffi = require 'ffi'
    local sampfuncs = require 'sampfuncs'
    -- from SAMP.Lua
    local raknet = require 'samp.raknet'
    require 'samp.synchronization'

    copy_from_player = copy_from_player or true
    local sync_traits = {
        player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData},
        vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData},
        passenger = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC, sampStorePlayerPassengerData},
        aim = {'AimSyncData', raknet.PACKET.AIM_SYNC, sampStorePlayerAimData},
        trailer = {'TrailerSyncData', raknet.PACKET.TRAILER_SYNC, sampStorePlayerTrailerData},
        unoccupied = {'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC, nil},
        bullet = {'BulletSyncData', raknet.PACKET.BULLET_SYNC, nil},
        spectator = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC, nil}
    }
    local sync_info = sync_traits[sync_type]
    local data_type = 'struct ' .. sync_info[1]
    local data = ffi.new(data_type, {})
    local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data)))
    -- copy player's sync data to the allocated memory
    if copy_from_player then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id
            if copy_from_player == true then
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            else
                player_id = tonumber(copy_from_player)
            end
            copy_func(player_id, raw_data_ptr)
        end
    end
    -- function to send packet
    local func_send = function()
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, sync_info[2])
        raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data))
        raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1)
        raknetDeleteBitStream(bs)
    end
    -- metatable to access sync data and 'send' function
    local mt = {
        __index = function(t, index)
            return data[index]
        end,
        __newindex = function(t, index, value)
            data[index] = value
        end
    }
    return setmetatable({send = func_send}, mt)
end

--IMGUI

local fa_font = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
function imgui.BeforeDrawFrame()
    if fa_font == nil then
        local font_config = imgui.ImFontConfig() -- to use 'imgui.ImFontConfig.new()' on error
        font_config.MergeMode = true

        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 14.0, font_config, fa_glyph_ranges)
        logo = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 45.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
        ik = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 25.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
end

function imgui.OnDrawFrame()
    if window.v then
        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(526.0, 300.0), imgui.Cond.FirstUseEver)
        imgui.Begin(' ', window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)

        imgui.SetCursorPos(imgui.ImVec2(186, 15));
            imgui.PushFont(logo)
                imgui.Text('TrainBot')
            imgui.PopFont()

        imgui.SetCursorPos(imgui.ImVec2(490, 10));
            if imgui.Button(fa.ICON_FA_TIMES_CIRCLE .. '', imgui.ImVec2(23, 23)) then
                window.v = false
            end

        if menu ~= 'list' then
            imgui.SetCursorPos(imgui.ImVec2(20, 24));
                if imgui.Button(fa.ICON_FA_ARROW_LEFT .. u8' Íàçàä', imgui.ImVec2(100, 30)) then
                    menu = 'list'
                end

            imgui.SetCursorPos(imgui.ImVec2(214, 70));
                imgui.Separator()
        end

        if menu == 'list' then
            imgui.SetCursorPos(imgui.ImVec2(220, 65));
                imgui.PushFont(ik)
                    imgui.Text('by illum1na')
                imgui.PopFont()

            imgui.SetCursorPos(imgui.ImVec2(50, 110));
                if imgui.Button(fa.ICON_FA_TRAIN .. u8' Áîò', imgui.ImVec2(130, 70)) then
                    menu = 'bots'
                end 

            --imgui.SetCursorPos(imgui.ImVec2(200, 110));
                --if imgui.Button(fa.ICON_FA_PAPER_PLANE .. u8' Óâåäîìëåíèå', imgui.ImVec2(130, 70)) then
                --    menu = 'notification'
                --end

            imgui.SetCursorPos(imgui.ImVec2(350, 110));
                if imgui.Button(fa.ICON_FA_USER_ALT_SLASH .. u8' Àíòè Àäìèí', imgui.ImVec2(130, 70)) then
                   menu = 'antiAdmin'
                end

            imgui.SetCursorPos(imgui.ImVec2(200, 110)); -- Ñòàðîå çíà÷åíèå 50, 200
                if imgui.Button(fa.ICON_FA_CROW .. u8' Äîïîëíèòåëüíî', imgui.ImVec2(130, 70)) then
                    menu = 'additionally'
                end

            imgui.SetCursorPos(imgui.ImVec2(50, 200)); -- Ñòàðîå çíà÷åíèå 200 200
                if imgui.Button(fa.ICON_FA_CODE .. u8' Î ñêðèïòå', imgui.ImVec2(430, 35)) then -- Ñòàðîå çíà÷åíèå 130, 70
                    menu = 'about'
                end
                       
        end

        if menu == 'bots' then
            imgui.SetCursorPos(imgui.ImVec2(10.5, 265));
                if control.start == false then
                    if imgui.Button(fa.ICON_FA_PLAY .. u8' Âêëþ÷èòü', imgui.ImVec2(505, 25)) then
                        control.start = true
                        control.step = 1
                    end
                else
                    if imgui.Button(fa.ICON_FA_STOP .. u8' Âûêëþ÷èòü', imgui.ImVec2(505, 25)) then
                        control.start = false
                        control.step = 0
                        control.startTp = false
                        control.nop = false
                    end
                end
            imgui.SetCursorPos(imgui.ImVec2(150, 230));
                imgui.RadioButton('Legit', control.selectMode, 1)
            imgui.SetCursorPos(imgui.ImVec2(320, 230));
                imgui.RadioButton('Rage', control.selectMode, 2)
			imgui.SetCursorPos(imgui.ImVec2(25, 130));
				imgui.Text(u8'Óðîâåíü òîðìîæåíèÿ ïîêà ÍÅ ðàáîòàåò')
		
            if control.selectMode.v == 1 then
                imgui.SetCursorPos(imgui.ImVec2(25, 100));
                    if imgui.SliderInt(u8'Óðîâåíü òîðìîæåíèÿ', stopLvl, 1, 40) then
                        inicfg.save({
                            Telegram =
                            {
                                chat_id = buffer_chatid.v,
                                token = buffer_token.v,
                            },
                            Bot = {
                                dist = distTp.v,
                                speed = speedTp.v,
                                stop = stopLvl.v,
                            }
                        }, 'TrainBot/TrainBot')
                        chat_id = buffer_chatid.v
                        token = buffer_token.v
                    end
            elseif control.selectMode.v == 2 then
                imgui.SetCursorPos(imgui.ImVec2(65, 100));
                    if imgui.SliderInt(u8'Äèñòàíöèÿ', distTp, 1, 10) then
                        inicfg.save({
                            Telegram =
                            {
                                chat_id = buffer_chatid.v,
                                token = buffer_token.v,
                            },
                            Bot = {
                                dist = distTp.v,
                                speed = speedTp.v,
                                stop = stopLvl.v,
                            }
                        }, 'TrainBot/TrainBot')
                        chat_id = buffer_chatid.v
                        token = buffer_token.v
                    end
                imgui.SetCursorPos(imgui.ImVec2(65, 160));
                    if imgui.SliderInt(u8'Ñêîðîñòü', speedTp, 15, 50) then
                        inicfg.save({
                            Telegram =
                            {
                                chat_id = buffer_chatid.v,
                                token = buffer_token.v,
                            },
                            Bot = {
                                dist = distTp.v,
                                speed = speedTp.v,
                                stop = stopLvl.v,
                            }
                        }, 'TrainBot/TrainBot')
                        chat_id = buffer_chatid.v
                        token = buffer_token.v
                    end
            end

        end

        if menu == 'notification' then
            imgui.InputText('TOKEN', buffer_token, imgui.InputTextFlags.Password)
            imgui.InputText('USER ID', buffer_chatid)

            imgui.SetCursorPos(imgui.ImVec2(410, 80));
                if imgui.Button(u8'Òåñò', imgui.ImVec2(108, 50)) then
                    sendTelegramNotification('ß ãåé, à îé. Âñå âîðê!')
                end

            imgui.SetCursorPos(imgui.ImVec2(10.5, 145));
                imgui.Text(u8'!send - îòïðàâèòü ñîîáùåíèå â ÷àò')
            imgui.SetCursorPos(imgui.ImVec2(255, 145));
                imgui.Text(u8'!stats - ñòàòèñòèêà ðàáîòû')
            imgui.SetCursorPos(imgui.ImVec2(10.5, 170));
                imgui.Text(u8'!start - âêëþ÷èòü áîòà')
            imgui.SetCursorPos(imgui.ImVec2(255, 170));
                imgui.Text(u8'!exit - âûéòè èç èãðû')
            imgui.SetCursorPos(imgui.ImVec2(10.5, 195));
                imgui.Text(u8'!stop - âûêëþ÷èòü áîòà')
            imgui.SetCursorPos(imgui.ImVec2(255, 195));
                imgui.Text(u8'!close - çàêðûòü äèàëîã ÷åê áîòà(àäìèíà)')
            imgui.SetCursorPos(imgui.ImVec2(10.5, 220));
                imgui.Text(u8'!crash - êðàøíóòü èãðó')

            imgui.SetCursorPos(imgui.ImVec2(10.5, 265));
                if imgui.Button(u8'Ñîõðàíèòü', imgui.ImVec2(505, 25)) then
                    if notf then
                        notf.addNotification("TrainBot\n\nÍàñòðîéêè òåëåãðàììà ñîõðàíåíû!", 5, 10)
                    end
                    inicfg.save({
                        Telegram =
                        {
                            chat_id = buffer_chatid.v,
                            token = buffer_token.v,
                        },
                        Bot = {
                            dist = distTp.v,
                            speed = speedTp.v,
                            stop = stopLvl.v,
                        }
                    }, 'TrainBot/TrainBot')
                    chat_id = buffer_chatid.v
                    token = buffer_token.v
                end
        end

        if menu == 'antiAdmin' then
            imgui.SetCursorPos(imgui.ImVec2(10.8, 80));
                imgui.Checkbox(u8'Âûêëþ÷åíèå áîòà', control.autoOff)
            -- imgui.SetCursorPos(imgui.ImVec2(200, 80));
               -- imgui.Checkbox(u8'Ðàçâîðîò èãðû', control.reversal)
            -- imgui.SetCursorPos(imgui.ImVec2(380, 80));    
               -- imgui.Checkbox(u8'Ìèãàíèå îêíîì', control.blinking)
            -- imgui.SetCursorPos(imgui.ImVec2(10.8, 110));
               -- imgui.Checkbox(u8'Óâåäîìëåíèå â TG', control.telegramNotf)
            imgui.SetCursorPos(imgui.ImVec2(10.8, 110)); -- Ñòàðîå çíà÷åíèå 200, 110
                imgui.Checkbox(u8'Âûõîä èç èãðû', control.autoExit)
        end 

        if menu == 'additionally' then
            imgui.SetCursorPos(imgui.ImVec2(10.8, 80));
                if imgui.Checkbox(u8'Ñòàòèñòèêà', control.stats) then
                    window_stats.v = not window_stats.v
                end
            imgui.SetCursorPos(imgui.ImVec2(200, 80));    
                imgui.Checkbox(u8'Àâòî âçÿòèå ðåéñà', control.autoTake)
            imgui.SetCursorPos(imgui.ImVec2(380, 80));    
                imgui.RadioButton(u8'Ïåðâàÿ ñòîéêà', control.selectMarker, 1) 
            imgui.SetCursorPos(imgui.ImVec2(380, 110));
                imgui.RadioButton(u8'Âòîðàÿ ñòîéêà', control.selectMarker, 2)

            imgui.SetCursorPos(imgui.ImVec2(10.8, 110));  
                imgui.Checkbox(u8'Àâòî åäà', control.autoEat)

            imgui.SetCursorPos(imgui.ImVec2(200, 110));
                imgui.PushItemWidth(90)
                    imgui.InputInt('', control.setCirclesEat)
                imgui.PushItemWidth(0)

            imgui.SetCursorPos(imgui.ImVec2(10.8, 140));
                imgui.PushItemWidth(120)
                    imgui.Combo(u8'×òî êóøàòü', control.eat, control.eatSelect, #control.eatSelect)
                imgui.PushItemWidth(0)
        end

        if menu == 'about' then
            imgui.PushFont(ik)
                imgui.SetCursorPos(imgui.ImVec2(200, 80));
                    imgui.Text(u8'Àâòîð: ')
                imgui.SetCursorPos(imgui.ImVec2(270, 80));
                    if imgui.Link(u8'illum1na') then
                        os.execute(('explorer.exe "%s"'):format("https://vk.com/id55904399"))
                    end

                imgui.SetCursorPos(imgui.ImVec2(150, 110));
                    imgui.Text(u8'Âåðñèÿ ñêðèïòà: 1.4')
            imgui.PopFont()
        end

        imgui.End()
    end
    if window_stats.v then
        imgui.ShowCursor = window.v
        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 1.5, sh / 1.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(180, 145), imgui.Cond.FirstUseEver)
        imgui.Begin('Stats', window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)

        if isCharInAnyTrain(PLAYER_PED) then
            local x, y, z = getCharCoordinates(PLAYER_PED)
            imgui.SetCursorPos(imgui.ImVec2(7, 7));
            imgui.Text(u8'Äèñòàíöèÿ: '..math.floor(getDistanceBetweenCoords2d(x, y, blipX, blipY)))

            local train = storeCarCharIsInNoSave(PLAYER_PED)
            local speed = getCarSpeed(train) * 3.67
            imgui.SetCursorPos(imgui.ImVec2(7, 23));
            imgui.Text(u8'Ñêîðîñòü: '..math.floor(speed))
        end

        imgui.SetCursorPos(imgui.ImVec2(7, 45));
        imgui.Text(u8'Âñåãî ðåéñîâ ñäåëàíî: '..stats.circles)

        imgui.SetCursorPos(imgui.ImVec2(7, 60));
        imgui.Text(u8'Îáùèé çàðàáîòîê: '..stats.profit..'$')

        imgui.SetCursorPos(imgui.ImVec2(7, 75));
        imgui.Text(u8'Ëàðöîâ: '..stats.casket)

        imgui.SetCursorPos(imgui.ImVec2(7, 100));
        imgui.Text(u8'Âðåìÿ: '..os.date('%X'))

        imgui.SetCursorPos(imgui.ImVec2(7, 115));
        imgui.Text(u8'Áîò ðàáîòàåò: '..get_timer(stats.jobTime))

        imgui.End()
    end

    if crash.v then
        imgui.Begin(' ', crash, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
    end
end

function imgui.Link(label, description)

    local size = imgui.CalcTextSize(label)
    local p = imgui.GetCursorScreenPos()
    local p2 = imgui.GetCursorPos()
    local result = imgui.InvisibleButton(label, size)

    imgui.SetCursorPos(p2)

    if imgui.IsItemHovered() then
        if description then
            imgui.BeginTooltip()
            imgui.PushTextWrapPos(600)
            imgui.TextUnformatted(description)
            imgui.PopTextWrapPos()
            imgui.EndTooltip()

        end

        imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.CheckMark], label)
        imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y + size.y), imgui.ImVec2(p.x + size.x, p.y + size.y), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.CheckMark]))

    else
        imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.CheckMark], label)
    end

    return result
end

function Dark()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2
 
    style.WindowPadding = ImVec2(6, 6)
    style.WindowRounding = 15.0
    style.FramePadding = ImVec2(5, 5)
    style.ItemSpacing = ImVec2(12, 8)
    style.ItemInnerSpacing = ImVec2(8, 6)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 15.0
    style.ScrollbarRounding = 15.0
    style.GrabMinSize = 15.0
    style.GrabRounding = 7.0
    style.ChildWindowRounding = 8.0
    style.FrameRounding = 6.0
   
 
    colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
    colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
    colors[clr.WindowBg] = ImVec4(0.11, 0.15, 0.17, 1.00)
    colors[clr.ChildWindowBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
    colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
    colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
    colors[clr.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
    colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
    colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
    colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
    colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
    colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
    colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
    colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
    colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
    colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[clr.ButtonHovered] = ImVec4(0.28, 0.56, 1.00, 1.00)
    colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
    colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
    colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
    colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
    colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
    colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
    colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
    colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end
Dark()

--TELEGRAM
function threadHandle(runner, url, args, resolve, reject)
    local t = runner(url, args)
    local r = t:get(0)
    while not r do
        r = t:get(0)
        wait(0)
    end
    local status = t:status()
    if status == 'completed' then
        local ok, result = r[1], r[2]
        if ok then resolve(result) else reject(result) end
    elseif err then
        reject(err)
    elseif status == 'canceled' then
        reject(status)
    end
    t:cancel(0)
end

function requestRunner()
    return effil.thread(function(u, a)
        local https = require 'ssl.https'
        local ok, result = pcall(https.request, u, a)
        if ok then
            return {true, result}
        else
            return {false, result}
        end
    end)
end

function async_http_request(url, args, resolve, reject)
    local runner = requestRunner()
    if not reject then reject = function() end end
    lua_thread.create(function()
        threadHandle(runner, url, args, resolve, reject)
    end)
end

function encodeUrl(str)
    str = str:gsub(' ', '%+')
    str = str:gsub('\n', '%%0A')
    return u8:encode(str, 'CP1251')
end

function sendTelegramNotification(msg)
    msg = msg:gsub('{......}', '')
    msg = encodeUrl(msg)
    async_http_request('https://api.telegram.org/bot' .. token .. '/sendMessage?chat_id=' .. chat_id .. '&text='..msg,'', function(result) end)
end

function get_telegram_updates()
    while not updateid do wait(1) end
    local runner = requestRunner()
    local reject = function() end
    local args = ''
    while true do
        url = 'https://api.telegram.org/bot'..token..'/getUpdates?chat_id='..chat_id..'&offset=-1'
        threadHandle(runner, url, args, processing_telegram_messages, reject)
        wait(0)
    end
end

function processing_telegram_messages(result)
    if result then
        local proc_table = decodeJson(result)
        if proc_table.ok then
            if #proc_table.result > 0 then
                local res_table = proc_table.result[1]
                if res_table then
                    if res_table.update_id ~= updateid then
                        updateid = res_table.update_id
                        local message_from_user = res_table.message.text
                        if message_from_user then
                            local text = u8:decode(message_from_user) .. ' '
                            if text:match('^!stats') then
                                sendTelegramNotification('Çàðàáîòîê: '..stats.profit..'\nÐåéñîâ: '..stats.circles..'\nËàðöîâ: '..stats.casket..'\nÂðåìÿ ðàáîòû: '..get_timer(stats.jobTime))
                            elseif text:match('^!send') then
                                local sendMessageTelegram = text:match('^!send (.+)')
                                sampSendChat(sendMessageTelegram)
                                sendTelegramNotification('Îòïðàâèë!')
                            elseif text:match('^!exit') then 
                                sampProcessChatInput('/q')
                                sendTelegramNotification('Âûøåë!')
                            elseif text:match('^!start') then 
                                control.start = true
                                sendTelegramNotification('Áîò óñïåøíî âêëþ÷åí!')
                            elseif text:match('^!stop') then 
                                control.start = false
                                sendTelegramNotification('Áîò óñïåøíî âûêëþ÷åí!')
                            elseif text:match('^!close') then 
                                sampSendDialogResponse(15039, 1, 0, nil)
                                sendTelegramNotification('Äèàëîã çàêðûò!')
                            elseif text:match('^!crash') then 
                                crash.v = not crash.v
                                sendTelegramNotification('Êðàøíóë!')
                            else
                                sendTelegramNotification('Íåèçâåñòíàÿ êîìàíäà!')
                            end
                        end
                    end
                end
            end
        end
    end
end

function getLastUpdate()
    async_http_request('https://api.telegram.org/bot'..token..'/getUpdates?chat_id='..chat_id..'&offset=-1','',function(result)
        if result then
            local proc_table = decodeJson(result)
            if proc_table.ok then
                if #proc_table.result > 0 then
                    local res_table = proc_table.result[1]
                    if res_table then
                        updateid = res_table.update_id
                    end
                else
                    updateid = 1
                end
            end
        end
    end)
end

--RUN

function BeginToPoint(x, y, z, radius, move_code, isSprint)
    repeat
        local posX, posY, posZ = GetCoordinates()
        local dist = getDistanceBetweenCoords3d(x, y, z, posX, posY, z)
        setAngle(x, y, dist, 0.05)
        MovePlayer(move_code, isSprint)
        wait(0)
    until not control.start or dist < radius
end

function MovePlayer(move_code, isSprint)
    setGameKeyState(1, move_code)
    --[[255 - îáû÷íûé áåã íàçàä
       -255 - îáû÷íûé áåã âïåðåä
      65535 - èäòè øàãîì âïåðåä
    -65535 - èäòè øàãîì íàçàä]]
    if isSprint then setGameKeyState(16, 255) end
end

function setAngle(x, y, distance, speed)
    local source_x = fix(representIntAsFloat(readMemory(0xB6F248, 4, false)))
    local source_z = fix(representIntAsFloat(readMemory(0xB6F258, 4, false))) + math.pi
    local angle = GetAngleBeetweenTwoPoints(x,y) - source_z - math.pi

    if distance > 1.8 then
        if angle > -0.1 and angle < 0.03 then setCameraPositionUnfixed(-0.3, GetAngleBeetweenTwoPoints(x,y))
        elseif angle < -5.7 and angle > -5.93 then setCameraPositionUnfixed(-0.3, GetAngleBeetweenTwoPoints(x,y))
        elseif angle < -6.0 and angle > -6.4 then setCameraPositionUnfixed(-0.3, GetAngleBeetweenTwoPoints(x,y))
        elseif angle > 0.04 then setCameraPositionUnfixed(-0.3, fix(representIntAsFloat(readMemory(0xB6F258, 4, false)))+speed)
        elseif angle < -3.5 and angle > -5.67 then setCameraPositionUnfixed(-0.3, fix(representIntAsFloat(readMemory(0xB6F258, 4, false)))+speed)
        else setCameraPositionUnfixed(-0.3, fix(representIntAsFloat(readMemory(0xB6F258, 4, false)))-speed)
        end
    else setCameraPositionUnfixed(source_x, GetAngleBeetweenTwoPoints(x,y)) end
end

function GetAngleBeetweenTwoPoints(x2,y2)
    local x1, y1, z1 = getCharCoordinates(playerPed)
    local plus = 0.0
    local mode = 1
    if x1 < x2 and y1 > y2 then plus = math.pi/2; mode = 2; end
    if x1 < x2 and y1 < y2 then plus = math.pi; end
    if x1 > x2 and y1 < y2 then plus = math.pi*1.5; mode = 2; end
    local lx = x2 - x1
    local ly = y2 - y1
    lx = math.abs(lx)
    ly = math.abs(ly)
    if mode == 1 then ly = ly/lx;
    else ly = lx/ly; end 
    ly = math.atan(ly)
    ly = ly + plus
    return ly
end

function fix(angle)
    while angle > math.pi do
        angle = angle - (math.pi*2)
    end
    while angle < -math.pi do
        angle = angle + (math.pi*2)
    end
    return angle
end

function GetCoordinates()
    if isCharInAnyCar(playerPed) then
        local car = storeCarCharIsInNoSave(playerPed)
        return getCarCoordinates(car)
    else
        return getCharCoordinates(playerPed)
    end
end
