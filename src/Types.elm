module Types exposing (..)

import Browser exposing (UrlRequest)
import Http
import Url exposing (Url)


type alias Model =
    { markers : List Marker
    , error : Maybe ErrorMsg
    }


type alias ErrorMsg =
    { title : String
    , body : String
    }


type alias Marker =
    { lat : Float
    , lng : Float
    , streetName : String
    , number : String
    , postalCode : String
    , city : String
    , displayName : String
    }


type Msg
    = ChangedUrl Url
    | ClickedLink UrlRequest
    | RequestMarkers
    | ReceivedMarkers (Result Http.Error (List Marker))
