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
-- 
-----------------------------------------------------------------------------
{-# OPTIONS_GHC -fglasgow-exts -XTemplateHaskell #-}

module TestGenerator (
  defaultMainGenerator,
  testGroupGenerator
) where
import Language.Haskell.TH
import Language.Haskell.Exts.Parser
import Language.Haskell.Exts.Syntax
import Text.Regex.Posix
import Maybe
import Language.Haskell.Exts.Extension
import Test.Framework.Providers.HUnit
import FunctionExtractor
import Test.Framework (Test)

import Test.HUnit


import Test.Framework (defaultMain, testGroup)
import Test.Framework.Providers.HUnit

-- | Generate the usual code and extract the usual functions needed in order to run HUnit.
--  
--   > {-# OPTIONS_GHC -fglasgow-exts -XTemplateHaskell #-}
--   > module MyModuleTest where
--   > import Test.HUnit
--   > import MainTestGenerator
--   > 
--   > main = $(defaultMainGenerator)
--   >
--   > testFoo = do 4 @=? 4
--   >
--   > testBar = do "hej" @=? "hej"
--   
--   will automagically extract testFoo and testBar and run them as well as present them as belonging to the testGroup 'MyModuleTest' such as
--
--   > me: runghc MyModuleTest.hs 
--   > MyModuleTest:
--   >   testFoo: [OK]
--   >   testBar: [OK]
--   > 
--   >          Test Cases  Total      
--   >  Passed  2           2          
--   >  Failed  0           0          
--   >  Total   2           2 
--   
defaultMainGenerator :: ExpQ
defaultMainGenerator = 
  [| defaultMain [ testGroup $(locationModule) (mapTestCases $(functionExtractor "^test") ) ] |]

-- | Generate the usual code and extract the usual functions needed for a testGroup in HUnit.
--  
--   > -- file SomeModule.hs
--   > fooTestGroup = $(testGroupGenerator)
--   > main = defaultMain [fooTestGroup]
--   > test1 = do 1 @=? 1
--   > test2 = do 2 @=? 2
--   
--   is the same as
--
--   > -- file SoomeModule.hs
--   > fooTestGroup = testGroup "SomeModule" [testCase "test1" test1, testCase "test2" test2]
--   > main = defaultMain [fooTestGroup]
--   > test1 = do 1 @=? 1
--   > test2 = do 2 @=? 2
--
testGroupGenerator :: ExpQ
testGroupGenerator =
  [| testGroup $(locationModule) (mapTestCases $(functionExtractor "^test") ) |]


mapTestCases :: [(String, Assertion)] -> [Test.Framework.Test]
mapTestCases list =
  map (uncurry testCase) list
