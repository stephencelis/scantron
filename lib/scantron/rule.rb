module Scantron
  # A simple Struct-derived class to store class rules.
  #
  #   Scantron::Rule.new /\btest\b/, {}, lambda {}
  #   # => #<struct Scantron::Rule ...>
  class Rule < Struct.new :regexp, :data, :block
    def to_s
      regexp.to_s
    end
  end
end
