module Main exposing (main)

import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Browser
import Html exposing (Html, button, text)
import Html.Attributes exposing (for, style)
import Ports


type alias Model =
    { token : Maybe String
    }


type alias Flags =
    { token : Maybe String }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { token = flags.token }, Cmd.none )


main : Platform.Program Flags Model Msg
main =
    Browser.element { init = init, subscriptions = subscriptions, update = update, view = view }


type Msg
    = SetToken String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetToken newToken ->
            ( { model | token = Just newToken }, Ports.token newToken )


view : Model -> Html Msg
view model =
    case model.token of
        Just _ ->
            text "you're logged in" |> narrowContainer

        Nothing ->
            loginForm |> narrowContainer


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


narrowContainer : Html Msg -> Html Msg
narrowContainer content =
    Grid.container
        [ style "max-width" "23rem"
        , style "margin" "10rem auto 0"
        , style "box-shadow" "0 0 15px rgba(0, 0, 0, .15)"
        , style "padding" "2rem"
        ]
        [ content ]


loginForm : Html Msg
loginForm =
    Form.form []
        [ Form.group []
            [ Form.label [ for "login" ] [ text "Login" ]
            , Input.text [ Input.id "login" ]
            ]
        , Form.group []
            [ Form.label [ for "password" ] [ text "Passwort" ]
            , Input.password [ Input.id "password" ]
            ]
        , Button.button [ Button.primary ] [ text "Anmelden" ]
        ]
