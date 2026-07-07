' Persistent storage helpers for playlist credentials.
' Single-account first, with legacy/multi-section fallbacks so a saved login is
' not lost by older builds, empty form submits, or cache resets.
function PlaylistStorageSectionName() as String
    return "playlist"
end function

function PlaylistStorageBackupSectionName() as String
    return "PXTPlayerAccount"
end function

function PlaylistStorageLegacySectionName() as String
    return "PXTPlayerLogin"
end function

function PlaylistStoragePermanentSectionName() as String
    return "PXTPlayerPermanentAccount"
end function

function LoadSavedPlaylist() as Object
    ' PRINT "LOGIN_RESTORE_START"
    playlists = LoadSavedPlaylists()
    if playlists.Count() = 0 then
        ' PRINT "ACCOUNT_STORAGE_READ empty"
        ' PRINT "LOGIN_RESTORE_FAILED"
        return invalid
    end if
    ' PRINT "ACCOUNT_STORAGE_READ count="; playlists.Count()

    activeUsername = LoadActivePlaylistUsername()
    for each playlist in playlists
        if safePlaylistText(playlist.username) = activeUsername then
            ' PRINT "LOGIN_RESTORE_OK"
            ' PRINT "ACCOUNT_RESTORE_SUCCESS"
            return playlist
        end if
    end for

    ' PRINT "LOGIN_RESTORE_OK"
    ' PRINT "ACCOUNT_RESTORE_SUCCESS"
    return playlists[0]
end function

function LoadSavedPlaylists() as Object
    playlists = []
    appendStoredPlaylistsFromSection(playlists, PlaylistStoragePermanentSectionName())
    appendStoredPlaylistsFromSection(playlists, PlaylistStorageSectionName())
    appendStoredPlaylistsFromSection(playlists, PlaylistStorageBackupSectionName())
    appendStoredPlaylistsFromSection(playlists, PlaylistStorageLegacySectionName())
    return uniqueStoredPlaylists(playlists)
end function

sub appendStoredPlaylistsFromSection(playlists as Object, sectionName as String)
    section = CreateObject("roRegistrySection", sectionName)

    if section.Exists("accountsJson") then
        raw = section.Read("accountsJson")
        if raw <> invalid and raw.Trim() <> "" then
            parsed = ParseJson(raw)
            if parsed <> invalid and Type(parsed) = "roArray" then
                for each entry in parsed
                    if isStoredPlaylistValid(entry) then playlists.Push(normalizeStoredPlaylist(entry))
                end for
            end if
        end if
    end if

    if section.Exists("accountJson") then
        rawAccount = section.Read("accountJson")
        if rawAccount <> invalid and rawAccount.Trim() <> "" then
            parsedAccount = ParseJson(rawAccount)
            if isStoredPlaylistValid(parsedAccount) then playlists.Push(normalizeStoredPlaylist(parsedAccount))
        end if
    end if

    if section.Exists("dns") and section.Exists("username") and section.Exists("password") then
        legacy = {
            dns: section.Read("dns"),
            username: section.Read("username"),
            password: section.Read("password")
        }
        if section.Exists("status") then legacy.status = section.Read("status")
        if isStoredPlaylistValid(legacy) then playlists.Push(normalizeStoredPlaylist(legacy))
    end if
end sub

function uniqueStoredPlaylists(items as Object) as Object
    result = []
    seen = {}
    for each item in items
        if isStoredPlaylistValid(item) then
            key = LCase(safePlaylistText(item.dns).Trim() + "|" + safePlaylistText(item.username).Trim())
            if seen[key] = invalid then
                seen[key] = true
                result.Push(normalizeStoredPlaylist(item))
            end if
        end if
    end for
    return result
end function

