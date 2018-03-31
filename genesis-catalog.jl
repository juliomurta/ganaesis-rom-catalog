
module GenesisOptions   
    using Cascadia
    using Gumbo
    using Requests
 
    import Requests:get

    export list_all_roms
    export list_by_letter
    export search_by_name
    export load_available_games
    export Game

    type Game
        name::String
        link::String
        category::String
    end

    games = Dict{ Int64, Game }()
    url = "http://coolrom.com"
    
    function map_link(link_content)
        link = matchall(Selector("a"), link_content)[1]
        complete_url = string(url, link.attributes["href"])
        return (nodeText(link), complete_url)
    end

    function print_game(id, game)
        println("$id - [Name: $(game.name), Link: $(game.link)]")
    end

    function list_all_roms()
        for id in sort!(collect(keys(games))) 
            game = games[id]
            print_game(id, game)
        end
    end

    function list_by_letter()
        print("Type a letter -> ")
        found = false
        letter = lowercase(readline())
        for id in sort!(collect(keys(games))) 
            game = games[id]
            if game.category == letter
                print_game(id, game)     
                found = true
            end
        end
        if !found
            println("Any game that starts with the letter '$letter' was found.")
        end
    end

    function search_by_name()
        print("Type a game name -> ")
        found = false
        game_name = lowercase(readline())
        for id in sort!(collect(keys(games))) 
            game = games[id]
            if contains(lowercase(game.name), game_name)
                print_game(id, game)     
                found = true
            end
        end
        if !found
            println("Any game that contains '$game_name' was found.")
        end
    end

    function load_available_games()
        println("Loading games, it can take a few minutes...")

        alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", 
                    "n", "o", "p", "q", "r", "s", "t", "u", "v", "x", "w", "y", "z"]        
        id = 0
        for letter in alphabet
            content = get(string(url, "/roms/genesis/", letter))
            document = parsehtml(convert(String, content.data))

            usa_links    = matchall(Selector(".USA")   , document.root)
            japan_links  = matchall(Selector(".Japan") , document.root)
            europe_links = matchall(Selector(".Europe"), document.root)

            for (usa, japan, europe) in zip(usa_links, japan_links, europe_links)
                x = map_link(usa)
                y = map_link(japan)
                z = map_link(europe)

                id = id + 1
                games[id] = Game(x[1], x[2], letter)

                id = id + 1
                games[id] = Game(y[1], y[2], letter)

                id = id + 1
                games[id] = Game(z[1], z[2], letter)
            end            
        end    
        println("Done!")
    end
end

module GenesisCatalog
    using GenesisOptions
    export main
    
    options = Dict( "1 - List all Roms"  => list_all_roms, 
                    "2 - List by Letter" => list_by_letter,
                    "3 - Search by Name" => search_by_name)

    function show_presentation()
        println("====================================== GENESIS ROM ======================================")
        println("Version: 1.0.0")         
    end
                
    function show_menu()
        option_keys = keys(options)
        option_menu = sort!(collect(option_keys))           
        for item in option_menu
            println(item)
        end
    end

    function get_user_choice()
        print("option -> ")
        choice = parse(Int64, readline())
        for (k, option) in options
            if parse(Int64, k[1]) == choice 
                println("Loading...")
                option()
            end
        end
    end

    function main()        
        show_presentation()
        load_available_games()
        while(true)            
            show_menu()
            get_user_choice()
        end
    end
end

using GenesisCatalog
main()