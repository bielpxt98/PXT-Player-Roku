' Series episodes screen.
' This screen displays episodes for one category and notifies MainScene when a
' episode is selected for playback.
sub Init()
    m.background = m.top.FindNode("background")
    m.title = m.top.FindNode("title")
    m.subtitle = m.top.FindNode("subtitle")
    m.statusLabel = m.top.FindNode("statusLabel")
    m.episodesGroup = m.top.FindNode("episodesGroup")
    m.hintLabel = m.top.FindNode("hintLabel")

    m.episodes = []
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
        m.coverSize = 42
        m.coverInset = 10
    else
        m.itemHeight = 88
        m.cardHeight = 76
        m.coverSize = 52
        m.coverInset = 12
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

    m.episodesGroup.translation = [m.contentX, m.listY]

    m.hintLabel.width = width
    m.hintLabel.font = "font:SmallSystemFont"
    m.hintLabel.translation = [0, m.footerY]
end sub

sub show(category as Dynamic)
    if category <> invalid then
        m.subtitle.text = getCategoryName(category)
    else
        m.subtitle.text = "Temporada"
    end if

    configureLayout()
    resetSelection()
    updateVisibleWindow()
    renderList()
    updateFocus()
    m.top.visible = true
    if m.top.visible = true then m.top.SetFocus(true)
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
end sub

sub setLoading(isLoading as Boolean)
    clearEpisodeNodes()
    if isLoading then
        m.statusLabel.text = "Carregando episódios..."
        m.statusLabel.color = "#B8C3D6"
    else
        m.statusLabel.text = ""
    end if
end sub

sub setEpisodes(episodes as Object)
    m.episodes = normalizeEpisodes(episodes)
    resetSelection()

    if m.episodes.Count() = 0 then
        showMessage("Nenhum item foi encontrado.")
        return
    end if

    m.statusLabel.text = ""
    updateVisibleWindow()
    renderList()
    updateFocus()
end sub

sub showMessage(message as String)
    clearEpisodeNodes()
    m.episodes = []
    resetSelection()
    m.statusLabel.text = message
    m.statusLabel.color = "#FFCC66"
end sub

function normalizeEpisodes(episodes as Dynamic) as Object
    if episodes = invalid then return []
    if Type(episodes) = "roArray" then return episodes
    return []
end function

sub renderList()
    clearEpisodeNodes()
    if m.episodes.Count() = 0 then return

    lastIndex = m.firstVisibleIndex + m.visibleItemCount - 1
    if lastIndex >= m.episodes.Count() then lastIndex = m.episodes.Count() - 1

    for visualIndex = 0 to lastIndex - m.firstVisibleIndex
        realIndex = m.firstVisibleIndex + visualIndex
        item = createEpisodeItem(m.episodes[realIndex], visualIndex, realIndex)
        m.episodesGroup.AppendChild(item)
        m.itemNodes.Push(item)
    end for
end sub

function createEpisodeItem(episode as Object, visibleIndex as Integer, absoluteIndex as Integer) as Object
    item = CreateObject("roSGNode", "Group")
    item.translation = [0, visibleIndex * m.itemHeight]
    item.id = "episodeItem" + absoluteIndex.ToStr()

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

    coverBackground = CreateObject("roSGNode", "Rectangle")
    coverBackground.id = "coverBackground"
    coverBackground.width = m.coverSize + 6
    coverBackground.height = m.coverSize + 6
    coverBackground.translation = [22, Int((m.cardHeight - (m.coverSize + 6)) / 2)]
    coverBackground.color = "#1F2937"
    coverBackground.opacity = 0.95

    cover = CreateObject("roSGNode", "Poster")
    cover.id = "episodeCover"
    cover.width = m.coverSize
    cover.height = m.coverSize
    cover.translation = [25, m.coverInset]
    cover.loadDisplayMode = "scaleToFit"
    cover.uri = getEpisodeCover(episode)

    label = CreateObject("roSGNode", "Label")
    label.id = "itemLabel"
    label.width = m.contentWidth - 122
    label.height = m.cardHeight
    label.translation = [100, 0]
    label.vertAlign = "center"
    label.color = "#F8FAFC"
    label.font = "font:MediumSystemFont"
    label.text = getEpisodeName(episode)

    item.AppendChild(background)
    item.AppendChild(accent)
    item.AppendChild(coverBackground)
    item.AppendChild(cover)
    item.AppendChild(label)
    return item
