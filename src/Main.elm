module Main exposing (main)

import Base64
import Bootstrap.Alert as Alert
import Bootstrap.Grid as Grid
import Bootstrap.Modal as Modal
import Browser
import Html exposing (Html, text)
import Html.Attributes exposing (style)
import Http
import Json.Decode
import Json.Encode
import Page.Login as Login
import Ports


type alias Model =
    { token : Maybe String
    , blocked : Bool
    , error : Maybe String
    , login : Login.Model
    }


type alias Flags =
    { token : Maybe String }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { token = flags.token
      , blocked = False
      , error = Nothing
      , login = Login.init
      }
    , Cmd.none
    )


main : Platform.Program Flags Model Msg
main =
    Browser.element { init = init, subscriptions = subscriptions, update = update, view = view }


type Msg
    = NoOp
    | SetError String
    | SetToken String
    | GotLoginMsg Login.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetError x ->
            ( { model | error = Just x } |> unblockUI, Cmd.none )

        SetToken newToken ->
            ( { model | token = Just newToken } |> unblockUI, Ports.token newToken )

        GotLoginMsg Login.LoginNow ->
            ( { model | login = Login.init } |> clearError |> blockUI, loginRequest model.login )

        GotLoginMsg loginMsg ->
            ( { model | login = Login.update loginMsg model.login }, Cmd.none )


blockUI : Model -> Model
blockUI model =
    { model | blocked = True }


unblockUI : Model -> Model
unblockUI model =
    { model | blocked = False }


clearError : Model -> Model
clearError model =
    { model | error = Nothing }


view : Model -> Html Msg
view model =
    case model.token of
        Just x ->
            case decodeToken x |> Result.map .role of
                Ok User ->
                    text "nice, you're a user :-)"

                Ok Editor ->
                    text "woohoo, you're the editor!"

                Err _ ->
                    text "arghl, invalid token"

        Nothing ->
            Login.loginForm model.login |> Html.map GotLoginMsg |> narrowContainer model


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


narrowContainer : Model -> Html Msg -> Html Msg
narrowContainer model content =
    let
        alert =
            case model.error of
                Just x ->
                    [ Alert.simpleDanger [] [ text x ] ]

                Nothing ->
                    []

        blocker =
            if model.blocked then
                [ Modal.config NoOp |> Modal.body [] [ text "Daten werden geladen ..." ] |> Modal.view Modal.shown ]

            else
                []
    in
    alert
        ++ content
        :: blocker
        |> Grid.container
            [ style "max-width" "23rem"
            , style "margin" "10rem auto 0"
            , style "box-shadow" "0 0 15px rgba(0, 0, 0, .15)"
            , style "padding" "2rem"
            ]


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

        Err (Http.BadStatus 403) ->
            SetError "Zugriff verweigert"

        Err _ ->
            SetError "Unerwarteter Fehler"



--
-- Token Parser
--


type alias TokenInfo =
    { role : Role
    }


type Role
    = User
    | Editor


decodeToken : String -> Result String TokenInfo
decodeToken token =
    case String.split "." token of
        _ :: payload :: _ ->
            Base64.decode payload |> Result.andThen parseToken

        _ ->
            Err "Invalid JWT token structure"


parseToken : String -> Result String TokenInfo
parseToken decodedToken =
    case Json.Decode.decodeString (Json.Decode.field "role" Json.Decode.string) decodedToken of
        Ok roleStr ->
            decodeRole roleStr |> Result.map TokenInfo

        _ ->
            Err "Invalid JSON token payload"


decodeRole : String -> Result String Role
decodeRole roleStr =
    case roleStr of
        "user" ->
            Ok User

        "editor" ->
            Ok Editor

        _ ->
            Err "Unexpected role"
