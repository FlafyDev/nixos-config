#!/usr/bin/env sh 

lang=$(setxkbmap -query | grep "layout:")

if [ ${lang##* } = "us" ]; then
  setxkbmap il
else
  setxkbmap us
fi

