' Native Roku player screen for Live TV streams.
sub Init()
    m.video = m.top.FindNode("video")
    m.videoPlayer = m.video
    m.loadingGroup = m.top.FindNode("loadingGroup")
    m.loadingSpinner = m.top.FindNode("loadingSpinner")
    m.loadingLabel = m.top.FindNode("loadingLabel")
    m.errorGroup = m.top.FindNode("errorGroup")
    m.errorTitle = m.top.FindNode("errorTitle")
    m.errorMessage = m.top.FindNode("errorMessage")

    m.channel = invalid
    m.channelName = "Canal ao vivo"
    m.isPlaying = false

    configureLayout()
    m.video.ObserveField("state", "onVideoStateChanged")
    hide()
end sub

sub configureLayout()
    resolution = getDisplayResolution()
    width = resolution.width
    height = resolution.height

    m.video.width = width
    m.video.height = height

    m.loadingGroup.translation = [Int((width - 420) / 2), Int((height - 140) / 2)]
    m.loadingSpinner.translation = [180, 0]
    m.loadingLabel.width = 420
    m.loadingLabel.font = "font:MediumSystemFont"
    m.loadingLabel.translation = [0, 86]

    m.errorGroup.translation = [Int((width - 760) / 2), Int((height - 180) / 2)]
    m.errorTitle.width = 760
    m.errorTitle.font = "font:LargeBoldSystemFont"
    m.errorMessage.width = 760
    m.errorMessage.font = "font:MediumSystemFont"
    m.errorMessage.translation = [0, 78]
end sub

sub show(channel as Dynamic)
    m.channel = channel
    m.channelName = getChannelName(channel)
    m.top.channelName = m.channelName
    print "DEBUG LivePlayerScreen: canal selecionado = " + m.channelName
    m.top.visible = true
    if m.video <> invalid then m.video.visible = true
    showLoading("Preparando " + m.channelName + "...")
    m.top.SetFocus(true)
end sub

sub play(streamUrl as String)
    if streamUrl.Trim() = "" then
        showError("Não foi possível montar a URL deste canal.")
        return
    end if

    content = CreateObject("roSGNode", "ContentNode")
    content.url = streamUrl
    content.title = m.channelName
    content.streamFormat = getStreamFormat(streamUrl)
    content.live = true

    print "DEBUG LivePlayerScreen: URL recebida = " + content.url
    print "DEBUG LivePlayerScreen: Video content url = " + content.url
    print "DEBUG LivePlayerScreen: Video content streamFormat = " + content.streamFormat
    print "DEBUG LivePlayerScreen: Video content title = " + content.title

    m.video.visible = true
    m.video.content = content
    m.video.control = "play"
    print "DEBUG LivePlayerScreen: Video control = play"
    m.isPlaying = true
    showLoading("Carregando " + m.channelName + "...")
end sub

sub hide()
    stopPlayback()
    m.top.visible = false
end sub

sub stopPlayback()
    if m.video <> invalid then
        m.video.control = "stop"
        m.video.content = invalid
    end if
    m.isPlaying = false
    m.loadingSpinner.control = "stop"
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
    m.errorTitle.text = "Não foi possível reproduzir o canal"
    m.errorMessage.text = message + Chr(10) + "Pressione Voltar e tente novamente."
    m.errorGroup.visible = true
end sub

sub onVideoStateChanged()
    state = LCase(m.video.state)
    print "DEBUG LivePlayerScreen: estado do Video node = " + state
    if state = "playing" then
        m.loadingGroup.visible = false
        m.loadingSpinner.control = "stop"
        m.errorGroup.visible = false
    else if state = "error" or state = "finished" then
        print "DEBUG LivePlayerScreen: erro do Video node code = " + safeVideoFieldText(m.video.errorCode)
        print "DEBUG LivePlayerScreen: erro do Video node msg = " + safeVideoFieldText(m.video.errorMsg)
        if m.top.visible = true then
            showError("O stream de " + m.channelName + " não carregou ou foi encerrado pelo servidor.")
        end if
    end if
end sub

function safeVideoFieldText(value as Dynamic) as String
    if value = invalid then return ""
    return value.ToStr()
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if key = "back" then
        return handleBackKeySafely()
    end if

    return false
end function

function handleBackKeySafely() as Boolean
    if m.videoPlayer <> invalid then
        m.videoPlayer.control = "stop"
        m.videoPlayer.visible = false
        m.videoPlayer.content = invalid
    end if

    stopPlayback()
    m.top.visible = false
    parentNode = m.top.GetParent()
    if parentNode <> invalid then
        parentNode.SetFocus(true)
    else
        m.top.SetFocus(true)
    end if
    m.top.backRequested = true
    return true
end function

function getChannelName(channel as Dynamic) as String
    if channel = invalid then return "Canal ao vivo"
    if channel.name <> invalid and channel.name.ToStr().Trim() <> "" then return channel.name.ToStr()
    if channel.title <> invalid and channel.title.ToStr().Trim() <> "" then return channel.title.ToStr()
    return "Canal ao vivo"
end function

function getStreamFormat(streamUrl as String) as String
    lowerUrl = LCase(streamUrl)
    if Instr(1, lowerUrl, ".m3u8") > 0 then return "hls"
    if Instr(1, lowerUrl, ".mp4") > 0 then return "mp4"
    return "ts"
end function

function getDisplayResolution() as Object
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()

    return {
        width: displaySize.w,
        height: displaySize.h
    }
end function
