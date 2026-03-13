# C_DamageMeter API

## 概述

伤害统计系统API，用于获取战斗中的伤害、治疗等统计信息。

## 函数

### GetSessionDurationSeconds

获取当前战斗统计会话持续时间（秒）。

```lua
local seconds = C_DamageMeter.GetSessionDurationSeconds()
```

**返回值：**
- `seconds` (number) - 会话持续时间（秒）

---

### GetCombatSessionSourceFromID

根据ID获取战斗会话源信息。

```lua
local info = C_DamageMeter.GetCombatSessionSourceFromID(
    combatSessionID,
    sourceType,
    sourceGUID,        -- 可选 (12.0.1变更)
    sourceCreatureID   -- 12.0.1新增参数
)
```

**参数：**
- `combatSessionID` (number) - 战斗会话ID
- `sourceType` (Enum.DamageMeterEntityType) - 源类型
- `sourceGUID` (string, 可选) - 源GUID (12.0.1变更为可选)
- `sourceCreatureID` (number, 12.0.1新增) - 源生物ID

**返回值：**
- `info` (CombatSessionSourceInfo) - 战斗会话源信息

---

### GetCombatSessionSourceFromType

根据类型获取战斗会话源信息。

```lua
local info = C_DamageMeter.GetCombatSessionSourceFromType(
    combatSessionID,
    sourceType,
    sourceGUID,        -- 可选 (12.0.1变更)
    sourceCreatureID   -- 12.0.1新增参数
)
```

**参数：**
- `combatSessionID` (number) - 战斗会话ID
- `sourceType` (Enum.DamageMeterEntityType) - 源类型
- `sourceGUID` (string, 可选) - 源GUID
- `sourceCreatureID` (number, 12.0.1新增) - 源生物ID

**返回值：**
- `info` (CombatSessionSourceInfo) - 战斗会话源信息

---

## 数据结构

### CombatSessionSourceInfo

```lua
{
    name = "PlayerName",
    guid = "Player-XXX-XXXX",
    damage = 123456,
    healing = 78901,
}
```

### Enum.DamageMeterEntityType

| 值 | 说明 |
|----|------|
| `Player` | 玩家 |
| `Pet` | 宠物 |
| `Guardian` | 守护者 |

## 使用示例

```lua
-- 获取当前会话时长
local duration = C_DamageMeter.GetSessionDurationSeconds()
print("当前战斗已进行: " .. duration .. " 秒")

-- 获取战斗会话源信息
local info = C_DamageMeter.GetCombatSessionSourceFromID(
    sessionID,
    Enum.DamageMeterEntityType.Player
)
if info then
    print("玩家伤害: " .. info.damage)
end
```

## 相关链接

- [C_EncounterTimeline](C_EncounterTimeline.md) - 遭遇战时间轴API
- [Warcraft Wiki - DamageMeter](https://warcraft.wiki.gg)
