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
        [ h1 [ class "games-section" ] [ text "Games" ]
        -- , button [ class "btn btn-success", onClick DisplayGamesList ] [ text "Display Games List" ]
        -- , button [ class "btn btn-danger", onClick HideGamesList ] [ text "Hide Games List" ]
        , if not (List.isEmpty model.gamesList) && model.displayGamesList then gamesIndex model else div [] []
        , playersIndex model
        ]

gamesIndex : Model -> Html msg
gamesIndex model =
    div [ class "games-index" ] [ gamesList model.gamesList ]

gamesList : List Game -> Html msg
gamesList games =
    ul [ class "games-list" ] (List.map gamesListItem games)

gamesListItem : Game -> Html msg
gamesListItem game =
    li [ class "game-item" ]
        [ strong [] [ text game.title ]
        , p [] [ text game.description ]
        ]

playersIndex : Model -> Html msg
playersIndex model =
    if List.isEmpty model.playersList then
        div [] []
    else
        div [ class "players-index" ]
            [ h1 [ class "players-section" ] [ text "Players" ]
            , playersList model.playersList
                -- |> List.sortBy .score
                -- |> List.reverse
                -- |> playersList
            ]

playersList : List Player -> Html msg
playersList players =
    ul [ class "players-list" ] (List.map playersListItem players)

playersListItem : Player -> Html msg
playersListItem player =
    let
        displayName =
            if player.displayName == Nothing then
                player.username
            else
                Maybe.withDefault "" player.displayName
    in
        li [ class "player-item" ]
            [ strong [] [ text displayName ]
            , p [] [ text (toString player.score) ]
            ]