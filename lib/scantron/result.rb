module Scantron
  class Result
    attr_reader :name
    attr_reader :rule
    attr_reader :scanner
    attr_reader :value

    def initialize name, rule, scanner
      @name    = name
      @rule    = rule
      @scanner = scanner.dup
      @value   = rule.call self
    end

    def length
      scanner.matched_size
    end
    alias size length

    def offset
      scanner.pos - scanner.matched_size
    end

    def pos
      [offset, length]
    end

    def to_s
      scanner.matched
    end
  end
end
