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

main = $(defaultMainGenerator)

testFoo =
  do 4 @=? 4

testBar =
  do "hej" @=? "hej"
