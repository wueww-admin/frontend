module Page.Login exposing (Model, Msg(..), init, loginForm, update)

import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Html exposing (Html, button, text)
import Html.Attributes exposing (for)


type alias Model =
    { username : String
    , password : String
    }


type Msg
    = ChangeLoginUsername String
    | ChangeLoginPassword String
    | LoginNow


init : Model
init =
    { username = "", password = "" }


update : Msg -> Model -> Model
update msg model =
    case msg of
        ChangeLoginUsername x ->
            { model | username = x }

        ChangeLoginPassword x ->
            { model | password = x }

        LoginNow ->
            model


loginForm : Model -> Html Msg
loginForm model =
    Form.form []
        [ Form.group []
            [ Form.label [ for "username" ] [ text "Login" ]
            , Input.text [ Input.id "username", Input.value model.username, Input.onInput ChangeLoginUsername ]
            ]
        , Form.group []
            [ Form.label [ for "password" ] [ text "Passwort" ]
            , Input.password [ Input.id "password", Input.value model.password, Input.onInput ChangeLoginPassword ]
            ]
        , Button.button [ Button.primary, Button.onClick LoginNow ] [ text "Anmelden" ]
        ]
