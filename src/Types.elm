module Types exposing (..)

import Browser exposing (UrlRequest)
import Url exposing (Url)


type alias Model =
    {}


type Msg
    = ChangedUrl Url
    | ClickedLink UrlRequest
