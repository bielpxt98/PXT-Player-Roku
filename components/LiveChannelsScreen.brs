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
    m.allChannel = []
    m.searchQuery = ""
    m.keyboardDialog = invalid
    m.itemNodes = []
    m.selectedIndex = 0
    m.firstVisibleIndex = 0

    configureLayout()
end sub

sub configureLayout()
    resolution = getDisplayResolution()
    width = resolution.width
    height = resolution.height

    ' Use the real display size, but keep fixed safe-area reservations so the
    ' list never renders under the title or footer on different TV resolutions.
    m.safeMarginX = 72
    m.titleReservedHeight = 150
    m.footerReservedHeight = 86
    if height <= 720 then
        m.safeMarginX = 48
        m.titleReservedHeight = 124
        m.footerReservedHeight = 70
    end if

    m.contentX = m.safeMarginX
    m.contentWidth = width - (m.safeMarginX * 2)
    if m.contentWidth < 360 then
        m.contentX = 0
        m.contentWidth = width
    end if

    m.titleY = 42
    m.subtitleY = 100
    if height <= 720 then
        m.titleY = 28
        m.subtitleY = 78
    end if

    m.listY = m.titleReservedHeight
    m.footerY = height - m.footerReservedHeight + 18
    m.listHeight = m.footerY - m.listY - 20
    if m.listHeight < 96 then m.listHeight = 96

    if height <= 720 then
        m.itemHeight = 72
        m.cardHeight = 62
        m.logoSize = 42
        m.logoInset = 10
    else
        m.itemHeight = 88
        m.cardHeight = 76
        m.logoSize = 52
        m.logoInset = 12
    end if

    m.visibleItemCount = Int(m.listHeight / m.itemHeight)
    if m.visibleItemCount < 1 then m.visibleItemCount = 1

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
    m.statusLabel.translation = [m.contentX, m.listY + Int(m.listHeight / 2)]

    m.channelsGroup.translation = [m.contentX, m.listY]

    m.hintLabel.width = width
    m.hintLabel.font = "font:SmallSystemFont"
    m.hintLabel.translation = [0, m.footerY]
end sub

sub show(category as Dynamic)
    if category <> invalid then
        m.subtitle.text = "Canais • " + getCategoryName(category)
    else
        m.subtitle.text = "Canais"
    end if

    m.searchQuery = ""
    applySearchFilter()
    configureLayout()
    resetSelection()
    updateVisibleWindow()
    renderList()
    updateFocus()
    m.top.visible = true
    m.top.SetFocus(true)
end sub

sub hide()
    m.top.visible = false
end sub

sub resetSelection()
    m.selectedIndex = 0
    m.firstVisibleIndex = 0
    logInitialSelection()
end sub

sub logInitialSelection()
    print "INIT selectedIndex="; m.selectedIndex
    print "INIT firstVisibleIndex="; m.firstVisibleIndex
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
    m.allChannel = normalizeChannels(channels)
    applySearchFilter()

    if m.allChannel.Count() = 0 then
        showMessage("Nenhum canal foi encontrado nesta categoria.")
        return
    end if

    m.statusLabel.text = ""
    updateVisibleWindow()
    renderList()
    updateFocus()
end sub

sub showMessage(message as String)
    clearChannelNodes()
    m.channels = []
    m.allChannel = []
    resetSelection()
    m.statusLabel.text = message
    m.statusLabel.color = "#FFCC66"
end sub

function normalizeChannels(channels as Dynamic) as Object
    if channels = invalid then return []
    if Type(channels) = "roArray" then return channels
    return []
end function

sub renderList()
    clearChannelNodes()

    totalRows = m.channels.Count() + 1
    lastIndex = m.firstVisibleIndex + m.visibleItemCount - 1
    if lastIndex >= totalRows then lastIndex = totalRows - 1

    for visualIndex = 0 to lastIndex - m.firstVisibleIndex
        realIndex = m.firstVisibleIndex + visualIndex
        if realIndex = 0 then
            item = createSearchItem(visualIndex)
        else
            item = createChannelItem(m.channels[realIndex - 1], visualIndex, realIndex - 1)
        end if
        m.channelsGroup.AppendChild(item)
        m.itemNodes.Push(item)
    end for
end sub

function createSearchItem(visibleIndex as Integer) as Object
    item = CreateObject("roSGNode", "Group")
    item.translation = [0, visibleIndex * m.itemHeight]
    item.id = "searchItem"

    background = CreateObject("roSGNode", "Rectangle")
    background.id = "itemBackground"
    background.width = m.contentWidth
    background.height = m.cardHeight
    background.color = "#113B5C"
    background.opacity = 0.92

    accent = CreateObject("roSGNode", "Rectangle")
    accent.id = "itemAccent"
    accent.width = 6
    accent.height = m.cardHeight
    accent.color = "#5CE08A"
    accent.opacity = 0.0

    label = CreateObject("roSGNode", "Label")
    label.id = "itemLabel"
    label.width = m.contentWidth - 32
    label.height = m.cardHeight
    label.translation = [16, 0]
    label.vertAlign = "center"
    label.color = "#F8FAFC"
    label.font = "font:MediumBoldSystemFont"
    if m.searchQuery <> "" then
        label.text = "Buscar: " + m.searchQuery
    else
        label.text = "Buscar canais"
    end if

    item.AppendChild(background)
    item.AppendChild(accent)
    item.AppendChild(label)
    return item
end function

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
    accent.opacity = 0.0

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

