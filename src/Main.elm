port module Main exposing (..)

import Api
import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
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


init : String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init apiKey _ _ =
    ( { markers = []
      , error = Nothing
      , search = ""
      , apiKey = apiKey
      , suggestions = Nothing
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

        FetchMarkers ->
            ( model, Api.fetchMarkers )

        ReceivedMarkers result ->
            handleMarkers model result

        ReceivedSuggestions result ->
            handleSuggestions model result

        HideError ->
            ( { model | error = Nothing }, Cmd.none )

        SearchInput val ->
            ( { model | search = val }, sendSearch val )

        SubmitSearch ->
            handleSubmitSearch model


handleSubmitSearch : Model -> ( Model, Cmd Msg )
handleSubmitSearch model =
    ( model, Api.autocompleteSearch model.apiKey model.search )



--( model, sendSearch model.search )


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


handleSuggestions : Model -> Result Http.Error (List AutocompleteItem) -> ( Model, Cmd Msg )
handleSuggestions model result =
    let
        errorMsg =
            { title = "Something went wrong"
            , body = "Can't retrieve suggestions"
            }
    in
    case result of
        Ok suggestions ->
            ( { model | suggestions = Just suggestions }, Cmd.none )

        Err err ->
            ( { model | suggestions = Nothing, error = Just errorMsg }, Cmd.none )


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
        [ dialog model
        , searchBar model
        , div [ id "map" ] []
        ]


searchBar : Model -> Html Msg
searchBar model =
    div [ class "search-bar" ]
        [ input [ placeholder "Search", id "search-input", onInput SearchInput ] []
        , button [ class "search-btn fas fa-search", onClick SubmitSearch ] []
        ]


dialog : Model -> Html Msg
dialog model =
    case model.error of
        Just errorMsg ->
            div [ class "overlay" ]
                [ div [ class "dialog" ]
                    [ div [ class "header" ]
                        [ span [ class "title" ] [ text errorMsg.title ]
                        , button [ class "close fas fa-times", onClick HideError ] []
                        ]
                    , div [ class "body" ]
                        [ p [ class "dialog-message" ] [ text errorMsg.body ]
                        ]
                    ]
                ]

        Nothing ->
            div [] []


decodeMarkersSubscription : String -> Msg
decodeMarkersSubscription _ =
    FetchMarkers



-- Ports


port sendMaps : String -> Cmd msg


port sendSearch : String -> Cmd msg


port sendMarkers : List Marker -> Cmd msg


port requestMarkers : (String -> msg) -> Sub msg
