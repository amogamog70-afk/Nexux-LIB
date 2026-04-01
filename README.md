[README.md](https://github.com/user-attachments/files/26398605/README.md)
# NEXUS UI Library

Чёрно-белая UI-библиотека для Roblox.  
Широкий интерфейс с боковой панелью, поддержкой конфигов, слайдерами, color picker'ом и хоткеями.

## Быстрый старт

```lua
local Nexus = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/YOURNAME/NexusLib/main/NexusLib.lua"
))()

local Window = Nexus:CreateWindow({
    Title = "My Hub",
    Key   = Enum.KeyCode.F9,
})

local Tab = Window:AddTab("Главная")
Tab:AddToggle({ Name = "Noclip", Callback = function(v) end })
Tab:AddSlider({ Name = "Speed", Min=1, Max=200, Default=16, Callback=function(v)end })
```

## Элементы

| Метод | Описание |
|---|---|
| `Tab:AddToggle({})` | Вкл/выкл переключатель |
| `Tab:AddSlider({})` | Слайдер с числом |
| `Tab:AddButton({})` | Кнопка с ripple-эффектом |
| `Tab:AddColorPicker({})` | Выбор цвета (HSV + HEX) |
| `Tab:AddDropdown({})` | Выпадающий список |
| `Tab:AddTextbox({})` | Поле ввода текста |
| `Tab:AddKeybind({})` | Привязка клавиши |
| `Tab:AddLabel(text)` | Текстовая метка |
| `Tab:AddSeparator()` | Разделитель |
| `Nexus:Notify({})` | Уведомление (тост) |

## Параметры окна

```lua
Nexus:CreateWindow({
    Title   = "Hub Name",      -- название
    SubText = "v1.0",          -- подпись (справа от названия)
    Key     = Enum.KeyCode.F9, -- клавиша показать/скрыть
    Size    = UDim2.new(0,620,0,420), -- размер
})
```

## Примеры элементов

```lua
-- Слайдер
Tab:AddSlider({
    Name     = "WalkSpeed",
    Min      = 1, Max = 200, Default = 16,
    Suffix   = "",   -- добавляется после числа
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

-- Color Picker
Tab:AddColorPicker({
    Name     = "Accent",
    Default  = Color3.fromRGB(255, 255, 255),
    Callback = function(color)
        print(color)
    end
})

-- Keybind
Tab:AddKeybind({
    Name     = "Sprint",
    Default  = Enum.KeyCode.LeftShift,
    Callback = function(key) print(key.Name) end
})

-- Уведомление
Nexus:Notify({
    Title    = "Загружено",
    Text     = "Библиотека готова к работе",
    Duration = 3,
})
```

## Загрузка на GitHub

1. Создай репозиторий `NexusLib`
2. Загрузи `NexusLib.lua`
3. Открой файл → нажми **Raw** → скопируй ссылку
4. Вставь в `game:HttpGet("...")`
