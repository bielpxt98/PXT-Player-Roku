' Native Roku player screen for series episode streams.
sub Init()
    m.video = m.top.FindNode("video")
    m.loadingGroup = m.top.FindNode("loadingGroup")
    m.loadingSpinner = m.top.FindNode("loadingSpinner")
    m.loadingLabel = m.top.FindNode("loadingLabel")
    m.errorGroup = m.top.FindNode("errorGroup")
    m.errorTitle = m.top.FindNode("errorTitle")
    m.errorMessage = m.top.FindNode("errorMessage")
    m.controlsGroup = m.top.FindNode("controlsGroup")
    m.controlsBackground = m.top.FindNode("controlsBackground")
    m.rewindIcon = m.top.FindNode("rewindIcon")
    m.playPauseIcon = m.top.FindNode("playPauseIcon")
    m.forwardIcon = m.top.FindNode("forwardIcon")
    m.seekHoldTimer = m.top.FindNode("seekHoldTimer")

    m.episode = invalid
    m.episodeName = "Episódio"
    m.isPlaying = false
    m.isClosing = false
    m.resumePosition = 0
    m.lastPosition = 0
    m.seekStep = 10
    m.longSeekStep = 10
    m.holdThresholdMs = 450
    m.heldSeekKey = ""
    m.seekHoldHandled = false
    m.seekPressTimer = invalid
    m.pendingStreamUrl = ""
    m.resumeDialog = invalid

    configureLayout()
    m.video.showPlaybackInfo = false
    m.video.ObserveField("state", "onVideoStateChanged")
    m.seekHoldTimer.ObserveField("fire", "onSeekHoldTimerFire")
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

    controlsWidth = 420
    controlsHeight = 140
    iconSize = 92
    iconGap = 24
    m.controlsGroup.translation = [Int((width - controlsWidth) / 2), Int((height - controlsHeight) / 2)]
    m.controlsBackground.width = controlsWidth
    m.controlsBackground.height = controlsHeight
    m.rewindIcon.translation = [24, 24]
    m.rewindIcon.width = iconSize
    m.rewindIcon.height = iconSize
    m.rewindIcon.font = "font:LargeBoldSystemFont"
    m.playPauseIcon.translation = [24 + iconSize + iconGap, 24]
    m.playPauseIcon.width = iconSize
    m.playPauseIcon.height = iconSize
    m.playPauseIcon.font = "font:LargeBoldSystemFont"
    m.forwardIcon.translation = [24 + ((iconSize + iconGap) * 2), 24]
    m.forwardIcon.width = iconSize
    m.forwardIcon.height = iconSize
    m.forwardIcon.font = "font:LargeBoldSystemFont"
end sub

sub show(episode as Dynamic)
    m.episode = episode
    m.episodeName = getEpisodeName(episode)
    m.top.episodeName = m.episodeName
    m.isClosing = false
    m.top.visible = true
    showLoading("Preparando " + m.episodeName + "...")
    hideControls()
    m.top.SetFocus(true)
end sub

sub play(streamUrl as String)
    if streamUrl.Trim() = "" then
        showError("Não foi possível montar a URL deste episódio.")
        return
    end if

    if m.resumePosition > 30 then
        m.pendingStreamUrl = streamUrl
        showResumeDialog()
        return
    end if

    startPlayback(streamUrl, 0)
end sub

sub startPlayback(streamUrl as String, startPosition as Integer)
    content = CreateObject("roSGNode", "ContentNode")
    content.url = streamUrl
    content.title = m.episodeName
    content.streamFormat = getStreamFormat(streamUrl)
    content.live = false

    m.lastPosition = startPosition
    m.video.visible = true
    m.video.content = content
    if startPosition > 0 then content.PlayStart = startPosition
    m.video.control = "play"
    m.isPlaying = true
    m.top.SetFocus(true)
    showLoading("Carregando " + m.episodeName + "...")
end sub


sub setResumePosition(position as Dynamic)
    if position = invalid then
        m.resumePosition = 0
    else
        m.resumePosition = Int(position)
    end if
end sub

function getPlaybackPosition() as Integer
    if m.video <> invalid and m.video.position <> invalid then
        m.lastPosition = Int(m.video.position)
        return m.lastPosition
    end if
    return m.lastPosition
end function

sub showResumeDialog()
    dialog = CreateObject("roSGNode", "StandardMessageDialog")
    dialog.title = "Continuar de onde parou?"
    dialog.message = "Escolha como deseja iniciar a reprodução."
    dialog.buttons = ["Continuar", "Começar do início"]
    dialog.ObserveField("buttonSelected", "onResumeDialogButtonSelected")
    m.resumeDialog = dialog
    m.top.GetScene().dialog = dialog
end sub

sub onResumeDialogButtonSelected()
    if m.resumeDialog = invalid then return
    selected = m.resumeDialog.buttonSelected
    streamUrl = m.pendingStreamUrl
    m.top.GetScene().dialog = invalid
    m.resumeDialog = invalid
    m.pendingStreamUrl = ""
    if selected = 0 then
        startPlayback(streamUrl, m.resumePosition)
    else
        startPlayback(streamUrl, 0)
    end if
