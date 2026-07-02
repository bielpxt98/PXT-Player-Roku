' Reusable premium card tile for the PXT Player home menu.
sub Init()
    m.tileTitle = m.top.FindNode("tileTitle")
    m.tileIcon = m.top.FindNode("tileIcon")
    m.tileIconText = m.top.FindNode("tileIconText")
    m.tileBackground = m.top.FindNode("tileBackground")
    m.tileBorder = m.top.FindNode("tileBorder")
    m.tileColorWash = m.top.FindNode("tileColorWash")
    m.outerGlow = m.top.FindNode("outerGlow")
    m.focusInAnimation = m.top.FindNode("focusInAnimation")
    m.focusOutAnimation = m.top.FindNode("focusOutAnimation")

    m.tileTitle.font = "font:LargeBoldSystemFont"
    if m.tileIconText <> invalid then m.tileIconText.font = "font:LargeBoldSystemFont"
    onTitleChanged()
    onIconUriChanged()
    onIconTextChanged()
    onBaseColorChanged()
    onFocusedChanged()
end sub

sub onTitleChanged()
    if m.tileTitle <> invalid then m.tileTitle.text = m.top.title
end sub

sub onIconUriChanged()
    if m.tileIcon <> invalid and m.top.iconUri <> invalid then m.tileIcon.uri = m.top.iconUri
end sub

sub onIconTextChanged()
    if m.tileIconText = invalid then return
    iconText = ""
    if m.top.iconText <> invalid then iconText = m.top.iconText
    m.tileIconText.text = iconText
    m.tileIconText.visible = iconText <> ""
    if m.tileIcon <> invalid then m.tileIcon.visible = not m.tileIconText.visible
end sub

sub onBaseColorChanged()
    if m.top.baseColor = invalid or m.top.baseColor = "" then return

    if m.tileColorWash <> invalid then m.tileColorWash.color = m.top.baseColor
    if m.tileBorder <> invalid then m.tileBorder.color = m.top.baseColor
    if m.outerGlow <> invalid then m.outerGlow.color = m.top.baseColor
end sub

sub onFocusedChanged()
    applyFocusState(m.top.focused or m.top.selected)
end sub

sub onSelectedChanged()
    applyFocusState(m.top.focused or m.top.selected)
end sub

sub applyFocusState(isFocused as Boolean)
    if m.tileBackground = invalid then return

    if isFocused then
        m.focusOutAnimation.control = "stop"
        m.focusInAnimation.control = "start"
        m.tileBackground.color = "#0B1424"
        m.tileBackground.opacity = 0.96
        m.tileBorder.opacity = 0.86
        m.tileColorWash.opacity = 0.34
        m.tileTitle.color = "#FFFFFF"
    else
        m.focusInAnimation.control = "stop"
        m.focusOutAnimation.control = "start"
        m.tileBackground.color = "#07101F"
        m.tileBackground.opacity = 0.88
        m.tileBorder.opacity = 0.16
        m.tileColorWash.opacity = 0.20
        m.tileTitle.color = "#FFFFFF"
    end if
end sub
