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
    class << self
      def from name, rule, scanner, scantron
        result = new name, rule, scanner, scantron
        scantron.class.before ? scantron.class.before.call(result) : result
      end
    end

    # The name of the rule.
    attr_reader :name

    # The Rule the Result was matched from.
    attr_reader :rule

    # The StringScanner instance that matched the rule.
    attr_reader :scanner

    # Overwrite the length to adjust the length of the matched string returned.
    attr_writer :length

    # Overwrite the offset to adjust the offset of the matched string returned.
    attr_writer :offset

    # The Scantron::Scanner instance that created this result.
    attr_reader :scantron

    # Hash of information to write to and read from.
    attr_reader :data

    def initialize name, rule, scanner, scantron
      @name     = name
      @rule     = rule
      @scanner  = scanner.dup
      @length   = nil
      @offset   = nil
      @value    = nil
      @data     = {}
      @scantron = scantron
    end

    # The value as evaluated by the Rule's block (or Scanner's after_match).
    def value
      @value ||= rule.block ? rule.block.call(self) : to_s
    end

    def [] key
      data[key]
    end

    def []= key, value
      data[key] = value
    end

    def length
      @length || scanner.matched_size
    end
    alias size length

    def length= length
      @value = nil
      @length = length
    end

    def offset
      @offset || scanner.pos - scanner.matched_size
    end

    def offset= offset
      @value = nil
      @offset = offset
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
      [offset, -length] <=> [other.offset, -other.length]
    end

    def pre_match
      return scanner.pre_match if @offset.nil?
      scanner.string[0, offset]
    end

    def post_match
      return scanner.post_match if @length.nil? && @offset.nil?
      scanner.string[offset + length, scanner.string.length]
    end

    def to_s
      return scanner.matched if @length.nil? && @offset.nil?
      scanner.string[offset, length]
    end

    def inspect
      "#<#{self.class.name} #{to_s.inspect}>"
    end
  end
end
