# test-framework-th

Haskell-module to automagically generate repetetive code when writing HUnit/Quickcheck/Quickcheck2-tests.

## testGroupGenerator

### signature

    testGroupGenerator :: ExpQ

### usage

    myTestGroup = $(testGroupGenerator)

### example

    -- file SomeModule.hs
    {-# OPTIONS_GHC -fglasgow-exts -XTemplateHaskell #-}
    module SomeModule where
    import Test.Framework.TH
    import Test.Framework
    import Test.HUnit
    import Test.Framework.Providers.HUnit
    import Test.Framework.Providers.QuickCheck2
   
    -- observe this line! 
    fooTestGroup = $(testGroupGenerator)
    main = defaultMain [fooTestGroup]
    case_1 = do 1 @=? 1
    case_2 = do 2 @=? 2
    prop_reverse xs = reverse (reverse xs) == xs
       where types = xs::[Int]

is the same as


    -- file SomeModule.hs
    {-# OPTIONS_GHC -fglasgow-exts -XTemplateHaskell #-}
    module SomeModule where
    import Test.Framework.TH
    import Test.Framework
    import Test.HUnit
    import Test.Framework.Providers.HUnit
    import Test.Framework.Providers.QuickCheck2
    
    -- observe this line!
    fooTestGroup = testGroup "SomeModule" [testCase "1" case_1, testCase "2" case_2, testProperty "reverse" prop_reverse]
    main = defaultMain [fooTestGroup]
    case_1 = do 1 @=? 1
    case_2 = do 2 @=? 2
    prop_reverse xs = reverse (reverse xs) == xs
       where types = xs::[Int]


## defaultMainGenerator

### signature

    defaultMainGenerator :: ExpQ

### usage

    main = $(defaultMainGenerator)

### example


    -- file SomeModule.hs
    {-# OPTIONS_GHC -fglasgow-exts -XTemplateHaskell #-}
    module SomeModule where
    import Test.Framework.TH
    import Test.Framework
    import Test.HUnit
    import Test.Framework.Providers.HUnit
    import Test.Framework.Providers.QuickCheck2
   
    -- observe this line! 
    main = $(defaultMainGenerator)
    case_1 = do 1 @=? 1
    case_2 = do 2 @=? 2
    prop_reverse xs = reverse (reverse xs) == xs
       where types = xs::[Int]


will automagically extract prop_reverse, case_1 and case_2 and run them as well as present them as belonging to the testGroup 'SomeModule'. The above code is the same as

    -- file SomeModule.hs
    {-# OPTIONS_GHC -fglasgow-exts -XTemplateHaskell #-}
    module SomeModule where
    import Test.Framework.TH
    import Test.Framework
    import Test.HUnit
    import Test.Framework.Providers.HUnit
    import Test.Framework.Providers.QuickCheck2
   
    -- observe this line! 
    main =
      defaultMain [
        testGroup "SomeModule" [ testCase "1" case_1, testCase "2" case_2, testProperty "reverse" prop_reverse]
        ]

    case_1 = do 1 @=? 1
    case_2 = do 2 @=? 2
    prop_reverse xs = reverse (reverse xs) == xs
       where types = xs::[Int]


and will give the following result

    me: runghc MyModuleTest.hs 
    MyModuleTest:
      reverse: [OK, passed 100 tests]
      1: [OK]
      2: [OK]
     
            Properties  Test Cases  Total      
    Passed  1           2           3          
    Failed  0           0           0          
    Total   1           2           3 