end sub

sub hide()
    stopPlayback()
    m.top.visible = false
end sub

sub stopPlayback()
    m.lastPosition = getPlaybackPosition()
    m.isClosing = true
    if m.resumeDialog <> invalid then
        m.top.GetScene().dialog = invalid
        m.resumeDialog = invalid
    end if
    m.pendingStreamUrl = ""
    if m.video <> invalid then
        m.video.control = "stop"
        m.video.visible = false
        m.video.content = invalid
    end if
    m.isPlaying = false
    if m.loadingSpinner <> invalid then m.loadingSpinner.control = "stop"
    if m.loadingGroup <> invalid then m.loadingGroup.visible = false
    stopSeekHold()
    if m.controlsGroup <> invalid then m.controlsGroup.visible = false
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
        m.isPlaying = true
        m.video.visible = true
        m.loadingGroup.visible = false
        m.loadingSpinner.control = "stop"
        m.errorGroup.visible = false
    else if state = "paused" then
        m.isPlaying = false
        showControls()
    else if state = "finished" then
        m.isPlaying = false
        showControls()
    else if state = "error" then
        if m.top.visible = true and m.isClosing <> true then
            showError("O stream de " + m.episodeName + " não carregou ou foi encerrado pelo servidor.")
        end if
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if key = "right" or key = "left" then
        if press then
            beginSeekHold(key)
        else
            finishSeekHold(key)
        end if
        return true
    end if

    if not press then return false

    if key = "back" then
        stopPlayback()
        m.top.backRequested = true
        return true
    else if key = "OK" then
        togglePause()
        return true
    else if key = "up" then
        showControls()
        return true
    else if key = "down" then
        hideControls()
        return true
    else if key = "replay" then
        seekTo(0)
        return true
    end if

    return false
end function

sub beginSeekHold(key as String)
    if m.heldSeekKey = key then return
    m.heldSeekKey = key
    m.seekHoldHandled = false
    m.seekPressTimer = CreateObject("roTimespan")
    m.seekPressTimer.Mark()
    if m.seekHoldTimer <> invalid then m.seekHoldTimer.control = "start"
    showControls()
end sub

sub finishSeekHold(key as String)
    if m.heldSeekKey <> key then return
    elapsedMs = 0
    if m.seekPressTimer <> invalid then elapsedMs = m.seekPressTimer.TotalMilliseconds()
    wasLongPress = m.seekHoldHandled = true or elapsedMs >= m.holdThresholdMs
    stopSeekHold()
    if not wasLongPress then
        if key = "right" then
            seekBy(m.seekStep)
        else
            seekBy(-m.seekStep)
        end if
    end if
end sub

sub stopSeekHold()
    if m.seekHoldTimer <> invalid then m.seekHoldTimer.control = "stop"
    m.heldSeekKey = ""
    m.seekHoldHandled = false
    m.seekPressTimer = invalid
end sub

sub onSeekHoldTimerFire()
    if m.heldSeekKey = "" or m.seekPressTimer = invalid then return
    if m.seekPressTimer.TotalMilliseconds() < m.holdThresholdMs then return
    m.seekHoldHandled = true
    if m.heldSeekKey = "right" then
        seekBy(m.longSeekStep)
    else
        seekBy(-m.longSeekStep)
    end if
end sub

sub togglePause()
    if m.video = invalid then return
    if m.isPlaying = true then
        m.video.control = "pause"
        m.isPlaying = false
        showControls()
    else
        m.video.control = "resume"
        m.isPlaying = true
        hideControls()
    end if
    updatePlayPauseIcon()
end sub

sub seekBy(delta as Integer)
    seekTo(getPlaybackPosition() + delta)
end sub

sub seekTo(position as Integer)
    if m.video = invalid then return
    if position < 0 then position = 0
    m.video.seek = position
    showControls()
end sub

sub showControls()
    updateControls()
    if m.controlsGroup <> invalid then m.controlsGroup.visible = true
end sub

sub hideControls()
    if m.controlsGroup <> invalid then m.controlsGroup.visible = false
end sub

sub updateControls()
    updatePlayPauseIcon()
end sub

sub updatePlayPauseIcon()
    if m.playPauseIcon = invalid then return
    if m.isPlaying = true then
        m.playPauseIcon.text = "Ⅱ"
    else
        m.playPauseIcon.text = "▶"
    end if
end sub

function formatTime(seconds as Integer) as String
    if seconds < 0 then seconds = 0
    minutes = Int(seconds / 60)
    secs = seconds mod 60
    return twoDigits(minutes) + ":" + twoDigits(secs)
end function

function twoDigits(value as Integer) as String
    if value < 10 then return "0" + value.ToStr()
    return value.ToStr()
end function

function getEpisodeName(episode as Dynamic) as String
    if episode = invalid then return "Episódio"
    if episode.name <> invalid and episode.name.ToStr().Trim() <> "" then return episode.name.ToStr()
    if episode.title <> invalid and episode.title.ToStr().Trim() <> "" then return episode.title.ToStr()
    return "Episódio"
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
