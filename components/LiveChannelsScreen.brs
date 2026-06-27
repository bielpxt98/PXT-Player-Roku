' Live TV channel list screen.
' This screen displays channels for one category and intentionally shows only a
' playback placeholder when a channel is selected.
sub Init()
    m.background = m.top.FindNode("background")
    m.title = m.top.FindNode("title")
    m.subtitle = m.top.FindNode("subtitle")
    m.statusLabel = m.top.FindNode("statusLabel")
    m.channelsGroup = m.top.FindNode("channelsGroup")
    m.hintLabel = m.top.FindNode("hintLabel")

    m.channels = []
    m.itemNodes = []
    m.focusIndex = 0
    m.firstVisibleIndex = 0
    m.maxVisibleItems = 6
    m.itemHeight = 92

    configureLayout()
end sub

sub configureLayout()
    resolution = getDisplayResolution()
    width = resolution.width
    height = resolution.height

    m.background.width = width
    m.background.height = height

    m.title.width = width
    m.title.font = "font:LargeBoldSystemFont"
    m.title.translation = [0, Int(height * 0.08)]

    m.subtitle.width = width
    m.subtitle.font = "font:MediumSystemFont"
    m.subtitle.translation = [0, Int(height * 0.18)]

    m.statusLabel.width = width
    m.statusLabel.font = "font:MediumSystemFont"
    m.statusLabel.translation = [0, Int(height * 0.44)]

    m.channelsGroup.translation = [Int((width - 860) / 2), Int(height * 0.25)]

    m.hintLabel.width = width
    m.hintLabel.font = "font:SmallSystemFont"
    m.hintLabel.translation = [0, Int(height * 0.91)]
end sub

sub show(category as Dynamic)
    if category <> invalid then
        m.subtitle.text = "Canais • " + getCategoryName(category)
    else
        m.subtitle.text = "Canais"
    end if

    m.top.visible = true
    updateFocus()
    m.top.SetFocus(true)
end sub

sub hide()
    m.top.visible = false
end sub

sub setLoading(isLoading as Boolean)
    clearChannelNodes()
    if isLoading then
        m.statusLabel.text = "Carregando canais de TV ao vivo..."
        m.statusLabel.color = "#B8C3D6"
    else
        m.statusLabel.text = ""
    end if
end sub

sub setChannels(channels as Object)
    m.channels = normalizeChannels(channels)
    m.focusIndex = 0
    m.firstVisibleIndex = 0

    if m.channels.Count() = 0 then
        showMessage("Nenhum canal foi encontrado nesta categoria.")
        return
    end if

    m.statusLabel.text = ""
    renderVisibleItems()
end sub

sub showMessage(message as String)
    clearChannelNodes()
    m.channels = []
    m.statusLabel.text = message
    m.statusLabel.color = "#FFCC66"
end sub

function normalizeChannels(channels as Dynamic) as Object
    if channels = invalid then return []
    if Type(channels) = "roArray" then return channels
    return []
end function

sub renderVisibleItems()
    clearChannelNodes()
    lastIndex = m.firstVisibleIndex + m.maxVisibleItems - 1
    if lastIndex >= m.channels.Count() then lastIndex = m.channels.Count() - 1

    for i = m.firstVisibleIndex to lastIndex
        item = createChannelItem(m.channels[i], i - m.firstVisibleIndex)
        m.channelsGroup.AppendChild(item)
        m.itemNodes.Push(item)
    end for

    updateFocus()
end sub

