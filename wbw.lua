local Start = tick() --启动用
local ui = loadstring(game:HttpGet("https://pastebin.com/raw/3vQb4DJh"))() -- 显示脚本的UI库
local win = ui:new("脚本名称")

local UITab1 = win:Tab("📢 公告", "7734068321") -- 左侧边栏分类
local UITab2 = win:Tab("⚙️ 通用", "7734068321") -- 左侧边栏分类
local UITab3 = win:Tab("📝 其他文本", "7734068321") -- 左侧边栏分类

local about = UITab1:section("📢 公告",true) -- 分类内功能分类
about:Label("测试脚本")
about:Label("文本")

local about = UITab2:section("⚡ 功能",true) -- 分类内功能分类
about:Slider --（滑块输入类）
end)

about:Toggle --（开关类）
end)

about:Button("启动别的功能或脚本",function() --（单点类）
loadstring(game:HttpGet('脚本链接'))()
end)