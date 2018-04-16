module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
-- import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode


-- MAIN

main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

-- MODEL

type alias Model =
    { gamesList : List Game
    , playersList : List Player
    , errors : String
    , displayGamesList : Bool
    }

type alias Game =
    { id : Int
    , title : String
    , description : String
    , thumbnail : String
    , featured : Bool
    }

type alias Player =
    { id : Int
    , username : String
    , displayName : Maybe String
    , score : Int
    }

initialModel : Model
initialModel =
    { gamesList = []
    , playersList = []
    , errors = ""
    , displayGamesList = True
    }

init : ( Model, Cmd Msg )
init =
    ( initialModel, initialCommand )

initialCommand : Cmd Msg
initialCommand =
    Cmd.batch
        [ fetchGamesList
        , fetchPlayersList
        ]

-- API

fetchGamesList : Cmd Msg
fetchGamesList =
    Http.get "/api/games" decodeGamesList
        |> Http.send FetchGamesList

decodeGamesList : Decode.Decoder (List Game)
decodeGamesList =
    decodeGame
        |> Decode.list
        |> Decode.at [ "data" ]

decodeGame : Decode.Decoder Game
decodeGame =
    Decode.map5 Game
        (Decode.field "id" Decode.int)
        (Decode.field "title" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "thumbnail" Decode.string)
        (Decode.field "featured" Decode.bool)

fetchPlayersList : Cmd Msg
fetchPlayersList =
    Http.get "/api/players" decodePlayersList
        |> Http.send FetchPlayersList

decodePlayersList : Decode.Decoder (List Player)
decodePlayersList =
    decodePlayer
        |> Decode.list
        |> Decode.at [ "data" ]

decodePlayer : Decode.Decoder Player
decodePlayer =
    Decode.map4 Player
        (Decode.field "id" Decode.int)
        (Decode.field "username" Decode.string)
        (Decode.maybe (Decode.field "display_name" Decode.string))
        (Decode.field "score" Decode.int)

-- UPDATE

type Msg
    = DisplayGamesList
    | HideGamesList
    | FetchGamesList (Result Http.Error (List Game))
    | FetchPlayersList (Result Http.Error (List Player))

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchPlayersList (Ok players) ->
            ( { model | playersList = players }, Cmd.none )

        FetchPlayersList (Err message) ->
            ( { model | errors = toString message }, Cmd.none )

        FetchGamesList (Ok games) ->
            ( { model | gamesList = games }, Cmd.none )

        FetchGamesList (Err message) ->
            ( { model | errors = toString message }, Cmd.none )
        
        DisplayGamesList ->
            ( { model | displayGamesList = True }, Cmd.none )

        HideGamesList ->
            ( { model | displayGamesList = False }, Cmd.none )

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

-- VIEW

view : Model -> Html Msg
view model =
    div []
        -- , button [ class "btn btn-success", onClick DisplayGamesList ] [ text "Display Games List" ]
        -- , button [ class "btn btn-danger", onClick HideGamesList ] [ text "Hide Games List" ]
        [ featured model
        , gamesIndex model
        , playersIndex model
        ]

featured : Model -> Html msg
featured model =
    case featuredGame model.gamesList of
        Just game ->
            div [ class "row featured" ]
                [ div [ class "container" ]
                    [ div [ class "featured-img" ]
                        [ img [ class "featured-thumbnail", src game.thumbnail ] [] ]
                    , div [ class "featured-data" ]
                        [ h1 [] [ text "Featured" ]
                        , h2 [] [ text game.title ]
                        , p [] [ text game.description ]
                        , button [ class "btn btn-lg btn-primary" ]
                            [ text "Play now!" ]
                        ] ] ]
        Nothing ->
            div [] []

featuredGame : List Game -> Maybe Game
featuredGame games =
    games
        |> List.filter .featured
        |> List.head

gamesIndex : Model -> Html msg
gamesIndex model =
    if not (List.isEmpty model.gamesList) && model.displayGamesList then
        div [ class "games-index" ] 
            [ h1 [ class "games-section" ] [ text "Games" ]
            , gamesList model.gamesList
            ]
    else
        div [] []

gamesList : List Game -> Html msg
gamesList games =
    ul [ class "games-list media-list" ] (List.map gamesListItem games)

gamesListItem : Game -> Html msg
gamesListItem game =
    a [ href "#" ]
        [ li [ class "game-item media" ]
            [ div [ class "media-left" ]
                [ img [ class "media-object", src game.thumbnail ] []
                ]
            , div [ class "media-body media-middle" ]
                [ h4 [ class "media-heading" ] [ text game.title ]
                , p [] [ text game.description ]
                ]
            ]
        ]

playersIndex : Model -> Html msg
playersIndex model =
    if List.isEmpty model.playersList then
        div [] []
    else
        div [ class "players-index" ]
            [ h1 [ class "players-section" ] [ text "Players" ]
            , model.playersList
                |> List.sortBy .score
                |> List.reverse
                |> playersList
            ]

playersList : List Player -> Html msg
playersList players =
    div [ class "players-list panel panel-info" ]
        [ div [ class "panel-heading" ] [ text "Leaderboard" ]
        , ul [ class "list-group mt-0" ] (List.map playersListItem players)
        ]
    

playersListItem : Player -> Html msg
playersListItem player =
    let
        displayName =
            if player.displayName == Nothing then
                player.username
            else
                Maybe.withDefault "" player.displayName
        
        playerLink = "players/" ++ (toString player.id)
    in
        li [ class "player-item list-group-item" ]
            [ strong [] [ a [ href playerLink ] [ text displayName ] ]
            , span [ class "badge" ] [ text (toString player.score) ]
            ]