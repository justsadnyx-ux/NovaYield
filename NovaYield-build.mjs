/**
 * NovaYield Builder
 * Reads the full Infinite Yield source and applies UI customizations directly.
 * Outputs a single Lua file with all 400+ commands and a custom UI.
 */

import { readFileSync, writeFileSync } from 'fs';

// Read the original IY source
const source = readFileSync('C:\\Users\\Student\\.local\\share\\opencode\\tool-output\\tool_0f98b0509001C5UE5uKdN6flPL', 'utf8');

let output = source;

// ============================================================
// 1. CHANGE LOADED CHECK
// ============================================================
output = output.replace(
    'if IY_LOADED and not _G.IY_DEBUG then',
    'if NOVA_LOADED and not _G.NOVA_DEBUG then'
);
output = output.replace(
    'pcall(function() getgenv().IY_LOADED = true end)',
    'pcall(function() getgenv().NOVA_LOADED = true end)'
);

// ============================================================
// 2. CHANGE VERSION
// ============================================================
output = output.replace(
    'currentVersion = "6.4.2"',
    'currentVersion = "1.0.0"'
);

// ============================================================
// 3. CHANGE TITLE TEXT
// ============================================================
output = output.replace(
    'Title.Text = "Infinite Yield FE v" .. currentVersion',
    'Title.Text = "  NovaYield v" .. currentVersion'
);

// ============================================================
// 4. CHANGE CREDITS
// ============================================================
output = output.replace(
    'Credits.Text = "Edge // Zwolf // Moon // Toon // Peyton // ATP"',
    'Credits.Text = "NovaYield UI // Based on IY by Edge // Zwolf // Moon // Toon // Peyton // ATP"'
);

// ============================================================
// 5. CHANGE FONTS (SourceSans -> Gotham)
// ============================================================
output = output.replaceAll('Enum.Font.SourceSansBold', 'Enum.Font.GothamBold');
output = output.replaceAll('Enum.Font.SourceSansLight', 'Enum.Font.GothamLight');
output = output.replaceAll('Enum.Font.SourceSansItalic', 'Enum.Font.GothamItalic');
output = output.replaceAll('Enum.Font.SourceSansSemibold', 'Enum.Font.GothamMedium');
output = output.replaceAll('Enum.Font.SourceSans', 'Enum.Font.Gotham');

// ============================================================
// 6. CHANGE COLORS - "Midnight Aurora" theme
// ============================================================

// Original colors:
// shade1 (darkest): Color3.fromRGB(36, 36, 37) -> Color3.fromRGB(18, 21, 32)
// shade2 (medium):  Color3.fromRGB(46, 46, 47) -> Color3.fromRGB(28, 32, 48)
// shade3 (light):   Color3.fromRGB(78, 78, 79) -> Color3.fromRGB(42, 48, 72)
// text1 (primary):  Color3.new(1, 1, 1)      -> Color3.fromRGB(240, 245, 255)
// text2 (secondary): Color3.new(0, 0, 0)      -> Color3.fromRGB(10, 12, 18)
// scrollbar:        Color3.fromRGB(78,78,79)  -> Color3.fromRGB(50, 58, 88)

// Replace all shade1 colors (36, 36, 37)
output = output.replaceAll('Color3.fromRGB(36, 36, 37)', 'Color3.fromRGB(18, 21, 37)');
output = output.replaceAll('Color3.new(0.14117647707462,0.14117647707462,0.14509804546833)', 'Color3.fromRGB(18, 21, 32)');

// Replace all shade2 colors (46, 46, 47)
output = output.replaceAll('Color3.fromRGB(46, 46, 47)', 'Color3.fromRGB(28, 32, 48)');
output = output.replaceAll('Color3.new(0.1803921610117,0.1803921610117,0.1843137294054)', 'Color3.fromRGB(28, 32, 48)');

// Replace all shade3 colors (78, 78, 79)
output = output.replaceAll('Color3.fromRGB(78, 78, 79)', 'Color3.fromRGB(42, 48, 72)');
output = output.replaceAll('Color3.new(0.30588236451149,0.30588236451149,0.3098039329052)', 'Color3.fromRGB(42, 48, 72)');

// Replace scrollbar colors
output = output.replaceAll('Color3.fromRGB(78,78,79)', 'Color3.fromRGB(50, 58, 88)');

// Replace text colors
output = output.replaceAll('Color3.new(1, 1, 1)', 'Color3.fromRGB(240, 245, 255)');
output = output.replaceAll('Color3.new(0, 0, 0)', 'Color3.fromRGB(10, 12, 18)');

// ============================================================
// 7. CHANGE DEFAULT SETTINGS COLORS
// ============================================================
output = output.replace(
    'currentShade1 = Color3.fromRGB(36, 36, 37)',
    'currentShade1 = Color3.fromRGB(18, 21, 32)'
);
output = output.replace(
    'currentShade2 = Color3.fromRGB(46, 46, 47)',
    'currentShade2 = Color3.fromRGB(28, 32, 48)'
);
output = output.replace(
    'currentShade3 = Color3.fromRGB(78, 78, 79)',
    'currentShade3 = Color3.fromRGB(42, 48, 72)'
);
output = output.replace(
    'currentText1 = Color3.new(1, 1, 1)',
    'currentText1 = Color3.fromRGB(240, 245, 255)'
);
output = output.replace(
    'currentText2 = Color3.new(0, 0, 0)',
    'currentText2 = Color3.fromRGB(10, 12, 18)'
);
output = output.replace(
    'currentScroll = Color3.fromRGB(78,78,79)',
    'currentScroll = Color3.fromRGB(50, 58, 88)'
);

