#魔兽世界插件开发模板库

本项目包含魔兽世界正式服（Retail）插件开发的完整指南和实用模板。

## 目录结构

```
addon_retail/
├── docs/
│   ├── WoW_ADDON_DEVELOPMENT_GUIDE.md   # 完整开发指南
│   └── QUICK_REFERENCE.md                # 快速参考卡
├── templates/
│   ├── basic-addon/                      # 基础插件模板
│   │   ├── MyAddon.toc
│   │   ├── MyAddon.lua
│   │   └── MyAddon.xml
│   ├── ace3-addon/                       # Ace3框架模板
│   │   ├── MyAceAddon.toc
│   │   └── MyAceAddon.lua
│   └── examples/                         # 功能示例代码
│       ├── FramePoolExample.lua
│       └── QuestTrackerExample.lua
└── README.md
```

## 快速开始

### 1. 选择模板

- **basic-addon**: 适合简单插件，不依赖第三方库
- **ace3-addon**: 适合复杂插件，使用Ace3框架提供更多功能

### 2. 复制到游戏目录

将选择的模板文件夹复制到：
```
World of Warcraft/_retail_/Interface/AddOns/
```

### 3. 重命名

将文件夹和文件中的 `MyAddon` 或 `MyAceAddon` 替换为你的插件名。

### 4. 修改 TOC

编辑 `.toc` 文件，更新：
- `Interface`: 当前版本号（使用 `/dump select(4, GetBuildInfo())` 查询）
- `Title`: 插件名称
- `Notes`: 插件描述
- `Author`: 作者名
- `Version`: 版本号

### 5. 测试

进入游戏，使用 `/reload` 测试更改。

## 学习资源

### 官方资源
- 游戏内置源码: `_retail_/Interface/FrameXML/`
- API文档: `_retail_/Interface/FrameXML/APIDocumentation/`

### 社区资源
- [Wowpedia](https://wowpedia.fandom.com) - 最全面的API文档
- [WoW Programming](https://wowprogramming.com) - 经典教程
- [CurseForge](https://www.curseforge.com/wow/addons) - 插件发布平台

## 开发工具

### 推荐 VS Code 扩展
- Lua Language Server (sumneko.lua)
- WoW API (WoW开发API提示)
- XML Tools

### 游戏内调试工具
- BugSack - 错误收集
- BugGrabber - 错误捕获

## 常用命令

```lua
/reload                    -- 重载UI
/dump var                  -- 打印变量
/fstack                    -- 显示帧层级
/console scriptErrors 1    -- 启用错误显示
```

## 注意事项

1. **战斗锁定**: 部分操作无法在战斗中执行，使用 `InCombatLockdown()` 检查
2. **安全代码**: `secure`属性的按钮有特殊限制
3. **性能优化**: 避免在OnUpdate中创建表，使用帧池
4. **版本兼容**: 使用 `select(4, GetBuildInfo())` 检测版本

## 许可证

此模板库仅供学习参考使用。
