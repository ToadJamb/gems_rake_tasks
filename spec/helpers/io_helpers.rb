module IOHelpers
  # Returns the output from stdout as a string.
  # ==== Output
  # [String] The output from stdout.
  #
  #          All trailing line feeds are removed.
  def out
    @out.respond_to?(:string) ?  @out.string.gsub(/\n*\z/, '') : ''
  end

  # Returns the output from stderr as a string.
  # ==== Output
  # [String] The output from stderr.
  #
  #          All trailing line feeds are removed.
  def err
    @err.respond_to?(:string) ?  @err.string.gsub(/\n*\z/, '') : ''
  end

  # Return the actual output to stdout and stderr.
  # ==== Output
  # [Array] Two element array of strings.
  #
  #         The first element is from stdout.
  #
  #         The second element is from stderr.
  def real_finis
    return out, err
  end

  # Reset the stdout and stderr stream variables.
  def reset_io
    @out = StringIO.new
    @err = StringIO.new
  end

  # Wrap a block to capture the output to stdout and stderr.
  # ==== Input
  # [&block : Block] The block of code
  #                  that will have stdout and stderr trapped.
  def wrap_output(&block)
    begin
      $stdout = @out
      $stderr = @err
      yield
    ensure
      $stdout = STDOUT
      $stderr = STDERR
    end
  end
end

RSpec.configure do |config|
  include IOHelpers
end
