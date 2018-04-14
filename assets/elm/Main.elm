module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
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
    , displayGamesList : Bool
    }

type alias Game =
    { id : Int
    , title : String
    , description : String
    , thumbnail : String
    , featured : Bool
    }

initialModel : Model
initialModel =
    { gamesList = []
    , displayGamesList = True
    }

model : List String
model =
    [ "Platform Game"
    , "Adventure Game"
    ]

init : ( Model, Cmd Msg )
init =
    ( initialModel, fetchGamesList)

-- API

fetchGamesList : Cmd Msg
fetchGamesList =
    Http.get "/api/games" decodeGamesList
        |> Http.send FetchGameList

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

-- UPDATE

type Msg
    = DisplayGamesList
    | HideGamesList
    | FetchGameList (Result Http.Error (List Game))

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchGameList (Ok games) ->
            ( { model | gamesList = games }, Cmd.none )

        FetchGameList (Err _) ->
            ( model, Cmd.none )
        
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
        , button [ class "btn btn-success", onClick DisplayGamesList ] [ text "Display Games List" ]
        , button [ class "btn btn-danger", onClick HideGamesList ] [ text "Hide Games List" ]
        , if model.displayGamesList && not (List.isEmpty model.gamesList) then gamesIndex model else div [] []
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

