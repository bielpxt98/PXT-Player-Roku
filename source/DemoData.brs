' Local demo catalog for testing PXT Player without Xtream credentials.
function DemoStreams() as Object
    return {
        bunny: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
        sintel: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
        bipbop: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8",
        akamai: "https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8"
    }
end function

function GetDemoLiveCategories() as Object
    return [{ category_id: "demo_tv", category_name: "TV DEMO", name: "TV DEMO" }]
end function

function GetDemoLiveChannels(categoryId as String) as Object
    if categoryId <> "" and categoryId <> "demo_tv" then return []
    s = DemoStreams()
    return [
        { name: "Big Buck Bunny TV", stream_id: "demo_live_1", category_id: "demo_tv", stream_icon: "https://placehold.co/300x300/111827/FFFFFF?text=Big+Buck+Bunny+TV", direct_url: s.bunny },
        { name: "Sintel TV", stream_id: "demo_live_2", category_id: "demo_tv", stream_icon: "https://placehold.co/300x300/0F172A/FFFFFF?text=Sintel+TV", direct_url: s.sintel },
        { name: "Apple BipBop TV", stream_id: "demo_live_3", category_id: "demo_tv", stream_icon: "https://placehold.co/300x300/1E293B/FFFFFF?text=Apple+BipBop+TV", direct_url: s.bipbop },
        { name: "Akamai Test TV", stream_id: "demo_live_4", category_id: "demo_tv", stream_icon: "https://placehold.co/300x300/312E81/FFFFFF?text=Akamai+Test+TV", direct_url: s.akamai }
    ]
end function

function GetDemoMovieCategories() as Object
    return [
        { category_id: "search", category_name: "PESQUISAR", name: "PESQUISAR", isSearch: true },
        { category_id: "favorites", category_name: "FAVORITOS", name: "FAVORITOS", isFavorites: true },
        { category_id: "recent", category_name: "ÚLTIMOS ASSISTIDOS", name: "ÚLTIMOS ASSISTIDOS", isRecent: true },
        { category_id: "demo_action", category_name: "AÇÃO DEMO", name: "AÇÃO DEMO" },
        { category_id: "demo_animation", category_name: "ANIMAÇÃO DEMO", name: "ANIMAÇÃO DEMO" },
        { category_id: "demo_adventure", category_name: "AVENTURA DEMO", name: "AVENTURA DEMO" }
    ]
end function

function GetDemoMovies(categoryId as String) as Object
    movies = GetDemoSearchMovies()
    if categoryId = "" or categoryId = "search" then return movies
    return DemoFilterByCategory(movies, categoryId)
end function

function GetDemoSearchMovies() as Object
    s = DemoStreams()
    return [
        DemoMovie("Big Buck Bunny", "demo_movie_1", "demo_animation", "https://placehold.co/300x450/111827/FFFFFF?text=Big+Buck+Bunny", "Animação", "2008", "Um curta de animação usado para demonstração pública de HLS.", s.bunny),
        DemoMovie("Sintel", "demo_movie_2", "demo_adventure", "https://placehold.co/300x450/0F172A/FFFFFF?text=Sintel", "Aventura", "2010", "Uma aventura fantástica em stream HLS público.", s.sintel),
        DemoMovie("Apple BipBop", "demo_movie_3", "demo_adventure", "https://placehold.co/300x450/1E293B/FFFFFF?text=Apple+BipBop", "Teste", "2024", "Conteúdo de teste HLS da Apple para validar reprodução.", s.bipbop),
        DemoMovie("Akamai Test", "demo_movie_4", "demo_action", "https://placehold.co/300x450/312E81/FFFFFF?text=Akamai+Test", "Teste", "2024", "Stream público de teste para validar carregamento ao vivo.", s.akamai),
        DemoMovie("Homem Demo", "demo_movie_5", "demo_action", "https://placehold.co/300x450/1E293B/FFFFFF?text=Homem+Demo", "Ação", "2024", "Um herói fictício enfrenta bugs em produção.", s.bunny),
        DemoMovie("Home Demo", "demo_movie_6", "demo_adventure", "https://placehold.co/300x450/334155/FFFFFF?text=Home+Demo", "Drama", "2024", "Drama fictício para testar busca por nomes parecidos.", s.sintel),
        DemoMovie("House Demo", "demo_movie_7", "demo_action", "https://placehold.co/300x450/475569/FFFFFF?text=House+Demo", "Suspense", "2024", "Suspense fictício para validar capas, favoritos e histórico.", s.bipbop)
    ]
end function

