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

    def eql? other
      pos == other.pos && value == other.value
    end
    alias == eql?

    def hash
      pos.hash ^ value.hash
    end

    include Comparable
    def <=> other
      pos <=> other.pos
    end

    def to_s
      scanner.matched
    end

    def inspect
      "#<#{self.class.name} #{to_s.inspect}>"
    end
  end
end