function LoadActivePlaylistUsername() as String
    names = [PlaylistStoragePermanentSectionName(), PlaylistStorageSectionName(), PlaylistStorageBackupSectionName(), PlaylistStorageLegacySectionName()]
    for each name in names
        section = CreateObject("roRegistrySection", name)
        if section.Exists("activeUsername") then return section.Read("activeUsername")
        if section.Exists("username") then return section.Read("username")
    end for
    return ""
end function

sub SavePlaylist(playlist as Object)
    if not isStoredPlaylistValid(playlist) then
        ' PRINT "ACCOUNT_STORAGE_SKIP_EMPTY_OVERWRITE"
        return
    end if
    ' PRINT "LOGIN_SAVE_OK"
    ' PRINT "ACCOUNT_STORAGE_WRITE"

    normalizedPlaylist = normalizeStoredPlaylist(playlist)
    playlists = LoadSavedPlaylists()
    updated = false
    for i = 0 to playlists.Count() - 1
        if LCase(safePlaylistText(playlists[i].dns).Trim() + "|" + safePlaylistText(playlists[i].username).Trim()) = LCase(safePlaylistText(normalizedPlaylist.dns).Trim() + "|" + safePlaylistText(normalizedPlaylist.username).Trim()) then
            playlists[i] = normalizedPlaylist
            updated = true
            exit for
        end if
    end for
    if updated <> true then playlists.Push(normalizedPlaylist)

    writePlaylistSection(PlaylistStoragePermanentSectionName(), normalizedPlaylist, playlists)
    writePlaylistSection(PlaylistStorageSectionName(), normalizedPlaylist, playlists)
    writePlaylistSection(PlaylistStorageBackupSectionName(), normalizedPlaylist, playlists)
    writePlaylistSection(PlaylistStorageLegacySectionName(), normalizedPlaylist, playlists)
end sub

sub writePlaylistSection(sectionName as String, playlist as Object, playlists as Object)
    section = CreateObject("roRegistrySection", sectionName)
    section.Write("accountsJson", FormatJson(playlists))
    section.Write("accountJson", FormatJson(playlist))
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
    ' PRINT "ACCOUNT_REMOVE_ONLY_MANUAL"
    deletePlaylistSection(PlaylistStoragePermanentSectionName())
    deletePlaylistSection(PlaylistStorageSectionName())
    deletePlaylistSection(PlaylistStorageBackupSectionName())
    deletePlaylistSection(PlaylistStorageLegacySectionName())
end sub

sub deletePlaylistSection(sectionName as String)
    section = CreateObject("roRegistrySection", sectionName)
    keys = ["dns", "username", "password", "status", "accountsJson", "accountJson", "activeUsername"]
    for each key in keys
        if section.Exists(key) then section.Delete(key)
    end for
    section.Flush()
end sub

sub SavePlaylistConnectionStatus(status as String)
    names = [PlaylistStoragePermanentSectionName(), PlaylistStorageSectionName(), PlaylistStorageBackupSectionName(), PlaylistStorageLegacySectionName()]
    for each name in names
        section = CreateObject("roRegistrySection", name)
        section.Write("status", status)
        section.Flush()
    end for
end sub

function normalizeStoredPlaylist(playlist as Dynamic) as Object
    result = {
        dns: safePlaylistText(playlist.dns).Trim(),
        username: safePlaylistText(playlist.username).Trim(),
        password: safePlaylistText(playlist.password).Trim()
    }
    if playlist <> invalid and playlist.status <> invalid then result.status = safePlaylistText(playlist.status)
    return result
end function

function isStoredPlaylistValid(playlist as Dynamic) as Boolean
    if playlist = invalid then return false
    if Type(playlist) <> "roAssociativeArray" then return false
    return safePlaylistText(playlist.dns).Trim() <> "" and safePlaylistText(playlist.username).Trim() <> "" and safePlaylistText(playlist.password).Trim() <> ""
end function

function safePlaylistText(value as Dynamic) as String
    if value = invalid then return ""
    return value.ToStr()
end function
