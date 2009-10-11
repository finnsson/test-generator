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

module MainTestGenerator (
  mainTestGenerator
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
--   > main = $(mainTestGenerator)
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
mainTestGenerator :: ExpQ
mainTestGenerator = 
  [| defaultMain [ testGroup $(locationModule) (mapTestCases $(functionExtractor "^test") ) ] |]

mapTestCases :: [(String, Assertion)] -> [Test.Framework.Test]
mapTestCases list =
  map (uncurry testCase) list
