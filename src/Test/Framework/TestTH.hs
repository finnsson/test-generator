{-# OPTIONS_GHC -fglasgow-exts -XTemplateHaskell #-}
module Test.Framework.TestTH where 
import Test.Framework.TH 

import Test.HUnit
import Test.Framework.Providers.QuickCheck2
import Test.Framework.Providers.HUnit
import Language.Haskell.Extract 

main = $(defaultMainGenerator)

case_Foo =
   4 @=? 4

case_Bar =
   "hej" @=? "hej"

prop_Reverse xs = reverse (reverse xs) == xs
  where types = xs ::[Int]

case_num_Prop =
  do let expected = 1
         actual = length $ $(functionExtractor "^prop")
     expected @=? actual
