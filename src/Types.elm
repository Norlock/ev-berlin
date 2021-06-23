module Types exposing (..)

import Browser exposing (UrlRequest)
import Http
import Url exposing (Url)


type alias Model =
    { markers : List Marker
    , favorites : List Marker
    , dialog : Maybe DialogType
    , showFavorites : Bool
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


type alias Location =
    { lat : Float
    , lng : Float
    }


type Msg
    = ChangedUrl Url
    | ClickedLink UrlRequest
    | PortFavorites (List Marker)
    | ReceivedMarkers (Result Http.Error (List Marker))
    | HideDialog
    | AddToFavorites Marker
    | DeleteFromFavorites Marker
    | UpdateFavorites Location
    | ToggleFavorites


type DialogType
    = Error ErrorMsg
    | Favorites Marker
