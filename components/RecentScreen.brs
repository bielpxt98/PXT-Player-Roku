' Recent viewing history screen.
sub Init()
    m.background = m.top.FindNode("background")
    m.title = m.top.FindNode("title")
    m.statusLabel = m.top.FindNode("statusLabel")
    m.itemsGroup = m.top.FindNode("itemsGroup")
    m.hintLabel = m.top.FindNode("hintLabel")
    configureLayout()
end sub

sub configureLayout()
    size = CreateObject("roDeviceInfo").GetDisplaySize()
    width = size.w : height = size.h
    m.background.width = width : m.background.height = height
    m.title.width = width : m.title.font = "font:LargeBoldSystemFont" : m.title.translation = [0, 42]
    m.statusLabel.width = width - 144 : m.statusLabel.font = "font:MediumSystemFont" : m.statusLabel.translation = [72, 160]
    m.itemsGroup.translation = [72, 140]
    m.hintLabel.width = width : m.hintLabel.font = "font:SmallSystemFont" : m.hintLabel.translation = [0, height - 58]
    m.contentWidth = width - 144
end sub

sub show()
    configureLayout()
    m.top.visible = true
    m.top.SetFocus(true)
end sub

sub hide()
    m.top.visible = false
end sub

sub setHistory(history as Object)
    clearItems()
    if history = invalid then return
    y = 0
    y = addSection("Continuar assistindo", history.continueWatching, y)
    y = addSection("Últimos filmes assistidos", history.movies, y + 18)
    y = addSection("Últimas séries assistidas", history.series, y + 18)
    if y = 0 then
        m.statusLabel.color = "#B8C3D6"
        m.statusLabel.text = "Você ainda não assistiu nenhum conteúdo. Seus itens recentes aparecerão aqui."
    else
        m.statusLabel.text = ""
    end if
end sub

function addSection(title as String, items as Dynamic, startY as Integer) as Integer
    list = []
    if items <> invalid and Type(items) = "roArray" then list = items
    header = CreateObject("roSGNode", "Label")
    header.width = m.contentWidth : header.height = 42 : header.translation = [0, startY]
    header.font = "font:MediumBoldSystemFont" : header.color = "#5CE08A" : header.text = title
    m.itemsGroup.AppendChild(header)
    y = startY + 44
    if list.Count() = 0 then
        label = makeLabel("Nenhum item por enquanto.", y, "#B8C3D6")
        m.itemsGroup.AppendChild(label)
        return y + 42
    end if
    count = 0
    for each item in list
        if count >= 5 then exit for
        m.itemsGroup.AppendChild(makeLabel(historyItemTitle(item), y, "#F8FAFC"))
        y = y + 38 : count = count + 1
    end for
    return y
end function

function makeLabel(text as String, y as Integer, color as String) as Object
    label = CreateObject("roSGNode", "Label")
    label.width = m.contentWidth : label.height = 34 : label.translation = [20, y]
    label.font = "font:MediumSystemFont" : label.color = color : label.text = text
    return label
end function

function historyItemTitle(item as Dynamic) as String
    if item = invalid then return "Item sem título"
    if item.seriesTitle <> invalid and item.seriesTitle.ToStr().Trim() <> "" then return item.seriesTitle.ToStr() + " • " + item.title.ToStr()
    if item.title <> invalid and item.title.ToStr().Trim() <> "" then return item.title.ToStr()
    return "Item sem título"
end function

sub clearItems()
    while m.itemsGroup.GetChildCount() > 0
        m.itemsGroup.RemoveChildIndex(0)
    end while
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "back" then
        m.top.backRequested = true
        return true
    end if
    return false
end function
