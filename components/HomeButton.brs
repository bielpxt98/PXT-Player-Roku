' Reusable Home button used by the PXT Player home menu.
' It keeps visual focus behavior encapsulated so future screens can reuse it.
sub Init()
    m.buttonLabel = m.top.FindNode("buttonLabel")
    m.buttonBackground = m.top.FindNode("buttonBackground")
    m.buttonAccent = m.top.FindNode("buttonAccent")
    m.focusInAnimation = m.top.FindNode("focusInAnimation")
    m.focusOutAnimation = m.top.FindNode("focusOutAnimation")

    m.buttonLabel.font = "font:MediumBoldSystemFont"
    onLabelTextChanged()
    onSelectedChanged()
end sub

sub onLabelTextChanged()
    if m.buttonLabel <> invalid then
        m.buttonLabel.text = m.top.labelText
    end if
end sub

sub onSelectedChanged()
    if m.buttonBackground = invalid then return

    if m.top.selected then
        m.focusOutAnimation.control = "stop"
        m.focusInAnimation.control = "start"
        m.buttonBackground.color = "#0B2239"
        m.buttonAccent.opacity = 1.0
    else
        m.focusInAnimation.control = "stop"
        m.focusOutAnimation.control = "start"
        m.buttonBackground.color = "#111827"
        m.buttonAccent.opacity = 0.55
    end if
end sub
