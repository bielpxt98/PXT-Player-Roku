' Demo catalog used when the user starts the app without Xtream credentials.
function CreateDemoData() as Object
    liveCategories = [
        { category_id: "demo-live", category_name: "CANAIS DEMO", name: "CANAIS DEMO" }
    ]

    movieCategories = [
        { category_id: "demo-movies", category_name: "FILMES DEMO", name: "FILMES DEMO" }
    ]

    channels = [
        {
            stream_id: "demo-live-1",
            name: "Canal Demo",
            title: "Canal Demo",
            category_id: "demo-live",
            stream_icon: "pkg:/images/background.jpeg",
            direct_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"
        }
    ]

    movies = [
        {
            stream_id: "demo-movie-1",
            name: "Filme Demo",
            title: "Filme Demo",
            category_id: "demo-movies",
            stream_icon: "pkg:/images/background.jpeg",
            cover: "pkg:/images/background.jpeg",
            container_extension: "mp4",
            direct_url: "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            plot: "Conteúdo de demonstração para validar navegação e player sem credenciais Xtream."
        }
    ]

    series = [
        {
            series_id: "demo-series-1",
            name: "Série Demo",
            title: "Série Demo",
            category_id: "demo-series",
            cover: "pkg:/images/background.jpeg",
            series_image: "pkg:/images/background.jpeg"
        }
    ]

    return {
        account: { dns: "demo://pxt-player", username: "demo", password: "demo" },
        liveCategories: liveCategories,
        liveChannels: channels,
        movieCategories: movieCategories,
        movies: movies,
        series: series
    }
end function
