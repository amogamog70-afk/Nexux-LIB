--[[
    NEXUS UI LIBRARY v1.0
    GitHub: https://github.com/YOURNAME/NexusLib
    
    Использование:
    local Nexus = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOURNAME/NexusLib/main/NexusLib.lua"))()
    
    local Window = Nexus:CreateWindow({
        Title = "My Hub",
        Key = Enum.KeyCode.F9
    })
    
    local Tab = Window:AddTab("Главная")
    
    Tab:AddToggle({ Name = "Noclip", Default = false, Callback = function(v) ... end })
    Tab:AddSlider({ Name = "WalkSpeed", Min = 1, Max = 200, Default = 16, Callback = function(v) ... end })
    Tab:AddButton({ Name = "Teleport", Callback = function() ... end })
    Tab:AddColorPicker({ Name = "Accent Color", Default = Color3.fromRGB(255,255,255), Callback = function(c) ... end })
    Tab:AddDropdown({ Name = "Mode", Options = {"Mode A","Mode B"}, Default = "Mode A", Callback = function(v) ... end })
    Tab:AddTextbox({ Name = "Player Name", Default = "", Callback = function(v) ... end })
    Tab:AddKeybind({ Name = "Sprint Key", Default = Enum.KeyCode.LeftShift, Callback = function(k) ... end })
    Tab:AddLabel("Это просто текст")
    Tab:AddSeparator()
]]

local Nexus = {}
Nexus.__index = Nexus

