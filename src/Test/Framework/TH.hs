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
{-# OPTIONS_GHC -XTemplateHaskell #-}

module Test.Framework.TH (
  defaultMainGenerator,
  defaultMainGenerator2,
  testGroupGenerator
) where
import Language.Haskell.TH
import Language.Haskell.Exts.Parser
import Language.Haskell.Exts.Syntax
import Text.Regex.Posix
import Data.Maybe
import Language.Haskell.Exts.Extension
import Language.Haskell.Extract 

import Test.Framework (defaultMain, testGroup)

-- | Generate the usual code and extract the usual functions needed in order to run HUnit/Quickcheck/Quickcheck2.
--   All functions beginning with case_, prop_ or test_ will be extracted.
--  
--   > {-# LANGUAGE TemplateHaskell #-}
--   > module MyModuleTest where
--   > import Test.HUnit
--   > import Test.QuickCheck
--   > import MainTestGenerator
--   > 
--   > main = $(defaultMainGenerator)
--   >
--   > case_Foo = do 4 @=? 4
--   >
--   > case_Bar = do "hej" @=? "hej"
--   > 
--   > prop_Reverse xs = reverse (reverse xs) == xs
--   >   where types = xs :: [Int]
--   >
--   > feat_Show_to_Read_Roundtrip xs = xs == (read . show) xs
--   >   where types = xs :: [Int]
--   >
--   > test_Group =
--   >     [ testCase "1" case_Foo
--   >     , testProperty "2" prop_Reverse
--   >     ]
--   
--   will automagically extract prop_Reverse, case_Foo, case_Bar and test_Group and run them as well as present them as belonging to the testGroup 'MyModuleTest' such as
--
--   > me: runghc MyModuleTest.hs 
--   > MyModuleTest:
--   >   Reverse: [OK, passed 100 tests]
--   >   Foo: [OK]
--   >   Bar: [OK]
--   >   Show to Read Roundtrip: [Property OK]
--   >   Group:
--   >     1: [OK]
--   >     2: [OK, passed 100 tests]
--   > 
--   >          Properties  Test Cases   Total       
--   >  Passed  3           3            6          
--   >  Failed  0           0            0           
--   >  Total   3           3            6
 
--   
defaultMainGenerator :: ExpQ
defaultMainGenerator = 
  [| defaultMain [ testGroup $(locationModule) $ $(propListGenerator) 
                                              ++ $(caseListGenerator) 
                                              ++ $(testFeatGenerator) 
                                              ++ $(testListGenerator) ] |]

defaultMainGenerator2 :: ExpQ
defaultMainGenerator2 = 
  [| defaultMain [ testGroup $(locationModule) $ $(caseListGenerator) 
                                              ++ $(propListGenerator) 
                                              ++ $(testFeatGenerator) 
                                              ++ $(testListGenerator) ] |]

-- | Generate the usual code and extract the usual functions needed for a testGroup in HUnit\/Quickcheck\/Quickcheck2\/Feat.
--   All functions beginning with case_, prop_, feat_ or test_ will be extracted.
--  
--   > -- file SomeModule.hs
--   > fooTestGroup = $(testGroupGenerator)
--   > main = defaultMain [fooTestGroup]
--   > case_1 = do 1 @=? 1
--   > case_2 = do 2 @=? 2
--   > prop_p xs = reverse (reverse xs) == xs
--   >  where types = xs :: [Int]
--   > feat_f xs = xs == (read . show) xs
--   >   where types = xs :: [Int]
--   
--   is the same as
--
--   > -- file SoomeModule.hs
--   > fooTestGroup = testGroup "SomeModule" [testProperty "p" prop_1, 
--   >                                        testCase     "1" case_1, 
--   >                                        testCase     "2" case_2,
--   >                                        testFeat     "f" feat_1]
--   > main = defaultMain [fooTestGroup]
--   > case_1 = do 1 @=? 1
--   > case_2 = do 2 @=? 2
--   > prop_1 xs = reverse (reverse xs) == xs
--   >  where types = xs :: [Int]
--   > feat_1 xs = xs == (read . show) xs
--   >   where types = xs :: [Int]
--
testGroupGenerator :: ExpQ
testGroupGenerator =
  [| testGroup $(locationModule) $ $(propListGenerator)
                                ++ $(caseListGenerator)
                                ++ $(testFeatGenerator)
                                ++ $(testListGenerator) |]

listGenerator :: String -> String -> ExpQ
listGenerator beginning funcName =
  functionExtractorMap beginning (applyNameFix funcName)

propListGenerator :: ExpQ
propListGenerator = listGenerator "^prop_" "testProperty"

caseListGenerator :: ExpQ
caseListGenerator = listGenerator "^case_" "testCase"

testListGenerator :: ExpQ
testListGenerator = listGenerator "^test_" "testGroup"

testFeatGenerator :: ExpQ
testFeatGenerator = listGenerator "^feat_" "testFeat"

-- | The same as
--   e.g. \n f -> testProperty (fixName n) f
applyNameFix :: String -> ExpQ
applyNameFix n =
  do fn <- [|fixName|]
     return $ LamE [VarP (mkName "n")] (AppE (VarE (mkName n)) (AppE (fn) (VarE (mkName "n"))))

fixName :: String -> String
fixName name = replace '_' ' ' $ drop 5 name

replace :: Eq a => a -> a -> [a] -> [a]
replace b v = map (\i -> if b == i then v else i)
