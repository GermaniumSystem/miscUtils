#!/bin/bash

echo ''
echo 'decoderRing.sh - A small utility for encoding, decoding, and brute forcing linear substitution ciphers used on "secret decoder rings".'
echo ''

function prompt {
  echo 'Available commands:'
  echo '[E]ncode - Takes a string of letters and encodes them using a specified offset.'
  echo '[D]ecode - Takes a string of numbers and decodes them using a specified offset.'
  echo '[B]rute force - Takes a string of numbers and prints decoded output for all 26 offsets.'
  echo ''
  printf 'Please enter the letter for the task you with to complete (E/D/B): '
  read COMMAND
  echo ''
  if [[ $COMMAND == "E" ]] || [[ $COMMAND == "e" ]] ; then
    encode
  elif [[ $COMMAND == "D" ]] || [[ $COMMAND == "d" ]] ; then
    decode
  elif [[ $COMMAND == "B" ]] || [[ $COMMAND == "b" ]] ; then
    brute
  else
    echo 'Invalid command.'
    echo ''
    prompt
  fi
}

#The matrix is a simple and easily processed list of what character goes to what number and vice versa.
function genMatrix {
  #OFFSET is assumed to be provided by whatever calls this function.
  INT=1
  #MINT is the counter used once the loop has hit 26 and needs to roll over.
  MINT=1
  #The matrix is generated multiple times during brute forcing, so it must be cleared before generating again.
  MATRIX=''
  for LETTER in $(echo {A..Z} | sed 's/ /\n/g'); do
    if [ $((INT + OFFSET)) -gt 26 ] ; then
      MATRIX="$(echo "$MATRIX" ; echo "$MINT $LETTER")"
      MINT=$((MINT + 1))
    else
      MATRIX="$(echo "$MATRIX" ; echo "$((OFFSET + INT)) $LETTER")"
    fi
    INT=$((INT + 1))
  done
}

function encode {
  printf "Letters you wish to encode: "
  read LETTERS
  LETTERS="$(echo "$LETTERS" | sed 's/ //g' | tr [:lower:] [:upper:])"
  if ! [[ $LETTERS =~ [A-Z] ]] ; then
    echo 'Only letters A-Z can be encoded.'
    encode
  else
    printf "Offset (0-25): "
    read OFFSET
    if ! [[ $OFFSET =~ [0-9] ]] || [[ $OFFSET -gt 25 ]] ; then
      echo 'Only an offset of 0-25 may be used.'
      encode
    else
      #Generate a matrix for the specified offset value.
      genMatrix
      printf "Encoded string: "
      echo "$LETTERS" | sed 's/\(.\)/\1\n/g' | while read LETTER ; do
        printf "$(echo "$MATRIX" | grep " ${LETTER}$" | awk '{print $1}') "
      done
      echo ''
    fi
  fi
}

function decode {
  printf "Numbers you wish to decode, separated by spaces: "
  read CODE
  if ! [[ "$(echo "$CODE" | sed 's/ //g')" =~ [0-9] ]] ; then
    echo 'Only numbers and spaces may be entered.'
    decode
  else
    printf "Offset (0-25): "
    read OFFSET
    if ! [[ $OFFSET =~ [0-9] ]] || [[ $OFFSET -gt 25 ]] ; then
      echo 'Only an offset of 0-25 may be used.'
      decode
    else
      #Generate a matrix for the specified offset value.
      genMatrix
      printf "Decoded string: "
      echo "$CODE" | sed 's/ /\n/g' | while read CHAR ; do
        if [ $CHAR -lt 27 ] && [ $CHAR -gt 0 ] ; then
          printf "$(echo "$MATRIX" | grep "^$CHAR " | awk '{print $2}')"
        else
          printf "_"
        fi
      done
      echo ''
    fi
  fi
}

function brute {
  printf "Enter numerical codes separated by spaces: "
  read CODE
  if ! [[ "$(echo "$CODE" | sed 's/ //g')" =~ [0-9] ]] ; then
    echo 'Only numbers and spaces may be entered.'
    brute
  else
    echo 'Possible solutions:'
    for OFFSET in $(seq 0 25); do
      #Generate a matrix for the current offset value.
      genMatrix
      printf "Offset $OFFSET: "
      echo "$CODE" | sed 's/ /\n/g' | while read CHAR ; do
        if [ $CHAR -lt 27 ] && [ $CHAR -gt 0 ] ; then
          printf "$(echo "$MATRIX" | grep "^$CHAR " | awk '{print $2}')"
        else
          printf "_"
        fi
      done
      echo ''
    done
  fi
}

prompt
