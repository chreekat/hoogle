{-# LANGUAGE PatternGuards, TupleSections #-}

module Input.Set(setStackage, setPlatform, setGHC) where

import Control.Applicative
import Data.List.Extra
import System.IO.Extra
import qualified Data.Set as Set
import Prelude


-- | Return information about which items are in a particular set.
setStackage :: FilePath -> IO (Set.Set String)
setStackage file = Set.fromList . delete "telegram-api" . f . lines <$> readFile' file
    where
        f (x:xs) | Just x <- stripPrefix "constraints:" x =
                    map (fst . word1) $ takeWhile (" " `isPrefixOf`) $ (' ':x) : xs
                 | otherwise = f xs
        f [] = []


setPlatform :: FilePath -> IO (Set.Set String)
setPlatform file = setPlatformWith file ["incGHCLib","incLib"]

setPlatformWith :: FilePath -> [String] -> IO (Set.Set String)
setPlatformWith file names = do
    src <- lines <$> readFile' file
    return $ Set.fromList [read lib | ",":name:lib:_ <- map words src, name `elem` names]

setGHC :: FilePath -> IO (Set.Set String)
setGHC file = setPlatformWith file ["incGHCLib"]
