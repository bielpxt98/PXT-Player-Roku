' Persistent storage helpers for playlist credentials.
' This module is intentionally limited to local Roku registry access; Xtream
' connectivity and channel loading will be integrated in a later step.
function PlaylistStorageSectionName() as String
    return "playlist"
end function

function LoadSavedPlaylist() as Object
    PRINT "LOGIN_RESTORE_START"
    playlists = LoadSavedPlaylists()
    if playlists.Count() = 0 then
        PRINT "LOGIN_RESTORE_FAILED"
        return invalid
    end if

    activeUsername = LoadActivePlaylistUsername()
    for each playlist in playlists
        if safePlaylistText(playlist.username) = activeUsername then
            PRINT "LOGIN_RESTORE_SUCCESS"
            return playlist
        end if
    end for

    PRINT "LOGIN_RESTORE_SUCCESS"
    return playlists[0]
end function

function LoadSavedPlaylists() as Object
    section = CreateObject("roRegistrySection", PlaylistStorageSectionName())
    playlists = []

    if section.Exists("accountsJson") then
        parsed = ParseJson(section.Read("accountsJson"))
        if parsed <> invalid and Type(parsed) = "roArray" then
            for each entry in parsed
                if isStoredPlaylistValid(entry) then playlists.Push(entry)
            end for
        end if
    end if

    if playlists.Count() = 0 and section.Exists("dns") and section.Exists("username") and section.Exists("password") then
        legacy = {
            dns: section.Read("dns"),
            username: section.Read("username"),
            password: section.Read("password")
        }
        if section.Exists("status") then legacy.status = section.Read("status")
        if isStoredPlaylistValid(legacy) then
            playlists.Push(legacy)
            section.Write("accountsJson", FormatJson(playlists))
            section.Write("activeUsername", legacy.username)
            section.Flush()
        end if
    end if

    return playlists
end function

function LoadActivePlaylistUsername() as String
    section = CreateObject("roRegistrySection", PlaylistStorageSectionName())
    if section.Exists("activeUsername") then return section.Read("activeUsername")
    if section.Exists("username") then return section.Read("username")
    return ""
end function

sub SavePlaylist(playlist as Object)
    if not isStoredPlaylistValid(playlist) then return
    PRINT "LOGIN_SAVE_SUCCESS"

    playlists = LoadSavedPlaylists()
    updated = false
    for i = 0 to playlists.Count() - 1
        if safePlaylistText(playlists[i].username) = safePlaylistText(playlist.username) then
            playlists[i] = playlist
            updated = true
            exit for
        end if
    end for
    if updated <> true then playlists.Push(playlist)

    section = CreateObject("roRegistrySection", PlaylistStorageSectionName())
    section.Write("accountsJson", FormatJson(playlists))
    section.Write("activeUsername", playlist.username)
    section.Write("dns", playlist.dns)
    section.Write("username", playlist.username)
    section.Write("password", playlist.password)
    section.Write("status", "Conectado")
    section.Flush()
end sub

sub ClearSavedPlaylist()
    DeleteSavedPlaylist()
end sub

sub DeleteSavedPlaylist()
    section = CreateObject("roRegistrySection", PlaylistStorageSectionName())
    if section.Exists("dns") then section.Delete("dns")
    if section.Exists("username") then section.Delete("username")
    if section.Exists("password") then section.Delete("password")
    if section.Exists("status") then section.Delete("status")
    if section.Exists("accountsJson") then section.Delete("accountsJson")
    if section.Exists("activeUsername") then section.Delete("activeUsername")
    section.Flush()
end sub

sub SavePlaylistConnectionStatus(status as String)
    section = CreateObject("roRegistrySection", PlaylistStorageSectionName())
    section.Write("status", status)
    section.Flush()
end sub


function isStoredPlaylistValid(playlist as Dynamic) as Boolean
    if playlist = invalid then return false
    return safePlaylistText(playlist.dns) <> "" and safePlaylistText(playlist.username) <> "" and safePlaylistText(playlist.password) <> ""
end function

function safePlaylistText(value as Dynamic) as String
    if value = invalid then return ""
    return value.ToStr()
end function
