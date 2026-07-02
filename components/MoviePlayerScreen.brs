' Native Roku player screen for movie streams.
sub Init()
    m.cleanBackground = m.top.FindNode("cleanBackground")
    m.video = m.top.FindNode("video")
    m.videoPlayer = m.video
    m.loadingGroup = m.top.FindNode("loadingGroup")
    m.loadingSpinner = m.top.FindNode("loadingSpinner")
    m.loadingLabel = m.top.FindNode("loadingLabel")
    m.errorGroup = m.top.FindNode("errorGroup")
    m.errorTitle = m.top.FindNode("errorTitle")
    m.errorMessage = m.top.FindNode("errorMessage")
    m.controlsGroup = m.top.FindNode("controlsGroup")
    m.controlsBackground = m.top.FindNode("controlsBackground")
    m.progressBackground = m.top.FindNode("progressBackground")
    m.progressFill = m.top.FindNode("progressFill")
    m.currentTimeLabel = m.top.FindNode("currentTimeLabel")
    m.durationLabel = m.top.FindNode("durationLabel")
    m.playPauseIcon = m.top.FindNode("playPauseIcon")
    m.progressUpdateTimer = m.top.FindNode("progressUpdateTimer")
    m.seekHoldTimer = m.top.FindNode("seekHoldTimer")
    m.controlsAutoHideTimer = m.top.FindNode("controlsAutoHideTimer")

    m.movie = invalid
    m.movieName = "Filme"
    m.isPlaying = false
    m.isClosing = false
    m.isReturningFromPlayer = false
    m.resumePosition = 0
    m.lastPosition = 0
    m.seekStep = 20
    m.seekDirection = ""
    m.pendingSeekPosition = invalid
    m.isHoldingSeek = false
    m.pendingStreamUrl = ""
    m.resumeDialog = invalid

    configureLayout()
    m.video.showPlaybackInfo = false
    m.video.ObserveField("state", "onVideoStateChanged")
    m.progressUpdateTimer.ObserveField("fire", "onProgressUpdateTimerFire")
    m.seekHoldTimer.ObserveField("fire", "onSeekHoldTick")
    m.controlsAutoHideTimer.ObserveField("fire", "onControlsAutoHideTimerFire")
    hide()
end sub

sub configureLayout()
    resolution = getDisplayResolution()
    width = resolution.width
    height = resolution.height

    m.cleanBackground.width = width
    m.cleanBackground.height = height
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

    controlsWidth = width
    controlsHeight = 116
    progressWidth = width - 220
    controlsTop = height - controlsHeight
    m.controlsGroup.translation = [0, controlsTop]
    m.controlsBackground.width = controlsWidth
    m.controlsBackground.height = controlsHeight
    m.playPauseIcon.translation = [42, 18]
    m.playPauseIcon.width = 52
    m.playPauseIcon.height = 52
    m.playPauseIcon.font = "font:LargeBoldSystemFont"
    m.currentTimeLabel.translation = [42, 74]
    m.currentTimeLabel.width = 76
    m.currentTimeLabel.font = "font:SmallSystemFont"
    m.durationLabel.translation = [width - 118, 74]
    m.durationLabel.width = 76
    m.durationLabel.font = "font:SmallSystemFont"
    m.progressBackground.translation = [120, 82]
    m.progressBackground.width = progressWidth
    m.progressBackground.height = 8
    m.progressFill.translation = [120, 82]
    m.progressFill.width = 0
    m.progressFill.height = 8
end sub

sub show(movie as Dynamic)
    m.movie = movie
    m.movieName = getMovieName(movie)
    m.top.movieName = m.movieName
    m.isClosing = false
    m.isReturningFromPlayer = false
    m.video.visible = false
    m.top.visible = true
    showLoading("Preparando " + m.movieName + "...")
    hideControls()
    m.top.SetFocus(true)
end sub

