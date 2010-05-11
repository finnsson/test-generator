-----------------------------------------------------------------------------
--
-- Module      :  TestGenerator
-- Copyright   :  
-- License     :  BSD4
--
-- Maintainer  :  Oscar Finnsson
-- Stability   :  
-- Portability :  
--
-- |
--
-----------------------------------------------------------------------------
{-# OPTIONS_GHC -fglasgow-exts -XTemplateHaskell #-}
module TestGeneratorTest where 
import TestGenerator

import Test.HUnit
import TemplateHelper

main = $(defaultMainGenerator)

case_Foo =
  do 4 @=? 4

case_Bar =
  do "hej" @=? "hej"

prop_Reverse xs = reverse (reverse xs) == xs
  where types = xs ::[Int]

case_numProp =
  do let expected = 1
         actual = length $ $(functionExtractor "^prop")
     expected @=? actual
