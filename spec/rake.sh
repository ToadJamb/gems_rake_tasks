#!/bin/bash

if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  source "$HOME/.rvm/scripts/rvm"
elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then
  source "/usr/local/rvm/scripts/rvm"
else
  printf "ERROR: An RVM installation was not found.\n"
fi

rubies=(
  1.9.3-p547
  2.0.0-p481
  2.1.2
  2.2.0
)

header='****************************************'
footer='----------------------------------------'

bundle config --local path vendor

for i in "${rubies[@]}"
do
  echo "$header$header"
  rvm use $i
  rvm current
  bundle check || bundle install
  bundle clean --force
  bundle exec rake
  echo "$footer$footer"
  echo
done
