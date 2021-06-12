port module Main exposing (main)

import Api
import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Types exposing (..)
import Url


main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ _ _ =
    ( { markers = []
      , error = Nothing
      }
    , sendMaps "load"
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangedUrl _ ->
            ( model, Cmd.none )

        ClickedLink _ ->
            ( model, Cmd.none )

        ReceivedMarkers result ->
            handleMarkers model result

        RequestMarkers ->
            ( model, Api.fetchMarkers )


handleMarkers : Model -> Result Http.Error (List Marker) -> ( Model, Cmd Msg )
handleMarkers model result =
    let
        errorMsg =
            { title = "Something went wrong"
            , body = "Can't retrieve markers"
            }
    in
    case result of
        Ok markers ->
            ( { model | markers = markers }, sendMarkers markers )

        Err err ->
            ( { model | error = Just errorMsg }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    requestMarkers decodeMarkersSubscription


view : Model -> Browser.Document Msg
view model =
    { title = "Ev charge"
    , body = [ body model ]
    }


body : Model -> Html Msg
body model =
    div [ class "container" ]
        [ searchBar model
        , div [ id "map" ] []
        ]


searchBar : Model -> Html Msg
searchBar model =
    div [ class "search-bar" ]
        [ input [ placeholder "Search" ] []
        , button [] [ text "Submit" ]
        ]


dialog : Model -> Html Msg
dialog model =
    div [] []


decodeMarkersSubscription : String -> Msg
decodeMarkersSubscription _ =
    RequestMarkers



-- Ports


port sendMaps : String -> Cmd msg


port sendMarkers : List Marker -> Cmd msg


port requestMarkers : (String -> msg) -> Sub msg
