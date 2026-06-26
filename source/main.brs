' Entry point for the PXT Player Roku channel.
' Keep startup orchestration here and move feature logic into components/services
' as the application grows.
sub Main()
    screen = CreateObject("roSGScreen")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)

    scene = screen.CreateScene("MainScene")
    screen.Show()

    while true
        message = Wait(0, port)
        messageType = Type(message)

        if messageType = "roSGScreenEvent" and message.IsScreenClosed() then
            return
        end if
    end while
end sub
