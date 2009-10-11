-----------------------------------------------------------------------------
--
-- Module      :  MainTestGenerator
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
module MainTestGeneratorTest where 
import MainTestGenerator

import Test.HUnit

main = $(mainTestGenerator)

testFoo =
  do 4 @=? 4

testBar =
  do "hej" @=? "hej"
