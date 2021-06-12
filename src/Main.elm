port module Main exposing (main)

import Api
import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
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
    ( { markers = [] }
    , Cmd.batch
        [ mapsSend "load"
        , Api.fetchMarkers
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangedUrl _ ->
            ( model, Cmd.none )

        ClickedLink _ ->
            ( model, Cmd.none )

        FetchMarkers ->
            ( model, Cmd.none )

        ReceivedMarkers markers ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


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



-- Ports


port mapsSend : String -> Cmd msg


port fetchMarkers : (String -> msg) -> Sub msg
