module BabySudoku exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes as Attribute
import Html.Events as Event
import MicroKanren
import MicroKanren.Kernel as Kernel exposing (..)


main =
    Browser.sandbox
        { init = emptyModel
        , update = update
        , view = view
        }


type alias Model =
    { a : Hint
    , b : Hint
    , c : Hint
    , d : Hint
    , e : Hint
    , f : Hint
    , g : Hint
    , h : Hint
    , i : Hint
    , j : Hint
    , k : Hint
    , l : Hint
    , m : Hint
    , n : Hint
    , o : Hint
    , p : Hint
    }


type alias Hint =
    Maybe SudokuValue


type SudokuValue
    = One
    | Two
    | Three
    | Four


emptyModel : Model
emptyModel =
    { a = Just Four
    , b = Nothing
    , c = Nothing
    , d = Nothing
    , e = Nothing
    , f = Nothing
    , g = Nothing
    , h = Nothing
    , i = Nothing
    , j = Nothing
    , k = Nothing
    , l = Nothing
    , m = Nothing
    , n = Nothing
    , o = Nothing
    , p = Nothing
    }



-- UPDATE


type Message
    = Set (Model -> Hint) String


update : Message -> Model -> Model
update message model =
    case message of
        Set attribute input ->
            { model | a = stringToSudokuValue input }



-- VIEW


view : Model -> Html Message
view model =
    Html.div []
        [ viewPuzzleInput model
        , viewPuzzle model
        ]


viewPuzzleInput : Model -> Html Message
viewPuzzleInput model =
    Html.table []
        [ Html.tr []
            [ Html.td []
                [ Html.select [ Event.onInput <| Set .a ]
                    [ Html.option [ Attribute.value "unknown" ] [ Html.text "unknown" ]
                    , Html.option [ Attribute.value <| sudokuValueToString One ] [ Html.text <| sudokuValueToString One ]
                    , Html.option [ Attribute.value <| sudokuValueToString Two ] [ Html.text <| sudokuValueToString Two ]
                    , Html.option [ Attribute.value <| sudokuValueToString Three ] [ Html.text <| sudokuValueToString Three ]
                    , Html.option [ Attribute.value <| sudokuValueToString Four ] [ Html.text <| sudokuValueToString Four ]
                    ]
                ]
            ]
        ]


sudokuValueToString : SudokuValue -> String
sudokuValueToString value =
    case value of
        One ->
            "1"

        Two ->
            "2"

        Three ->
            "3"

        Four ->
            "4"


stringToSudokuValue : String -> Maybe SudokuValue
stringToSudokuValue input =
    case input of
        "1" ->
            Just One

        "2" ->
            Just Two

        "3" ->
            Just Three

        "4" ->
            Just Four

        _ ->
            Nothing


sudokuValueToInt : SudokuValue -> Int
sudokuValueToInt value =
    case value of
        One ->
            1

        Two ->
            2

        Three ->
            3

        Four ->
            4


viewPuzzle : Model -> Html Message
viewPuzzle model =
    Html.table []
        [ Html.tr []
            [ Html.td [] [ Html.text <| hintToString model.a ]
            ]
        ]


hintToString : Hint -> String
hintToString aHint =
    aHint
        |> Maybe.map sudokuValueToString
        |> Maybe.withDefault ""


streamModel : MicroKanren.StreamModel Int
streamModel =
    let
        goal =
            callFresh
                (\a ->
                    callFresh
                        (\b ->
                            callFresh
                                (\c ->
                                    callFresh
                                        (\d ->
                                            callFresh
                                                (\e ->
                                                    callFresh
                                                        (\f ->
                                                            callFresh
                                                                (\g ->
                                                                    callFresh
                                                                        (\h ->
                                                                            callFresh
                                                                                (\i ->
                                                                                    callFresh
                                                                                        (\j ->
                                                                                            callFresh
                                                                                                (\k ->
                                                                                                    callFresh
                                                                                                        (\l ->
                                                                                                            callFresh
                                                                                                                (\m ->
                                                                                                                    callFresh
                                                                                                                        (\n ->
                                                                                                                            callFresh
                                                                                                                                (\o ->
                                                                                                                                    callFresh
                                                                                                                                        (\p ->
                                                                                                                                            conj
                                                                                                                                                [ hint b 4
                                                                                                                                                , hint e 1
                                                                                                                                                , hint i 3
                                                                                                                                                , hint l 2
                                                                                                                                                , hint o 3
                                                                                                                                                , sudoku a b c d e f g h i j k l m n o p
                                                                                                                                                ]
                                                                                                                                        )
                                                                                                                                )
                                                                                                                        )
                                                                                                                )
                                                                                                        )
                                                                                                )
                                                                                        )
                                                                                )
                                                                        )
                                                                )
                                                        )
                                                )
                                        )
                                )
                        )
                )
    in
    MicroKanren.streamModelFromGoal "baby sudoku" goal


hint : Term Int -> Int -> Goal Int
hint term value =
    identical term <| Value value


sudoku : Term Int -> Term Int -> Term Int -> Term Int -> Term Int -> Term Int -> Term Int -> Term Int -> Term Int -> Term Int -> Term Int -> Term Int -> Term Int -> Term Int -> Term Int -> Term Int -> Goal Int
sudoku a b c d e f g h i j k l m n o p =
    conj
        [ sudokuRow a b c d
        , sudokuRow e f g h
        , sudokuRow i j k l
        , sudokuRow m n o p
        , sudokuColumn a e i m
        , sudokuColumn b f j n
        , sudokuColumn c g k o
        , sudokuColumn d h l p
        , sudokuBlock a b e f
        , sudokuBlock c d g h
        , sudokuBlock i j k l
        , sudokuBlock m n o p
        ]


sudokuRow : Term Int -> Term Int -> Term Int -> Term Int -> Goal Int
sudokuRow =
    pairwiseDistinct [ 1, 2, 3, 4 ]


sudokuColumn : Term Int -> Term Int -> Term Int -> Term Int -> Goal Int
sudokuColumn =
    sudokuRow


sudokuBlock : Term Int -> Term Int -> Term Int -> Term Int -> Goal Int
sudokuBlock =
    sudokuRow


pairwiseDistinct : List a -> Term a -> Term a -> Term a -> Term a -> Goal a
pairwiseDistinct elements a b c d =
    conj
        [ notEqual elements a b
        , notEqual elements a c
        , notEqual elements a d
        , notEqual elements b c
        , notEqual elements b d
        , notEqual elements c d
        ]


notEqual : List a -> Term a -> Term a -> Goal a
notEqual elements left right =
    elements
        |> split
        |> List.map (asa left right)
        |> disj


asa : Term a -> Term a -> ( a, List a ) -> Goal a
asa left right ( x, xs ) =
    conjoin
        (identical left <| Value x)
        (disj <| List.map (\y -> identical right <| Value y) xs)


conj : List (Goal a) -> Goal a
conj goals =
    case goals of
        [] ->
            succeed

        g :: gs ->
            conjoin g <| conj gs


disj : List (Goal a) -> Goal a
disj goals =
    case goals of
        [] ->
            fail

        g :: gs ->
            disjoin g <| disj gs


split : List a -> List ( a, List a )
split elements =
    let
        removeFromElements x =
            List.filter ((/=) x) elements
    in
    elements
        |> List.map (\x -> ( x, removeFromElements x ))


fail : Goal a
fail state =
    Empty


succeed : Goal a
succeed state =
    unit state