-- Services
local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")
local CoreGui        = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Utils
local function Tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function MakeInstance(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function Ripple(btn)
    local rip = MakeInstance("Frame", {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = 0.6,
        ZIndex = 10,
        ClipsDescendants = false
    }, btn)
    MakeInstance("UICorner", {CornerRadius = UDim.new(1,0)}, rip)
    Tween(rip, {Size = UDim2.new(0,120,0,120), BackgroundTransparency = 1}, 0.4)
    game:GetService("Debris"):AddItem(rip, 0.5)
end

-- Theme
local Theme = {
    BG         = Color3.fromRGB(10,  10,  10),
    BG2        = Color3.fromRGB(17,  17,  17),
    BG3        = Color3.fromRGB(26,  26,  26),
    BG4        = Color3.fromRGB(34,  34,  34),
    Border     = Color3.fromRGB(42,  42,  42),
    Border2    = Color3.fromRGB(55,  55,  55),
    Text       = Color3.fromRGB(255, 255, 255),
    Text2      = Color3.fromRGB(153, 153, 153),
    Text3      = Color3.fromRGB(85,  85,  85),
    Accent     = Color3.fromRGB(255, 255, 255),
}

-- ╔══════════════════════════════════╗
-- ║         WINDOW                   ║
-- ╚══════════════════════════════════╝

function Nexus:CreateWindow(config)
    config = config or {}
    local Title   = config.Title   or "Nexus"
    local SubText = config.SubText or "v1.0"
    local Key     = config.Key     or Enum.KeyCode.F9
    local Size    = config.Size    or UDim2.new(0, 620, 0, 420)

    local self = setmetatable({}, {__index = Nexus})
    self._tabs    = {}
    self._open    = true
    self._dragging = false

    -- ScreenGui
    local gui = MakeInstance("ScreenGui", {
        Name = "NexusLib_" .. Title,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, (pcall(function() return CoreGui end) and CoreGui or LocalPlayer.PlayerGui))

    -- Main Frame
    local main = MakeInstance("Frame", {
        Size = Size,
        Position = UDim2.new(0.5, -310, 0.5, -210),
        BackgroundColor3 = Theme.BG,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, gui)
    MakeInstance("UICorner", {CornerRadius = UDim.new(0, 8)}, main)
    MakeInstance("UIStroke", {Color = Theme.Border, Thickness = 1}, main)

    -- Topbar
    local topbar = MakeInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Theme.BG2,
        BorderSizePixel = 0,
    }, main)
    MakeInstance("UIStroke", {Color = Theme.Border, Thickness = 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, topbar)

    -- Bottom border line on topbar
    MakeInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
    }, topbar)

    -- Logo dot
    MakeInstance("Frame", {
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(0, 14, 0.5, -3),
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0,
    }, topbar)

    -- Title
    local titleLbl = MakeInstance("TextLabel", {
        Text = Title:upper(),
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 28, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, topbar)

    -- SubText
    MakeInstance("TextLabel", {
        Text = SubText,
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(0, titleLbl.TextBounds.X + 36, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text3,
        Font = Enum.Font.Code,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, topbar)

    -- Close button
    local closeBtn = MakeInstance("TextButton", {
        Text = "×",
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -40, 0.5, -16),
        BackgroundColor3 = Theme.BG3,
        TextColor3 = Theme.Text2,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        BorderSizePixel = 0,
    }, topbar)
    MakeInstance("UICorner", {CornerRadius = UDim.new(0, 5)}, closeBtn)

    closeBtn.MouseButton1Click:Connect(function()
        Tween(main, {Size = UDim2.new(0, main.AbsoluteSize.X, 0, 0), Position = UDim2.new(
            main.Position.X.Scale, main.Position.X.Offset,
            main.Position.Y.Scale, main.Position.Y.Offset + main.AbsoluteSize.Y / 2
        )}, 0.2)
        task.delay(0.25, function() gui:Destroy() end)
    end)

    -- Minimize button
    local minBtn = MakeInstance("TextButton", {
        Text = "−",
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -78, 0.5, -16),
        BackgroundColor3 = Theme.BG3,
        TextColor3 = Theme.Text2,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        BorderSizePixel = 0,
    }, topbar)
    MakeInstance("UICorner", {CornerRadius = UDim.new(0, 5)}, minBtn)

    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(main, {Size = UDim2.new(0, main.AbsoluteSize.X, 0, 46)}, 0.2)
            minBtn.Text = "+"
        else
            Tween(main, {Size = Size}, 0.2)
            minBtn.Text = "−"
        end
    end)

    -- Drag
    local dragStart, startPos
    topbar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            self._dragging = true
            dragStart = inp.Position
            startPos = main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if self._dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            self._dragging = false
        end
    end)

    -- Toggle key
    UserInputService.InputBegan:Connect(function(inp, gp)
        if not gp and inp.KeyCode == Key then
            self._open = not self._open
            main.Visible = self._open
        end
    end)

    -- Sidebar
    local sidebar = MakeInstance("Frame", {
        Size = UDim2.new(0, 140, 1, -46),
        Position = UDim2.new(0, 0, 0, 46),
        BackgroundColor3 = Theme.BG2,
        BorderSizePixel = 0,
    }, main)

    MakeInstance("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
    }, sidebar)

    local sideList = MakeInstance("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, sidebar)

    MakeInstance("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
    }, sidebar)

    -- Content area
    local content = MakeInstance("Frame", {
        Size = UDim2.new(1, -140, 1, -46),
        Position = UDim2.new(0, 140, 0, 46),
        BackgroundColor3 = Theme.BG,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, main)

    -- Store refs
    self._gui      = gui
    self._main     = main
    self._sidebar  = sidebar
    self._content  = content
    self._tabIndex = 0

    return self
end

-- ╔══════════════════════════════════╗
-- ║         TAB                      ║
-- ╚══════════════════════════════════╝

function Nexus:AddTab(name)
    self._tabIndex = self._tabIndex + 1
    local idx = self._tabIndex

    -- Tab button in sidebar
    local tabBtn = MakeInstance("TextButton", {
        Text = "",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Theme.BG3,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = idx,
    }, self._sidebar)
    MakeInstance("UICorner", {CornerRadius = UDim.new(0, 5)}, tabBtn)

    local accent = MakeInstance("Frame", {
        Size = UDim2.new(0, 2, 0.6, 0),
        Position = UDim2.new(0, 0, 0.2, 0),
        BackgroundColor3 = Theme.Text,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, tabBtn)
    MakeInstance("UICorner", {CornerRadius = UDim.new(1, 0)}, accent)

    MakeInstance("TextLabel", {
        Text = name,
        Size = UDim2.new(1, -12, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text3,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, tabBtn)

    -- Tab content frame
    local tabFrame = MakeInstance("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Border2,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, self._content)

    MakeInstance("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, tabFrame)

    MakeInstance("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
    }, tabFrame)

    local tab = {_frame = tabFrame, _idx = idx, _window = self, _order = 0}

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(self._tabs) do
            t._frame.Visible = false
            local b = t._btn
            Tween(b, {BackgroundTransparency = 1}, 0.1)
            local a = b:FindFirstChildWhichIsA("Frame")
            if a then Tween(a, {BackgroundTransparency = 1}, 0.1) end
            local l = b:FindFirstChildWhichIsA("TextLabel")
            if l then Tween(l, {TextColor3 = Theme.Text3}, 0.1) end
        end
        tabFrame.Visible = true
        Tween(tabBtn, {BackgroundTransparency = 0.85}, 0.1)
        Tween(accent, {BackgroundTransparency = 0}, 0.1)
        local lbl = tabBtn:FindFirstChildWhichIsA("TextLabel")
        if lbl then Tween(lbl, {TextColor3 = Theme.Text}, 0.1) end
    end)

    tab._btn = tabBtn
    table.insert(self._tabs, tab)

    -- Auto-select first tab
    if #self._tabs == 1 then
        tabFrame.Visible = true
        tabBtn.BackgroundTransparency = 0.85
        accent.BackgroundTransparency = 0
        local lbl = tabBtn:FindFirstChildWhichIsA("TextLabel")
        if lbl then lbl.TextColor3 = Theme.Text end
    end

    -- ── helpers that create elements inside this tab ──

    local function nextOrder()
        tab._order = tab._order + 1
        return tab._order
    end

    local function MakeRow(height)
        local row = MakeInstance("Frame", {
            Size = UDim2.new(1, 0, 0, height or 36),
            BackgroundColor3 = Theme.BG2,
            BorderSizePixel = 0,
            LayoutOrder = nextOrder(),
        }, tabFrame)
        MakeInstance("UICorner", {CornerRadius = UDim.new(0, 5)}, row)
        MakeInstance("UIStroke", {Color = Theme.Border, Thickness = 0.5}, row)
        return row
    end

    -- ── TOGGLE ──
    function tab:AddToggle(cfg)
        cfg = cfg or {}
        local name     = cfg.Name     or "Toggle"
        local default  = cfg.Default  or false
        local callback = cfg.Callback or function() end
        local state    = default

        local row = MakeRow(36)

        MakeInstance("TextLabel", {
            Text = name,
            Size = UDim2.new(1, -60, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = Theme.Text2,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)

        local track = MakeInstance("Frame", {
            Size = UDim2.new(0, 36, 0, 20),
            Position = UDim2.new(1, -48, 0.5, -10),
            BackgroundColor3 = state and Theme.Text or Theme.BG4,
            BorderSizePixel = 0,
        }, row)
        MakeInstance("UICorner", {CornerRadius = UDim.new(1, 0)}, track)
        MakeInstance("UIStroke", {Color = Theme.Border2, Thickness = 0.5}, track)

        local thumb = MakeInstance("Frame", {
            Size = UDim2.new(0, 14, 0, 14),
            Position = state and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),
            BackgroundColor3 = state and Theme.BG or Theme.Text3,
            BorderSizePixel = 0,
        }, track)
        MakeInstance("UICorner", {CornerRadius = UDim.new(1,0)}, thumb)

        local btn = MakeInstance("TextButton", {
            Text = "", Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1, BorderSizePixel = 0,
        }, row)

        btn.MouseButton1Click:Connect(function()
            state = not state
            Tween(track, {BackgroundColor3 = state and Theme.Text or Theme.BG4}, 0.15)
            Tween(thumb, {
                Position = state and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),
                BackgroundColor3 = state and Theme.BG or Theme.Text3,
            }, 0.15)
            callback(state)
        end)

        function tab:SetToggle(n, v)
            if n == name then
                state = v
                Tween(track, {BackgroundColor3 = v and Theme.Text or Theme.BG4}, 0.15)
                Tween(thumb, {
                    Position = v and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),
                    BackgroundColor3 = v and Theme.BG or Theme.Text3,
                }, 0.15)
                callback(v)
            end
        end

        return {SetValue = function(v) tab:SetToggle(name, v) end}
    end

    -- ── SLIDER ──
    function tab:AddSlider(cfg)
        cfg = cfg or {}
        local name     = cfg.Name     or "Slider"
        local min      = cfg.Min      or 0
        local max      = cfg.Max      or 100
        local default  = cfg.Default  or min
        local suffix   = cfg.Suffix   or ""
        local callback = cfg.Callback or function() end
        local value    = math.clamp(default, min, max)

        local row = MakeRow(50)

        local topRow = MakeInstance("Frame", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
        }, row)

        MakeInstance("TextLabel", {
            Text = name,
            Size = UDim2.new(0.6, 0, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = Theme.Text2,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, topRow)

        local valLbl = MakeInstance("TextLabel", {
            Text = tostring(value) .. suffix,
            Size = UDim2.new(0.4, -12, 1, 0),
            Position = UDim2.new(0.6, 0, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = Theme.Text3,
            Font = Enum.Font.Code,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Right,
        }, topRow)

        local track = MakeInstance("Frame", {
            Size = UDim2.new(1, -24, 0, 3),
            Position = UDim2.new(0, 12, 0, 38),
            BackgroundColor3 = Theme.BG4,
            BorderSizePixel = 0,
        }, row)
        MakeInstance("UICorner", {CornerRadius = UDim.new(1, 0)}, track)

        local fill = MakeInstance("Frame", {
            Size = UDim2.new((value-min)/(max-min), 0, 1, 0),
            BackgroundColor3 = Theme.Text,
            BorderSizePixel = 0,
        }, track)
        MakeInstance("UICorner", {CornerRadius = UDim.new(1, 0)}, fill)

        local thumb = MakeInstance("Frame", {
            Size = UDim2.new(0, 13, 0, 13),
            Position = UDim2.new((value-min)/(max-min), -6, 0.5, -6),
            BackgroundColor3 = Theme.Text,
            BorderSizePixel = 0,
            ZIndex = 2,
        }, track)
        MakeInstance("UICorner", {CornerRadius = UDim.new(1, 0)}, thumb)
        MakeInstance("UIStroke", {Color = Theme.BG2, Thickness = 2}, thumb)

        local dragging = false
        local function update(input)
            local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            value = math.floor(min + rel * (max - min) + 0.5)
            rel = (value - min) / (max - min)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            thumb.Position = UDim2.new(rel, -6, 0.5, -6)
            valLbl.Text = tostring(value) .. suffix
            callback(value)
        end

        track.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true; update(inp)
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then update(inp) end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)

        return {
            SetValue = function(v)
                value = math.clamp(v, min, max)
                local rel = (value-min)/(max-min)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                thumb.Position = UDim2.new(rel, -6, 0.5, -6)
                valLbl.Text = tostring(value) .. suffix
                callback(value)
            end,
            GetValue = function() return value end
        }
    end

    -- ── BUTTON ──
    function tab:AddButton(cfg)
        cfg = cfg or {}
        local name     = cfg.Name     or "Button"
        local callback = cfg.Callback or function() end

        local row = MakeRow(36)

        MakeInstance("TextLabel", {
            Text = name,
            Size = UDim2.new(1, -12, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = Theme.Text2,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)

        MakeInstance("TextLabel", {
            Text = "▶",
            Size = UDim2.new(0, 24, 1, 0),
            Position = UDim2.new(1, -28, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = Theme.Text3,
            Font = Enum.Font.GothamBold,
            TextSize = 10,
        }, row)

        local btn = MakeInstance("TextButton", {
            Text = "", Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2,
        }, row)

        btn.MouseButton1Click:Connect(function()
            Ripple(row)
            Tween(row, {BackgroundColor3 = Theme.BG3}, 0.05)
            task.delay(0.15, function() Tween(row, {BackgroundColor3 = Theme.BG2}, 0.1) end)
            callback()
        end)
    end

    -- ── COLOR PICKER ──
    function tab:AddColorPicker(cfg)
        cfg = cfg or {}
        local name     = cfg.Name     or "Color"
        local default  = cfg.Default  or Color3.fromRGB(255,255,255)
        local callback = cfg.Callback or function() end
        local color    = default

        local row = MakeRow(36)

        MakeInstance("TextLabel", {
            Text = name,
            Size = UDim2.new(1, -60, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = Theme.Text2,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)

        local swatch = MakeInstance("Frame", {
            Size = UDim2.new(0, 22, 0, 22),
            Position = UDim2.new(1, -34, 0.5, -11),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
        }, row)
        MakeInstance("UICorner", {CornerRadius = UDim.new(0,4)}, swatch)
        MakeInstance("UIStroke", {Color = Theme.Border2, Thickness = 1}, swatch)

        -- Picker popup
        local pickerOpen = false
        local picker = MakeInstance("Frame", {
            Size = UDim2.new(0, 200, 0, 190),
            Position = UDim2.new(0, 0, 1, 4),
            BackgroundColor3 = Theme.BG2,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 10,
        }, row)
        MakeInstance("UICorner", {CornerRadius = UDim.new(0,6)}, picker)
        MakeInstance("UIStroke", {Color = Theme.Border2, Thickness = 1}, picker)

        -- Hue/Sat square (simplified gradient)
        local hueBar = MakeInstance("Frame", {
            Size = UDim2.new(1, -16, 0, 14),
            Position = UDim2.new(0, 8, 0, 8),
            BackgroundColor3 = Color3.fromRGB(255,0,0),
            BorderSizePixel = 0, ZIndex = 11,
        }, picker)
        MakeInstance("UICorner", {CornerRadius = UDim.new(0,3)}, hueBar)
        MakeInstance("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0)),
            })
        }, hueBar)

        local hueThumb = MakeInstance("Frame", {
            Size = UDim2.new(0,3,1,4),
            Position = UDim2.new(0,-1,0,-2),
            BackgroundColor3 = Theme.Text,
            BorderSizePixel = 0, ZIndex = 12,
        }, hueBar)
        MakeInstance("UICorner", {CornerRadius = UDim.new(0,2)}, hueThumb)

        -- Saturation bar
        local satBar = MakeInstance("Frame", {
            Size = UDim2.new(1, -16, 0, 14),
            Position = UDim2.new(0, 8, 0, 30),
            BorderSizePixel = 0, ZIndex = 11,
            BackgroundColor3 = Color3.fromRGB(255,255,255),
        }, picker)
        MakeInstance("UICorner", {CornerRadius = UDim.new(0,3)}, satBar)
        local satGrad = MakeInstance("UIGradient", {
            Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(255,0,0))
        }, satBar)

        -- Value bar
        local valBar = MakeInstance("Frame", {
            Size = UDim2.new(1, -16, 0, 14),
            Position = UDim2.new(0, 8, 0, 52),
            BorderSizePixel = 0, ZIndex = 11,
            BackgroundColor3 = Color3.fromRGB(255,255,255),
        }, picker)
        MakeInstance("UICorner", {CornerRadius = UDim.new(0,3)}, valBar)
        MakeInstance("UIGradient", {
            Color = ColorSequence.new(Color3.fromRGB(0,0,0), Color3.fromRGB(255,255,255))
        }, valBar)

        local previewBox = MakeInstance("Frame", {
            Size = UDim2.new(1,-16,0,22),
            Position = UDim2.new(0,8,0,74),
            BackgroundColor3 = color, BorderSizePixel = 0, ZIndex = 11,
        }, picker)
        MakeInstance("UICorner", {CornerRadius = UDim.new(0,4)}, previewBox)

        local hexIn = MakeInstance("TextBox", {
            Text = string.format("#%02X%02X%02X", color.R*255, color.G*255, color.B*255),
            Size = UDim2.new(1,-16,0,22),
            Position = UDim2.new(0,8,0,104),
            BackgroundColor3 = Theme.BG3,
            TextColor3 = Theme.Text2,
            Font = Enum.Font.Code,
            TextSize = 11,
            BorderSizePixel = 0, ZIndex = 11,
        }, picker)
        MakeInstance("UICorner", {CornerRadius = UDim.new(0,4)}, hexIn)

        local applyBtn = MakeInstance("TextButton", {
            Text = "ПРИМЕНИТЬ",
            Size = UDim2.new(1,-16,0,22),
            Position = UDim2.new(0,8,0,134),
            BackgroundColor3 = Theme.BG4,
            TextColor3 = Theme.Text2,
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            BorderSizePixel = 0, ZIndex = 11,
        }, picker)
        MakeInstance("UICorner", {CornerRadius = UDim.new(0,4)}, applyBtn)

        local h, s, v2 = 0, 1, 1

        local function updateColor()
            color = Color3.fromHSV(h, s, v2)
            swatch.BackgroundColor3 = color
            previewBox.BackgroundColor3 = color
            hexIn.Text = string.format("#%02X%02X%02X", math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255))
            satGrad.Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromHSV(h,1,1))
        end

        -- Hue drag
        local hueDrag = false
        hueBar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag = true end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if hueDrag and inp.UserInputType == Enum.UserInputType.MouseMovement then
                h = math.clamp((inp.Position.X - hueBar.AbsolutePosition.X)/hueBar.AbsoluteSize.X,0,1)
                hueThumb.Position = UDim2.new(h,-1,0,-2)
                updateColor()
            end
            if inp.UserInputType == Enum.UserInputType.MouseMovement then
                if not hueDrag then end
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag = false end
        end)

        -- Saturation drag
        local satDrag = false
        satBar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then satDrag = true end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if satDrag and inp.UserInputType == Enum.UserInputType.MouseMovement then
                s = math.clamp((inp.Position.X - satBar.AbsolutePosition.X)/satBar.AbsoluteSize.X,0,1)
                updateColor()
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then satDrag = false end
        end)

        -- Value drag
        local valDrag = false
        valBar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then valDrag = true end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if valDrag and inp.UserInputType == Enum.UserInputType.MouseMovement then
                v2 = math.clamp((inp.Position.X - valBar.AbsolutePosition.X)/valBar.AbsoluteSize.X,0,1)
                updateColor()
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then valDrag = false end
        end)

        applyBtn.MouseButton1Click:Connect(function()
            callback(color)
            picker.Visible = false
            pickerOpen = false
        end)

        local openBtn = MakeInstance("TextButton", {
            Text = "", Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 3,
        }, row)
        openBtn.MouseButton1Click:Connect(function()
            pickerOpen = not pickerOpen
            picker.Visible = pickerOpen
        end)

        return {
            SetColor = function(c)
                color = c; swatch.BackgroundColor3 = c
                h, s, v2 = Color3.toHSV(c)
                updateColor()
            end,
            GetColor = function() return color end
        }
    end

    -- ── DROPDOWN ──
    function tab:AddDropdown(cfg)
        cfg = cfg or {}
        local name     = cfg.Name     or "Dropdown"
        local options  = cfg.Options  or {}
        local default  = cfg.Default  or (options[1] or "")
        local callback = cfg.Callback or function() end
        local selected = default
        local isOpen   = false

        local row = MakeRow(36)

        MakeInstance("TextLabel", {
            Text = name,
            Size = UDim2.new(0.45, 0, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = Theme.Text2,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)

        local valBox = MakeInstance("Frame", {
            Size = UDim2.new(0.5, -12, 0, 24),
            Position = UDim2.new(0.5, 0, 0.5, -12),
            BackgroundColor3 = Theme.BG3,
            BorderSizePixel = 0,
        }, row)
        MakeInstance("UICorner", {CornerRadius = UDim.new(0,4)}, valBox)
        MakeInstance("UIStroke", {Color = Theme.Border2, Thickness = 0.5}, valBox)

        local valLbl = MakeInstance("TextLabel", {
            Text = selected,
            Size = UDim2.new(1,-20,1,0),
            Position = UDim2.new(0,8,0,0),
            BackgroundTransparency = 1,
            TextColor3 = Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, valBox)

        MakeInstance("TextLabel", {
            Text = "▾",
            Size = UDim2.new(0,16,1,0),
            Position = UDim2.new(1,-18,0,0),
            BackgroundTransparency = 1,
            TextColor3 = Theme.Text3,
            Font = Enum.Font.GothamBold,
            TextSize = 10,
        }, valBox)

        -- Dropdown list
        local list = MakeInstance("Frame", {
            Size = UDim2.new(0.5, -12, 0, #options * 26 + 4),
            Position = UDim2.new(0.5, 0, 1, 2),
            BackgroundColor3 = Theme.BG3,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 20,
        }, row)
        MakeInstance("UICorner", {CornerRadius = UDim.new(0,4)}, list)
        MakeInstance("UIStroke", {Color = Theme.Border2, Thickness = 0.5}, list)
        MakeInstance("UIPadding", {PaddingTop = UDim.new(0,2), PaddingBottom = UDim.new(0,2)}, list)
        MakeInstance("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}, list)

        for i, opt in ipairs(options) do
            local optBtn = MakeInstance("TextButton", {
                Text = opt,
                Size = UDim2.new(1,0,0,26),
                BackgroundTransparency = 1,
                TextColor3 = opt == selected and Theme.Text or Theme.Text2,
                Font = Enum.Font.Gotham,
                TextSize = 10,
                BorderSizePixel = 0,
                LayoutOrder = i,
                ZIndex = 21,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, list)
            MakeInstance("UIPadding", {PaddingLeft = UDim.new(0,8)}, optBtn)

            optBtn.MouseButton1Click:Connect(function()
                selected = opt
                valLbl.Text = opt
                list.Visible = false
                isOpen = false
                callback(opt)
            end)
            optBtn.MouseEnter:Connect(function()
                Tween(optBtn, {BackgroundTransparency = 0.85}, 0.1)
                optBtn.BackgroundColor3 = Theme.BG4
            end)
            optBtn.MouseLeave:Connect(function()
                Tween(optBtn, {BackgroundTransparency = 1}, 0.1)
            end)
        end

        local openBtn = MakeInstance("TextButton", {
            Text = "", Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5,
        }, row)
        openBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            list.Visible = isOpen
        end)

        return {
            SetValue = function(v)
                selected = v; valLbl.Text = v; callback(v)
            end,
            GetValue = function() return selected end
        }
    end

    -- ── TEXTBOX ──
    function tab:AddTextbox(cfg)
        cfg = cfg or {}
        local name     = cfg.Name     or "Textbox"
        local default  = cfg.Default  or ""
        local callback = cfg.Callback or function() end

        local row = MakeRow(36)

        MakeInstance("TextLabel", {
            Text = name,
            Size = UDim2.new(0.4, 0, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = Theme.Text2,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)

        local box = MakeInstance("TextBox", {
            Text = default,
            PlaceholderText = "Введи текст...",
            Size = UDim2.new(0.55, -12, 0, 24),
            Position = UDim2.new(0.45, 0, 0.5, -12),
            BackgroundColor3 = Theme.BG3,
            TextColor3 = Theme.Text,
            PlaceholderColor3 = Theme.Text3,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            BorderSizePixel = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
        }, row)
        MakeInstance("UICorner", {CornerRadius = UDim.new(0,4)}, box)
        MakeInstance("UIStroke", {Color = Theme.Border2, Thickness = 0.5}, box)
        MakeInstance("UIPadding", {PaddingLeft = UDim.new(0,8)}, box)

        box.FocusLost:Connect(function(enter)
            if enter then callback(box.Text) end
        end)

        return {GetValue = function() return box.Text end}
    end

    -- ── KEYBIND ──
    function tab:AddKeybind(cfg)
        cfg = cfg or {}
        local name     = cfg.Name     or "Keybind"
        local default  = cfg.Default  or Enum.KeyCode.Unknown
        local callback = cfg.Callback or function() end
        local key      = default
        local listening = false

        local row = MakeRow(36)

        MakeInstance("TextLabel", {
            Text = name,
            Size = UDim2.new(1, -90, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = Theme.Text2,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)

        local keyBox = MakeInstance("Frame", {
            Size = UDim2.new(0, 72, 0, 22),
            Position = UDim2.new(1, -82, 0.5, -11),
            BackgroundColor3 = Theme.BG3,
            BorderSizePixel = 0,
        }, row)
        MakeInstance("UICorner", {CornerRadius = UDim.new(0,4)}, keyBox)
        MakeInstance("UIStroke", {Color = Theme.Border2, Thickness = 0.5}, keyBox)

        local keyLbl = MakeInstance("TextLabel", {
            Text = key.Name,
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            TextColor3 = Theme.Text2,
            Font = Enum.Font.Code,
            TextSize = 10,
        }, keyBox)

        local btn = MakeInstance("TextButton", {
            Text = "", Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 3,
        }, row)

        btn.MouseButton1Click:Connect(function()
            listening = true
            keyLbl.Text = "..."
            Tween(keyBox, {BackgroundColor3 = Theme.BG4}, 0.1)
        end)

        UserInputService.InputBegan:Connect(function(inp, gp)
            if listening and not gp then
                if inp.UserInputType == Enum.UserInputType.Keyboard then
                    key = inp.KeyCode
                    keyLbl.Text = key.Name
                    Tween(keyBox, {BackgroundColor3 = Theme.BG3}, 0.1)
                    listening = false
                    callback(key)
                end
            end
        end)

        return {GetKey = function() return key end}
    end

    -- ── LABEL ──
    function tab:AddLabel(text)
        local row = MakeRow(28)
        row.BackgroundTransparency = 1

        MakeInstance("TextLabel", {
            Text = text,
            Size = UDim2.new(1, -24, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = Theme.Text3,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
    end

    -- ── SEPARATOR ──
    function tab:AddSeparator()
        local sep = MakeInstance("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = Theme.Border,
            BorderSizePixel = 0,
            LayoutOrder = nextOrder(),
        }, tabFrame)
    end

    return tab
end

-- Notification
function Nexus:Notify(cfg)
    cfg = cfg or {}
    local title    = cfg.Title    or "Уведомление"
    local text     = cfg.Text     or ""
    local duration = cfg.Duration or 3

    local gui = MakeInstance("ScreenGui", {
        Name = "NexusNotif",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, (pcall(function() return CoreGui end) and CoreGui or LocalPlayer.PlayerGui))

    local notif = MakeInstance("Frame", {
        Size = UDim2.new(0, 260, 0, 60),
        Position = UDim2.new(1, 10, 1, -70),
        BackgroundColor3 = Theme.BG2,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 1),
    }, gui)
    MakeInstance("UICorner", {CornerRadius = UDim.new(0,6)}, notif)
    MakeInstance("UIStroke", {Color = Theme.Border2, Thickness = 1}, notif)

    MakeInstance("Frame", {
        Size = UDim2.new(0, 3, 0.7, 0),
        Position = UDim2.new(0, 0, 0.15, 0),
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0,
    }, notif)

    MakeInstance("TextLabel", {
        Text = title,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, notif)

    MakeInstance("TextLabel", {
        Text = text,
        Size = UDim2.new(1, -20, 0, 18),
        Position = UDim2.new(0, 14, 0, 30),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text3,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, notif)

    Tween(notif, {Position = UDim2.new(1, -10, 1, -70)}, 0.3)

    task.delay(duration, function()
        Tween(notif, {Position = UDim2.new(1, 280, 1, -70)}, 0.3)
        task.delay(0.35, function() gui:Destroy() end)
    end)
end

return Nexus