function createChannelItem(channel as Object, visibleIndex as Integer) as Object
    item = CreateObject("roSGNode", "Group")
    item.translation = [0, visibleIndex * m.itemHeight]

    background = CreateObject("roSGNode", "Rectangle")
    background.id = "itemBackground"
    background.width = 860
    background.height = 78
    background.color = "#111827"
    background.opacity = 0.86

    accent = CreateObject("roSGNode", "Rectangle")
    accent.id = "itemAccent"
    accent.width = 6
    accent.height = 78
    accent.color = "#009DFF"
    accent.opacity = 0.45

    logoBackground = CreateObject("roSGNode", "Rectangle")
    logoBackground.id = "logoBackground"
    logoBackground.width = 58
    logoBackground.height = 58
    logoBackground.translation = [22, 10]
    logoBackground.color = "#1F2937"
    logoBackground.opacity = 0.95

    logo = CreateObject("roSGNode", "Poster")
    logo.id = "channelLogo"
    logo.width = 52
    logo.height = 52
    logo.translation = [25, 13]
    logo.loadDisplayMode = "scaleToFit"
    logo.uri = getChannelLogo(channel)

    label = CreateObject("roSGNode", "Label")
    label.id = "itemLabel"
    label.width = 735
    label.height = 78
    label.translation = [100, 0]
    label.vertAlign = "center"
    label.color = "#F8FAFC"
    label.font = "font:MediumSystemFont"
    label.text = getChannelName(channel)

    item.AppendChild(background)
    item.AppendChild(accent)
    item.AppendChild(logoBackground)
    item.AppendChild(logo)
    item.AppendChild(label)
    return item
end function

function getChannelName(channel as Dynamic) as String
    if channel = invalid then return "Canal sem nome"
    if channel.name <> invalid and channel.name.ToStr().Trim() <> "" then return channel.name.ToStr()
    if channel.title <> invalid and channel.title.ToStr().Trim() <> "" then return channel.title.ToStr()
    return "Canal sem nome"
end function

function getChannelLogo(channel as Dynamic) as String
    if channel = invalid then return ""
    if channel.stream_icon <> invalid and channel.stream_icon.ToStr().Trim() <> "" then return channel.stream_icon.ToStr()
    if channel.logo <> invalid and channel.logo.ToStr().Trim() <> "" then return channel.logo.ToStr()
    return ""
end function

function getCategoryName(category as Dynamic) as String
    if category = invalid then return "Categoria"
    if category.category_name <> invalid and category.category_name.ToStr().Trim() <> "" then return category.category_name.ToStr()
    if category.name <> invalid and category.name.ToStr().Trim() <> "" then return category.name.ToStr()
    return "Categoria"
end function

sub clearChannelNodes()
    while m.channelsGroup.GetChildCount() > 0
        m.channelsGroup.RemoveChildIndex(0)
    end while
    m.itemNodes = []
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
        if m.channels.Count() > 0 then showMessage("Player será implementado na próxima etapa.")
        return true
    end if

    return false
end function

sub moveFocus(direction as Integer)
    if m.channels.Count() = 0 then return

    nextIndex = m.focusIndex + direction
    if nextIndex < 0 then nextIndex = m.channels.Count() - 1
    if nextIndex >= m.channels.Count() then nextIndex = 0
    m.focusIndex = nextIndex

    if m.focusIndex < m.firstVisibleIndex then
        m.firstVisibleIndex = m.focusIndex
        renderVisibleItems()
    else if m.focusIndex >= m.firstVisibleIndex + m.maxVisibleItems then
        m.firstVisibleIndex = m.focusIndex - m.maxVisibleItems + 1
        renderVisibleItems()
    else
        updateFocus()
    end if
end sub

sub updateFocus()
    for i = 0 to m.itemNodes.Count() - 1
        selected = (m.firstVisibleIndex + i) = m.focusIndex
        background = m.itemNodes[i].FindNode("itemBackground")
        accent = m.itemNodes[i].FindNode("itemAccent")
        label = m.itemNodes[i].FindNode("itemLabel")
        logoBackground = m.itemNodes[i].FindNode("logoBackground")

        if selected then
            background.color = "#0B3A5E"
            background.opacity = 1.0
            accent.opacity = 1.0
            label.color = "#FFFFFF"
            logoBackground.color = "#0F4F7A"
        else
            background.color = "#111827"
            background.opacity = 0.86
            accent.opacity = 0.45
            label.color = "#F8FAFC"
            logoBackground.color = "#1F2937"
        end if
    end for
end sub

function getDisplayResolution() as Object
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()

    return {
        width: displaySize.w
        height: displaySize.h
    }
end function
