module Schedule.Alerts.View exposing (view)

import Maybe exposing (..)
import NativeUi as Ui exposing (Node)
import NativeUi.Elements as Elements exposing (..)
import NativeUi.Events exposing (..)
import NativeUi.Properties exposing (..)
import NativeUi.Style as Style
import App.Color as Color
import App.Maybe exposing (..)
import Message exposing (..)
import Model exposing (..)
import Types exposing (..)


view : Model -> Maybe (Node Msg)
view { alertsAreExpanded, alerts, dismissedAlertIds } =
    case alerts of
        Loading ->
            Nothing

        Ready (Err _) ->
            Nothing

        Ready (Ok loadedAlerts) ->
            renderAlerts alertsAreExpanded loadedAlerts dismissedAlertIds


renderAlerts : Bool -> List Alert -> List Int -> Maybe (Node Msg)
renderAlerts alertsAreExpanded allAlerts dismissedAlertIds =
    let
        alerts =
            visibleAlerts allAlerts dismissedAlertIds
    in
        if List.isEmpty alerts then
            Nothing
        else
            Just <|
                Elements.view
                    []
                    (catMaybes
                        [ Just <| alertsBanner alertsAreExpanded <| List.length alerts
                        , maybeExpandedAlerts alertsAreExpanded alerts
                        ]
                    )


alertsBanner : Bool -> Int -> Node Msg
alertsBanner alertsAreExpanded alertCount =
    Elements.touchableOpacity
        [ Ui.style
            [ Style.backgroundColor Color.red
            , Style.paddingHorizontal 8
            , Style.paddingVertical 18
            , Style.flexDirection "row"
            , Style.alignItems "center"
            ]
        , onPress ToggleAlerts
        , activeOpacity 0.7
        ]
        [ text
            [ Ui.style
                [ Style.flex 1
                , Style.color Color.white
                ]
            ]
            [ Ui.string <| arrowCharacter alertsAreExpanded ]
        , text
            [ Ui.style
                [ Style.color Color.lightGray
                , Style.fontSize 14
                , Style.fontWeight "700"
                , Style.letterSpacing 0.25
                , Style.textAlign "center"
                , Style.flex 2
                ]
            ]
            [ Ui.string <| alertsBannerText alertCount ]
        , Elements.view
            [ Ui.style [ Style.flex 1 ] ]
            []
        ]


maybeExpandedAlerts : Bool -> Alerts -> Maybe (Node Msg)
maybeExpandedAlerts alertsAreExpanded alerts =
    if alertsAreExpanded then
        Just <|
            Elements.scrollView
                [ Ui.style
                    [ Style.backgroundColor Color.lightGray ]
                ]
                (List.map expandedAlert alerts)
    else
        Nothing


expandedAlert : Alert -> Node Msg
expandedAlert alert =
    Elements.view
        [ Ui.style
            [ Style.borderBottomWidth 1
            , Style.borderBottomColor Color.darkGray
            , Style.paddingHorizontal 18
            , Style.paddingVertical 18
            ]
        ]
        [ Elements.view
            [ Ui.style
                [ Style.flex 1
                , Style.flexDirection "row"
                , Style.marginBottom 4
                , Style.alignItems "center"
                ]
            ]
            [ text
                [ Ui.style
                    [ Style.fontWeight "700"
                    , Style.fontSize 14
                    , Style.flex 1
                    , Style.lineHeight 30
                    ]
                ]
                [ Ui.string alert.effectName ]
            , text
                [ onPress <| DismissAlert alert
                , Ui.style
                    [ Style.color Color.dismissColor
                    , Style.padding 5
                    ]
                ]
                [ Ui.string "dismiss" ]
            ]
        , text
            []
            [ Ui.string alert.headerText ]
        ]


alertsBannerText : Int -> String
alertsBannerText alertCount =
    let
        pluralizedDescription =
            if alertCount == 1 then
                "ALERT"
            else
                "ALERTS"
    in
        String.join
            " "
            [ toString alertCount
            , pluralizedDescription
            ]


arrowCharacter : Bool -> String
arrowCharacter alertsAreExpanded =
    if alertsAreExpanded then
        "▼"
    else
        "▶"
