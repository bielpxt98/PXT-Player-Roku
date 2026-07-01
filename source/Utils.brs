function getDisplayResolution() as Object
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()
    return { width: displaySize.w, height: displaySize.h }
end function

function getCategoryName(category as Dynamic) as String
    if category = invalid then return "Categoria"
    if category.category_name <> invalid and category.category_name.ToStr().Trim() <> "" then return category.category_name.ToStr()
    if category.name <> invalid and category.name.ToStr().Trim() <> "" then return category.name.ToStr()
    return "Categoria"
end function

function getCategoryId(category as Dynamic) as String
    if category = invalid then return ""
    if category.category_id <> invalid then return category.category_id.ToStr()
    if category.id <> invalid then return category.id.ToStr()
    return ""
end function

function normalizeArray(items as Dynamic) as Object
    if items = invalid then return []
    if Type(items) = "roArray" then return items
    return []
end function

function firstText(item as Dynamic, keys as Object) as String
    if item = invalid or Type(item) <> "roAssociativeArray" then return ""
    for each k in keys
        if item.DoesExist(k) and item[k] <> invalid and item[k].ToStr().Trim() <> "" then return item[k].ToStr().Trim()
    end for
    return ""
end function

function joinText(parts as Object, sep as String) as String
    out = ""
    for each part in parts
        if part <> "" then
            if out <> "" then out = out + sep
            out = out + part
        end if
    end for
    return out
end function

function ratingText(value as String) as String
    if value = "" then return ""
    n = Val(value)
    if n > 5 then n = n / 2
    stars = ""
    for i = 1 to 5
        if i <= Int(n + 0.5) then stars = stars + "★" else stars = stars + "☆"
    end for
    return stars
end function

function normalizeKey(key as String) as String
    if key = invalid then return ""
    if key = " " then return "OK"

    normalized = LCase(key.Trim())

    if normalized = "ok" or normalized = "enter" or normalized = "return" or normalized = "space" or normalized = "spacebar" then return "OK"
    if normalized = "back" or normalized = "esc" or normalized = "escape" or normalized = "backspace" then return "back"

    if normalized = "up" or normalized = "arrowup" or normalized = "arrow up" then return "up"
    if normalized = "down" or normalized = "arrowdown" or normalized = "arrow down" then return "down"
    if normalized = "left" or normalized = "arrowleft" or normalized = "arrow left" then return "left"
    if normalized = "right" or normalized = "arrowright" or normalized = "arrow right" then return "right"

    if normalized = "home" then return "home"
    if normalized = "options" or normalized = "info" or normalized = "delete" or normalized = "del" then return "options"

    if normalized = "play" or normalized = "pause" or normalized = "playpause" or normalized = "play/pause" or normalized = "insert" then return "play"
    if normalized = "rewind" or normalized = "pageup" or normalized = "page up" then return "rewind"
    if normalized = "fastforward" or normalized = "fast forward" or normalized = "forward" or normalized = "pagedown" or normalized = "page down" then return "forward"
    if normalized = "replay" or normalized = "instantreplay" or normalized = "instant replay" or normalized = "end" then return "replay"

    if Len(normalized) = 1 and Instr(1, "0123456789", normalized) > 0 then return normalized
    if Left(normalized, 4) = "lit_" then return normalized

    return ""
end function
