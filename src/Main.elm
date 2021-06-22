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
      , favorites = []
      , dialog = Nothing
      , search = ""
      , showFavorites = False
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

        HideDialog ->
            ( { model | dialog = Nothing }, Cmd.none )

        SearchInput val ->
            ( { model | search = val }, Cmd.none )

        SubmitSearch ->
            handleSubmitSearch model

        UpdateFavorites marker ->
            ( handleUpdateFavorites model marker, Cmd.none )

        AddToFavorites marker ->
            ( { model
                | favorites = model.favorites ++ [ marker ]
                , dialog = Nothing
              }
            , Cmd.none
            )

        DeleteFromFavorites marker ->
            let
                favorites =
                    model.favorites
                        |> List.filter (\m -> m.lat /= marker.lat && m.lng /= marker.lng)
            in
            ( { model | favorites = favorites, dialog = Nothing }, Cmd.none )

        ToggleFavorites ->
            { model | showFavorites = not model.showFavorites }
                |> portMarkers


portMarkers : Model -> ( Model, Cmd Msg )
portMarkers model =
    if model.showFavorites then
        ( model, toJSMarkers model.favorites )

    else
        ( model, toJSMarkers model.markers )


handleUpdateFavorites : Model -> Location -> Model
handleUpdateFavorites model marker =
    let
        errorMsg =
            { title = "Something went wrong"
            , body = "Can't find the selected marker"
            }
    in
    model.markers
        |> List.filter (\m -> m.lat == marker.lat && m.lng == marker.lng)
        |> List.head
        |> Maybe.map (openFavoriteDialog model)
        |> Maybe.withDefault { model | dialog = Just (Error errorMsg) }


openFavoriteDialog : Model -> Marker -> Model
openFavoriteDialog model marker =
    { model | dialog = Just (Favorites marker) }


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
            ( { model | dialog = Just (Error errorMsg) }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ requestMarkers decodeMarkersSubscription
        , toElmMarkerSelected locationSubscription
        ]


view : Model -> Browser.Document Msg
view model =
    { title = "Ev charge"
    , body = [ body model ]
    }


body : Model -> Html Msg
body model =
    div [ class "container" ]
        [ selectedDialog model
        , searchBar model
        , div [ id "map" ] []
        ]


searchBar : Model -> Html Msg
searchBar model =
    div [ class "search-bar" ]
        [ input [ placeholder "Search", id "search-input", onInput SearchInput ] []
        , button [ class "nav-btn fas fa-search", onClick SubmitSearch ] []
        , button
            [ class "nav-btn fav-btn fas fa-star"
            , classList [ ( "show-favorites", model.showFavorites ) ]
            , onClick ToggleFavorites
            ]
            []
        ]


selectedDialog : Model -> Html Msg
selectedDialog model =
    case model.dialog of
        Just (Error errorMsg) ->
            errorDialog errorMsg

        Just (Favorites marker) ->
            favoritesDialog model marker

        Nothing ->
            div [] []


dialog : String -> Html Msg -> Html Msg
dialog title dialogBody =
    div [ class "overlay" ]
        [ div [ class "dialog" ]
            [ div [ class "header" ]
                [ span [ class "title" ] [ text title ]
                , button [ class "close fas fa-times", onClick HideDialog ] []
                ]
            , div [ class "body" ]
                [ dialogBody
                ]
            ]
        ]


favoritesDialog : Model -> Marker -> Html Msg
favoritesDialog model marker =
    if isFavorite model marker then
        let
            title =
                "Remove from favorites?"
        in
        dialog title (favoritesBody (DeleteFromFavorites marker))

    else
        let
            title =
                "Add to favorites?"
        in
        dialog title (favoritesBody (AddToFavorites marker))


isFavorite : Model -> Marker -> Bool
isFavorite model marker =
    model.favorites
        |> List.filter (\m -> m.lat == marker.lat && m.lng == marker.lng)
        |> List.head
        |> Maybe.map (\_ -> True)
        |> Maybe.withDefault False


favoritesBody : Msg -> Html Msg
favoritesBody msg =
    div [ class "favorites-dialog-body" ]
        [ button [ class "confirm", onClick msg ] [ text "yes" ]
        , button [ class "deny", onClick HideDialog ] [ text "no" ]
        ]


errorDialog : ErrorMsg -> Html Msg
errorDialog errorMsg =
    let
        dialogBody =
            p [ class "dialog-message" ] [ text errorMsg.body ]
    in
    dialog errorMsg.title dialogBody


decodeMarkersSubscription : String -> Msg
decodeMarkersSubscription _ =
    FetchMarkers


locationSubscription : Location -> Msg
locationSubscription location =
    UpdateFavorites location



-- Ports


port toJSLoadMaps : String -> Cmd msg


port toJSMarkers : List Marker -> Cmd msg


port requestMarkers : (String -> msg) -> Sub msg


port toElmMarkerSelected : (Location -> msg) -> Sub msg
