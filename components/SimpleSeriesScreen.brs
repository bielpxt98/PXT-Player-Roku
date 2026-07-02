' Minimal Series screen prepared for fixed navigation and the future category list.
sub Init()
    m.top.visible = false
    m.top.SetFocus(false)

    m.selectedIndex = 0
    m.activePanel = "categories"
    m.fixedItems = ["PESQUISAR", "FAVORITOS", "ÚLTIMOS ASSISTIDOS", "SÉRIES DEMO", "AVENTURA DEMO", "TECNOLOGIA DEMO"]
    m.demoSeries = []
    m.demoCategories = []

    m.background = m.top.FindNode("background")
    m.panel = m.top.FindNode("panel")
    m.titleLabel = m.top.FindNode("titleLabel")
    m.topDivider = m.top.FindNode("topDivider")
    m.categoriesTitleLabel = m.top.FindNode("categoriesTitleLabel")
    m.seriesTitleLabel = m.top.FindNode("seriesTitleLabel")
    m.verticalDivider = m.top.FindNode("verticalDivider")
    m.categoryFocus = m.top.FindNode("categoryFocus")
    m.seriesFocus = m.top.FindNode("seriesFocus")
    m.searchLabel = m.top.FindNode("searchLabel")
    m.favoritesLabel = m.top.FindNode("favoritesLabel")
    m.recentLabel = m.top.FindNode("recentLabel")
    m.watchedLabel = m.top.FindNode("watchedLabel")
    m.dynamicCategoryLabels = []
    m.dynamicSeriesLabels = []
    m.emptyMessageLabel = m.top.FindNode("emptyMessageLabel")
    m.statusLabel = m.top.FindNode("statusLabel")
    m.bottomDivider = m.top.FindNode("bottomDivider")
    m.helpLabel = m.top.FindNode("helpLabel")

    m.titleLabel.font = "font:LargeBoldSystemFont"
    m.categoriesTitleLabel.font = "font:MediumBoldSystemFont"
    m.seriesTitleLabel.font = "font:MediumBoldSystemFont"
    m.emptyMessageLabel.font = "font:MediumSystemFont"
    m.helpLabel.font = "font:SmallSystemFont"
    m.statusLabel.font = "font:SmallSystemFont"

    m.searchLabel.font = "font:MediumBoldSystemFont"
    m.favoritesLabel.font = "font:MediumSystemFont"
    m.recentLabel.font = "font:MediumSystemFont"
    m.watchedLabel.font = "font:MediumSystemFont"

    configureLayout()
    updateNavigationState()
end sub

