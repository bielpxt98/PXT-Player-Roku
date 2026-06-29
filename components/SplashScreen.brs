' Lightweight startup splash. It owns only presentation and key blocking;
' MainScene controls bootstrap timing so this screen never keeps the app stuck.
sub Init()
    m.background = m.top.FindNode("background")
    m.content = m.top.FindNode("content")
    m.iconLabel = m.top.FindNode("iconLabel")
    m.phaseLabel = m.top.FindNode("phaseLabel")
    m.brandLabel = m.top.FindNode("brandLabel")
    m.statusLabel = m.top.FindNode("statusLabel")
    m.animationTimer = m.top.FindNode("animationTimer")
    m.phaseIndex = 0
    m.phases = [
        { icon: "▣", label: "TV AO VIVO" },
        { icon: "▶", label: "FILMES" },
        { icon: "▶", label: "SÉRIES" },
        { icon: "⏯", label: "PLAYER" }
    ]

    size = CreateObject("roDeviceInfo").GetDisplaySize()
    m.background.width = size.w
    m.background.height = size.h
    m.content.translation = [size.w / 2, size.h / 2 - 30]

    m.animationTimer.ObserveField("fire", "onAnimationTick")
    m.top.visible = false
end sub

sub show()
    m.phaseIndex = 0
    m.top.visible = true
    m.top.SetFocus(true)
    applyPhase()
    m.animationTimer.control = "start"
end sub

sub hide()
    m.animationTimer.control = "stop"
    m.top.visible = false
end sub

sub onAnimationTick()
    m.phaseIndex = m.phaseIndex + 1
    applyPhase()
end sub

sub applyPhase()
    if m.phaseIndex < m.phases.Count() then
        phase = m.phases[m.phaseIndex]
        m.iconLabel.text = phase.icon
        m.phaseLabel.text = phase.label
        m.phaseLabel.opacity = 1
        m.brandLabel.opacity = 0
        m.iconLabel.rotation = m.iconLabel.rotation + 0.35
    else
        m.iconLabel.text = "▶"
        m.phaseLabel.text = ""
        m.phaseLabel.opacity = 0
        m.brandLabel.opacity = 1
        m.statusLabel.text = "Carregamento concluído"
        m.iconLabel.rotation = m.iconLabel.rotation + 0.35
        if m.phaseIndex > m.phases.Count() + 1 then m.phaseIndex = 0
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    return m.top.visible = true
end function
