module Scantron
  # The class Scanner yields to the most. If scrubbing with a block, you're
  # yielding to one of these.
  #
  # ==== Using Results
  #
  # Results have a few components that are important to know about during scans
  # and scrubs.
  #
  #   >> number_scanner = NumberScanner.new "One, 2, buckle my shoe"
  #   => #<NumberScanner...>
  #   >> number_scanner.scrub do |result|
  #   >>   p result.name, result.rule, result.scanner, result.value
  #   >>   "<#{result}>"
  #   >> end
  #   :integer
  #   #<struct Scantron::Rule...>
  #   #<StringScanner 6/22...>
  #   2
  #   :human
  #   #<struct Scantron::Rule...>
  #   #<StringScanner 3/22...>
  #   1
  #   => "<One>, <2>, buckle my shoe"
  #
  # [+name+]     The name of the particular rule matched for this result. Use
  #              case statements to process different rules in different ways.
  #
  # [+rule+]     The Rule itself (if you need access to the regular expression
  #              or any metadata you store there).
  #
  # [+scanner+]  The StringScanner used to capture this match. And used later
  #              for scrubbing. You can change its position, match something
  #              else, and the final scrub would be different.
  #
  # [+value+]    The value of the rule as processed by the rule's block.
  #
  # Also note that calling to_s on the Result will return the matched string.
  class Result
    # The name of the rule.
    attr_reader :name

    # The Rule the Result was matched from.
    attr_reader :rule

    # The StringScanner instance that matched the rule.
    attr_reader :scanner

    # The value as evaluated by the Rule's block.
    attr_reader :value

    attr_writer :length

    attr_writer :offset

    def initialize name, rule, scanner
      @name    = name
      @rule    = rule
      @scanner = scanner.dup
      @length  = nil
      @offset  = nil
      @value   = rule.block ? rule.block.call(self) : to_s
    end

    def length
      @length || scanner.matched_size
    end
    alias size length

    def offset
      @offset || scanner.pos - length
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