sub configureLayout()
    resolution = getDisplayResolution()
    width = resolution.width
    height = resolution.height

    m.screenWidth = width
    m.screenHeight = height
    m.safeMarginX = Int(width * 0.055)
    if m.safeMarginX < 48 then m.safeMarginX = 48
    m.safeMarginY = Int(height * 0.055)
    if m.safeMarginY < 36 then m.safeMarginY = 36

    m.titleHeight = 96
    m.footerHeight = 84
    if height <= 720 then
        m.titleHeight = 76
        m.footerHeight = 64
    end if

    m.panelX = m.safeMarginX
    m.panelY = m.safeMarginY
    m.panelWidth = width - (m.safeMarginX * 2)
    m.panelHeight = height - (m.safeMarginY * 2)
    if m.panelWidth < 320 then
        m.panelX = 0
        m.panelWidth = width
    end if
    if m.panelHeight < 240 then
        m.panelY = 0
        m.panelHeight = height
    end if

    m.headerBottomY = m.panelY + m.titleHeight
    m.footerTopY = m.panelY + m.panelHeight - m.footerHeight
    contentHeight = m.footerTopY - m.headerBottomY
    m.leftPanelWidth = Int(m.panelWidth * 0.28)
    if m.leftPanelWidth < 260 then m.leftPanelWidth = 260
    if m.leftPanelWidth > Int(m.panelWidth * 0.36) then m.leftPanelWidth = Int(m.panelWidth * 0.36)
    m.rightPanelX = m.panelX + m.leftPanelWidth
    m.rightPanelWidth = m.panelWidth - m.leftPanelWidth

    m.background.translation = [0, 0]
    m.background.width = width
    m.background.height = height

    m.panel.translation = [m.panelX, m.panelY]
    m.panel.width = m.panelWidth
    m.panel.height = m.panelHeight

    m.titleLabel.translation = [m.panelX, m.panelY]
    m.titleLabel.width = m.panelWidth
    m.titleLabel.height = m.titleHeight

    m.topDivider.translation = [m.panelX, m.headerBottomY]
    m.topDivider.width = m.panelWidth

    titleY = m.headerBottomY + 32
    if height <= 720 then titleY = m.headerBottomY + 20
    m.categoriesTitleLabel.translation = [m.panelX + 42, titleY]
    m.categoriesTitleLabel.width = m.leftPanelWidth - 72
    m.seriesTitleLabel.translation = [m.rightPanelX + 42, titleY]
    m.seriesTitleLabel.width = m.rightPanelWidth - 84

    m.verticalDivider.translation = [m.rightPanelX, m.headerBottomY]
    m.verticalDivider.height = contentHeight

    m.itemHeight = 66
    m.focusHeight = 54
    if height <= 720 then
        m.itemHeight = 54
        m.focusHeight = 46
    end if
    m.firstItemY = titleY + 86
    if m.firstItemY + (m.fixedItems.Count() * m.itemHeight) > m.footerTopY - 20 then
        m.firstItemY = titleY + 58
    end if

    m.categoryFocus.width = m.leftPanelWidth - 76
    m.categoryFocus.height = m.focusHeight
    m.categoryFocus.translation = [m.panelX + 32, m.firstItemY]

    labels = [m.searchLabel, m.favoritesLabel, m.recentLabel, m.watchedLabel]
    for i = 0 to labels.Count() - 1
        labels[i].translation = [m.panelX + 56, m.firstItemY + (i * m.itemHeight) + 6]
        labels[i].width = m.leftPanelWidth - 100
        labels[i].height = m.focusHeight
    end for

    m.seriesFocus.translation = [m.rightPanelX + 28, m.headerBottomY + 28]
    m.seriesFocus.width = m.rightPanelWidth - 56
    m.seriesFocus.height = contentHeight - 56

    messageWidth = m.rightPanelWidth - 96
    messageHeight = 164
    messageX = m.rightPanelX + 48
    messageY = m.headerBottomY + Int((contentHeight - messageHeight) / 2) - 20
    m.emptyMessageLabel.translation = [messageX, messageY]
    m.emptyMessageLabel.width = messageWidth
    m.emptyMessageLabel.height = messageHeight
    m.statusLabel.translation = [messageX, messageY + messageHeight]
    m.statusLabel.width = messageWidth
    m.statusLabel.height = 56

    m.bottomDivider.translation = [m.panelX, m.footerTopY]
    m.bottomDivider.width = m.panelWidth
    m.helpLabel.translation = [m.panelX + 42, m.footerTopY + 20]
    m.helpLabel.width = m.panelWidth - 84
    m.helpLabel.height = m.footerHeight - 20
end sub

sub show()
    configureLayout()
    m.top.visible = true
    m.top.SetFocus(true)
    m.selectedIndex = 0
    m.activePanel = "categories"
    m.statusLabel.text = ""
    updateNavigationState()
end sub

sub hide()
    m.top.visible = false
    m.top.SetFocus(false)
end sub

sub setDemoData(data as Object)
    if data = invalid then return
    if data.categories <> invalid then m.demoCategories = data.categories
    if data.series <> invalid then m.demoSeries = data.series
    m.fixedItems = []
    for each category in m.demoCategories
        if category.name <> invalid then m.fixedItems.Push(category.name.ToStr())
    end for
    if m.fixedItems.Count() = 0 then m.fixedItems = ["PESQUISAR", "FAVORITOS", "ÚLTIMOS ASSISTIDOS", "SÉRIES DEMO"]
    renderDynamicCategories()
    renderSeriesList(m.demoSeries)
end sub

