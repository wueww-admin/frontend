module Main exposing (main)

import Bootstrap.Grid as Grid
import Browser
import Html exposing (Html, text)
import Html.Attributes exposing (style)
import Http
import Json.Encode
import Page.Login as Login
import Ports


type alias Model =
    { token : Maybe String
    , login : Login.Model
    }


type alias Flags =
    { token : Maybe String }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { token = flags.token
      , login = Login.init
      }
    , Cmd.none
    )


main : Platform.Program Flags Model Msg
main =
    Browser.element { init = init, subscriptions = subscriptions, update = update, view = view }


type Msg
    = NoOp
    | SetToken String
    | GotLoginMsg Login.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetToken newToken ->
            ( { model | token = Just newToken }, Ports.token newToken )

        GotLoginMsg Login.LoginNow ->
            ( model, loginRequest model.login )

        GotLoginMsg loginMsg ->
            ( { model | login = Login.update loginMsg model.login }, Cmd.none )


view : Model -> Html Msg
view model =
    case model.token of
        Just _ ->
            text "you're logged in" |> narrowContainer

        Nothing ->
            Login.loginForm model.login |> Html.map GotLoginMsg |> narrowContainer


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


loginRequest : Login.Model -> Cmd Msg
loginRequest model =
    let
        body =
            Http.jsonBody <|
                Json.Encode.object
                    [ ( "username", Json.Encode.string model.username )
                    , ( "password", Json.Encode.string model.password )
                    ]
    in
    Http.post
        { url = "/api/login"
        , body = body
        , expect = Http.expectString <| handleHttpResult SetToken
        }


handleHttpResult : (a -> Msg) -> Result Http.Error a -> Msg
handleHttpResult lift result =
    case result of
        Ok value ->
            lift value

        Err _ ->
            NoOp
