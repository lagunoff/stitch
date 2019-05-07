-- | This module defines everything used to manage CSS selectors: creating them as well as combining them (using the 'Monoid' instance). It also includes a function 'fromText' for converting arbitrary 'Text's to 'Selector's.
module Stitch.Types.Selector
  ( Selector(..)
  , fromText ) where

import Data.Text (Text)
import Data.Monoid
import Data.String
import qualified Data.Text as Text

-- | Represents a CSS selector. Can be combined with other 'Selector's using its 'Monoid' instance.
data Selector = Selector
  { unMedia :: [Text]
  , unSelector :: [Text]
  }
  deriving (Show, Read, Eq, Ord)

instance IsString Selector where
  fromString = fromText . fromString

instance Monoid Selector where
  mempty = Selector [] []
  Selector xm [] `mappend` Selector ym ys = Selector (xm <> ym) ys
  Selector xm xs `mappend` Selector ym [] = Selector (xm <> ym) xs
  Selector xm xs `mappend` Selector ym ys =
    Selector (xm <> ym) $ do
      x <- xs
      y <- ys
      if Text.isInfixOf "&" y
        then return $ Text.replace "&" x y
        else return $ x <> " " <> y
        
-- | Parse a 'Selector' from a 'Text' value. This is the same function used by the 'IsString' instance used by @OverloadedStrings@.
fromText :: Text -> Selector
fromText = Selector [] . filter (not . Text.null) . map Text.strip . Text.splitOn ","