sub renderDynamicCategories()
    for each label in m.dynamicCategoryLabels
        m.top.RemoveChild(label)
    end for
    m.dynamicCategoryLabels = []
    baseLabels = [m.searchLabel, m.favoritesLabel, m.recentLabel, m.watchedLabel]
    for i = 0 to m.fixedItems.Count() - 1
        if i < baseLabels.Count() then
            label = baseLabels[i]
        else
            label = CreateObject("roSGNode", "Label")
            label.font = "font:MediumSystemFont"
            label.color = "#B9C4CF"
            m.top.AppendChild(label)
            m.dynamicCategoryLabels.Push(label)
        end if
        label.translation = [m.panelX + 56, m.firstItemY + (i * m.itemHeight) + 6]
        label.width = m.leftPanelWidth - 100
        label.height = m.focusHeight
    end for
end sub

sub renderSeriesList(items as Object)
    for each label in m.dynamicSeriesLabels
        m.top.RemoveChild(label)
    end for
    m.dynamicSeriesLabels = []
    y = m.headerBottomY + 96
    for each item in items
        label = CreateObject("roSGNode", "Label")
        label.text = item.name + "  •  " + item.genre + "  •  " + item.releaseDate
        label.color = "#FFFFFF"
        label.font = "font:MediumSystemFont"
        label.translation = [m.rightPanelX + 58, y]
        label.width = m.rightPanelWidth - 116
        label.height = 48
        m.top.AppendChild(label)
        m.dynamicSeriesLabels.Push(label)
        y = y + 60
    end for
    if items <> invalid and items.Count() > 0 then
        m.emptyMessageLabel.text = "Selecione uma série demo na lista. Episódios usam HLS público."
    end if
end sub


sub updateNavigationState()
    labels = [m.searchLabel, m.favoritesLabel, m.recentLabel, m.watchedLabel]
    for each dynLabel in m.dynamicCategoryLabels
        labels.Push(dynLabel)
    end for

    m.categoryFocus.translation = [m.panelX + 32, m.firstItemY + (m.selectedIndex * m.itemHeight)]

    for i = 0 to labels.Count() - 1
        if i = m.selectedIndex and m.activePanel = "categories" then
            labels[i].text = "> " + m.fixedItems[i]
            labels[i].color = "#FFFFFF"
            labels[i].font = "font:MediumBoldSystemFont"
        else
            labels[i].text = "  " + m.fixedItems[i]
            labels[i].color = "#B9C4CF"
            labels[i].font = "font:MediumSystemFont"
        end if
    end for

    if m.activePanel = "series" then
        m.categoryFocus.opacity = 0.35
        m.seriesFocus.opacity = 0.9
    else
        m.categoryFocus.opacity = 0.95
        m.seriesFocus.opacity = 0.0
    end if
end sub

sub showPendingMessage()
    m.statusLabel.text = "Função será ativada na próxima etapa."
end sub

sub showDemoSeriesInfo()
    if m.selectedIndex = 0 then
        renderSeriesList(m.demoSeries)
        m.statusLabel.text = "Pesquisa demo local: Breaking Code, Space Mission e Demo Adventures."
    else
        m.statusLabel.text = "Série demo pronta: abra a lista para validar capas, detalhes e episódios HLS."
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press <> true then return false

    if key = "back" then
        m.top.backRequested = true
        return true
    else if key = "up" then
        if m.activePanel = "categories" then
            m.selectedIndex = m.selectedIndex - 1
            if m.selectedIndex < 0 then m.selectedIndex = m.fixedItems.Count() - 1
            m.statusLabel.text = ""
            updateNavigationState()
        end if
        return true
    else if key = "down" then
        if m.activePanel = "categories" then
            m.selectedIndex = m.selectedIndex + 1
            if m.selectedIndex >= m.fixedItems.Count() then m.selectedIndex = 0
            m.statusLabel.text = ""
            updateNavigationState()
        end if
        return true
    else if key = "right" then
        m.activePanel = "series"
        m.statusLabel.text = ""
        updateNavigationState()
        return true
    else if key = "left" then
        m.activePanel = "categories"
        m.statusLabel.text = ""
        updateNavigationState()
        return true
    else if key = "OK" then
        if m.demoSeries <> invalid and m.demoSeries.Count() > 0 then
            showDemoSeriesInfo()
        else
            showPendingMessage()
        end if
        return true
    end if

    return false
end function
