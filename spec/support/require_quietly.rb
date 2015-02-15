def require_quietly(dependency)
  verbose = $VERBOSE
  $VERBOSE = false

  require dependency

  $VERBOSE = verbose
end
