module MochaHelpers
  def not_implemented(klass, method)
    klass.stubs(method).raises NotImplementedError,
      "#{klass}.#{method} has been stubbed as not implemented."
  end

  def match_keys(*keys)
    match = []
    keys.each do |key|
      match << match_key(key)
    end
    all_of(*match)
  end

  def match_key(key)
    match = []
    [key.to_sym, key.to_s].each do |key_value|
      match << has_key(key_value)
    end
    any_of(*match)
  end
end

RSpec.configure do |config|
  include MochaHelpers
end
