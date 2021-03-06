{-# LANGUAGE OverloadedStrings #-}

module SchemeR5RS_Unittests (
  r5rsTestTree
  )where

import Data.Void
import qualified Data.Text as T
import Data.Either
import Data.Bifunctor (first)
import Test.Tasty
import Test.Tasty.HUnit
import Text.Megaparsec
--import Text.Megaparsec.Char
import Data.SExpresso.SExpr
import Data.SExpresso.Parse
import Data.SExpresso.Language.SchemeR5RS as R5

type Parser = Parsec Void T.Text

pSExpr :: Parser [SExpr R5.SExprType R5.SchemeToken]
pSExpr = decode R5.sexpr

-- tparse parses the whole input
tparse :: Parser a -> T.Text -> Either String a
tparse p s = first errorBundlePretty $ parse (p <* eof) "" s
  
r5rsTestTree :: TestTree
r5rsTestTree = testGroup "Language/R5RS.hs" $ [
  testGroup "whitespace" $ [
      let s = " " in testCase (show s) $ tparse R5.whitespace s @?= Right (),
      let s = "\t" in testCase (show s) $ tparse R5.whitespace s @?= Right (),
      let s = "\n" in testCase (show s) $ tparse R5.whitespace s @?= Right (),
      let s = "\r\n" in testCase (show s) $ tparse R5.whitespace s @?= Right (),
      let s = "" in testCase (show s) $ (isLeft $ tparse R5.whitespace s) @? "Parsing must fail on empty input",
      let s = "a" in testCase (show s) $ (isLeft $ tparse R5.whitespace s) @? "Parsing must fail on a",
      let s = ";" in testCase (show s) $ (isLeft $ tparse R5.whitespace s) @? "Parsing must fail on ;"
      ],
  testGroup "comment" $ [
      let s = ";" in testCase (show s) $ tparse R5.comment s @?= Right (),
      let s = ";hello world" in testCase (show s) $ tparse R5.comment s @?= Right (),
      let s = ";hello\n" in testCase (show s) $ tparse R5.comment s @?= Right (),
      let s = ";abcdef\r\n" in testCase (show s) $ tparse R5.comment s @?= Right (),
      let s = "" in testCase (show s) $ (isLeft $ tparse R5.comment s) @? "Parsing must fail on empty input",
      let s = "a" in testCase (show s) $ (isLeft $ tparse R5.comment s) @? "Parsing must fail on a",
      let s = "#t" in testCase (show s) $ (isLeft $ tparse R5.comment s) @? "Parsing must fail on #t"
      ],
  testGroup "interTokenSpace" $ [
      let s = ";" in testCase (show s) $ tparse R5.interTokenSpace s @?= Right (),
      let s = ";hello world" in testCase (show s) $ tparse R5.interTokenSpace s @?= Right (),
      let s = ";hello\n" in testCase (show s) $ tparse R5.interTokenSpace s @?= Right (),
      let s = ";abcdef\r\n" in testCase (show s) $ tparse R5.interTokenSpace s @?= Right (),
      let s = " " in testCase (show s) $ tparse R5.interTokenSpace s @?= Right (),
      let s = "\t" in testCase (show s) $ tparse R5.interTokenSpace s @?= Right (),
      let s = "\n" in testCase (show s) $ tparse R5.interTokenSpace s @?= Right (),
      let s = "\r\n" in testCase (show s) $ tparse R5.interTokenSpace s @?= Right (),
      let s = " ;comment\n    " in testCase (show s) $ tparse R5.interTokenSpace s @?= Right (),
      let s = "\t\n;comment   \n   " in testCase (show s) $ tparse R5.interTokenSpace s @?= Right (),
      let s = "\n\n\n\n\n" in testCase (show s) $ tparse R5.interTokenSpace s @?= Right (),
      let s = "\r\n;Hello World" in testCase (show s) $ tparse R5.interTokenSpace s @?= Right (),
      let s = "" in testCase (show s) $ tparse R5.interTokenSpace s @?= Right ()
      ],
  testGroup "interTokenSpace1" $ [
      let s = ";" in testCase (show s) $ tparse R5.interTokenSpace1 s @?= Right (),
      let s = ";hello world" in testCase (show s) $ tparse R5.interTokenSpace1 s @?= Right (),
      let s = ";hello\n" in testCase (show s) $ tparse R5.interTokenSpace1 s @?= Right (),
      let s = ";abcdef\r\n" in testCase (show s) $ tparse R5.interTokenSpace1 s @?= Right (),
      let s = " " in testCase (show s) $ tparse R5.interTokenSpace1 s @?= Right (),
      let s = "\t" in testCase (show s) $ tparse R5.interTokenSpace1 s @?= Right (),
      let s = "\n" in testCase (show s) $ tparse R5.interTokenSpace1 s @?= Right (),
      let s = "\r\n" in testCase (show s) $ tparse R5.interTokenSpace1 s @?= Right (),
      let s = " ;comment\n    " in testCase (show s) $ tparse R5.interTokenSpace1 s @?= Right (),
      let s = "\t\n;comment   \n   " in testCase (show s) $ tparse R5.interTokenSpace1 s @?= Right (),
      let s = "\n\n\n\n\n" in testCase (show s) $ tparse R5.interTokenSpace1 s @?= Right (),
      let s = "\r\n;Hello World" in testCase (show s) $ tparse R5.interTokenSpace1 s @?= Right (),
      let s = "" in testCase (show s) $ (isLeft $ tparse R5.interTokenSpace1 s) @? "Parsing must fail on empty input",
      let s = "1234" in testCase (show s) $ (isLeft $ tparse R5.interTokenSpace1 s) @? "Parsing must fail on 1234",
      let s = "a" in testCase (show s) $ (isLeft $ tparse R5.interTokenSpace1 s) @? "Parsing must fail on a",
      let s = "#t" in testCase (show s) $ (isLeft $ tparse R5.interTokenSpace1 s) @? "Parsing must fail on #t"
      ],
  testGroup "character" $ [
      let s = "#\\t" in testCase (show s) $ tparse R5.character s @?= Right 't',
      let s = "#\\a" in testCase (show s) $ tparse R5.character s @?= Right 'a',
      let s = "#\\space" in testCase (show s) $ tparse R5.character s @?= Right ' ',
      let s = "#\\newline" in testCase (show s) $ tparse R5.character s @?= Right '\n',
      let s = "#\\\n" in testCase (show s) $ tparse R5.character s @?= Right '\n',
      let s = "#\\ " in testCase (show s) $ tparse R5.character s @?= Right ' ',
      let s = "#\\\t" in testCase (show s) $ tparse R5.character s @?= Right '\t',
      let s = "" in testCase (show s) $ (isLeft $ tparse R5.character s) @? "Parsing must fail on empty input",
      let s = "#t" in testCase (show s) $ (isLeft $ tparse R5.character s) @? "Parsing must fail on #t",
      let s = "#f" in testCase (show s) $ (isLeft $ tparse R5.character s) @? "Parsing must fail on #f"
      ],
  testGroup "boolean" $ [
      let s = "#t" in testCase (show s) $ tparse R5.boolean s @?= Right True,
      let s = "#f" in testCase (show s) $ tparse R5.boolean s @?= Right False,
      let s = "" in testCase (show s) $ (isLeft $ tparse R5.boolean s) @? "Parsing must fail on empty input",
      let s = "t" in testCase (show s) $ (isLeft $ tparse R5.boolean s) @? "Parsing must fail on t",
      let s = "f" in testCase (show s) $ (isLeft $ tparse R5.boolean s) @? "Parsing must fail on f"
      ],
  testGroup "identifier" $ [
      let s = "foo" in testCase (show s) $ tparse R5.identifier s @?= Right s,
      let s = "x2" in testCase (show s) $ tparse R5.identifier s @?= Right s,
      let s = "!hot!" in testCase (show s) $ tparse R5.identifier s @?= Right s,
      let s = "+" in testCase (show s) $ tparse R5.identifier s @?= Right s,
      let s = "-" in testCase (show s) $ tparse R5.identifier s @?= Right s,
      let s = "..." in testCase (show s) $ tparse R5.identifier s @?= Right s,
      let s = "helloWorld" in testCase (show s) $ tparse R5.identifier s @?= Right s,
      let s = "" in testCase (show s) $ (isLeft $ tparse R5.identifier s) @? "Parsing must fail on empty input",
      let s = "#t" in testCase (show s) $ (isLeft $ tparse R5.identifier s) @? "Parsing must fail on #t",
      let s = "#f" in testCase (show s) $ (isLeft $ tparse R5.identifier s) @? "Parsing must fail on #f",
      let s = "123" in testCase (show s) $ (isLeft $ tparse R5.identifier s) @? "Parsing must fail on 123",
      let s = "+123" in testCase (show s) $ (isLeft $ tparse R5.identifier s) @? "Parsing must fail on +123",
      let s = "-123" in testCase (show s) $ (isLeft $ tparse R5.identifier s) @? "Parsing must fail on -123",
      let s = "+i" in testCase (show s) $ (isLeft $ tparse R5.identifier s) @? "Parsing must fail on +i",
      let s = "-i" in testCase (show s) $ (isLeft $ tparse R5.identifier s) @? "Parsing must fail on -i"
      ],
    testGroup "string" $ [
      let s = "\"abc def ghi\"" in testCase (show s) $ tparse R5.stringParser s @?= Right "abc def ghi",
      let s = "\"\"" in testCase (show s) $ tparse R5.stringParser s @?= Right "",
      let s = "\"\n\"" in testCase (show s) $ tparse R5.stringParser s @?= Right "\n",
      let s = "\" \"" in testCase (show s) $ tparse R5.stringParser s @?= Right " ",
      let s = "\"\t\"" in testCase (show s) $ tparse R5.stringParser s @?= Right "\t",
      let s = T.pack ['"','\\','\\','"'] in testCase (show s) $ tparse R5.stringParser s @?= Right "\\",
      let s = T.pack ['"','\\','"','"'] in testCase (show s) $ tparse R5.stringParser s @?= Right "\"",
      let s = "#t" in testCase (show s) $ (isLeft $ tparse R5.stringParser s) @? "Parsing must fail on #t",
      let s = "#f" in testCase (show s) $ (isLeft $ tparse R5.stringParser s) @? "Parsing must fail on #f"
      ],
    testGroup "number" $ [
      let s = "-1" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CReal (SInteger Minus (UInteger 1))),
      let s = "-0" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CReal (SInteger Minus (UInteger 0 ))),
      let s = "0" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CReal (SInteger Plus (UInteger 0))),
      let s = "1" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CReal (SInteger Plus (UInteger 1))),

      
      let s = "#e1" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CReal (SInteger Plus (UInteger 1))),
        
      let s = "#i1" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SInteger Plus (UInteger 1))),
        
      let s = "#b1" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CReal (SInteger Plus (UInteger 1))),
      let s = "#o1" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CReal (SInteger Plus (UInteger 1))),
      let s = "#d1" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CReal (SInteger Plus (UInteger 1))),
      let s = "#x1" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CReal (SInteger Plus (UInteger 1))),
      let s = "#xa" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                                                                   CReal (SInteger Plus (UInteger 10))),
      let s = "#xb" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CReal (SInteger Plus (UInteger 11))),
      let s = "#xc" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CReal (SInteger Plus (UInteger 12))),
      let s = "#xd" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CReal (SInteger Plus (UInteger 13))),
      let s = "#xe" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CReal (SInteger Plus (UInteger 14))),
      let s = "#xf" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CReal (SInteger Plus (UInteger 15))),
      let s = "-0001" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CReal (SInteger Minus (UInteger 1))),
      let s = "-0000" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CReal (SInteger Minus (UInteger 0))),
      let s = "0000" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CReal (SInteger Plus (UInteger 0))),
      let s = "0001" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CReal (SInteger Plus (UInteger 1))),

      let s = "-1#" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SInteger Minus (UIntPounds 1 1))),
      let s = "-0#" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SInteger Minus (UIntPounds 0 1))),
      let s = "0#" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SInteger Plus (UIntPounds 0 1))),
      let s = "1#" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SInteger Plus (UIntPounds 1 1))),

      let s = "-1###" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SInteger Minus (UIntPounds 1 3))),
      let s = "-0###" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SInteger Minus (UIntPounds 0 3))),
      let s = "0###" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SInteger Plus (UIntPounds 0 3))),
      let s = "1###" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SInteger Plus (UIntPounds 1 3))),

      let s = "-12345" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CReal (SInteger Minus (UInteger 12345))),
      let s = "12345" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CReal (SInteger Plus (UInteger 12345))),

      let s = "-12345/5" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CReal (SRational Minus (UInteger 12345) (UInteger 5))),
      let s = "12345/5" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CReal (SRational Plus (UInteger 12345) (UInteger 5))),
      let s = "-12345#/5" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SRational Minus (UIntPounds 12345 1) (UInteger 5))),
      let s = "12345/5##" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SRational Plus (UInteger 12345) (UIntPounds 5 2))),
      let s = "-12345##/5" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SRational Minus (UIntPounds 12345 2) (UInteger 5))),
      let s = "12345####/5#" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SRational Plus (UIntPounds 12345 4) (UIntPounds 5 1))),


      let s = "-12345.0" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SDecimal Minus (UInteger 12345) (UInteger 0) Nothing)),
      let s = ".0" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SDecimal Plus (UInteger 0) (UInteger 0) Nothing)),
      let s = "0." in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SDecimal Plus (UInteger 0) (UInteger 0) Nothing)),
        
      let s = "0.###" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SDecimal Plus (UInteger 0) (UPounds 3) Nothing)),
      let s = "-.569" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SDecimal Minus (UInteger 0) (UInteger 569) Nothing)),
      let s = "-245#." in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SDecimal Minus (UIntPounds 245 1) (UPounds 0) Nothing)),
      let s = "#e-.569" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CReal (SDecimal Minus (UInteger 0) (UInteger 569) Nothing)),
      let s = "1e10" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SDecimal Plus (UInteger 1)
                                                         (UInteger 0)
                                                         (Just $ Suffix PDefault Plus 10))),
      let s = "1e-10" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SDecimal Plus (UInteger 1)
                                                         (UInteger 0)
                                                         (Just $ Suffix PDefault Minus 10))),
      let s = "1s10" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SDecimal Plus (UInteger 1)
                                                         (UInteger 0)
                                                         (Just $ Suffix PShort Plus 10))),
      let s = "1f10" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SDecimal Plus (UInteger 1)
                                                         (UInteger 0)
                                                         (Just $ Suffix PSingle Plus 10))),
      let s = "1d10" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SDecimal Plus (UInteger 1)
                                                         (UInteger 0)
                                                         (Just $ Suffix PDouble Plus 10))),
      let s = "1l10" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CReal (SDecimal Plus (UInteger 1)
                                                         (UInteger 0)
                                                         (Just $ Suffix PLong Plus 10))),
        
      let s = "1+i" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CAbsolute (SInteger Plus (UInteger 1)) (SInteger Plus (UInteger 1))),
        
      let s = "1-i" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CAbsolute (SInteger Plus (UInteger 1)) (SInteger Minus (UInteger 1))),

      let s = "0.5+i" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CAbsolute (SDecimal Plus (UInteger 0)
                                                    (UInteger 5)
                                                    Nothing) (SInteger Plus (UInteger 1))),
                                                                     
      let s = "-8i" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CAbsolute (SInteger Plus (UInteger 0)) (SInteger Minus (UInteger 8))),

      
      let s = "-8.25i" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CAbsolute (SInteger Plus (UInteger 0)) (SDecimal Minus (UInteger 8)
                                                                                      (UInteger 25)
                                                                                      Nothing)),
      let s = "0@25" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CAngle (SInteger Plus (UInteger 0)) (SInteger Plus (UInteger 25))),

      let s = "1/4@-25" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Exact $
                      CAngle (SRational Plus (UInteger 1) (UInteger 4)) (SInteger Minus (UInteger 25))),

      let s = "1#/4@-25##" in testCase (show s) $ tparse R5.number s @?= (Right $ SchemeNumber Inexact $
                      CAngle (SRational Plus (UIntPounds 1 1) (UInteger 4)) (SInteger Minus (UIntPounds 25 2))),

      let s = "#b3" in testCase (show s) $ (isLeft $ tparse R5.number s) @? "Parsing must fail on #b3",
      let s = "#o9" in testCase (show s) $ (isLeft $ tparse R5.number s) @? "Parsing must fail on #o9",
      let s = "#da" in testCase (show s) $ (isLeft $ tparse R5.number s) @? "Parsing must fail on #da",
      let s = "#xA" in testCase (show s) $ (isLeft $ tparse R5.number s) @? "Parsing must fail on #xA",
      
      let s = "#b1.1" in testCase (show s) $ (isLeft $ tparse R5.number s) @? "Parsing must fail on #b1.1",
      let s = "#o1.1" in testCase (show s) $ (isLeft $ tparse R5.number s) @? "Parsing must fail on #o1.1",
      let s = "#x1.1" in testCase (show s) $ (isLeft $ tparse R5.number s) @? "Parsing must fail on #x1.1",
      let s = "#b.1" in testCase (show s) $ (isLeft $ tparse R5.number s) @? "Parsing must fail on #b.1",
      let s = "#o.1" in testCase (show s) $ (isLeft $ tparse R5.number s) @? "Parsing must fail on #o.1",
      let s = "#x.1" in testCase (show s) $ (isLeft $ tparse R5.number s) @? "Parsing must fail on #x.1",
      
      let s = "123##.12" in testCase (show s) $ (isLeft $ tparse R5.number s) @? "Parsing must fail on 123##.12",
      let s = "#" in testCase (show s) $ (isLeft $ tparse R5.number s) @? "Parsing must fail on #",
      let s = "#t" in testCase (show s) $ (isLeft $ tparse R5.number s) @? "Parsing must fail on #t",
      let s = "#f" in testCase (show s) $ (isLeft $ tparse R5.number s) @? "Parsing must fail on #f"
      ],
    testGroup "datum" $ [
      let s = "1" in testCase (show s) $ (tparse pSExpr s >>= sexpr2Datum) @?=
                     (Right $ [DNumber (SchemeNumber Exact (CReal (SInteger Plus (UInteger 1))))]),
        
      let s = "foo" in testCase (show s) $ (tparse pSExpr s >>= sexpr2Datum) @?=
                     (Right $ [DIdentifier "foo"]),
      let s = "(foo #\\a)" in testCase (show s) $ (tparse pSExpr s >>= sexpr2Datum) @?=
                     (Right $ [DList [DIdentifier "foo", DChar 'a']]),
      let s = "(foo #\\a) \"hello\"" in testCase (show s) $ (tparse pSExpr s >>= sexpr2Datum) @?=
                     (Right $ [DList [DIdentifier "foo", DChar 'a'], DString "hello"]),
        
      let s = "'foo" in testCase (show s) $ (tparse pSExpr s >>= sexpr2Datum) @?=
                     (Right $ [DQuote (DIdentifier "foo")]),
      let s = "`foo" in testCase (show s) $ (tparse pSExpr s >>= sexpr2Datum) @?=
                     (Right $ [DQuasiquote (DIdentifier "foo")]),
      let s = "`(foo ,a)" in testCase (show s) $ (tparse pSExpr s >>= sexpr2Datum) @?=
                     (Right $ [DQuasiquote (DList [DIdentifier "foo", DComma (DIdentifier "a")])]),
      let s = "`(foo , a)" in testCase (show s) $ (tparse pSExpr s >>= sexpr2Datum) @?=
                     (Right $ [DQuasiquote (DList [DIdentifier "foo", DComma (DIdentifier "a")])]),
      let s = "`(foo, a)" in testCase (show s) $ (tparse pSExpr s >>= sexpr2Datum) @?=
                     (Right $ [DQuasiquote (DList [DIdentifier "foo", DComma (DIdentifier "a")])]),
      let s = "`(foo ,@a)" in testCase (show s) $ (tparse pSExpr s >>= sexpr2Datum) @?=
                     (Right $ [DQuasiquote (DList [DIdentifier "foo", DCommaAt (DIdentifier "a")])]),
      let s = "`(foo ,@ a)" in testCase (show s) $ (tparse pSExpr s >>= sexpr2Datum) @?=
                     (Right $ [DQuasiquote (DList [DIdentifier "foo", DCommaAt (DIdentifier "a")])]),
      let s = "`(foo,@ a)" in testCase (show s) $ (tparse pSExpr s >>= sexpr2Datum) @?=
                     (Right $ [DQuasiquote (DList [DIdentifier "foo", DCommaAt (DIdentifier "a")])]),
      let s = "(foo . a)" in testCase (show s) $ (tparse pSExpr s >>= sexpr2Datum) @?=
                     (Right $ [DDotList [DIdentifier "foo"] (DIdentifier "a")]),
      let s = "(foo a b c . d)" in testCase (show s) $ (tparse pSExpr s >>= sexpr2Datum) @?=
                     (Right $ [DDotList [DIdentifier "foo", DIdentifier "a", DIdentifier "b", DIdentifier "c"] (DIdentifier "d")]),
      let s = "(foo .)" in testCase (show s) $ (isLeft $ tparse R5.number s) @? "Parsing must fail on (foo .)",
      let s = "(foo ')" in testCase (show s) $ (isLeft $ tparse R5.number s) @? "Parsing must fail on (foo ')",
      let s = "(foo `)" in testCase (show s) $ (isLeft $ tparse R5.number s) @? "Parsing must fail on (foo `)",
      let s = "(foo ,)" in testCase (show s) $ (isLeft $ tparse R5.number s) @? "Parsing must fail on (foo ,)",
      let s = "(foo ,@)" in testCase (show s) $ (isLeft $ tparse R5.number s) @? "Parsing must fail on (foo ,@)",
      let s = "(foo a b . c d)" in testCase (show s) $ (isLeft $ tparse R5.number s) @? "Parsing must fail on (foo a b . c d)"
      ]
  ]
