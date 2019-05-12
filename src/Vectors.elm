module Vectors exposing (hamburgerIcon)

import Html
import Svg exposing (..)
import Svg.Attributes exposing (..)


hamburgerIcon =
    svg [ class "fill-current w-4 h-4 cursor-pointer text-white", viewBox "0 0 20 20" ]
        [ Svg.path [ d "M0 3h20v2H0V3zm0 6h20v2H0V9zm0 6h20v2H0v-2z" ] []
        ]
