' Reusable premium Home button used by the PXT Player home menu.
sub Init()
    m.buttonLabel = m.top.FindNode("buttonLabel")
    m.buttonIcon = m.top.FindNode("buttonIcon")
    m.buttonBackground = m.top.FindNode("buttonBackground")
    m.buttonAccent = m.top.FindNode("buttonAccent")
    m.focusGlow = m.top.FindNode("focusGlow")
    m.focusInAnimation = m.top.FindNode("focusInAnimation")
    m.focusOutAnimation = m.top.FindNode("focusOutAnimation")

    m.buttonLabel.font = "font:SmallBoldSystemFont"
    m.buttonIcon.font = "font:LargeBoldSystemFont"
    onLabelTextChanged()
    onIconTextChanged()
    onAccentColorChanged()
    onSelectedChanged()
end sub

sub onLabelTextChanged()
    if m.buttonLabel <> invalid then
        m.buttonLabel.text = m.top.labelText
    end if
end sub

sub onIconTextChanged()
    if m.buttonIcon <> invalid then
        m.buttonIcon.text = m.top.iconText
    end if
end sub

sub onAccentColorChanged()
    if m.buttonAccent <> invalid and m.top.accentColor <> invalid and m.top.accentColor <> "" then
        m.buttonAccent.color = m.top.accentColor
        m.focusGlow.color = m.top.accentColor
        m.buttonIcon.color = m.top.accentColor
    end if
end sub

sub onSelectedChanged()
    if m.buttonBackground = invalid then return

    if m.top.selected then
        m.focusOutAnimation.control = "stop"
        m.focusInAnimation.control = "start"
        m.buttonBackground.color = "#0B1220"
        m.buttonBackground.opacity = 0.94
        m.buttonAccent.opacity = 0.28
    else
        m.focusInAnimation.control = "stop"
        m.focusOutAnimation.control = "start"
        m.buttonBackground.color = "#050A14"
        m.buttonBackground.opacity = 0.82
        m.buttonAccent.opacity = 0.16
    end if
end sub
