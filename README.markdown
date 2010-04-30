# test-generator

Haskell-module to automagically generate repetetive code when writing HUnit-tests.

## testGroupGenerator

### signature

    testGroupGenerator :: ExpQ

### usage

    myTestGroup = $(testGroupGenerator)

### example

    -- file SomeModule.hs
    fooTestGroup = $(testGroupGenerator)
    main = defaultMain [fooTestGroup]
    test1 = do 1 @=? 1
    test2 = do 2 @=? 2

is the same as

    -- file SomeModule.hs
    fooTestGroup = testGroup "SomeModule" [testCase "test1" test1, testCase "test2" test2]
    main = defaultMain [fooTestGroup]
    test1 = do 1 @=? 1
    test2 = do 2 @=? 2

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
   
    testFoo = do 4 @=? 4
    
    testBar = do "hej" @=? "hej"

will automagically extract testFoo and testBar and run them as well as present them as belonging to the testGroup 'MyModuleTest'. The above code is the same as

    {-# OPTIONS_GHC -fglasgow-exts -XTemplateHaskell #-}
    module MyModuleTest where
    import Test.HUnit
    import MainTestGenerator
    
    main =
      defaultMain [
        testGroup "MyModuleTest" [ testCase "testFoo" testFoo, testCase "testBar" testBar]
        ]
    
    testFoo = do 4 @=? 4
   
    testBar = do "hej" @=? "hej"

and will give the following result

    me: runghc MyModuleTest.hs 
    MyModuleTest:
      testFoo: [OK]
      testBar: [OK]
     
             Test Cases  Total      
     Passed  2           2          
     Failed  0           0          
     Total   2           2 
