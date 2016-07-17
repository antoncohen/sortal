module Sortal
  module Utils
    module_function

    # Return a valid value.
    #
    # Checks if `value` is in `valids`, fallback to `default`.
    # `default_default` supports a fallback default.
    #
    # @param value requested
    # @param valids [#include?] Set or Array of valid values
    # @param default value if value isn't in `valids`
    # @param  default value if `default` is `nil`
    # @returns valid value
    def valid_or_default(value, valids, default, default_default = nil)
      if valids.include?(value)
        value
      else
        default.nil? ? default_default : default
      end
    end
  end
end