function getChannelLogTitle(channel as Dynamic) as String
    if channel = invalid then return ""
    if channel.title <> invalid and channel.title.ToStr().Trim() <> "" then return channel.title.ToStr()
    return getChannelName(channel)
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
        if m.searchQuery <> "" then
            m.searchQuery = ""
            applySearchFilter()
        else
            m.top.backRequested = true
        end if
        return true
    else if key = "up" then
        moveFocus(-1)
        return true
    else if key = "down" then
        moveFocus(1)
        return true
    else if key = "replay" then
        openSearchKeyboard()
        return true
    else if key = "options" then
        if m.channels.Count() > 0 and m.selectedIndex > 0 and m.selectedIndex <= m.channels.Count() then
            m.top.channelFavoriteToggled = m.channels[m.selectedIndex - 1]
            m.statusLabel.color = "#5CE08A"
            m.statusLabel.text = "Canal atualizado nos favoritos."
        end if
        return true
    else if key = "OK" then
        if m.selectedIndex = 0 then
            openSearchKeyboard()
        else if m.channels.Count() > 0 and m.selectedIndex <= m.channels.Count() then
            itemIndex = m.selectedIndex - 1
            print "OK opening selectedIndex="; itemIndex
            print "OK opening item="; getChannelLogTitle(m.channels[itemIndex])
            m.top.channelSelected = m.channels[itemIndex]
        end if
        return true
    end if

    return false
end function

sub moveFocus(direction as Integer)
    handleUpDown(direction)
end sub

sub handleUpDown(direction as Integer)
    if m.channels.Count() = 0 and m.selectedIndex = 0 then return

    if direction > 0 then
        m.selectedIndex = m.selectedIndex + 1
    else if direction < 0 then
        m.selectedIndex = m.selectedIndex - 1
    else
        return
    end if

    previousFirstVisibleIndex = m.firstVisibleIndex
    updateVisibleWindow()

    if m.firstVisibleIndex <> previousFirstVisibleIndex then
        renderList()
    end if

    updateFocus()
end sub

sub updateVisibleWindow()
    totalRows = m.channels.Count() + 1

    if m.selectedIndex < 0 then m.selectedIndex = 0
    if m.selectedIndex >= totalRows then m.selectedIndex = totalRows - 1
    if m.firstVisibleIndex < 0 then m.firstVisibleIndex = 0

    maxFirstIndex = totalRows - m.visibleItemCount
    if maxFirstIndex < 0 then maxFirstIndex = 0

    if m.selectedIndex < m.firstVisibleIndex then
        m.firstVisibleIndex = m.selectedIndex
    else if m.selectedIndex >= m.firstVisibleIndex + m.visibleItemCount then
        m.firstVisibleIndex = m.selectedIndex - m.visibleItemCount + 1
    end if

    if m.firstVisibleIndex > maxFirstIndex then m.firstVisibleIndex = maxFirstIndex
end sub

sub updateFocus()
    selectedNode = invalid

    ' Keep a single manual highlight: reset every visible item before
    ' applying the selectedIndex state to exactly one realIndex.
    for i = 0 to m.itemNodes.Count() - 1
        realIndex = m.firstVisibleIndex + i
        background = m.itemNodes[i].FindNode("itemBackground")
        accent = m.itemNodes[i].FindNode("itemAccent")
        label = m.itemNodes[i].FindNode("itemLabel")
        logoBackground = m.itemNodes[i].FindNode("logoBackground")

        m.itemNodes[i].scale = [1.0, 1.0]
        background.color = "#111827"
        background.opacity = 0.86
        accent.opacity = 0.0
        label.color = "#F8FAFC"
        if logoBackground <> invalid then logoBackground.color = "#1F2937"

        if realIndex = m.selectedIndex then selectedNode = m.itemNodes[i]
    end for

    if selectedNode <> invalid then
        background = selectedNode.FindNode("itemBackground")
        accent = selectedNode.FindNode("itemAccent")
        label = selectedNode.FindNode("itemLabel")
        logoBackground = selectedNode.FindNode("logoBackground")

        selectedNode.scale = [1.02, 1.02]
        background.color = "#0B3A5E"
        background.opacity = 1.0
        accent.opacity = 0.0
        label.color = "#FFFFFF"
        if logoBackground <> invalid then logoBackground.color = "#0F4F7A"
    end if
end sub


sub openSearchKeyboard()
    dialog = CreateObject("roSGNode", "StandardKeyboardDialog")
    dialog.title = "Buscar canais"
    dialog.text = m.searchQuery
    dialog.buttons = ["Buscar", "Limpar", "Cancelar"]
    dialog.ObserveField("buttonSelected", "onSearchKeyboardButtonSelected")
    m.keyboardDialog = dialog
    m.top.GetScene().dialog = dialog
end sub

sub onSearchKeyboardButtonSelected()
    if m.keyboardDialog = invalid then return
    selectedButton = m.keyboardDialog.buttonSelected
    if selectedButton = 0 then
        m.searchQuery = m.keyboardDialog.text.Trim()
        applySearchFilter()
    else if selectedButton = 1 then
        m.searchQuery = ""
        applySearchFilter()
    end if
    m.top.GetScene().dialog = invalid
    m.keyboardDialog = invalid
end sub

sub applySearchFilter()
    query = LCase(m.searchQuery.Trim())
    m.channels = []
    if query = "" then
        for each item in m.allChannel
            m.channels.Push(item)
        end for
    else
        for each item in m.allChannel
            if Instr(1, LCase(getChannelName(item)), query) > 0 then m.channels.Push(item)
        end for
    end if
    resetSelection()
    if m.allChannel.Count() > 0 and m.channels.Count() = 0 then
        m.statusLabel.color = "#FFCC66"
        m.statusLabel.text = "Nenhum resultado encontrado para esta busca."
    else
        m.statusLabel.text = ""
    end if
    updateVisibleWindow()
    renderList()
    updateFocus()
end sub

function getDisplayResolution() as Object
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()

    return {
        width: displaySize.w
        height: displaySize.h
    }
end function
