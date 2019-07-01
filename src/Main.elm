module Main exposing (main)

import Base64
import Bootstrap.Alert as Alert
import Bootstrap.Grid as Grid
import Bootstrap.Modal as Modal
import Bootstrap.Navbar as Navbar
import Browser
import Html exposing (Html, a, i, li, span, text, ul)
import Html.Attributes exposing (href, style)
import Http
import Json.Decode
import Json.Encode
import Page.Login as Login
import Ports


type alias Model =
    { token : Maybe String
    , navbarState : Navbar.State
    , blocked : Bool
    , error : Maybe String
    , login : Login.Model
    }


type alias Flags =
    { token : Maybe String }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavbarMsg
    in
    ( { token = flags.token
      , navbarState = navbarState
      , blocked = False
      , error = Nothing
      , login = Login.init
      }
    , navbarCmd
    )


main : Platform.Program Flags Model Msg
main =
    Browser.element { init = init, subscriptions = subscriptions, update = update, view = view }


type Msg
    = NoOp
    | SetError String
    | SetToken String
    | GotLoginMsg Login.Msg
    | NavbarMsg Navbar.State


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

        NavbarMsg state ->
            ( { model | navbarState = state }, Cmd.none )


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
            viewNavbar model.navbarState x

        {- case decodeToken x |> Result.map (\{ role, email } -> ( role, email )) of
           Ok ( User, email ) ->
               text <| "nice, you're a user w/ addy " ++ email

           Ok ( Editor, _ ) ->
               text "woohoo, you're the editor!"

           Err _ ->
               text "arghl, invalid token"
        -}
        Nothing ->
            Login.loginForm model.login |> Html.map GotLoginMsg |> narrowContainer model


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


viewNavbar : Navbar.State -> String -> Html Msg
viewNavbar navbarState token =
    Navbar.config NavbarMsg
        |> Navbar.withAnimation
        |> Navbar.dark
        |> Navbar.brand [ href "#" ] [ text "WueWW Admin" ]
        |> Navbar.items
            [ Navbar.itemLink [ href "#" ] [ text "Sessions" ]
            , Navbar.itemLink [ href "#" ] [ text "Organisation" ]
            ]
        |> Navbar.customItems
            [ Navbar.textItem [] [ text "foo@example.org" ]
            , ul [ Html.Attributes.class "navbar-nav" ]
                [ li [ Html.Attributes.class "nav-item" ]
                    [ a [ href "#", Html.Attributes.class "nav-link" ] [ text "\u{00A0}", i [ Html.Attributes.class "fa", Html.Attributes.class "fa-sign-out" ] [] ]
                    ]
                ]
                |> Navbar.customItem
            ]
        |> Navbar.view navbarState


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
    , email : String
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
    decodedToken
        |> Json.Decode.decodeString
            (Json.Decode.map2 TokenInfo
                (Json.Decode.field "role" Json.Decode.string |> Json.Decode.andThen decodeRole)
                (Json.Decode.field "email" Json.Decode.string)
            )
        |> Result.mapError Json.Decode.errorToString


decodeRole : String -> Json.Decode.Decoder Role
decodeRole roleStr =
    case roleStr of
        "user" ->
            Json.Decode.succeed User

        "editor" ->
            Json.Decode.succeed Editor

        _ ->
            Json.Decode.fail "Unexpected role"