sub play(streamUrl as String)
    if streamUrl.Trim() = "" then
        showError("Não foi possível montar a URL deste filme.")
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
    content.title = m.movieName
    content.streamFormat = getStreamFormat(streamUrl)
    content.live = false

    m.lastPosition = startPosition
    m.video.visible = true
    m.video.content = content
    if startPosition > 0 then content.PlayStart = startPosition
    m.video.control = "play"
    m.isPlaying = true
    startProgressUpdateTimer()
    m.top.SetFocus(true)
    showLoading("Carregando " + m.movieName + "...")
    showControls()
end sub


sub setResumePosition(position as Dynamic)
    if position = invalid then
        m.resumePosition = 0
    else
        m.resumePosition = Int(position)
    end if
end sub

function getPlaybackPosition() as Integer
    if m.lastPosition <> invalid and m.lastPosition > 0 and (m.video = invalid or m.video.position = invalid or Int(m.video.position) = 0) then return Int(m.lastPosition)
    if m.video <> invalid and m.video.position <> invalid then return Int(m.video.position)
    return 0
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
    stopProgressUpdateTimer()
    stopSeekHold()
    stopControlsAutoHideTimer()
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
    m.errorTitle.text = "Não foi possível reproduzir o filme"
    m.errorMessage.text = message + Chr(10) + "Pressione Voltar e tente novamente."
    m.errorGroup.visible = true
end sub

sub onVideoStateChanged()
    if m.isReturningFromPlayer = true then return
    if m.isClosing = true or m.video = invalid then return
    state = LCase(m.video.state)
    if state = "playing" then
        m.isPlaying = true
        m.video.visible = true
        m.loadingGroup.visible = false
        m.loadingSpinner.control = "stop"
        m.errorGroup.visible = false
        startProgressUpdateTimer()
        showControls()
    else if state = "buffering" or state = "loading" then
        showLoading("Carregando " + m.movieName + "...")
    else if state = "paused" then
        m.isPlaying = false
        showControls()
    else if state = "finished" then
        m.isPlaying = false
        stopProgressUpdateTimer()
        showControls()
    else if state = "error" then
        if m.top.visible = true and m.isClosing <> true then
            showError("O stream de " + m.movieName + " não carregou ou foi encerrado pelo servidor.")
        end if
    end if
end sub

function isSeekKey(key as String) as Boolean
    return normalizeSeekDirection(key) <> ""
end function

function normalizeSeekDirection(key as String) as String
    if key = "right" or key = "fastforward" then return "right"
    if key = "left" or key = "rewind" then return "left"
    return ""
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    if isSeekKey(key) then
        if press then
            beginSeekHold(key)
        else
            finishSeekHold(key)
        end if
        return true
    end if

    if not press then return false

    if key = "back" then
        closeMoviePlayer()
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

sub closeMoviePlayer()
    if m.isReturningFromPlayer = true then return
    m.isReturningFromPlayer = true

    stopPlayback()
    if m.video <> invalid then m.video.SetFocus(false)
    m.top.SetFocus(false)
    m.top.visible = false

    ' Notify MainScene after the player is already stopped and hidden. Do not
    ' move focus to the parent scene here, because that can let the BACK key
    ' continue into a stale screen and open an unexpected destination.
    m.top.backRequested = true
end sub

sub beginSeekHold(key as String)
    direction = normalizeSeekDirection(key)
    if direction = "" then return

    if m.isHoldingSeek = true and m.seekDirection = direction then return
    stopSeekHold()

    m.isHoldingSeek = true
    m.seekDirection = direction

    if direction = "right" then
        seekForward()
    else if direction = "left" then
        seekBackward()
    end if

    if m.seekHoldTimer <> invalid then
        m.seekHoldTimer.control = "stop"
        m.seekHoldTimer.control = "start"
    end if
    showControls()
end sub

sub finishSeekHold(key as String)
    direction = normalizeSeekDirection(key)
    if m.seekDirection <> direction then return
    stopSeekHold()
