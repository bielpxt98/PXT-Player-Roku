sub Init()
    m.video = m.top.FindNode("video")
    m.loadingGroup = m.top.FindNode("loadingGroup")
    m.loadingSpinner = m.top.FindNode("loadingSpinner")
    m.loadingLabel = m.top.FindNode("loadingLabel")
    m.errorGroup = m.top.FindNode("errorGroup")
    m.errorTitle = m.top.FindNode("errorTitle")
    m.errorMessage = m.top.FindNode("errorMessage")
    m.isClosing = false
    m.title = "Episódio"
    configureLayout()
    m.video.ObserveField("state", "onVideoStateChanged")
    hide()
end sub

sub configureLayout()
    deviceInfo = CreateObject("roDeviceInfo")
    size = deviceInfo.GetDisplaySize()
    m.video.width = size.w
    m.video.height = size.h
    m.loadingGroup.translation = [Int((size.w - 420) / 2), Int((size.h - 140) / 2)]
    m.loadingSpinner.translation = [180, 0]
    m.loadingLabel.width = 420
    m.loadingLabel.font = "font:MediumSystemFont"
    m.loadingLabel.translation = [0, 86]
    m.errorGroup.translation = [Int((size.w - 760) / 2), Int((size.h - 180) / 2)]
    m.errorTitle.width = 760
    m.errorTitle.font = "font:LargeBoldSystemFont"
    m.errorMessage.width = 760
    m.errorMessage.font = "font:MediumSystemFont"
    m.errorMessage.translation = [0, 78]
end sub

sub show(episode as Dynamic)
    stopPlayback()
    m.isClosing = false
    title = getText(episode, "title", "Episódio")
    streamUrl = getText(episode, "streamUrl", "")
    if streamUrl = "" then streamUrl = getText(episode, "url", "")
    if title = "" then title = "Episódio"
    m.title = title
    m.top.visible = true
    m.top.SetFocus(true)
    if streamUrl = "" then
        showError("Episódio sem link disponível.")
        return
    end if
    content = CreateObject("roSGNode", "ContentNode")
    content.url = streamUrl
    content.title = title
    content.streamFormat = "hls"
    m.video.content = invalid
    m.video.visible = false
    m.video.content = content
    m.video.control = "play"
    showLoading("Carregando " + title + "...")
end sub

sub hide()
    stopPlayback()
    m.top.visible = false
end sub

sub stopPlayback()
    m.isClosing = true
    if m.video <> invalid then
        m.video.control = "stop"
        m.video.visible = false
        m.video.content = invalid
    end if
    if m.loadingSpinner <> invalid then m.loadingSpinner.control = "stop"
end sub

sub showLoading(message as String)
    m.errorGroup.visible = false
    m.loadingLabel.text = message
    m.loadingGroup.visible = true
    m.loadingSpinner.control = "start"
end sub

sub showError(message as String)
    stopPlayback()
    m.loadingGroup.visible = false
    m.errorTitle.text = "Não foi possível reproduzir o episódio"
    m.errorMessage.text = message + Chr(10) + "Pressione Voltar e tente novamente."
    m.errorGroup.visible = true
end sub

sub onVideoStateChanged()
    if m.isClosing = true or m.video = invalid then return
    state = LCase(m.video.state)
    if state = "playing" then
        m.video.visible = true
        m.loadingGroup.visible = false
        m.loadingSpinner.control = "stop"
        m.errorGroup.visible = false
    else if state = "error" then
        showError("Não foi possível reproduzir este episódio.")
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "back" then
        stopPlayback()
        m.top.visible = false
        m.top.backRequested = true
        return true
    end if
    return false
end function

function getText(item as Dynamic, key as String, fallback as String) as String
    if item <> invalid and Type(item) = "roAssociativeArray" and item.DoesExist(key) and item[key] <> invalid then
        value = item[key].ToStr().Trim()
        if value <> "" then return value
    end if
    return fallback
end function
