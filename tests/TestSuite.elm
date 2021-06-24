module TestSuite exposing (..)

import Expect
import Html exposing (div)
import Main exposing (addToFavorites, openFavoriteDialog, selectedDialog, update)
import Test exposing (..)
import Types exposing (..)


stubModel : Model
stubModel =
    { markers = []
    , favorites = []
    , dialog = Nothing
    , showFavorites = False
    }


stubFavoritesModel : Model
stubFavoritesModel =
    { markers = []
    , favorites = stubMarkers
    , dialog = Nothing
    , showFavorites = False
    }


stubMarkers : List Marker
stubMarkers =
    [ { lat = 51.123456
      , lng = 54.123456
      , streetName = "Unter den Linden"
      , number = "77"
      , postalCode = "12345"
      , city = "Berlin"
      , displayName = "Ev charger Unter den Linden"
      }
    , { lat = 51.654321
      , lng = 54.654321
      , streetName = "Spandaur str."
      , number = "33"
      , postalCode = "12543"
      , city = "Berlin"
      , displayName = "Ev charger Spandaur str."
      }
    ]


newFavorite : Marker
newFavorite =
    { lat = 52.654321
    , lng = 52.654321
    , streetName = "Breite str."
    , number = "22"
    , postalCode = "12544"
    , city = "Berlin"
    , displayName = "Ev charger Breite str."
    }


suite : Test
suite =
    describe "Main module"
        [ describe "favorites"
            -- Nest as many descriptions as you like.
            [ test "will set the favorites" <|
                \_ ->
                    let
                        tuple =
                            update (PortFavorites stubMarkers) stubModel

                        model =
                            Tuple.first tuple
                    in
                    Expect.equal model.favorites stubMarkers

            -- Expect.equal is designed to be used in pipeline style, like this.
            , test "will add a favorite" <|
                \_ ->
                    let
                        newTuple =
                            update (AddToFavorites newFavorite) stubFavoritesModel

                        newModel =
                            Tuple.first newTuple
                    in
                    Expect.equal (List.length newModel.favorites) 3
            , test "remove a favorite" <|
                \_ ->
                    let
                        ( model, _ ) =
                            addToFavorites stubFavoritesModel newFavorite

                        ( newModel, _ ) =
                            update (DeleteFromFavorites newFavorite) model
                    in
                    Expect.equal (List.length newModel.favorites) 2
            ]
        ]


dialog : Test
dialog =
    describe "dialog"
        [ test "hide dialog by default" <|
            \_ ->
                Expect.equal (selectedDialog stubModel) (div [] [])
        , test "Show a dialog" <|
            \_ ->
                openFavoriteDialog stubModel newFavorite
                    |> selectedDialog
                    |> Expect.notEqual (div [] [])
        ]
