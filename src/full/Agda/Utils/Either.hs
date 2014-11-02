------------------------------------------------------------------------
-- | Utilities for the 'Either' type
------------------------------------------------------------------------

module Agda.Utils.Either
  ( whileLeft, caseEitherM
  , mapEither, mapLeft, mapRight
  , isLeft, isRight
  , allRight
  , tests
  ) where

import Control.Applicative

import Agda.Utils.QuickCheck
import Agda.Utils.TestHelpers

-- | Loop while we have an exception.

whileLeft :: Monad m => (a -> Either b c) -> (a -> b -> m a) -> (a -> c -> m d) -> a -> m d
whileLeft test left right = loop where
  loop a =
    case test a of
      Left  b -> loop =<< left a b
      Right c -> right a c

-- | Monadic version of 'either' with a different argument ordering.

caseEitherM :: Monad m => m (Either a b) -> (a -> m c) -> (b -> m c) -> m c
caseEitherM mm f g = either f g =<< mm

-- | 'Either' is a bifunctor.

mapEither :: (a -> c) -> (b -> d) -> Either a b -> Either c d
mapEither f g = either (Left . f) (Right . g)

-- | 'Either _ b' is a functor.

mapLeft :: (a -> c) -> Either a b -> Either c b
mapLeft f = mapEither f id

-- | 'Either a' is a functor.

mapRight :: (b -> d) -> Either a b -> Either a d
mapRight = mapEither id

-- | Returns 'True' iff the argument is @'Right' x@ for some @x@.
--   Note: from @base >= 4.7.0.0@ already present in @Data.Either@.
isRight :: Either a b -> Bool
isRight (Right _) = True
isRight (Left  _) = False

-- | Returns 'True' iff the argument is @'Left' x@ for some @x@.
--   Note: from @base >= 4.7.0.0@ already present in @Data.Either@.
isLeft :: Either a b -> Bool
isLeft (Right _) = False
isLeft (Left _)  = True

-- | Returns @'Just' <input with tags stripped>@ if all elements are
-- to the right, and otherwise 'Nothing'.
--
-- @
--  allRight xs ==
--    if all isRight xs then
--      Just (map (\(Right x) -> x) xs)
--     else
--      Nothing
-- @

allRight :: [Either a b] -> Maybe [b]
allRight []             = Just []
allRight (Left  _ : _ ) = Nothing
allRight (Right b : xs) = (b:) <$> allRight xs

prop_allRight xs =
  allRight xs ==
    if all isRight xs then
      Just $ map (\ (Right x) -> x) xs
     else
      Nothing

------------------------------------------------------------------------
-- All tests

tests :: IO Bool
tests = runTests "Agda.Utils.Either"
  [ quickCheck' (prop_allRight :: [Either Integer Bool] -> Bool)
  ]
