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


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ _ _ =
    ( { markers = []
      , error = Nothing
      , dialog = Nothing
      , search = ""
      }
    , toJSLoadMaps ""
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

        HideError ->
            ( { model | error = Nothing }, Cmd.none )

        SearchInput val ->
            ( { model | search = val }, Cmd.none )

        SubmitSearch ->
            handleSubmitSearch model


handleSubmitSearch : Model -> ( Model, Cmd Msg )
handleSubmitSearch model =
    ( model, Cmd.none )


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
            ( { model | markers = markers }, toJSMarkers markers )

        Err _ ->
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
        [ selectedDialog model
        , searchBar
        , div [ id "map" ] []
        ]


searchBar : Html Msg
searchBar =
    div [ class "search-bar" ]
        [ input [ placeholder "Search", id "search-input", onInput SearchInput ] []
        , button [ class "nav-btn fas fa-search", onClick SubmitSearch ] []
        , button [ class "nav-btn fas fa-star" ] []
        ]


selectedDialog : Model -> Html Msg
selectedDialog model =
    case model.dialog of
        Just Error ->
            errorDialog model

        Just Favorites ->
            favoritesDialog model

        Nothing ->
            div [] []


dialog : String -> Html Msg -> Html Msg
dialog title dialogBody =
    div [ class "overlay" ]
        [ div [ class "dialog" ]
            [ div [ class "header" ]
                [ span [ class "title" ] [ text title ]
                , button [ class "close fas fa-times", onClick HideError ] []
                ]
            , div [ class "body" ]
                [ dialogBody
                ]
            ]
        ]


favoritesDialog : Model -> Html Msg
favoritesDialog model =
    -- TODO add / remove from favorites
    let
        title =
            "Add to favorites?"
    in
    dialog title (favoritesBody model)


favoritesBody : Model -> Html Msg
favoritesBody model =
    div [ class "favorites-dialog-body" ]
        [ button [ class "confirm" ] [ text "yes" ]
        , button [ class "deny" ] [ text "no" ]
        ]


errorDialog : Model -> Html Msg
errorDialog model =
    case model.error of
        Just errorMsg ->
            let
                dialogBody =
                    p [ class "dialog-message" ] [ text errorMsg.body ]
            in
            dialog errorMsg.title dialogBody

        Nothing ->
            div [] []


decodeMarkersSubscription : String -> Msg
decodeMarkersSubscription _ =
    FetchMarkers



-- Ports


port toJSLoadMaps : String -> Cmd msg


port toJSMarkers : List Marker -> Cmd msg


port requestMarkers : (String -> msg) -> Sub msg
