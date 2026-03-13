# C_HousingPhotoSharing API

## 概述

房屋照片分享系统API，12.0 Midnight 新增功能。用于管理房屋系统的照片分享和截图上传。

## 函数

### RequestPhotoSharingAuthorization

请求照片分享授权。

```lua
C_HousingPhotoSharing.RequestPhotoSharingAuthorization()
```

---

### IsPhotoSharingAuthorized

检查是否已获得照片分享授权。

```lua
local isAuthorized = C_HousingPhotoSharing.IsPhotoSharingAuthorized()
```

**返回值：**
- `isAuthorized` (boolean) - 是否已授权

---

### GetPhotoUploadStatus

获取照片上传状态。

```lua
local status = C_HousingPhotoSharing.GetPhotoUploadStatus()
```

**返回值：**
- `status` (Enum.PhotoSharingUploadStatus) - 上传状态

---

## 事件

### PHOTO_SHARING_AUTHORIZATION_NEEDED

当需要照片分享授权时触发。

```lua
EventRegistry:RegisterFrameEventAndCallback("PHOTO_SHARING_AUTHORIZATION_NEEDED", function()
    print("需要照片分享授权")
end)
```

---

### PHOTO_SHARING_AUTHORIZATION_UPDATED

当授权状态更新时触发。

```lua
EventRegistry:RegisterFrameEventAndCallback("PHOTO_SHARING_AUTHORIZATION_UPDATED", function()
    local isAuthorized = C_HousingPhotoSharing.IsPhotoSharingAuthorized()
    print("授权状态:", isAuthorized)
end)
```

---

### PHOTO_SHARING_PHOTO_UPLOAD_STATUS

当照片上传状态变化时触发。

```lua
EventRegistry:RegisterFrameEventAndCallback("PHOTO_SHARING_PHOTO_UPLOAD_STATUS", function()
    local status = C_HousingPhotoSharing.GetPhotoUploadStatus()
    print("上传状态:", status)
end)
```

---

### PHOTO_SHARING_SCREENSHOT_READY

当截图准备就绪时触发。

```lua
EventRegistry:RegisterFrameEventAndCallback("PHOTO_SHARING_SCREENSHOT_READY", function()
    print("截图已准备就绪")
end)
```

---

## 使用示例

```lua
-- 检查授权状态
if not C_HousingPhotoSharing.IsPhotoSharingAuthorized() then
    C_HousingPhotoSharing.RequestPhotoSharingAuthorization()
end

-- 监听授权事件
EventRegistry:RegisterFrameEventAndCallback("PHOTO_SHARING_AUTHORIZATION_UPDATED", function()
    local isAuthorized = C_HousingPhotoSharing.IsPhotoSharingAuthorized()
    if isAuthorized then
        print("已授权照片分享")
    else
        print("未授权照片分享")
    end
end)
```

## 相关链接

- [C_Housing](C_Housing.md) - 房屋系统API
- [Warcraft Wiki - Housing](https://warcraft.wiki.gg)
