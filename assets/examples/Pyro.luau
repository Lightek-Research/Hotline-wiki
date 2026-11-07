-- HOTLINE 0.14.0+: continuous ParticleEmitter on/off example.
-- Install this ModuleScript as Hotline.Addons.Pyro.
local Addon = {Id = "Pyro", Version = 1, Enabled = true, Commands = {}}

local function turnOn(api)
    for _, object in ipairs(api.Folder:GetDescendants()) do
        if object:IsA("ParticleEmitter") then object.Enabled = true end
    end
end

local function turnOff(api)
    for _, object in ipairs(api.Folder:GetDescendants()) do
        if object:IsA("ParticleEmitter") then object.Enabled = false end
    end
end

local function noArguments(args)
    assert(args.n == 0, "Pyro On/Off do not accept arguments")
end

Addon.Commands.On = {
    Validate = noArguments,
    Run = turnOn,
    ReplayOnSeek = true,
}
Addon.Commands.Off = {
    Validate = noArguments,
    Run = turnOff,
    ReplayOnSeek = true,
}

function Addon.Resolve(context)
    local folder = context.Resolve(context.Options.FolderPath or "Workspace.Fire")
    local button = context.Resolve(context.Options.ButtonPath or "Workspace.PyroButton")
    if not folder or not button then return nil end
    local click = button:FindFirstChildOfClass("ClickDetector")
    assert(click, "PyroButton needs a ClickDetector")
    return {Folder = folder, Click = click}
end

function Addon.Connect(api, emit, context)
    local scripts = context.Root.Scripts
    local settings = require(scripts.SecuritySettings)
    local canUse = require(scripts.AccessPolicy).new(context.Config, settings)

    return {
        api.Click.MouseClick:Connect(function(player)
            if not canUse(player) then return end
            turnOn(api)
            emit("On")
        end),
        api.Click.RightMouseClick:Connect(function(player)
            if not canUse(player) then return end
            turnOff(api)
            emit("Off")
        end),
    }
end

function Addon.Reset(api)
    turnOff(api)
end

return Addon
