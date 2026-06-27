' Native Roku player screen for series episode streams.
sub Init()
    m.video = m.top.FindNode("video")
    m.loadingGroup = m.top.FindNode("loadingGroup")
    m.loadingSpinner = m.top.FindNode("loadingSpinner")
    m.loadingLabel = m.top.FindNode("loadingLabel")
    m.errorGroup = m.top.FindNode("errorGroup")
    m.errorTitle = m.top.FindNode("errorTitle")
    m.errorMessage = m.top.FindNode("errorMessage")
    m.infoGroup = m.top.FindNode("infoGroup")
    m.infoTitle = m.top.FindNode("infoTitle")
    m.infoTime = m.top.FindNode("infoTime")

    m.episode = invalid
    m.episodeName = "Episódio"
    m.isPlaying = false
    m.resumePosition = 0
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

    m.infoGroup.translation = [0, height - 112]
    m.infoGroup.width = width
    m.infoTitle.width = width - 120
    m.infoTitle.translation = [60, 16]
    m.infoTitle.font = "font:MediumBoldSystemFont"
    m.infoTime.width = width - 120
    m.infoTime.translation = [60, 58]
    m.infoTime.font = "font:MediumSystemFont"
end sub

sub show(episode as Dynamic)
    m.episode = episode
    m.episodeName = getEpisodeName(episode)
    m.top.episodeName = m.episodeName
    m.top.visible = true
    showLoading("Preparando " + m.episodeName + "...")
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

    m.video.content = content
    if startPosition > 0 then content.PlayStart = startPosition
    m.video.control = "play"
    m.top.SetFocus(true)
    m.isPlaying = true
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
    if m.video = invalid or m.video.position = invalid then return 0
    return Int(m.video.position)
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
    if m.video <> invalid then
        m.video.control = "stop"
        m.video.content = invalid
    end if
    m.isPlaying = false
    m.loadingSpinner.control = "stop"
    if m.infoGroup <> invalid then m.infoGroup.visible = false
    if m.resumeDialog <> invalid then
        m.top.GetScene().dialog = invalid
        m.resumeDialog = invalid
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
    m.errorTitle.text = "Não foi possível reproduzir o episódio"
    m.errorMessage.text = message + Chr(10) + "Pressione Voltar e tente novamente."
    m.errorGroup.visible = true
end sub

sub onVideoStateChanged()
    state = LCase(m.video.state)
    if state = "playing" then
        m.loadingGroup.visible = false
        m.loadingSpinner.control = "stop"
        m.errorGroup.visible = false
    else if state = "error" or state = "finished" then
        if m.top.visible = true then
            showError("O stream de " + m.episodeName + " não carregou ou foi encerrado pelo servidor.")
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
        seekBy(30)
        return true
    else if key = "left" then
        seekBy(-15)
        return true
    else if key = "up" then
        showInfo()
        return true
    else if key = "down" then
        hideInfo()
        return true
    end if

    return false
end function

sub togglePause()
    if m.video = invalid then return
    state = LCase(m.video.state)
    if state = "playing" or m.isPlaying = true then
        m.video.control = "pause"
        m.isPlaying = false
    else
        m.video.control = "resume"
        m.isPlaying = true
    end if
    showInfo()
end sub

sub seekBy(offsetSeconds as Integer)
    if m.video = invalid then return
    pos = getPlaybackPosition() + offsetSeconds
    if pos < 0 then pos = 0
    m.video.seek = pos
    showInfo()
end sub

sub showInfo()
    if m.infoGroup = invalid then return
    m.infoTitle.text = m.episodeName
    m.infoTime.text = formatSeconds(getPlaybackPosition())
    m.infoGroup.visible = true
end sub

sub hideInfo()
    if m.infoGroup <> invalid then m.infoGroup.visible = false
end sub

function formatSeconds(totalSeconds as Integer) as String
    if totalSeconds < 0 then totalSeconds = 0
    hours = Int(totalSeconds / 3600)
    minutes = Int((totalSeconds - (hours * 3600)) / 60)
    seconds = totalSeconds mod 60
    return twoDigits(hours) + ":" + twoDigits(minutes) + ":" + twoDigits(seconds)
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
