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

        PortFavorites favorites ->
            ( { model | favorites = favorites }, Api.fetchMarkers )

        ReceivedMarkers result ->
            handleMarkers model result

        HideDialog ->
            ( { model | dialog = Nothing }, Cmd.none )

        UpdateFavorites marker ->
            ( handleUpdateFavorites model marker, Cmd.none )

        AddToFavorites marker ->
            addToFavorites model marker

        DeleteFromFavorites marker ->
            deleteFromFavorites model marker

        ToggleFavorites ->
            { model | showFavorites = not model.showFavorites }
                |> portMarkers


portMarkers : Model -> ( Model, Cmd Msg )
portMarkers model =
    if model.showFavorites then
        ( model, toJSMarkers model.favorites )

    else
        ( model, toJSMarkers model.markers )



-- Favorites


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


addToFavorites : Model -> Marker -> ( Model, Cmd Msg )
addToFavorites model marker =
    let
        favorites =
            model.favorites ++ [ marker ]
    in
    ( { model
        | favorites = favorites
        , dialog = Nothing
      }
    , toJSStoreFavorites favorites
    )


deleteFromFavorites : Model -> Marker -> ( Model, Cmd Msg )
deleteFromFavorites model marker =
    let
        favorites =
            model.favorites
                |> List.filter (\m -> m.lat /= marker.lat && m.lng /= marker.lng)
    in
    ( { model | favorites = favorites, dialog = Nothing }, toJSStoreFavorites favorites )


isFavorite : Model -> Marker -> Bool
isFavorite model marker =
    model.favorites
        |> List.filter (\m -> m.lat == marker.lat && m.lng == marker.lng)
        |> List.head
        |> Maybe.map (\_ -> True)
        |> Maybe.withDefault False


favoritesBody : Marker -> Msg -> Html Msg
favoritesBody marker msg =
    div [ class "favorites-dialog-body" ]
        [ favoritesBodyRow "Name" marker.displayName
        , favoritesBodyRow "Address" (marker.streetName ++ " " ++ marker.number)
        , favoritesBodyRow "Postal code" marker.postalCode
        , favoritesBodyRow "City" marker.city
        , div [ class "button-bar" ]
            [ button [ class "confirm", onClick msg ] [ text "yes" ]
            , button [ class "deny", onClick HideDialog ] [ text "no" ]
            ]
        ]


favoritesBodyRow : String -> String -> Html Msg
favoritesBodyRow label info =
    div [ class "row" ]
        [ div [ class "label" ] [ text label ]
        , div [ class "detail" ] [ text info ]
        ]


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
        [ input [ placeholder "Search", id "search-input" ] []
        , div
            [ class "fav-btn fas fa-star"
            , classList [ ( "show-favorites", model.showFavorites ) ]
            , onClick ToggleFavorites
            ]
            []
        , div [ id "tooltip" ] [ text "Toggle favorites" ]
        ]



-- Dialog


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


openFavoriteDialog : Model -> Marker -> Model
openFavoriteDialog model marker =
    { model | dialog = Just (Favorites marker) }


favoritesDialog : Model -> Marker -> Html Msg
favoritesDialog model marker =
    if isFavorite model marker then
        let
            title =
                "Remove from favorites?"
        in
        dialog title (favoritesBody marker (DeleteFromFavorites marker))

    else
        let
            title =
                "Add to favorites?"
        in
        dialog title (favoritesBody marker (AddToFavorites marker))


errorDialog : ErrorMsg -> Html Msg
errorDialog errorMsg =
    let
        dialogBody =
            p [ class "dialog-message" ] [ text errorMsg.body ]
    in
    dialog errorMsg.title dialogBody



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ toElmFavorites favoritesSubscription
        , toElmMarkerSelected selectedSubscription
        ]


favoritesSubscription : List Marker -> Msg
favoritesSubscription favorites =
    PortFavorites favorites


selectedSubscription : Location -> Msg
selectedSubscription location =
    UpdateFavorites location



-- Ports


port toJSLoadMaps : String -> Cmd msg


port toJSMarkers : List Marker -> Cmd msg


port toJSStoreFavorites : List Marker -> Cmd msg


port toElmFavorites : (List Marker -> msg) -> Sub msg


port toElmMarkerSelected : (Location -> msg) -> Sub msg