// ============================================================
// 8. CHANGE DEFAULT THEME IN COLOR PICKER
// ============================================================
output = output.replace(
    'updateColors(Color3.fromRGB(36, 36, 37),shade1)',
    'updateColors(Color3.fromRGB(18, 21, 32),shade1)'
);
output = output.replace(
    'updateColors(Color3.fromRGB(46, 46, 47),shade2)',
    'updateColors(Color3.fromRGB(28, 32, 48),shade2)'
);
output = output.replace(
    'updateColors(Color3.fromRGB(78, 78, 79),shade3)',
    'updateColors(Color3.fromRGB(42, 48, 72),shade3)'
);
output = output.replace(
    'updateColors(Color3.new(1, 1, 1),text1)',
    'updateColors(Color3.fromRGB(240, 245, 255),text1)'
);
output = output.replace(
    'updateColors(Color3.new(0, 0, 0),text2)',
    'updateColors(Color3.fromRGB(10, 12, 18),text2)'
);
output = output.replace(
    'updateColors(Color3.fromRGB(78,78,79),scroll)',
    'updateColors(Color3.fromRGB(50, 58, 88),scroll)'
);

// ============================================================
// 9. ADD ACCENT ELEMENTS AFTER TITLE
// ============================================================
const accentElements = `
-- NovaYield accent elements
local NovaTopAccent = Instance.new("Frame")
NovaTopAccent.Name = "NovaTopAccent"
NovaTopAccent.Parent = Holder
NovaTopAccent.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
NovaTopAccent.BorderSizePixel = 0
NovaTopAccent.Position = UDim2.new(0, 0, 0, 0)
NovaTopAccent.Size = UDim2.new(1, 0, 0, 2)
NovaTopAccent.ZIndex = 11

local NovaBottomAccent = Instance.new("Frame")
NovaBottomAccent.Name = "NovaBottomAccent"
NovaBottomAccent.Parent = Holder
NovaBottomAccent.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
NovaBottomAccent.BorderSizePixel = 0
NovaBottomAccent.Position = UDim2.new(0, 0, 1, -2)
NovaBottomAccent.Size = UDim2.new(1, 0, 0, 2)
NovaBottomAccent.ZIndex = 11

`;

// Insert after the Title section
output = output.replace(
    'table.insert(text1,Title)\n\nDark.Name = "Dark"',
    'table.insert(text1,Title)\n' + accentElements + '\nDark.Name = "Dark"'
);

// ============================================================
// 10. ADD HOVER EFFECTS TO SETTINGS BUTTONS
// ============================================================
const hoverEffects = `
-- NovaYield hover effects
local function addHoverEffect(btn)
    if btn and btn:IsA("TextButton") then
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(58, 66, 96)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(28, 32, 48)
        end )
    end
end

if ColorsButton then addHoverEffect(ColorsButton) end
if Keybinds then addHoverEffect(Keybinds) end
if Aliases then addHoverEffect(Aliases) end
if Positions then addHoverEffect(Positions) end
if Plugins then addHoverEffect(Plugins) end
if EventBind then addHoverEffect(EventBind) end

`;

// Insert after the settings buttons are created
output = output.replace(
    'Plugins.Parent = SettingsHolder\n\nExample.Name = "Example"',
    'Plugins.Parent = SettingsHolder\n' + hoverEffects + '\nExample.Name = "Example"'
);

// ============================================================
// 11. ADD HOVER EFFECTS TO COMMAND BUTTONS
// ============================================================
const cmdHoverEffects = `
-- NovaYield command button hover effects
local function addCmdHoverEffect(btn)
    if btn and btn:IsA("TextButton") then
        btn.BackgroundColor3 = Color3.fromRGB(28, 32, 48)
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(58, 66, 96)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(28, 32, 48)
        end)
    end
end

for _, child in pairs(CMDsF:GetChildren()) do
    if child:IsA("TextButton") then
        addCmdHoverEffect(child)
    end
end

`;

// Insert after command buttons are created
output = output.replace(
    'IndexContents("", true)\n\nfunction checkTT()',
    'IndexContents("", true)\n' + cmdHoverEffects + '\nfunction checkTT()'
);

// ============================================================
// 12. ADD WELCOME NOTIFICATION
// ============================================================
const welcomeScript = `
-- NovaYield welcome notification
task.spawn(function()
    task.wait(2)
    notify("NovaYield", "Welcome! Press " .. prefix .. " to open the command bar.\\nTheme: Midnight Aurora\\nBased on Infinite Yield by Edge // Zwolf // Moon // Toon // Peyton // ATP", 5)
end)

`;

// Insert at the very end
output = output + welcomeScript;

// ============================================================
// 13. ADD HEADER COMMENT
// ============================================================
const header = `--[[
    ============================================================
    NovaYield v1.0.0 - Custom UI Fork of Infinite Yield
    ============================================================
    
    Original Infinite Yield by:
        Edge // Zwolf // Moon // Sleaze // Toon // Peyton // ATP
    https://github.com/EdgeIY/infiniteyield
    
    This is a FULL fork with all 400+ commands preserved.
    Only the visual layer (colors, layout, name, credits) has been modified.
    
    Theme: "Midnight Aurora" - Deep navy + cyan/violet accents
    ============================================================
]]

`;

output = header + output;

// ============================================================
// WRITE OUTPUT
// ============================================================

writeFileSync('C:\\Users\\Student\\Downloads\\SWB\\scratch\\novayield-custom.lua', output, 'utf8');

console.log('NovaYield custom build complete!');
console.log('Output: scratch/novayield-custom.lua');
console.log('Lines:', output.split('\n').length);
