#!/bin/bash

echo ""

# 13k demo - change this if you're target package size is different
let KBSIZE=13

# preprocess - run ///#define macros
rm -f index_pp.html
filepp -kc "///#" full.html >index_pp.html
chmod -w index_pp.html

# minify resultant preprocessed output to final file
#/usr/bin/minify index_pp.html >index.html
minify index_pp.html -o index.html
#/usr/bin/minify w_full.js >w.js

# check how many newlines
LINES=`< index.html wc -l`

if test $LINES -gt 0
then
  echo WARNING - source minified to multiple lines - check your semicolons!
fi

if grep -q ";}" index.html
then
  echo WARNING - ending semicolons found - check your semicolons!
fi

if grep -q ",)" index.html
then
  echo WARNING - bracket commas found - check your commas!
fi

if grep -q "console.log" index.html
then
  echo WARNING - console logs left in packaged code!
fi

SRCSIZE=`stat --printf="%s" full.html`
OUTSIZE=`stat --printf="%s" index.html`

echo "Minified code from $SRCSIZE to $OUTSIZE bytes"

#advpng -q -z -4 t.png
#advpng -q -z -4 n.png
#advpng -q -z -4 d.png

#cp t.png t
#cp n.png n
#cp d.png d

rm min.zip 2> /dev/null

if hash ect 2>/dev/null; then
    ect -9 -zip min.zip index.html
else
    advzip -q -a -4 min.zip index.html
fi

advzip -l min.zip

let MAXSIZE=(1024*$KBSIZE)
PKGSIZE=`stat --printf="%s" min.zip`
let REMAINING=$MAXSIZE-$PKGSIZE
let OVER=$PKGSIZE-$MAXSIZE

echo package is $PKGSIZE bytes

if test $REMAINING -ge 0
then
  echo $REMAINING bytes are available for more goodness
  if [ ! -z "$CI" ]
  then
    curl -s https://img.shields.io/badge/size-$PKGSIZE-success --output badge.svg
  fi
else
  echo You are overbudget by $OVER bytes!!
  if [ ! -z "$CI" ]
  then
    curl -s https://img.shields.io/badge/size-$PKGSIZE-critical --output badge.svg
  fi
fi

echo ""

if [ ! -z "$CI" ]
then
mkdir public 2> /dev/null
pushd public
unzip ../min.zip
popd
cp full.html public
cp min.zip public
cp badge.svg public
#cp w.js public
#cp m.json public
fi
