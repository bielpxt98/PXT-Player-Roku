' Live TV channel list screen.
' This screen displays channels for one category and notifies MainScene when a
' channel is selected for live playback.
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

    configureLayout()
end sub

sub configureLayout()
    resolution = getDisplayResolution()
    width = resolution.width
    height = resolution.height

    m.safeX = Int(width * 0.06)
    m.safeTop = Int(height * 0.07)
    m.safeBottom = Int(height * 0.08)
    m.contentWidth = width - (m.safeX * 2)
    if m.contentWidth > 940 then m.contentWidth = 940
    m.contentX = Int((width - m.contentWidth) / 2)

    if height <= 720 then
        m.itemHeight = 76
        m.cardHeight = 66
        m.logoSize = 44
        m.logoInset = 11
        m.titleY = m.safeTop
        m.subtitleY = m.titleY + 58
        m.listY = m.subtitleY + 54
        m.footerGap = 42
    else
        m.itemHeight = 92
        m.cardHeight = 78
        m.logoSize = 52
        m.logoInset = 13
        m.titleY = m.safeTop
        m.subtitleY = m.titleY + 74
        m.listY = m.subtitleY + 70
        m.footerGap = 56
    end if

    hintY = height - m.safeBottom - 28
    if hintY < m.listY + m.cardHeight then hintY = m.listY + m.cardHeight + 12
    availableListHeight = hintY - m.listY - m.footerGap
    m.maxVisibleItems = Int(availableListHeight / m.itemHeight)
    if m.maxVisibleItems < 1 then m.maxVisibleItems = 1

    m.background.width = width
    m.background.height = height

    m.title.width = width
    m.title.font = "font:LargeBoldSystemFont"
    m.title.translation = [0, m.titleY]

    m.subtitle.width = width
    m.subtitle.font = "font:MediumSystemFont"
    m.subtitle.translation = [0, m.subtitleY]

    m.statusLabel.width = m.contentWidth
    m.statusLabel.font = "font:MediumSystemFont"
    m.statusLabel.translation = [m.contentX, m.listY + Int(availableListHeight / 2)]

    m.channelsGroup.translation = [m.contentX, m.listY]

    m.hintLabel.width = width
    m.hintLabel.font = "font:SmallSystemFont"
    m.hintLabel.translation = [0, hintY]
end sub

sub show(category as Dynamic)
    if category <> invalid then
        m.subtitle.text = "Canais • " + getCategoryName(category)
    else
        m.subtitle.text = "Canais"
    end if

    configureLayout()
    ensureFocusIsVisible()
    renderVisibleItems()
    m.top.visible = true
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
    m.focusIndex = 0
    m.firstVisibleIndex = 0
    m.statusLabel.color = "#FFCC66"
end sub

function normalizeChannels(channels as Dynamic) as Object
    if channels = invalid then return []
    if Type(channels) = "roArray" then return channels
    return []
end function

sub renderVisibleItems()
    clearChannelNodes()
    if m.channels.Count() = 0 then return

    ensureFocusIsVisible()
    lastIndex = m.firstVisibleIndex + m.maxVisibleItems - 1
    if lastIndex >= m.channels.Count() then lastIndex = m.channels.Count() - 1

    for i = m.firstVisibleIndex to lastIndex
        item = createChannelItem(m.channels[i], i - m.firstVisibleIndex, i)
        m.channelsGroup.AppendChild(item)
        m.itemNodes.Push(item)
    end for

    updateFocus()
end sub

function createChannelItem(channel as Object, visibleIndex as Integer, absoluteIndex as Integer) as Object
    item = CreateObject("roSGNode", "Group")
    item.translation = [0, visibleIndex * m.itemHeight]
    item.id = "channelItem" + absoluteIndex.ToStr()

    background = CreateObject("roSGNode", "Rectangle")
    background.id = "itemBackground"
    background.width = m.contentWidth
    background.height = m.cardHeight
    background.color = "#111827"
    background.opacity = 0.86

    accent = CreateObject("roSGNode", "Rectangle")
    accent.id = "itemAccent"
    accent.width = 6
    accent.height = m.cardHeight
    accent.color = "#009DFF"
    accent.opacity = 0.45

    logoBackground = CreateObject("roSGNode", "Rectangle")
    logoBackground.id = "logoBackground"
    logoBackground.width = m.logoSize + 6
    logoBackground.height = m.logoSize + 6
    logoBackground.translation = [22, Int((m.cardHeight - (m.logoSize + 6)) / 2)]
    logoBackground.color = "#1F2937"
    logoBackground.opacity = 0.95

    logo = CreateObject("roSGNode", "Poster")
    logo.id = "channelLogo"
    logo.width = m.logoSize
    logo.height = m.logoSize
    logo.translation = [25, m.logoInset]
    logo.loadDisplayMode = "scaleToFit"
    logo.uri = getChannelLogo(channel)

    label = CreateObject("roSGNode", "Label")
    label.id = "itemLabel"
    label.width = m.contentWidth - 122
    label.height = m.cardHeight
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
        if m.channels.Count() > 0 and m.focusIndex >= 0 and m.focusIndex < m.channels.Count() then
            m.top.channelSelected = m.channels[m.focusIndex]
        end if
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

    oldFirstVisibleIndex = m.firstVisibleIndex
    ensureFocusIsVisible()
    if oldFirstVisibleIndex <> m.firstVisibleIndex then
        renderVisibleItems()
    else
        updateFocus()
    end if
end sub

sub ensureFocusIsVisible()
    if m.channels.Count() = 0 then
        m.focusIndex = 0
        m.firstVisibleIndex = 0
        return
    end if

    if m.focusIndex < 0 then m.focusIndex = 0
    if m.focusIndex >= m.channels.Count() then m.focusIndex = m.channels.Count() - 1
    if m.firstVisibleIndex < 0 then m.firstVisibleIndex = 0

    maxFirstIndex = m.channels.Count() - m.maxVisibleItems
    if maxFirstIndex < 0 then maxFirstIndex = 0

    if m.focusIndex < m.firstVisibleIndex then
        m.firstVisibleIndex = m.focusIndex
    else if m.focusIndex >= m.firstVisibleIndex + m.maxVisibleItems then
        m.firstVisibleIndex = m.focusIndex - m.maxVisibleItems + 1
    end if

    if m.firstVisibleIndex > maxFirstIndex then m.firstVisibleIndex = maxFirstIndex
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
