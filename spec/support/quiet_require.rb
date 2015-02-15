def quiet_require(dependency)
  verbose = $VERBOSE
  $VERBOSE = false
  require dependency
  $VERBOSE = verbose
end
