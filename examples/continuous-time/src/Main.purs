module Main where

import Prelude

import Hareactive.Types (Behavior, Stream, Now)
import Hareactive.Combinators (time, sample, stepper, snapshot)
import Data.Array (head)
import Data.Maybe (fromMaybe)
import Data.String (split, Pattern(..))
import Data.JSDate (fromTime, toTimeString)
import Turbine (Component, runComponent, dynamic, output, modelView, (</>))
import Turbine.HTML.Elements as E

formatTime :: Number -> String
formatTime = fromTime >>> toTimeString >>> split (Pattern " ") >>> head >>> fromMaybe ""

type AppModelOut =
  { time :: Behavior Number
  , message :: Behavior String
  }

type AppViewOut = {snapClick :: Stream Unit}

appModel :: AppViewOut -> Unit -> Now AppModelOut
appModel { snapClick } _ = do
  let msgFromClick =
        map (\t -> "You last pressed the button at " <> formatTime t)
            (snapshot time snapClick)
  message <- sample $ stepper "You've not clicked the button yet" msgFromClick
  pure {time, message}

appView :: AppModelOut -> Unit -> Component _ AppViewOut
appView { message, time } _ =
  E.h1_ (E.text "Continuous") </>
  E.p_ (E.textB $ formatTime <$> time) </>
  E.button_ (E.text "Click to snap time") `output` (\o -> {snapClick: o.click}) </>
  E.p_ (E.textB message)

app = modelView appModel appView unit

main = runComponent "#mount" app