function DemoMovie(name as String, id as String, categoryId as String, cover as String, genre as String, year as String, plot as String, url as String) as Object
    return { name: name, title: name, stream_id: id, category_id: categoryId, stream_icon: cover, cover: cover, genre: genre, releaseDate: year, plot: plot, container_extension: "m3u8", direct_url: url }
end function

function GetDemoSeriesCategories() as Object
    return [
        { category_id: "search", category_name: "PESQUISAR", name: "PESQUISAR", isSearch: true },
        { category_id: "favorites", category_name: "FAVORITOS", name: "FAVORITOS", isFavorites: true },
        { category_id: "recent", category_name: "ÚLTIMOS ASSISTIDOS", name: "ÚLTIMOS ASSISTIDOS", isRecent: true },
        { category_id: "demo_series", category_name: "SÉRIES DEMO", name: "SÉRIES DEMO" },
        { category_id: "demo_adventure", category_name: "AVENTURA DEMO", name: "AVENTURA DEMO" },
        { category_id: "demo_tech", category_name: "TECNOLOGIA DEMO", name: "TECNOLOGIA DEMO" }
    ]
end function

function GetDemoSeries(categoryId as String) as Object
    series = GetDemoSearchSeries()
    if categoryId = "" or categoryId = "search" or categoryId = "demo_series" then return series
    return DemoFilterByCategory(series, categoryId)
end function

function GetDemoSearchSeries() as Object
    return [
        DemoSeries("Breaking Code", "demo_series_1", "demo_tech", "https://placehold.co/300x450/111827/FFFFFF?text=Breaking+Code", "Tecnologia", "2024", "Uma equipe investiga bugs misteriosos em uma plataforma de streaming."),
        DemoSeries("Space Mission", "demo_series_2", "demo_adventure", "https://placehold.co/300x450/0F172A/FFFFFF?text=Space+Mission", "Aventura", "2024", "Tripulação demo testa transmissões HLS em uma missão espacial."),
        DemoSeries("Demo Adventures", "demo_series_3", "demo_series", "https://placehold.co/300x450/1E293B/FFFFFF?text=Demo+Adventures", "Animação", "2024", "Aventuras curtas para validar séries, episódios e player.")
    ]
end function

function DemoSeries(name as String, id as String, categoryId as String, cover as String, genre as String, year as String, plot as String) as Object
    return { series_id: id, name: name, title: name, category_id: categoryId, cover: cover, stream_icon: cover, genre: genre, releaseDate: year, plot: plot }
end function

function GetDemoSeriesInfo(seriesId as Dynamic) as Object
    id = seriesId.ToStr()
    s = DemoStreams()
    if id = "demo_series_1" then
        info = DemoSeries("Breaking Code", id, "demo_tech", "https://placehold.co/300x450/111827/FFFFFF?text=Breaking+Code", "Tecnologia", "2024", "Uma equipe investiga bugs misteriosos em uma plataforma de streaming.")
        episodes = [DemoEpisode("bc_1", 1, "O Primeiro Bug", s.bunny), DemoEpisode("bc_2", 2, "A Tela Preta", s.sintel), DemoEpisode("bc_3", 3, "O Cache Perdido", s.bipbop)]
    else if id = "demo_series_2" then
        info = DemoSeries("Space Mission", id, "demo_adventure", "https://placehold.co/300x450/0F172A/FFFFFF?text=Space+Mission", "Aventura", "2024", "Tripulação demo testa transmissões HLS em uma missão espacial.")
        episodes = [DemoEpisode("sm_1", 1, "Decolagem", s.akamai), DemoEpisode("sm_2", 2, "Sinal Perdido", s.bunny)]
    else
        info = DemoSeries("Demo Adventures", "demo_series_3", "demo_series", "https://placehold.co/300x450/1E293B/FFFFFF?text=Demo+Adventures", "Animação", "2024", "Aventuras curtas para validar séries, episódios e player.")
        episodes = [DemoEpisode("da_1", 1, "Começo", s.sintel), DemoEpisode("da_2", 2, "O Retorno", s.bipbop)]
    end if
    return { info: info, seasons: [{ season_number: 1, name: "Temporada 1" }], episodes: { "1": episodes } }
end function

function DemoEpisode(id as String, num as Integer, title as String, url as String) as Object
    return { id: id, episode_num: num, title: title, name: title, container_extension: "m3u8", direct_url: url, stream_id: id }
end function

function DemoFilterByCategory(items as Object, categoryId as String) as Object
    filtered = []
    for each item in items
        if item.category_id = categoryId then filtered.Push(item)
    end for
    return filtered
end function
