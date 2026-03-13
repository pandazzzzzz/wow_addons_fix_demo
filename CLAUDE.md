# CLAUDE.md

## 项目说明

魔兽世界正式服（Retail）插件开发项目。

## API文档来源

### 官方资源

- 游戏内置源码: `_retail_/Interface/FrameXML/`
- Gethe/wow-ui-source: https://github.com/Gethe/wow-ui-source
- wago.tools: https://wago.tools

### 社区资源

- Warcraft Wiki: https://warcraft.wiki.gg
- CurseForge: https://www.curseforge.com/wow/addons

## 开发规范

### TOC版本号

```
## Interface: 120001  # Midnight (12.x)
```

### 核心模式

**帧池** - 内存复用
**Mixin** - 面向对象封装
**EventRegistry** - 现代事件系统（优于传统frame:RegisterEvent）

### 常用API命名空间

**核心**: `C_QuestLog` `C_Map` `C_Timer` `C_SuperTrack` `C_CVar`
**Midnight新增**: `C_Housing` `C_DamageMeter` `C_EncounterTimeline`

### 关键注意事项

1. 战斗锁定 - 部分操作无法在战斗中进行
2. 内存优化 - 避免在OnUpdate中创建表
3. 版本检测 - `select(4, GetBuildInfo())`

### 第三方库

LibStub, AceAddon-3.0, AceDB-3.0

### API变更 (Midnight 12.x)

参考: [Patch 12.0.1/API changes](https://warcraft.wiki.gg/wiki/Patch_12.0.1/API_changes)

#### 已移除的API
- `BNSetAFK`/`BNSetDND` → 使用 `C_BattleNet.SetAFK`/`SetDND`
- `GetCurrentGraphicsSetting`/`SetCurrentGraphicsSetting` 已移除
- `C_NamePlate.GetTargetClampingInsets`/`SetTargetClampingInsets` 已移除

#### 新增API命名空间
- `C_DamageMeter` - 伤害统计 ([文档](docs/api-reference/namespaces/C_DamageMeter.md))
- `C_EncounterTimeline` - 遭遇战时间轴 ([文档](docs/api-reference/namespaces/C_EncounterTimeline.md))
- `C_EncounterEvents` - 遭遇战事件 ([文档](docs/api-reference/namespaces/C_EncounterEvents.md))
- `C_EncounterWarnings` - 遭遇战警告
- `C_HousingPhotoSharing` - 房屋照片分享 ([文档](docs/api-reference/namespaces/C_HousingPhotoSharing.md))
- `C_CombatAudioAlert` - 战斗音频警报

#### 新增全局函数
- `GetNumTotemSlots()` - 获取图腾槽位数量
- `dumpobject(obj)` - 调试对象转储

#### 参数变更
- `C_DamageMeter.GetCombatSessionSourceFromID` - `sourceGUID` 变为可选，新增 `sourceCreatureID`
- `C_StringUtil.StripHyperlinks` - 新增 `maintainTextures` 参数
- `UnitCastingInfo` - 新增返回值 `delayTimeMs`

#### 新增事件
- `ENCOUNTER_TIMELINE_VIEW_ACTIVATED`/`DEACTIVATED`
- `PHOTO_SHARING_AUTHORIZATION_NEEDED`/`UPDATED`/`PHOTO_UPLOAD_STATUS`/`SCREENSHOT_READY`
- `PLAYER_MAX_LEVEL_UPDATE`

#### 已移除事件
- `CHAT_MSG_ENCOUNTER_EVENT`
