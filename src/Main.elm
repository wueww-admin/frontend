module Main exposing (main)

import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Ports


type alias Model =
    { value : Int
    , token : Maybe String
    }


type alias Flags =
    { token : Maybe String }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { value = 0, token = flags.token }, Cmd.none )


main : Platform.Program Flags Model Msg
main =
    Browser.element { init = init, subscriptions = subscriptions, update = update, view = view }


type Msg
    = Increment
    | Decrement
    | SetToken String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | value = model.value + 1 }, Cmd.none )

        Decrement ->
            ( { model | value = model.value - 1 }, Cmd.none )

        SetToken newToken ->
            ( { model | token = Just newToken }, Ports.token newToken )


view : Model -> Html Msg
view model =
    Grid.container []
        [ Button.button [ Button.onClick Decrement ] [ text "-" ]
        , div [] [ text (String.fromInt model.value) ]
        , Button.button [ Button.onClick Increment ] [ text "+" ]
        ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
