module Main exposing (main)

import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)


type alias Model =
    Int


main : Platform.Program () Model Msg
main =
    Browser.sandbox { init = 0, update = update, view = view }


type Msg
    = Increment
    | Decrement


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            model + 1

        Decrement ->
            model - 1


view : Model -> Html Msg
view model =
    Grid.container []
        [ Button.button [ Button.onClick Decrement ] [ text "-" ]
        , div [] [ text (String.fromInt model) ]
        , Button.button [ Button.onClick Increment ] [ text "+" ]
        ]
