' Native Roku player screen for movie streams.
sub Init()
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
    m.controlsTitle = m.top.FindNode("controlsTitle")
    m.seekStatusLabel = m.top.FindNode("seekStatusLabel")
    m.currentTimeLabel = m.top.FindNode("currentTimeLabel")
    m.durationLabel = m.top.FindNode("durationLabel")
    m.progressTrack = m.top.FindNode("progressTrack")
    m.progressFill = m.top.FindNode("progressFill")
    m.seekHoldTimer = m.top.FindNode("seekHoldTimer")
    m.progressTimer = m.top.FindNode("progressTimer")

    m.movie = invalid
    m.movieName = "Filme"
    m.isPlaying = false
    m.isClosing = false
    m.resumePosition = 0
    m.lastPosition = 0
    m.seekStep = 10
    m.seekHoldDelta = 0
    m.heldSeekKey = ""
    m.pendingStreamUrl = ""
    m.pendingSeekPosition = invalid
    m.pendingSeekTimer = invalid
    m.resumeDialog = invalid

    configureLayout()
    m.video.showPlaybackInfo = false
    m.video.ObserveField("state", "onVideoStateChanged")
    m.video.ObserveField("position", "onVideoProgressChanged")
    m.video.ObserveField("duration", "onVideoProgressChanged")
    m.seekHoldTimer.ObserveField("fire", "onSeekHoldTimerFire")
    m.progressTimer.ObserveField("fire", "onProgressTimerFire")
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

    controlsWidth = width - 160
    if controlsWidth > 980 then controlsWidth = 980
    if controlsWidth < 520 then controlsWidth = width - 64
    controlsHeight = 150
    controlsX = Int((width - controlsWidth) / 2)
    controlsY = height - controlsHeight - 64
    m.controlsGroup.translation = [controlsX, controlsY]
    m.controlsBackground.width = controlsWidth
    m.controlsBackground.height = controlsHeight
    m.controlsTitle.translation = [28, 18]
    m.controlsTitle.width = controlsWidth - 56
    m.controlsTitle.height = 34
    m.controlsTitle.font = "font:MediumBoldSystemFont"
    m.seekStatusLabel.translation = [28, 54]
    m.seekStatusLabel.width = controlsWidth - 56
    m.seekStatusLabel.height = 30
    m.seekStatusLabel.font = "font:SmallSystemFont"
    m.currentTimeLabel.translation = [28, 92]
    m.currentTimeLabel.width = 120
    m.currentTimeLabel.font = "font:SmallSystemFont"
    m.durationLabel.translation = [controlsWidth - 148, 92]
    m.durationLabel.width = 120
    m.durationLabel.font = "font:SmallSystemFont"
    m.progressTrack.translation = [28, 124]
    m.progressTrack.width = controlsWidth - 56
    m.progressTrack.height = 8
    m.progressFill.translation = [28, 124]
    m.progressFill.width = 0
    m.progressFill.height = 8
end sub

sub show(movie as Dynamic)
    m.movie = movie
    m.movieName = getMovieName(movie)
    m.top.movieName = m.movieName
    m.isClosing = false
    m.top.visible = true
    showLoading("Preparando " + m.movieName + "...")
    hideControls()
    setTopFocus()
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
    m.pendingSeekPosition = invalid
    m.pendingSeekTimer = invalid
    m.video.visible = true
    m.video.content = content
    if startPosition > 0 then content.PlayStart = startPosition
    m.video.control = "play"
    m.isPlaying = true
    setTopFocus()
    showLoading("Carregando " + m.movieName + "...")
end sub


sub setResumePosition(position as Dynamic)
    if position = invalid then
        m.resumePosition = 0
    else
        m.resumePosition = Int(position)
    end if
end sub

function getPlaybackPosition() as Integer
    if m.pendingSeekPosition <> invalid then
        if m.pendingSeekTimer <> invalid and m.pendingSeekTimer.TotalMilliseconds() < 1800 then
            return Int(m.pendingSeekPosition)
        end if
        m.pendingSeekPosition = invalid
        m.pendingSeekTimer = invalid
    end if
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
    if m.progressTimer <> invalid then m.progressTimer.control = "stop"
    m.pendingSeekPosition = invalid
    m.pendingSeekTimer = invalid
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
    if m.isClosing = true or m.video = invalid then return
    state = LCase(m.video.state)
    if state = "playing" then
        m.isPlaying = true
        m.video.visible = true
        m.loadingGroup.visible = false
        m.loadingSpinner.control = "stop"
        m.errorGroup.visible = false
        if m.progressTimer <> invalid then m.progressTimer.control = "start"
        m.top.SetFocus(true)
        updateControls()
    else if state = "paused" then
        m.isPlaying = false
        showControls()
    else if state = "finished" then
        m.isPlaying = false
        showControls()
    else if state = "error" then
        if m.top.visible = true and m.isClosing <> true then
            showError("O stream de " + m.movieName + " não carregou ou foi encerrado pelo servidor.")
        end if
    end if
end sub

sub onVisibleChanged()
    print "MoviePlayer visible changed"
    if m.top.visible = true then setTopFocus()
end sub

