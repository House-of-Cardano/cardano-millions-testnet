{-# OPTIONS_GHC -Wno-incomplete-uni-patterns #-}

module Main
    ( main
    ) where

import Data.String        (IsString (..))
import System.Environment (getArgs)
import Validate.Utils     (unsafeTokenNameToHex)

main :: IO ()
main = do
    [tn'] <- getArgs
    let tn = fromString tn'
    putStrLn $ unsafeTokenNameToHex tn