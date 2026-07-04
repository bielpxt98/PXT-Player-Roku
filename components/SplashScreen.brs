' "Preparando biblioteca" screen. Shown right after the intro video, while
' MainScene loads accounts/categories/cache in the background (see
' startSplashBootstrap in MainScene.brs). It reuses the same background photo
' as the rest of the app so there is no
' visual cut/flash when the video splash hands off to this screen, or when
' this screen hands off to the Home screen.
' The checklist animation is simulated on a timer -- it does not need to
' reflect real network progress, it only needs to communicate that the app
' is getting ready.
sub Init()
    m.background = m.top.FindNode("background")
    m.overlay = m.top.FindNode("overlay")
    m.tickTimer = m.top.FindNode("tickTimer")
    m.progressFill = m.top.FindNode("progressFill")

    m.statuses = [
        { label: m.top.FindNode("status0"), threshold: 0.8, done: false }
        { label: m.top.FindNode("status1"), threshold: 1.8, done: false }
        { label: m.top.FindNode("status2"), threshold: 2.8, done: false }
        { label: m.top.FindNode("status3"), threshold: 3.6, done: false }
    ]

    size = CreateObject("roDeviceInfo").GetDisplaySize()
    m.background.width = size.w
    m.background.height = size.h
    m.overlay.width = size.w
    m.overlay.height = size.h


    m.totalDuration = 4.0
    m.maxBarWidth = 700
    m.elapsed = 0

    m.tickTimer.ObserveField("fire", "onTick")
    m.top.visible = false
end sub

sub show()
    m.elapsed = 0
    m.progressFill.width = 0

    for each item in m.statuses
        item.done = false
        item.label.text = "Esperando..."
        item.label.color = "#9AA4B5"
    end for

    m.top.visible = true
    m.top.SetFocus(true)
    m.tickTimer.control = "stop"
    m.tickTimer.control = "start"
end sub

sub hide()
    m.tickTimer.control = "stop"
    m.top.visible = false
end sub

sub onTick()
    m.elapsed = m.elapsed + 0.1
    progress = m.elapsed / m.totalDuration
    if progress > 1 then progress = 1
    m.progressFill.width = m.maxBarWidth * progress

    for each item in m.statuses
        if item.done <> true and m.elapsed >= item.threshold then
            item.done = true
            item.label.text = "SUCESSO!"
            item.label.color = "#5DCAA5"
        end if
    end for

    if progress >= 1 then m.tickTimer.control = "stop"
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    return m.top.visible = true
end function
