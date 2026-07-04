' Plays the intro splash video (videos/pxtsplash.mp4) once on app launch.
' MainScene keeps loading data in the background while this plays, then
' listens to the "finished" field to move on to the preparing/home flow.
' A fallback timer guarantees the app never gets stuck here if the video
' fails to load or play on a given device.
sub Init()
    m.background = m.top.FindNode("background")
    m.video = m.top.FindNode("splashVideo")
    m.fallbackTimer = m.top.FindNode("fallbackTimer")

    size = CreateObject("roDeviceInfo").GetDisplaySize()
    m.background.width = size.w
    m.background.height = size.h
    m.video.width = size.w
    m.video.height = size.h

    m.video.ObserveField("state", "onVideoStateChange")
    m.fallbackTimer.ObserveField("fire", "onFallbackTimerFire")
    m.isFinished = false
    m.top.visible = false
end sub

sub show()
    m.isFinished = false
    m.top.visible = true
    m.top.SetFocus(true)

    content = CreateObject("roSGNode", "ContentNode")
    content.url = "pkg:/videos/pxtsplash.mp4"
    m.video.content = content
    m.video.control = "play"

    m.fallbackTimer.control = "stop"
    m.fallbackTimer.control = "start"
end sub

sub hide()
    m.fallbackTimer.control = "stop"
    m.video.control = "stop"
    m.top.visible = false
end sub

sub onVideoStateChange()
    state = m.video.state
    if state = "finished" or state = "error" then finishSplash()
end sub

sub onFallbackTimerFire()
    finishSplash()
end sub

sub finishSplash()
    if m.isFinished = true then return
    m.isFinished = true
    m.fallbackTimer.control = "stop"
    m.top.finished = true
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    return m.top.visible = true
end function
