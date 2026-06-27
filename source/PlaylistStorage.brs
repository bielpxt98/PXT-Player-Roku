' Persistent storage helpers for playlist credentials.
' This module is intentionally limited to local Roku registry access; Xtream
' connectivity and channel loading will be integrated in a later step.
function PlaylistStorageSectionName() as String
    return "playlist"
end function

function LoadSavedPlaylist() as Object
    section = CreateObject("roRegistrySection", PlaylistStorageSectionName())

    if not section.Exists("dns") or not section.Exists("username") or not section.Exists("password") then
        return invalid
    end if

    playlist = {
        dns: section.Read("dns"),
        username: section.Read("username"),
        password: section.Read("password")
    }

    if playlist.dns = "" or playlist.username = "" or playlist.password = "" then
        return invalid
    end if

    return playlist
end function

sub SavePlaylist(playlist as Object)
    section = CreateObject("roRegistrySection", PlaylistStorageSectionName())
    section.Write("dns", playlist.dns)
    section.Write("username", playlist.username)
    section.Write("password", playlist.password)
    section.Flush()
end sub

sub DeleteSavedPlaylist()
    section = CreateObject("roRegistrySection", PlaylistStorageSectionName())
    if section.Exists("dns") then section.Delete("dns")
    if section.Exists("username") then section.Delete("username")
    if section.Exists("password") then section.Delete("password")
    section.Flush()
end sub
