' Minimal replacement screen for the Series entry point.
sub Init()
    m.top.visible = false
    m.top.SetFocus(false)

    titleLabel = m.top.FindNode("titleLabel")
    messageLabel = m.top.FindNode("messageLabel")
    backLabel = m.top.FindNode("backLabel")

    titleLabel.font = "font:LargeBoldSystemFont"
    messageLabel.font = "font:MediumSystemFont"
    backLabel.font = "font:SmallSystemFont"
end sub

sub show()
    m.top.visible = true
    m.top.SetFocus(true)
end sub

sub hide()
    m.top.visible = false
    m.top.SetFocus(false)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press <> true then return false

    if key = "back" then
        m.top.backRequested = true
        return true
    end if

    return false
end function
