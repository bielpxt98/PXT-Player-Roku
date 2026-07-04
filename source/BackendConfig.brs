' Central backend configuration for Roku-to-Node.js API calls.
' Local testing URL; replace this with the public backend URL after hosting.
function BACKEND_BASE_URL() as String
    return "https://pxt-backend-g8j8.onrender.com"
end function

function GetBackendBaseUrl() as String
    return BACKEND_BASE_URL()
end function