sub setTopFocus()
    m.top.SetFocus(true)
    print "MoviePlayer SetFocus top"
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    print "MoviePlayer onKeyEvent: "; key; " press="; press

    if key = "right" or key = "fastforward" then
        if press then
            beginSeekHold(key, m.seekStep)
        else
            finishSeekHold(key)
        end if
        setTopFocus()
        updateControls()
        return true
    end if

    if key = "left" or key = "rewind" then
        if press then
            beginSeekHold(key, -m.seekStep)
        else
            finishSeekHold(key)
        end if
        setTopFocus()
        updateControls()
        return true
    end if

    if key = "play" or key = "pause" then
        if press then
            togglePause()
            setTopFocus()
            updateControls()
        end if
        return true
    end if

    if key = "back" then
        if not press then return true
        return handleBackKeySafely()
    else if key = "OK" then
        if press then
            togglePause()
            setTopFocus()
            updateControls()
        end if
        return true
    else if key = "options" then
        if press then
            toggleControls()
            setTopFocus()
            updateControls()
        end if
        return true
    else if key = "up" then
        if press then showControls()
        return true
    else if key = "down" then
        if press then hideControls()
        return true
    else if key = "replay" then
        if press then seekTo(0)
        return true
    end if

    return false
end function

function handleBackKeySafely() as Boolean
    stopPlayback()
    m.top.backRequested = true
    return true
end function

sub beginSeekHold(key as String, delta as Integer)
    if m.heldSeekKey = key then
        if m.seekHoldTimer <> invalid then m.seekHoldTimer.control = "start"
        showControls()
        return
    end if

    stopSeekHold()
    m.heldSeekKey = key
    m.seekHoldDelta = delta
    seekBy(delta)
    if m.seekHoldTimer <> invalid then m.seekHoldTimer.control = "start"
    showControls()
end sub

sub finishSeekHold(key as String)
    if m.heldSeekKey <> key then return
    stopSeekHold()
end sub

sub stopSeekHold()
    if m.seekHoldTimer <> invalid then m.seekHoldTimer.control = "stop"
    m.heldSeekKey = ""
    m.seekHoldDelta = 0
end sub

sub onSeekHoldTimerFire()
    if m.heldSeekKey = "" or m.seekHoldDelta = 0 then return
    seekBy(m.seekHoldDelta)
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
    updateControls()
end sub

sub seekBy(delta as Integer)
    seekToWithDelta(getPlaybackPosition() + delta, delta)
end sub

sub seekTo(position as Integer)
    seekToWithDelta(position, 0)
end sub

sub seekToWithDelta(position as Integer, delta as Integer)
    if m.video = invalid then return
    if position < 0 then position = 0
    duration = getPlaybackDuration()
    if duration > 0 and position > duration then position = duration
    m.video.seek = position
    m.lastPosition = position
    m.pendingSeekPosition = position
    m.pendingSeekTimer = CreateObject("roTimespan")
    m.pendingSeekTimer.Mark()
    if delta > 0 then
        m.seekStatusLabel.text = "+" + delta.ToStr() + "s  " + formatTime(position)
    else if delta < 0 then
        m.seekStatusLabel.text = delta.ToStr() + "s  " + formatTime(position)
    else
        m.seekStatusLabel.text = formatTime(position)
    end if
    showControls()
    updateControls()
end sub

sub onVideoProgressChanged()
    if m.video <> invalid and m.video.position <> invalid then
        videoPosition = Int(m.video.position)
        if m.pendingSeekPosition = invalid or videoPosition >= Int(m.pendingSeekPosition) - 1 then
            m.lastPosition = videoPosition
            m.pendingSeekPosition = invalid
            m.pendingSeekTimer = invalid
        end if
    end if
    updateControls()
end sub

sub onProgressTimerFire()
    if m.top.visible <> true then return
    m.top.SetFocus(true)
    updateControls()
end sub

sub showControls()
    updateControls()
    if m.controlsGroup <> invalid then m.controlsGroup.visible = true
end sub

sub hideControls()
    if m.controlsGroup <> invalid then m.controlsGroup.visible = false
end sub

sub toggleControls()
    if m.controlsGroup <> invalid and m.controlsGroup.visible = true then
        hideControls()
    else
        showControls()
    end if
end sub

sub updateControls()
    if m.controlsTitle <> invalid then m.controlsTitle.text = m.movieName
    position = getPlaybackPosition()
    duration = getPlaybackDuration()
    if m.currentTimeLabel <> invalid then m.currentTimeLabel.text = formatTime(position)
    if m.durationLabel <> invalid then m.durationLabel.text = formatTime(duration)
    if m.progressTrack <> invalid and m.progressFill <> invalid then
        fillWidth = 0
        if duration > 0 then fillWidth = Int((m.progressTrack.width * position) / duration)
        if fillWidth < 0 then fillWidth = 0
        if fillWidth > m.progressTrack.width then fillWidth = m.progressTrack.width
        m.progressFill.width = fillWidth
    end if
end sub

function getPlaybackDuration() as Integer
    if m.video <> invalid and m.video.duration <> invalid then return Int(m.video.duration)
    return 0
end function

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
