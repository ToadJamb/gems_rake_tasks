#!/bin/bash

if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  source "$HOME/.rvm/scripts/rvm"
elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then
  source "/usr/local/rvm/scripts/rvm"
else
  printf "ERROR: An RVM installation was not found.\n"
fi

rvm use $2

if [ $# -ge 3 ]; then
  gem install rake -v $3 --no-rdoc --no-ri
  rake _$3_ $1
else
  bundle exec rake $1
fi 
