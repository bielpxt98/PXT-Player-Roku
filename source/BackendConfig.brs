' Central backend configuration for Roku-to-Node.js API calls.
function BACKEND_BASE_URL() as String
    return "http://192.168.X.X:3000"
end function

function GetBackendBaseUrl() as String
    return BACKEND_BASE_URL()
end function
