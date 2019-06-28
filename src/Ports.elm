port module Ports exposing (token)


port token_ : String -> Cmd msg


token : String -> Cmd msg
token =
    token_
