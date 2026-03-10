# 开发环境搭建

> 配置魔兽世界Retail插件开发环境

## 目录结构

魔兽世界插件目录位于：

```
# Windows
C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\

# macOS
/Applications/World of Warcraft/_retail_/Interface/AddOns/
```

### 推荐的项目目录结构

```
MyAddon/
├── MyAddon.toc      # 配置文件（必需）
├── MyAddon.lua      # 主入口文件
├── Libs/            # 第三方库
│   └── LibStub/
├── Modules/         # 功能模块
│   └── *.lua
└── Loca/            # 本地化
    ├── enUS.lua
    └── zhCN.lua
```

## VS Code 配置

### 安装扩展

推荐安装以下 VS Code 扩展：

1. **Lua** - sumneko.lua
   - Lua 语言服务器
   - 代码补全、语法检查

2. **WoW Bundle** - Septh.wow-bundle
   - 魔兽世界 API 补全
   - 事件、API 自动提示

### 工作区配置

创建 `.vscode/settings.json`:

```json
{
    "Lua.diagnostics.globals": [
        "GameTooltip",
        "UIParent",
        "CreateFrame",
        "RegisterEvent",
        "C_QuestLog",
        "C_Map",
        "C_Timer",
        "C_CurrencyInfo",
        "C_TaskQuest",
        "EventRegistry",
        "CreateObjectPool",
        "CreateFromMixins",
        "Mixin",
        "wipe",
        "strsplit",
        "GetBuildInfo"
    ],
    "Lua.workspace.library": [
        "./_retail_/Interface/FrameXML"
    ],
    "files.encoding": "utf8",
    "files.eol": "\n"
}
```

### API 补全配置

安装 WoW API 类型定义：

```bash
# 克隆 WoW API 定义到项目
git clone https://github.com/Ketho/vscode-wow-api .vscode/wow-api
```

更新 `settings.json`:

```json
{
    "Lua.workspace.library": [
        ".vscode/wow-api/EmmyLua"
    ]
}
```

## 开发流程

### 1. 创建符号链接

创建从项目到游戏目录的符号链接：

```powershell
# Windows PowerShell (以管理员运行)
New-Item -ItemType SymbolicLink -Path "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\MyAddon" -Target "N:\code-temp\addon_retail\addons\MyAddon"
```

```bash
# macOS/Linux
ln -s /path/to/your/project/MyAddon /Applications/World\ of\ Warcraft/_retail_/Interface/AddOns/MyAddon
```

### 2. 开发循环

1. 编辑代码
2. 保存文件
3. 在游戏中执行 `/reload` 重新加载

### 3. 快速重载

创建宏绑定快捷键：

```
/reload
```

或使用插件:
- **AddonLoader** - 自动重载
- **DevTools** - 开发者工具

## 游戏内置工具

### 控制台命令

```
/console scriptErrors 1    # 显示 Lua 错误
/console scriptProfile 1   # 启用脚本性能分析
```

### 开发者工具

按 `Esc` → 选项 → 帮助 → 显示 Lua 错误

### Slash 命令

```lua
-- 在插件中注册 slash 命令
SLASH_MYADDON1 = "/myaddon"
SLASH_MYADDON2 = "/ma"

SlashCmdList["MYADDON"] = function(msg)
    print("MyAddon command:", msg)
end
```

## 调试技巧

### 使用 print 调试

```lua
print("Debug:", variable, table.concat(tbl, ", "))
```

### 使用 DevTools

安装 **Blizzard Development Tools**:

```
/run DevTools_Dump({ key = "value" })
/run DevTools_RunSnippet("print(GetTime())")
```

### 错误追踪

```lua
-- 安全调用
local success, err = pcall(function()
    -- 可能出错的代码
end)
if not success then
    print("Error:", err)
end

-- 使用 xpcall 获取堆栈
local function errorHandler(err)
    return debug.traceback(err)
end

local success, err = xpcall(function()
    -- 代码
end, errorHandler)
```

## 项目模板

参考项目中的模板目录：

- `templates/basic-addon/` - 基础插件模板
- `templates/ace3-addon/` - Ace3 框架模板

### 使用模板

复制模板目录到游戏 AddOns 目录，重命名并修改：

1. 文件夹名称
2. TOC 文件名称
3. TOC 内的 Title
4. Lua 文件中的命名空间

## 常见问题

### Q: 代码修改后没有生效？

确保：
1. 文件已保存
2. 执行了 `/reload`
3. 插件已启用（角色选择界面 → 插件）

### Q: 找不到 API 定义？

检查：
1. VS Code 扩展已安装
2. `settings.json` 中已配置 globals
3. 重启 VS Code

### Q: 中文显示乱码？

确保文件编码为 UTF-8：

```json
// settings.json
{
    "files.encoding": "utf8"
}
```

## 相关链接

- [第一个插件](02-first-addon.md)
- [调试技巧](04-debugging.md)
- [Warcraft Wiki - API](https://warcraft.wiki.gg/wiki/World_of_Warcraft_API)
