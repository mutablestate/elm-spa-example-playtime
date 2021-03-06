module Page exposing (Page(..), view, viewErrors)

import Api exposing (Cred)
import Avatar
import Browser exposing (Document)
import Html exposing (Html, a, button, div, footer, i, img, li, nav, p, span, text, ul)
import Html.Attributes exposing (class, classList, href, style)
import Html.Events exposing (onClick)
import Profile
import Route exposing (Route)
import Session exposing (Session)
import Username exposing (Username)
import Vectors
import Viewer exposing (Viewer)


{-| Determines which navbar link (if any) will be rendered as active.

Note that we don't enumerate every page here, because the navbar doesn't
have links for every page. Anything that's not part of the navbar falls
under Other.

-}
type Page
    = Other
    | Home
    | Login
    | Register
    | Settings
    | Profile Username
    | NewArticle


{-| Take a page's Html and frames it with a header and footer.

The caller provides the current user, so we can display in either
"signed in" (rendering username) or "signed out" mode.

isLoading is for determining whether we should show a loading spinner
in the header. (This comes up during slow page transitions.)

-}
view : Maybe Viewer -> Page -> { title : String, content : Html msg } -> Document msg
view maybeViewer page { title, content } =
    { title = title ++ " - Conduit"
    , body = viewHeader page maybeViewer :: content :: [ viewFooter ]
    }


viewHeader : Page -> Maybe Viewer -> Html msg
viewHeader page maybeViewer =
    nav [ class "relative flex items-center justify-between flex-wrap bg-white py-2 px-1" ]
        [ div [ class "flex items-center flex-shrink-0 text-green-500 mr-6 ml-12" ]
            [ a [ class "font-semibold text-xl tracking-tight", Route.href Route.Home ]
                [ text "conduit" ]
            ]
        , div [ class "block lg:hidden" ]
            [ button [ class "flex items-center px-3 py-2 rounded text-teal-200 border border-teal-400 hover:border-white hover:text-white " ]
                [ Vectors.hamburgerIcon ]
            ]
        , div [ class "w-full block flex-grow lg:flex lg:items-center lg:w-auto mr-12" ]
            [ div [ class "text-sm lg:flex-grow text-right" ] <|
                navbarLink
                    page
                    Route.Home
                    [ text "Home" ]
                    :: viewMenu page maybeViewer
            ]
        ]


viewMenu : Page -> Maybe Viewer -> List (Html msg)
viewMenu page maybeViewer =
    let
        linkTo =
            navbarLink page
    in
    case maybeViewer of
        Just viewer ->
            let
                username =
                    Viewer.username viewer

                avatar =
                    Viewer.avatar viewer
            in
            [ linkTo Route.NewArticle [ i [ class "ion-compose" ] [], text "\u{00A0}New Post" ]
            , linkTo Route.Settings [ i [ class "ion-gear-a" ] [], text "\u{00A0}Settings" ]
            , linkTo
                (Route.Profile username)
                [ img [ class "user-pic", Avatar.src avatar ] []
                , Username.toHtml username
                ]
            , linkTo Route.Logout [ text "Sign out" ]
            ]

        Nothing ->
            [ linkTo Route.Login [ text "Sign in" ]
            , linkTo Route.Register [ text "Sign up" ]
            ]


viewFooter : Html msg
viewFooter =
    footer []
        [ div [ class "container" ]
            [ a [ class "logo-font", href "/" ] [ text "conduit" ]
            , span [ class "attribution" ]
                [ text "An interactive learning project from "
                , a [ href "https://thinkster.io" ] [ text "Thinkster" ]
                , text ". Code & design licensed under MIT."
                ]
            ]
        ]


navbarLink : Page -> Route -> List (Html msg) -> Html msg
navbarLink page route linkContent =
    a
        [ Route.href route
        , class "block mt-4 lg:inline-block lg:mt-0 text-gray-600 hover:text-gray-800 mr-4"
        , classList
            [ ( "text-gray-900", isActive page route )
            ]
        ]
        linkContent


isActive : Page -> Route -> Bool
isActive page route =
    case ( page, route ) of
        ( Home, Route.Home ) ->
            True

        ( Login, Route.Login ) ->
            True

        ( Register, Route.Register ) ->
            True

        ( Settings, Route.Settings ) ->
            True

        ( Profile pageUsername, Route.Profile routeUsername ) ->
            pageUsername == routeUsername

        ( NewArticle, Route.NewArticle ) ->
            True

        _ ->
            False


{-| Render dismissable errors. We use this all over the place!
-}
viewErrors : msg -> List String -> Html msg
viewErrors dismissErrors errors =
    if List.isEmpty errors then
        Html.text ""

    else
        div
            [ class "error-messages"
            , style "position" "fixed"
            , style "top" "0"
            , style "background" "rgb(250, 250, 250)"
            , style "padding" "20px"
            , style "border" "1px solid"
            ]
        <|
            List.map (\error -> p [] [ text error ]) errors
                ++ [ button [ onClick dismissErrors ] [ text "Ok" ] ]
