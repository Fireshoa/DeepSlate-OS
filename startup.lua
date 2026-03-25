term.clear()
term.setCursorPos(1,1)
print(os.version())
print("Starting...")

if not fs.exists("lib/basalt.lua") then
    shell.run("wget", "run", "https://raw.githubusercontent.com/Pyroxenium/basalt/refs/heads/master/docs/install.lua", "release", "latest.lua", "lib/basalt.lua")
end

os.pullEvent = os.pullEventRaw

function table.split(inputstr, sep)
    if sep == nil then
        sep = "%s" -- Default to splitting by whitespace
    end
    local t = {}
    -- This pattern captures everything that isn't the separator
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function os.saveTheme()
    local f = fs.open("settings/themes.txt", "w")
    f.writeLine(os.theme.button)
    f.writeLine(os.theme.osBg)
    f.writeLine(os.theme.menuBg)
    f.writeLine(os.theme.text)
    f:close()
end
function os.loadTheme()
    os.theme = {}
    local f = fs.open("settings/themes.txt", "r")
    os.theme.button = tonumber(f.readLine())
    os.theme.osBg = tonumber(f.readLine())
    os.theme.menuBg = tonumber(f.readLine())
    os.theme.text = tonumber(f.readLine())
    f:close()
end
os.loadTheme()

function sleep(n)
    local t = os.startTimer(n)
    repeat
        local _, id = os.pullEvent("timer")
    until id == t
end

function os.shutdown()
    os.running = false
end

function os.version()
    return "DeepSlateOS v0.1"
end

function os.runApp(app)
    local dir = "apps/" .. app .. "/main.lua"
    if fs.exists(dir) then
        dofile(dir)
    end
end

function os.appExists(app)
    local dir = "apps/" .. app .. "/main.lua"
    if fs.exists(dir) then
        return true
    end
    return false
end

function os.newWindow(title, xs, ys, fullscreen, scale)
    local window = OSMain:addMovableFrame()
    if fullscreen == nil then
        fullscreen = true
    end
    if scale == nil then
        scale = true
    end

    xs = xs or 20
    ys = ys or 10
    window:setSize(xs,ys)
    window:setPosition(5,5)
    window:setBackground(os.theme.menuBg)

    window:addLabel()
        :setText(title)
        :setPosition(9, 1)
        :setBackground(os.theme.menuBg)
        :setForeground(os.theme.text)

    window:addButton()
        :setText("X")
        :setSize(3,1)
        :setPosition(1,1)
        :setBackground(os.theme.button)
        :setForeground(os.theme.text)
        :onClick(function()
            window:disable()
            window:remove()
        end)
        
    if fullscreen then
        window:addButton()
            :setText("O")
            :setSize(3,1)
            :setPosition(5,1)
            :setBackground(os.theme.button)
            :setForeground(os.theme.text)
            :onClick(function(self)
                if self:getText() == "O" then
                    window.mx, window.my = window:getPosition()
                    window.mw, window.mh = window:getSize()
                    
                    window.full = true -- Tell the onDrag to lock the window
                    local w, h = OSMain:getSize()
                    window:setSize(w, h - 1)
                    window:setPosition(1, 2)
                    self:setText("o")
                else
                    window.full = false -- Unlock the window
                    window:setSize(window.mw, window.mh)
                    window:setPosition(window.mx, window.my)
                    self:setText("O")
                end
            end)
    end
    
    --[[if scale then
        window:addButton()
            :setText("/")
            :setSize(1,1)
            :setPosition("parent.w", "parent.h")
            :onDrag(function(self, event, button, x, y, ox, oy)
                window:setSize(x,y)
            end)
    end]]
        
    return window
end

os.basalt = require("lib.basalt")
OSMain = os.basalt.createFrame()
    :setBackground(os.theme.osBg)
    :setPosition(1,1)
OSTaskbar = OSMain:addFrame()
    :setBackground(os.theme.menuBg)
    :setSize("parent.w", 1)
OSSidePanel = OSMain:addFrame()
    :setBackground(os.theme.menuBg)
    :setPosition(1,3)
    :setSize(11,6)
    :hide()
    :onRelease(function(self)
        self:hide()
    end)

OSTaskbar:addButton()
    :setText("Menu")
    :setSize(6,1)
    :setPosition(1,1)
    :setBackground(os.theme.button)
    :setForeground(os.theme.text)
    :onClick(function()
        if OSSidePanel:isVisible() then
            OSSidePanel:hide()
        else
            OSSidePanel:show()
        end
    end)
    
OSTaskbar:addButton()
    :setText("Run")
    :setSize(5,1)
    :setPosition(7,1)
    :setBackground(os.theme.button)
    :setForeground(os.theme.text)
    :onClick(function()
        os.runApp("run")
    end)
    
OSSidePanel:addLabel()
    :setText("DeepSlate")
    :setPosition(2,1)
    :setForeground(os.theme.text)

OSSidePanel:addButton()
    :setText("Restart")
    :setSize(9,1)
    :setPosition(2,2)
    :setBackground(os.theme.button)
    :setForeground(os.theme.text)
    :onClick(function()
        os.reboot()
    end)

OSSidePanel:addButton()
    :setText("Run")
    :setSize(9,1)
    :setPosition(2,3)
    :setBackground(os.theme.button)
    :setForeground(os.theme.text)
    :onClick(function()
        OSSidePanel:hide()
        os.runApp("run")
    end)

OSSidePanel:addButton()
    :setText("Browse")
    :setSize(9,1)
    :setPosition(2,4)
    :setBackground(os.theme.button)
    :setForeground(os.theme.text)
    :onClick(function()
        OSSidePanel:hide()
        os.runApp("appbrowse")
    end)
    
OSSidePanel:addButton()
    :setText("Shell")
    :setSize(9,1)
    :setPosition(2,5)
    :setBackground(os.theme.button)
    :setForeground(os.theme.text)
    :onClick(function()
        OSSidePanel:hide()
        os.basalt.stopUpdate()
    end)

sleep(0)

os.basalt.autoUpdate()