end sub

sub stopSeekHold()
    if m.seekHoldTimer <> invalid then m.seekHoldTimer.control = "stop"
    m.isHoldingSeek = false
    m.seekDirection = ""
    m.pendingSeekPosition = invalid
end sub

sub onProgressUpdateTimerFire()
    updateControls()
end sub

sub onSeekHoldTick()
    if m.isHoldingSeek = false then return

    if m.seekDirection = "right" then
        seekForward()
    else if m.seekDirection = "left" then
        seekBackward()
    end if
end sub

sub togglePause()
    if m.video = invalid then return
    state = LCase(m.video.state)
    if m.isPlaying = true or state = "playing" or state = "buffering" then
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

sub seekForward()
    seekBy(m.seekStep)
end sub

sub seekBackward()
    seekBy(-m.seekStep)
end sub

sub seekBy(delta as Integer)
    current = getSeekBasePosition()
    seekTo(current + delta)
end sub

sub seekTo(position as Integer)
    if m.video = invalid then return
    target = clampSeekPosition(position)
    m.pendingSeekPosition = target
    m.video.seek = target
    updateProgress()
    showControls()
end sub

function getSeekBasePosition() as Integer
    if m.pendingSeekPosition <> invalid then return Int(m.pendingSeekPosition)
    return getPlaybackPosition()
end function

function clampSeekPosition(position as Integer) as Integer
    target = position
    if target < 0 then target = 0
    duration = getPlaybackDuration()
    if duration > 0 and target > duration then target = duration
    if target < 0 then target = 0
    return target
end function

function getPlaybackDuration() as Integer
    if m.video <> invalid and m.video.duration <> invalid then return Int(m.video.duration)
    return 0
end function

sub showControls()
    updateControls()
    if m.controlsGroup <> invalid then m.controlsGroup.visible = true
    startControlsAutoHideTimer()
end sub

sub hideControls()
    stopControlsAutoHideTimer()
    if m.controlsGroup <> invalid then m.controlsGroup.visible = false
end sub

sub startControlsAutoHideTimer()
    if m.controlsAutoHideTimer = invalid then return
    m.controlsAutoHideTimer.control = "stop"
    m.controlsAutoHideTimer.control = "start"
end sub

sub stopControlsAutoHideTimer()
    if m.controlsAutoHideTimer <> invalid then m.controlsAutoHideTimer.control = "stop"
end sub

sub startProgressUpdateTimer()
    if m.progressUpdateTimer = invalid then return
    m.progressUpdateTimer.control = "stop"
    m.progressUpdateTimer.control = "start"
end sub

sub stopProgressUpdateTimer()
    if m.progressUpdateTimer <> invalid then m.progressUpdateTimer.control = "stop"
end sub

sub onControlsAutoHideTimerFire()
    if m.isPlaying = true then hideControls()
end sub

sub updateControls()
    updatePlayPauseIcon()
    updateProgress()
end sub

sub updateProgress()
    position = getSeekBasePosition()
    duration = getPlaybackDuration()
    if m.currentTimeLabel <> invalid then m.currentTimeLabel.text = formatTime(position)
    if m.durationLabel <> invalid then m.durationLabel.text = formatTime(duration)
    if m.progressFill <> invalid and m.progressBackground <> invalid then
        progressWidth = 0
        if duration > 0 then progressWidth = Int((position / duration) * m.progressBackground.width)
        if progressWidth < 0 then progressWidth = 0
        if progressWidth > m.progressBackground.width then progressWidth = m.progressBackground.width
        m.progressFill.width = progressWidth
    end if
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

function getMovieName(movie as Dynamic) as String
    if movie = invalid then return "Filme"
    if movie.name <> invalid and movie.name.ToStr().Trim() <> "" then return movie.name.ToStr()
    if movie.title <> invalid and movie.title.ToStr().Trim() <> "" then return movie.title.ToStr()
    return "Filme"
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