end function

function getEpisodeName(episode as Dynamic) as String
    if episode = invalid then return "Episódio sem nome"
    if episode.title <> invalid and episode.title.ToStr().Trim() <> "" then return episode.title.ToStr()
    if episode.name <> invalid and episode.name.ToStr().Trim() <> "" then return episode.name.ToStr()
    if episode.episode_num <> invalid and episode.episode_num.ToStr().Trim() <> "" then return "Episódio " + episode.episode_num.ToStr()
    return "Episódio sem nome"
end function

function getEpisodeLogTitle(episode as Dynamic) as String
    if episode = invalid then return ""
    if episode.title <> invalid and episode.title.ToStr().Trim() <> "" then return episode.title.ToStr()
    return getEpisodeName(episode)
end function

function getEpisodeCover(episode as Dynamic) as String
    if episode = invalid then return ""
    if episode.stream_icon <> invalid and episode.stream_icon.ToStr().Trim() <> "" then return episode.stream_icon.ToStr()
    if episode.cover <> invalid and episode.cover.ToStr().Trim() <> "" then return episode.cover.ToStr()
    if episode.episode_image <> invalid and episode.episode_image.ToStr().Trim() <> "" then return episode.episode_image.ToStr()
    if episode.logo <> invalid and episode.logo.ToStr().Trim() <> "" then return episode.logo.ToStr()
    return ""
end function

function getCategoryName(category as Dynamic) as String
    if category = invalid then return "Categoria"
    if category.category_name <> invalid and category.category_name.ToStr().Trim() <> "" then return category.category_name.ToStr()
    if category.name <> invalid and category.name.ToStr().Trim() <> "" then return category.name.ToStr()
    return "Categoria"
end function

sub clearEpisodeNodes()
    while m.episodesGroup.GetChildCount() > 0
        m.episodesGroup.RemoveChildIndex(0)
    end while
    m.itemNodes = []
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if key = "back" or key = "left" then
        m.top.backRequested = true
        return true
    else if key = "up" then
        moveFocus(-1)
        return true
    else if key = "down" then
        moveFocus(1)
        return true
    else if key = "options" then
        if m.episodes.Count() > 0 and m.selectedIndex >= 0 and m.selectedIndex < m.episodes.Count() then
            m.top.episodeFavoriteToggled = m.episodes[m.selectedIndex]
            m.statusLabel.color = "#5CE08A"
            m.statusLabel.text = "Episódio atualizado nos favoritos."
        end if
        return true
    else if key = "OK" then
        if m.episodes.Count() > 0 and m.selectedIndex >= 0 and m.selectedIndex < m.episodes.Count() then
            m.top.episodeSelected = m.episodes[m.selectedIndex]
        end if
        return true
    end if

    return false
end function

sub moveFocus(direction as Integer)
    handleUpDown(direction)
end sub

sub handleUpDown(direction as Integer)
    if m.episodes.Count() = 0 then return

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
    if m.episodes.Count() = 0 then
        m.selectedIndex = 0
        m.firstVisibleIndex = 0
        return
    end if

    if m.selectedIndex < 0 then m.selectedIndex = 0
    if m.selectedIndex >= m.episodes.Count() then m.selectedIndex = m.episodes.Count() - 1
    if m.firstVisibleIndex < 0 then m.firstVisibleIndex = 0

    maxFirstIndex = m.episodes.Count() - m.visibleItemCount
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
        coverBackground = m.itemNodes[i].FindNode("coverBackground")

        m.itemNodes[i].scale = [1.0, 1.0]
        background.color = "#111827"
        background.opacity = 0.86
        accent.opacity = 0.0
        label.color = "#F8FAFC"
        coverBackground.color = "#1F2937"

        if realIndex = m.selectedIndex then selectedNode = m.itemNodes[i]
    end for

    if selectedNode <> invalid then
        background = selectedNode.FindNode("itemBackground")
        accent = selectedNode.FindNode("itemAccent")
        label = selectedNode.FindNode("itemLabel")
        coverBackground = selectedNode.FindNode("coverBackground")

        selectedNode.scale = [1.02, 1.02]
        background.color = "#0B3A5E"
        background.opacity = 1.0
        accent.opacity = 0.0
        label.color = "#FFFFFF"
        coverBackground.color = "#0F4F7A"
    end if
end sub

function getDisplayResolution() as Object
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()

    return {
        width: displaySize.w
        height: displaySize.h
    }
end function
