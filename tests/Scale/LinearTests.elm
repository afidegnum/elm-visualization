module Scale.LinearTests exposing (all)

import Expect exposing (FloatingPointTolerance(..))
import Fuzz exposing (..)
import Helper exposing (expectAll, isAbout, isBetween)
import Scale
import Test exposing (..)


all : Test
all =
    describe "Scale.linear"
        [ test "convert maps a domain value x to range value y" <|
            \() ->
                Scale.convert (Scale.linear ( 1, 2 ) ( 0, 1 )) 0.5
                    |> Expect.within (Absolute 0.0001) 1.5
        , test "maps an empty domain to the middle of the range" <|
            \() ->
                expectAll
                    [ Scale.convert (Scale.linear ( 1, 2 ) ( 0, 0 )) 0
                        |> Expect.within (Absolute 0.0001) 1.5
                    , Scale.convert (Scale.linear ( 2, 1 ) ( 0, 0 )) 1
                        |> Expect.within (Absolute 0.0001) 1.5
                    ]
        , fuzz (tuple3 ( tuple ( float, float ), tuple ( float, float ), float )) "invert is the inverse of convert" <|
            \( ( r0, r1 ), ( d0, d1 ), val ) ->
                let
                    scale =
                        Scale.linear ( r0, r1 ) ( d0, d1 )

                    double =
                        Scale.convert scale val |> Scale.invert scale
                in
                if r0 == r1 || d0 == d1 then
                    -- this is a special case, since it needs to go into the middle
                    double |> isAbout ((d0 + d1) / 2)

                else
                    double
                        |> Expect.within (Absolute 0.0001) val
        , fuzz (tuple3 ( tuple ( float, float ), tuple ( float, float ), float )) "clamp limits output value to the range" <|
            \( domain, range, val ) ->
                let
                    convert =
                        Scale.convert (Scale.clamp (Scale.linear range domain)) val
                in
                convert |> isBetween range
        , fuzz (tuple3 ( tuple ( float, float ), tuple ( float, float ), float )) "rangeExtent returns the range" <|
            \( domain, range, val ) ->
                Scale.rangeExtent (Scale.linear range domain) |> Expect.equal range

        -- Clamping is not performed for inversion yet due to type constraints
        -- , fuzz (tuple3 ( tuple ( float, float ), tuple ( float, float ), float )) "clamp limits output value to the range" <|
        --     \( domain, range, val ) ->
        --         let
        --             invert =
        --                 Scale.invert (Scale.clamp (Scale.linear domain range)) val
        --         in
        --             invert |> isBetween domain
        -- , describe "nice"
        --  [ test "small domain" <|
        --     () ->
        --       Scale.nice (Scale.linear (0, 0.96) (0, 1)) 10
        --   ]
        ]
