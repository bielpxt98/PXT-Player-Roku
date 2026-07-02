' Reusable premium card tile for the PXT Player home menu.
sub Init()
    m.tileTitle = m.top.FindNode("tileTitle")
    m.tileImage = m.top.FindNode("tileImage")
    m.tileIcon = m.top.FindNode("tileIcon")
    m.tileIconText = m.top.FindNode("tileIconText")
    m.tileBorder = m.top.FindNode("tileBorder")
    m.tileFocusOverlay = m.top.FindNode("tileFocusOverlay")
    m.outerGlow = m.top.FindNode("outerGlow")
    m.focusInAnimation = m.top.FindNode("focusInAnimation")
    m.focusOutAnimation = m.top.FindNode("focusOutAnimation")

    m.tileTitle.font = "font:LargeBoldSystemFont"
    if m.tileIconText <> invalid then m.tileIconText.font = "font:LargeBoldSystemFont"
    onTitleChanged()
    onImageUriChanged()
    onIconUriChanged()
    onIconTextChanged()
    onBaseColorChanged()
    onFocusedChanged()
end sub

sub onTitleChanged()
    if m.tileTitle <> invalid then m.tileTitle.text = m.top.title
end sub

sub onImageUriChanged()
    if m.tileImage <> invalid and m.top.imageUri <> invalid then m.tileImage.uri = m.top.imageUri
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
    if m.tileImage = invalid then return

    if isFocused then
        m.focusOutAnimation.control = "stop"
        m.focusInAnimation.control = "start"
        m.tileBorder.opacity = 0.86
        m.tileFocusOverlay.opacity = 0.10
        m.tileTitle.color = "#FFFFFF"
    else
        m.focusInAnimation.control = "stop"
        m.focusOutAnimation.control = "start"
        m.tileBorder.opacity = 0.16
        m.tileFocusOverlay.opacity = 0
        m.tileTitle.color = "#FFFFFF"
    end if
end sub
