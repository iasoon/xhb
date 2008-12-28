module Cabal where

import Text.StringTemplate

import System.IO
import System.Environment (getArgs)
import System.Exit
import System.Locale

import Data.Time


{-

  plugs the generated files into a cabal-file template

-}


{-
 args ! 0    -- cabal file template
 args ! 1    -- output file name
 args ! 2    -- directory containing generated files
 drop 3 args -- names of generated modules
 -}
main = do
  args <- getArgs
  if length args < 3 then exitBadArgs else do
  let templateFile : outFile : genDirName : modNames = args

  templateString <- readFile templateFile
  time <- Just `fmap` getCurrentTime
  let cabalString = applyTemplate time templateString genDirName modNames
  writeFile outFile cabalString

exitBadArgs = do
  hPutStrLn stderr "Command requires at least three arguments."
  exitFailure

applyTemplate :: Maybe UTCTime -> String -> String -> [String] -> String
applyTemplate time template dirName mods =
    toString $ setAttribute "Module" mods $
               setAttribute "GenDir" dirName $
               setAttribute "DateString" dateString $
               newSTMP template
 where dateString = formatTime defaultTimeLocale "%Y.%m.%d" `fmap` time
                    