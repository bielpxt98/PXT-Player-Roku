' Demo catalog used when the user starts the app without Xtream credentials.
function CreateDemoData() as Object
    liveCategories = [
        { category_id: "demo-live", category_name: "CANAIS DEMO", name: "CANAIS DEMO" }
    ]

    movieCategories = [
        { category_id: "demo-movies", category_name: "FILMES DEMO", name: "FILMES DEMO" }
    ]

    seriesCategories = [
        { category_id: "demo-series", category_name: "SÉRIES DEMO", name: "SÉRIES DEMO" }
    ]

    channels = [
        {
            stream_id: "demo-live-1",
            name: "Big Buck Bunny",
            title: "Big Buck Bunny",
            category_id: "demo-live",
            stream_icon: "https://placehold.co/300x450/111827/FFFFFF.png?text=Big+Buck+Bunny",
            direct_url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
            stream_type: "m3u8",
            container_extension: "m3u8"
        },
        {
            stream_id: "demo-live-2",
            name: "Sintel",
            title: "Sintel",
            category_id: "demo-live",
            stream_icon: "https://placehold.co/300x450/1F2937/FFFFFF.png?text=Sintel",
            direct_url: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
            stream_type: "m3u8",
            container_extension: "m3u8"
        },
        {
            stream_id: "demo-live-3",
            name: "Apple BipBop",
            title: "Apple BipBop",
            category_id: "demo-live",
            stream_icon: "https://placehold.co/300x450/0F172A/FFFFFF.png?text=Apple+BipBop",
            direct_url: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8",
            stream_type: "m3u8",
            container_extension: "m3u8"
        }
    ]

    movies = [
        createDemoMovie("demo-movie-1", "Big Buck Bunny", "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8", "Big+Buck+Bunny"),
        createDemoMovie("demo-movie-2", "Sintel", "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8", "Sintel"),
        createDemoMovie("demo-movie-3", "Homem Demo", "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8", "Homem+Demo"),
        createDemoMovie("demo-movie-4", "Home Demo", "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8", "Home+Demo"),
        createDemoMovie("demo-movie-5", "House Demo", "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8", "House+Demo")
    ]

    series = [
        {
            series_id: "demo-series-1",
            name: "Breaking Code",
            title: "Breaking Code",
            category_id: "demo-series",
            cover: "https://placehold.co/300x450/312E81/FFFFFF.png?text=Breaking+Code",
            series_image: "https://placehold.co/300x450/312E81/FFFFFF.png?text=Breaking+Code",
            plot: "Série demo sobre uma equipe investigando bugs misteriosos.",
            seasons: [
                {
                    season_number: 1,
                    name: "Temporada 1",
                    episodes: [
                        createDemoEpisode("demo-episode-1", "E01 - O Primeiro Bug", 1, 1, "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"),
                        createDemoEpisode("demo-episode-2", "E02 - A Tela Preta", 1, 2, "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"),
                        createDemoEpisode("demo-episode-3", "E03 - O Cache Perdido", 1, 3, "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")
                    ]
                }
            ]
        },
        {
            series_id: "demo-series-2",
            name: "Space Mission",
            title: "Space Mission",
            category_id: "demo-series",
            cover: "https://placehold.co/300x450/164E63/FFFFFF.png?text=Space+Mission",
            series_image: "https://placehold.co/300x450/164E63/FFFFFF.png?text=Space+Mission",
            plot: "Série demo com uma missão espacial em episódios curtos.",
            seasons: [
                {
                    season_number: 1,
                    name: "Temporada 1",
                    episodes: [
                        createDemoEpisode("demo-episode-4", "E01 - Decolagem", 1, 1, "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"),
                        createDemoEpisode("demo-episode-5", "E02 - Sinal Perdido", 1, 2, "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")
                    ]
                }
            ]
        }
    ]

    return {
        account: { dns: "demo://pxt-player", username: "demo", password: "demo" },
        liveCategories: liveCategories,
        liveChannels: channels,
        movieCategories: movieCategories,
        seriesCategories: seriesCategories,
        movies: movies,
        series: series
    }
end function

function createDemoMovie(streamId as String, title as String, directUrl as String, posterText as String) as Object
    poster = "https://placehold.co/300x450/111827/FFFFFF.png?text=" + posterText
    return {
        stream_id: streamId,
        name: title,
        title: title,
        category_id: "demo-movies",
        stream_icon: poster,
        cover: poster,
        container_extension: "m3u8",
        direct_url: directUrl,
        plot: "Conteúdo de demonstração para validar navegação e player sem credenciais Xtream."
    }
end function

function createDemoEpisode(streamId as String, title as String, seasonNumber as Integer, episodeNumber as Integer, directUrl as String) as Object
    return {
        id: streamId,
        stream_id: streamId,
        name: title,
        title: title,
        season: seasonNumber,
        episode_num: episodeNumber,
        direct_url: directUrl,
        container_extension: "m3u8"
    }
end function
