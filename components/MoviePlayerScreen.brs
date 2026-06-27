' Native Roku player screen for movie streams.
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
    m.controlsTitle = m.top.FindNode("controlsTitle")
    m.controlsTime = m.top.FindNode("controlsTime")
    m.progressTrack = m.top.FindNode("progressTrack")
    m.progressFill = m.top.FindNode("progressFill")
    m.controlsHint = m.top.FindNode("controlsHint")

    m.movie = invalid
    m.movieName = "Filme"
    m.isPlaying = false
    m.isClosing = false
    m.resumePosition = 0
    m.lastPosition = 0
    m.seekStep = 30
    m.pendingStreamUrl = ""
    m.resumeDialog = invalid

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

    m.controlsGroup.translation = [60, height - 150]
    m.controlsBackground.width = width - 120
    m.controlsBackground.height = 112
    m.controlsTitle.translation = [24, 12]
    m.controlsTitle.width = width - 360
    m.controlsTitle.font = "font:MediumBoldSystemFont"
    m.controlsTime.translation = [width - 260, 12]
    m.controlsTime.width = 176
    m.controlsTime.font = "font:SmallSystemFont"
    m.controlsTime.horizAlign = "right"
    m.progressTrack.translation = [24, 54]
    m.progressTrack.width = width - 168
    m.progressTrack.height = 8
    m.progressFill.translation = [24, 54]
    m.progressFill.width = 0
    m.progressFill.height = 8
    m.controlsHint.translation = [24, 74]
    m.controlsHint.width = width - 168
    m.controlsHint.font = "font:SmallSystemFont"
end sub

sub show(movie as Dynamic)
    m.movie = movie
    m.movieName = getMovieName(movie)
    m.top.movieName = m.movieName
    m.isClosing = false
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
    m.top.SetFocus(true)
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

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if key = "back" then
        stopPlayback()
        m.top.backRequested = true
        return true
    else if key = "OK" then
        togglePause()
        return true
    else if key = "right" then
        seekBy(m.seekStep)
        return true
    else if key = "left" then
        seekBy(-m.seekStep)
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
    if m.controlsTitle <> invalid then m.controlsTitle.text = m.movieName
    position = getPlaybackPosition()
    duration = 0
    if m.video <> invalid and m.video.duration <> invalid then duration = Int(m.video.duration)
    if m.controlsTime <> invalid then m.controlsTime.text = formatTime(position) + " / " + formatTime(duration)
    if m.progressFill <> invalid and m.progressTrack <> invalid then
        fillWidth = 0
        if duration > 0 then fillWidth = Int((position * m.progressTrack.width) / duration)
        if fillWidth < 0 then fillWidth = 0
        if fillWidth > m.progressTrack.width then fillWidth = m.progressTrack.width
        m.progressFill.width = fillWidth
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
