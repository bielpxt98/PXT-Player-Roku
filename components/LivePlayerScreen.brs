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
    m.isClosing = false
    m.isLoading = false
    m.currentStreamUrl = ""
    m.lastObservedPosition = -1
    m.stalledTicks = 0
    m.resyncAttempts = 0
    m.loadingTimer = CreateObject("roSGNode", "Timer")
    m.loadingTimer.duration = 15
    m.loadingTimer.repeat = false
    m.top.AppendChild(m.loadingTimer)
    m.resyncTimer = CreateObject("roSGNode", "Timer")
    m.resyncTimer.duration = 6
    m.resyncTimer.repeat = true
    m.top.AppendChild(m.resyncTimer)

    configureLayout()
    m.video.ObserveField("state", "onVideoStateChanged")
    m.loadingTimer.ObserveField("fire", "onLoadingTimeout")
    m.resyncTimer.ObserveField("fire", "onResyncTick")
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
    stopPlayback()
    m.isClosing = false
    m.channel = channel
    m.channelName = getChannelName(channel)
    m.top.channelName = m.channelName
    if m.video <> invalid then
        m.video.content = invalid
        m.video.visible = false
    end if
    m.top.visible = true
    showLoading("Preparando " + m.channelName + "...")
    m.top.SetFocus(true)
end sub

sub play(streamUrl as String)
    cleanUrl = streamUrl.Trim()
    if cleanUrl = "" or not isSupportedLiveUrl(cleanUrl) then
        showError("Stream sem URL válida")
        return
    end if
    if m.channelName.Trim() = "" then m.channelName = "Canal ao vivo"

    if m.video = invalid or m.isClosing = true then return

    m.currentStreamUrl = cleanUrl
    m.lastObservedPosition = -1
    m.stalledTicks = 0
    m.resyncAttempts = 0
    startLiveEdgePlayback(cleanUrl, m.channelName)
end sub

sub hide()
    stopPlayback()
    m.top.visible = false
end sub

sub stopPlayback()
    m.isClosing = true
    if m.video <> invalid then
        clearVideoForLiveEdge()
    end if
    m.currentStreamUrl = ""
    m.lastObservedPosition = -1
    m.stalledTicks = 0
    m.resyncAttempts = 0
    m.isPlaying = false
    m.isLoading = false
    if m.loadingTimer <> invalid then m.loadingTimer.control = "stop"
    if m.resyncTimer <> invalid then m.resyncTimer.control = "stop"
    m.loadingSpinner.control = "stop"
end sub


sub clearVideoForLiveEdge()
    ' Reuse the Video node, but remove every reference to the previous live stream
    ' so channel changes never resume from an old live buffer.
    if m.video = invalid then return
    m.video.control = "stop"
    m.video.visible = false
    m.video.content = invalid
end sub

sub startLiveEdgePlayback(streamUrl as String, title as String)
    if m.video = invalid or m.isClosing = true then return

    content = CreateObject("roSGNode", "ContentNode")
    content.url = streamUrl
    content.title = title
    content.streamFormat = getStreamFormat(streamUrl)
    content.live = true

    print "LIVE PLAYER URL: "; streamUrl
    clearVideoForLiveEdge()
    m.video.content = content
    m.video.control = "play"
    m.isPlaying = true
    showLoading("Carregando " + m.channelName + "...")
    startLoadingTimeout()
end sub

sub restartCurrentLiveStream(reason as String)
    if m.currentStreamUrl = "" or m.top.visible <> true or m.isClosing = true then return
    m.resyncAttempts = m.resyncAttempts + 1
    print "LIVE PLAYER RESYNC ("; reason; ") attempt "; m.resyncAttempts
    m.lastObservedPosition = -1
    m.stalledTicks = 0
    startLiveEdgePlayback(m.currentStreamUrl, m.channelName)
end sub

sub onResyncTick()
    if m.top.visible <> true or m.isClosing = true or m.video = invalid or m.currentStreamUrl = "" then return
    state = LCase(m.video.state)
    if state = "error" then return

    if state = "buffering" or state = "loading" then
        m.stalledTicks = m.stalledTicks + 1
        if m.stalledTicks >= 2 then
            if m.resyncAttempts < 1 then
                restartCurrentLiveStream("stalled " + state)
            else
                showError("Não foi possível reproduzir o canal")
            end if
        end if
        return
    end if

    if state = "playing" then
        currentPosition = -1
        if m.video.position <> invalid then currentPosition = Int(m.video.position)
        if currentPosition >= 0 and currentPosition = m.lastObservedPosition then
            m.stalledTicks = m.stalledTicks + 1
        else
            m.stalledTicks = 0
            m.resyncAttempts = 0
        end if
        m.lastObservedPosition = currentPosition
        if m.stalledTicks >= 3 then restartCurrentLiveStream("unchanged playback position")
    end if
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
    if m.isClosing = true or m.video = invalid then return
    state = LCase(m.video.state)
    print "LIVE PLAYER STATE: "; state
    if state = "playing" then
        m.isLoading = false
        if m.loadingTimer <> invalid then m.loadingTimer.control = "stop"
        m.video.visible = true
        m.loadingGroup.visible = false
        m.loadingSpinner.control = "stop"
        m.errorGroup.visible = false
    else if state = "buffering" or state = "loading" then
        if m.isPlaying = true then
            showLoading("Carregando " + m.channelName + "...")
            if m.isLoading <> true then startLoadingTimeout()
        end if
    else if state = "error" then
        if m.top.visible = true and m.isClosing <> true then
            showError("Não foi possível reproduzir este canal.")
        end if
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if key = "back" then
        return handleBackKeySafely()
    end if

    return false
end function

function handleBackKeySafely() as Boolean
    m.isClosing = true

    stopPlayback()
    if m.video <> invalid then m.video.SetFocus(false)
    m.top.SetFocus(false)
    m.top.visible = false

    parentNode = m.top.GetParent()
    if parentNode <> invalid then parentNode.SetFocus(true)
    m.top.backRequested = true
    return true
end function

function getChannelName(channel as Dynamic) as String
    if channel = invalid then return "Canal ao vivo"
    if channel.name <> invalid and channel.name.ToStr().Trim() <> "" then return channel.name.ToStr()
    if channel.title <> invalid and channel.title.ToStr().Trim() <> "" then return channel.title.ToStr()
    return "Canal ao vivo"
end function

sub startLoadingTimeout()
    m.isLoading = true
    if m.loadingTimer <> invalid then
        m.loadingTimer.control = "stop"
        m.loadingTimer.control = "start"
    end if
    if m.resyncTimer <> invalid then
        m.resyncTimer.control = "stop"
        m.resyncTimer.control = "start"
    end if
end sub

sub onLoadingTimeout()
    if m.top.visible = true and m.isClosing <> true and m.isLoading = true then
        showError("Não foi possível reproduzir o canal")
    end if
end sub

function isSupportedLiveUrl(streamUrl as String) as Boolean
    lowerUrl = LCase(streamUrl)
    return Instr(1, lowerUrl, ".m3u8") > 0 or Instr(1, lowerUrl, ".ts") > 0
end function

function getStreamFormat(streamUrl as String) as String
    lowerUrl = LCase(streamUrl)
    if Instr(1, lowerUrl, ".m3u8") > 0 then return "hls"
    if Instr(1, lowerUrl, ".ts") > 0 then return "ts"
    return "hls"
end function

function getDisplayResolution() as Object
    deviceInfo = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()

    return {
        width: displaySize.w,
        height: displaySize.h
    }
end function
