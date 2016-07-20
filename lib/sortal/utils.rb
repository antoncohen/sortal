require 'set'

module Sortal
  # Module of utility methods
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

    # Return a Set from a String of character-separated values
    #
    # @param string [String] of character-separated values
    # @param default value if resulting Set is empty, defaults to empty Set
    # @param separator [String] to split on, defaults to comma (',')
    # @returns [Set]
    def csv_to_set(string, default = Set[], separator = ',')
      new_set = Set.new(string.to_s.split(separator).map(&:strip))
      new_set.empty? ? default : new_set
    end
  end
end
