# C_Map 命名空间

> 地图 API 参考
> 权威来源: [Warcraft Wiki - Map](https://warcraft.wiki.gg/wiki/Category:API_functions/Map)

## 概述

C_Map 提供地图相关的操作 API。

## 常用函数

### 地图信息

```lua
-- 获取当前地图
local mapID = C_Map.GetBestMapForUnit("player")

-- 获取地图信息
local mapInfo = C_Map.GetMapInfo(mapID)
-- mapInfo.mapID, mapInfo.name, mapInfo.mapType, mapInfo.parentMapID

-- 地图类型枚举
Enum.UIMapType = {
    Cosmic = 0,
    World = 1,
    Continent = 2,
    Zone = 3,
    Dungeon = 4,
    Micro = 5,
    Orphan = 6,
}
```

### 用户位置

```lua
-- 获取玩家在地图上的位置
local position = C_Map.GetPlayerMapPosition(mapID, "player")
if position then
    local x, y = position:GetXY()
    -- x, y 是 0-1 范围
end

-- 获取玩家准确位置
local mapID = C_Map.GetBestMapForUnit("player")
local pos = C_Map.GetPlayerMapPosition(mapID, "player")
```

### 子地图

```lua
-- 获取地图的子地图列表
local mapIDs = C_Map.GetMapChildrenInfo(mapID)
-- 返回所有子地图的信息表

-- 获取地图层级
local floors = C_Map.GetFloors(mapID)
```

### 世界地图

```lua
-- 获取世界地图当前显示的地图
local mapID = WorldMapFrame:GetMapID()

-- 设置世界地图显示的地图
WorldMapFrame:SetMapID(mapID)
```

### 坐标转换

```lua
-- 地图坐标转换为世界坐标
local worldX, worldY = C_Map.GetWorldPosFromMapPos(mapID, x, y)

-- 获取地图在父地图中的位置
local x, y, width, height = C_Map.GetMapRectOnMap(mapID, parentMapID)
```

### 导路点

```lua
-- 设置用户导路点
local waypoint = UiMapPoint.CreateFromCoordinates(mapID, x, y)
C_Map.SetUserWaypoint(waypoint)

-- 获取用户导路点
local waypoint = C_Map.GetUserWaypoint()

-- 清除用户导路点
C_Map.ClearUserWaypoint()

-- 检查是否有用户导路点
local hasWaypoint = C_Map.HasUserWaypoint()
```

### 地图探索

```lua
-- 获取地图探索纹理信息
local textureInfo = C_MapExplorationInfo.GetExploredMapTextureInfo(mapID)
-- 返回表，包含已探索区域的纹理信息

-- 检查地图是否为城市（通过 flags 判断）
local mapInfo = C_Map.GetMapInfo(mapID)
local isCity = mapInfo and bit.band(mapInfo.flags, Enum.UIMapFlag.City) ~= 0
```

## 示例用法

### 获取玩家位置信息

```lua
local function GetPlayerLocationInfo()
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then return nil end

    local mapInfo = C_Map.GetMapInfo(mapID)
    local position = C_Map.GetPlayerMapPosition(mapID, "player")

    local x, y
    if position then
        x, y = position:GetXY()
    end

    return {
        mapID = mapID,
        mapName = mapInfo and mapInfo.name,
        mapType = mapInfo and mapInfo.mapType,
        x = x,
        y = y,
    }
end
```

### 获取地图路径

```lua
local function GetMapPath(mapID)
    local path = {}
    local currentID = mapID

    while currentID do
        local info = C_Map.GetMapInfo(currentID)
        if info then
            table.insert(path, 1, {
                id = currentID,
                name = info.name,
                type = info.mapType,
            })
            currentID = info.parentMapID
        else
            break
        end
    end

    return path
end

-- 使用示例
local path = GetMapPath(C_Map.GetBestMapForUnit("player"))
for i, info in ipairs(path) do
    print(string.rep("  ", i-1) .. info.name)
end
```

### 设置导路点到任务

```lua
local function SetWaypointToQuest(questID)
    -- 获取任务位置
    local mapID = C_QuestLog.GetNextWaypointMapID(questID)
    if not mapID then return false end

    -- 获取下一个导路点文本（注意：这是导航文本而非坐标）
    local waypointText = C_QuestLog.GetNextWaypointText(questID)

    -- 如果需要坐标，应使用 SuperTrack 或其他方式
    -- 创建导路点需要通过 C_SuperTrack 设置追踪
    C_SuperTrack.SetSuperTrackedQuestID(questID)

    return true
end
```

### 缓存地图信息

```lua
local MapCache = {}

local function GetCachedMapInfo(mapID)
    if MapCache[mapID] then
        return MapCache[mapID]
    end

    local info = C_Map.GetMapInfo(mapID)
    if info then
        MapCache[mapID] = info
    end

    return info
end

-- 使用
local mapInfo = GetCachedMapInfo(1234)
print(mapInfo.name)
```

## 事件

| 事件 | 说明 |
|------|------|
| `ZONE_CHANGED` | 区域改变（小区域） |
| `ZONE_CHANGED_INDOORS` | 室内区域改变 |
| `ZONE_CHANGED_NEW_AREA` | 进入新区域 |
| `NEW_WMO_CHUNK` | WMO 块改变 |
| `USER_WAYPOINT_UPDATED` | 用户导路点更新 |

## 实用工具

```lua
-- 获取玩家所在大洲
local function GetPlayerContinent()
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then return nil end

    local info = C_Map.GetMapInfo(mapID)
    while info and info.mapType ~= Enum.UIMapType.Continent do
        info = C_Map.GetMapInfo(info.parentMapID)
    end

    return info and info.mapID
end

-- 检查玩家是否在指定地图
local function IsPlayerInMap(mapID)
    local playerMapID = C_Map.GetBestMapForUnit("player")
    while playerMapID do
        if playerMapID == mapID then
            return true
        end
        local info = C_Map.GetMapInfo(playerMapID)
        playerMapID = info and info.parentMapID
    end
    return false
end

-- 计算两点距离（同一地图）
local function GetDistanceInMap(mapID, x1, y1, x2, y2)
    local wx1, wy1 = C_Map.GetWorldPosFromMapPos(mapID, x1, y1)
    local wx2, wy2 = C_Map.GetWorldPosFromMapPos(mapID, x2, y2)

    if wx1 and wx2 then
        local dx = wx2 - wx1
        local dy = wy2 - wy1
        return math.sqrt(dx * dx + dy * dy)
    end

    return nil
end
```

## 相关链接

- [Warcraft Wiki - Map API](https://warcraft.wiki.gg/wiki/Category:API_functions/Map)
- [C_QuestLog](C_QuestLog.md)
- [事件系统概述](../events/README.md)
