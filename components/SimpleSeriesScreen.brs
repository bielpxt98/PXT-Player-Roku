' Minimal Series screen prepared for fixed navigation and the future category list.
sub Init()
    m.top.visible = false
    m.top.SetFocus(false)

    m.selectedIndex = 0
    m.activePanel = "categories"
    m.fixedItems = ["PESQUISAR", "FAVORITOS", "ÚLTIMOS ASSISTIDOS"]

    m.categoryFocus = m.top.FindNode("categoryFocus")
    m.seriesFocus = m.top.FindNode("seriesFocus")
    m.searchLabel = m.top.FindNode("searchLabel")
    m.favoritesLabel = m.top.FindNode("favoritesLabel")
    m.recentLabel = m.top.FindNode("recentLabel")
    m.statusLabel = m.top.FindNode("statusLabel")

    titleLabel = m.top.FindNode("titleLabel")
    categoriesTitleLabel = m.top.FindNode("categoriesTitleLabel")
    seriesTitleLabel = m.top.FindNode("seriesTitleLabel")
    emptyMessageLabel = m.top.FindNode("emptyMessageLabel")
    helpLabel = m.top.FindNode("helpLabel")

    titleLabel.font = "font:LargeBoldSystemFont"
    categoriesTitleLabel.font = "font:MediumBoldSystemFont"
    seriesTitleLabel.font = "font:MediumBoldSystemFont"
    emptyMessageLabel.font = "font:MediumSystemFont"
    helpLabel.font = "font:SmallSystemFont"
    m.statusLabel.font = "font:SmallSystemFont"

    m.searchLabel.font = "font:MediumBoldSystemFont"
    m.favoritesLabel.font = "font:MediumSystemFont"
    m.recentLabel.font = "font:MediumSystemFont"

    updateNavigationState()
end sub

sub show()
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

sub updateNavigationState()
    labels = [m.searchLabel, m.favoritesLabel, m.recentLabel]
    yPositions = [326, 396, 466]

    m.categoryFocus.translation = [150, yPositions[m.selectedIndex]]

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
        showPendingMessage()
        return true
    end if

    return false
end function
