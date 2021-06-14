module Types exposing (..)

import Browser exposing (UrlRequest)
import Http
import Url exposing (Url)


type alias Model =
    { markers : List Marker
    , error : Maybe ErrorMsg
    , search : String
    , apiKey : String
    , suggestions : Maybe (List AutocompleteItem)
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


type alias AutocompleteItem =
    { description : String
    , distanceInMeters : Int
    , placeId : String
    , types : List String
    }


type Msg
    = ChangedUrl Url
    | ClickedLink UrlRequest
    | FetchMarkers 
    | ReceivedMarkers (Result Http.Error (List Marker))
    | ReceivedSuggestions (Result Http.Error (List AutocompleteItem))
    | HideError
    | SearchInput String
    | SubmitSearch
