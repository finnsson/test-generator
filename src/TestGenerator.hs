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
import Test.Framework.Providers.QuickCheck2
import TemplateHelper
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
--   > caseFoo = do 4 @=? 4
--   >
--   > caseBar = do "hej" @=? "hej"
--   > 
--   > propReverse xs = reverse (reverse xs) == xs
--   >   where types = xs :: [Int]
--   
--   will automagically extract caseFoo and caseBar and run them as well as present them as belonging to the testGroup 'MyModuleTest' such as
--
--   > me: runghc MyModuleTest.hs 
--   > MyModuleTest:
--   >   propReverse: [OK, passed 100 tests]
--   >   caseFoo: [OK]
--   >   caseBar: [OK]
--   > 
--   >          Properties  Test Cases   Total       
--   >  Passed  1           2            3          
--   >  Failed  0           0            0           
--   >  Total   1           1            3
 
--   
defaultMainGenerator :: ExpQ
defaultMainGenerator = 
  [| defaultMain [ testGroup $(locationModule) $ $(propListGenerator) ++ (mapTestCases $(functionExtractor "^case") ) ] |]

-- | Generate the usual code and extract the usual functions needed for a testGroup in HUnit.
--  
--   > -- file SomeModule.hs
--   > fooTestGroup = $(testGroupGenerator)
--   > main = defaultMain [fooTestGroup]
--   > case1 = do 1 @=? 1
--   > case2 = do 2 @=? 2
--   > prop1 xs = reverse (reverse xs) == xs
--   >  where types = xs :: [Int]
--   
--   is the same as
--
--   > -- file SoomeModule.hs
--   > fooTestGroup = testGroup "SomeModule" [testProperty "prop1" prop1, testCase "case1" case1, testCase "case2" case2]
--   > main = defaultMain [fooTestGroup]
--   > case1 = do 1 @=? 1
--   > case2 = do 2 @=? 2
--   > prop1 xs = reverse (reverse xs) == xs
--   >  where types = xs :: [Int]
--
testGroupGenerator :: ExpQ
testGroupGenerator =
  [| testGroup $(locationModule) $ $(propListGenerator) ++ (mapTestCases $(functionExtractor "^case") ) |]

propListGenerator :: ExpQ
propListGenerator =
  functionExtractorMap "^prop" [|testProperty|]

mapTestCases :: [(String, Assertion)] -> [Test.Framework.Test]
mapTestCases list =
  map (uncurry testCase) list
