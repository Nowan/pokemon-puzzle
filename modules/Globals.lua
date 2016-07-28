--[[

	Stores global values

]]--

local current_path = debug.getinfo(1).source; -- path to current script
local current_dir = string.match(string.sub(current_path,2), "(.-)([^\\]-([^%.]+))$"); -- path to current directory (modules)
package.path = package.path..";"..current_dir.."?.lua" -- include all modules to the path

content = {};
content.width = display.contentWidth;
content.height = display.contentHeight;
content.centerX = display.contentCenterX;
content.centerY = display.contentCenterY;
content.screenHeight = display.pixelWidth*(content.width/display.pixelHeight);