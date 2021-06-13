module Api exposing (..)

import Http
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Types exposing (..)



-- Markers


fetchMarkers : Cmd Msg
fetchMarkers =
    Http.get
        { url = "/resources/ev-chargepoints.json"
        , expect = Http.expectJson ReceivedMarkers markersDecoder
        }


markersDecoder : Decoder (List Marker)
markersDecoder =
    list markerDecoder


markerDecoder : Decoder Marker
markerDecoder =
    Decode.succeed Marker
        |> required "lat" float
        |> required "lng" float
        |> required "street_name" string
        |> required "number" string
        |> required "postal_code" string
        |> required "city" string
        |> required "name" string



-- Maps TODO restrict lat lng search


autocompleteSearch : ( String, String ) -> Cmd Msg
autocompleteSearch searchData =
    Http.get
        { url = autocompleteUrl searchData
        , expect = Http.expectJson ReceivedMarkers markersDecoder
        }


autocompleteUrl : ( String, String ) -> String
autocompleteUrl ( key, val ) =
    "https://maps.googleapis.com/maps/api/place/autocomplete/json?input="
        ++ val
        ++ " &key="
        ++ key
        ++ "&sessiontoken=1234567890"
