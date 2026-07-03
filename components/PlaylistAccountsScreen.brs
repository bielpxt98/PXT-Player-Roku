sub Init()
    m.background = m.top.FindNode("background")
    m.title = m.top.FindNode("title")
    m.listGroup = m.top.FindNode("listGroup")
    m.hintLabel = m.top.FindNode("hintLabel")
    m.items = []
    m.itemNodes = []
    m.selectedIndex = 0
    configureLayout()
end sub

sub configureLayout()
    resolution = getDisplayResolution()
    m.width = resolution.width
    m.height = resolution.height
    m.contentWidth = 760
    if m.width < 1000 then m.contentWidth = m.width - 160
    m.contentX = Int((m.width - m.contentWidth) / 2)
    m.itemHeight = 74
    m.background.width = m.width
    m.background.height = m.height
    m.title.width = m.width
    m.title.font = "font:LargeBoldSystemFont"
    m.title.translation = [0, 72]
    m.listGroup.translation = [m.contentX, 170]
    m.hintLabel.width = m.width
    m.hintLabel.font = "font:SmallSystemFont"
    m.hintLabel.translation = [0, m.height - 72]
end sub

sub show()
    configureLayout()
    m.top.visible = true
    m.top.SetFocus(true)
    renderList()
    updateFocus()
end sub

sub hide()
    m.top.visible = false
end sub

sub setPlaylists(data as Object)
    m.items = []
    playlists = []
    activeUsername = ""
    if data <> invalid then
        if data.playlists <> invalid then playlists = data.playlists
        if data.activeUsername <> invalid then activeUsername = data.activeUsername
    end if
    if playlists <> invalid then
        for each playlist in playlists
            username = safeAccountScreenText(playlist.username)
            if username <> "" then
                m.items.Push({ username: username, active: username = activeUsername, account: playlist, isNew: false })
            end if
        end for
    end if
    m.items.Push({ username: "+  Nova Playlist", active: false, isNew: true })
    m.selectedIndex = 0
    renderList()
    updateFocus()
end sub

sub renderList()
    while m.listGroup.GetChildCount() > 0
        m.listGroup.RemoveChild(m.listGroup.GetChild(0))
    end while
    m.itemNodes = []
    for i = 0 to m.items.Count() - 1
        item = m.items[i]
        row = CreateObject("roSGNode", "Group")
        row.translation = [0, i * m.itemHeight]
        bg = CreateObject("roSGNode", "Rectangle")
        bg.id = "background"
        bg.width = m.contentWidth
        bg.height = 58
        bg.color = "#111827"
        bg.opacity = 0.0
        icon = CreateObject("roSGNode", "Label")
        icon.id = "icon"
        icon.width = 64
        icon.height = 58
        icon.vertAlign = "center"
        icon.horizAlign = "center"
        icon.font = "font:MediumBoldSystemFont"
        icon.color = "#A7F3D0"
        if item.active = true then icon.text = "✓" else icon.text = ""
        label = CreateObject("roSGNode", "Label")
        label.id = "label"
        label.width = m.contentWidth - 92
        label.height = 58
        label.translation = [72, 0]
        label.vertAlign = "center"
        label.font = "font:MediumSystemFont"
        label.color = "#F8FAFC"
        if item.active = true then label.text = item.username + " (active)" else label.text = item.username
        row.AppendChild(bg)
        row.AppendChild(icon)
        row.AppendChild(label)
        m.listGroup.AppendChild(row)
        m.itemNodes.Push({ row: row, bg: bg, icon: icon, label: label })
    end for
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "back" then
        m.top.backRequested = true
        return true
    else if key = "up" then
        moveFocus(-1)
        return true
    else if key = "down" then
        moveFocus(1)
        return true
    else if key = "OK" then
        if m.items.Count() = 0 then return true
        item = m.items[m.selectedIndex]
        if item.isNew = true then
            m.top.newPlaylistRequested = true
        else
            m.top.playlistSelected = item.account
        end if
        return true
    end if
    return false
end function

sub moveFocus(delta as Integer)
    if m.items.Count() = 0 then return
    old = m.selectedIndex
    m.selectedIndex = m.selectedIndex + delta
    if m.selectedIndex < 0 then m.selectedIndex = m.items.Count() - 1
    if m.selectedIndex >= m.items.Count() then m.selectedIndex = 0
    updateFocusAt(old)
    updateFocusAt(m.selectedIndex)
end sub

sub updateFocus()
    for i = 0 to m.itemNodes.Count() - 1
        updateFocusAt(i)
    end for
end sub

sub updateFocusAt(index as Integer)
    if index < 0 or index >= m.itemNodes.Count() then return
    refs = m.itemNodes[index]
    focused = index = m.selectedIndex
    if focused then
        refs.bg.opacity = 0.92
        refs.label.color = "#FFFFFF"
    else
        refs.bg.opacity = 0.0
        refs.label.color = "#DDE6F3"
    end if
end sub

function getDisplayResolution() as Object
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()
    return { width: displaySize.w, height: displaySize.h }
end function

function safeAccountScreenText(value as Dynamic) as String
    if value = invalid then return ""
    return value.ToStr()
end function
