# test-framework-th

Haskell-module to automagically generate repetetive code when writing HUnit/Quickcheck/Quickcheck2-tests.

## testGroupGenerator

### signature

    testGroupGenerator :: ExpQ

### usage

    myTestGroup = $(testGroupGenerator)

### example

    -- file SomeModule.hs
    fooTestGroup = $(testGroupGenerator)
    main = defaultMain [fooTestGroup]
    case_1 = do 1 @=? 1
    case_2 = do 2 @=? 2
    prop_reverse = reverse (reverse xs) == xs where types = xs::[Int]

is the same as

    -- file SomeModule.hs
    fooTestGroup = testGroup "SomeModule" [testCase "1" case_1, testCase "2" case_2, testProperty "reverse" prop_reverse]
    main = defaultMain [fooTestGroup]
    case_1 = do 1 @=? 1
    case_2 = do 2 @=? 2
    prop_reverse = reverse (reverse xs) == xs where types = xs::[Int]

## defaultMainGenerator

### signature

    defaultMainGenerator :: ExpQ

### usage

    main = $(defaultMainGenerator)

### example

    {-# OPTIONS_GHC -fglasgow-exts -XTemplateHaskell #-}
    module MyModuleTest where
    import Test.HUnit
    import MainTestGenerator
    
    main = $(defaultMainGenerator)
   
    case_Foo = do 4 @=? 4
    
    case_Bar = do "hej" @=? "hej"

    prop_reverse = reverse (reverse xs) == xs where types = xs::[Int]

will automagically extract prop_reverse, case_Foo and case_Bar and run them as well as present them as belonging to the testGroup 'MyModuleTest'. The above code is the same as

    {-# OPTIONS_GHC -fglasgow-exts -XTemplateHaskell #-}
    module MyModuleTest where
    import Test.HUnit
    import MainTestGenerator
    
    main =
      defaultMain [
        testGroup "MyModuleTest" [ testCase "Foo" case_Foo, testCase "Bar" case_Bar, testProperty "reverse" prop_reverse]
        ]
    
    case_Foo = do 4 @=? 4
   
    case_Bar = do "hej" @=? "hej"

    prop_reverse = reverse (reverse xs) == xs where types = xs::[Int]

and will give the following result

    me: runghc MyModuleTest.hs 
    MyModuleTest:
      reverse: [OK, passed 100 tests]
      Foo: [OK]
      Bar: [OK]
     
            Properties  Test Cases  Total      
    Passed  1           2           3          
    Failed  0           0           0          
    Total   1           2           3 

