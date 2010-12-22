require 'strscan'
require 'scantron/result'
require 'scantron/rule'

module Scantron
  # Scantron::Scanner is meant to be inherited from. It provides functionality
  # above and beyond StringScanner.
  #
  # Define a few rules, scan, sort, and process the results all at once.
  #
  #   class HTMLScanner < Scantron::Scanner
  #     rule :tag, %r{<(\w+)[^>]*>([^<]+)</[^>]+>} do |r|
  #       { :tag => r.scanner[1].downcase, :innerHTML => r.scanner[2] }
  #     end
  #
  #     rule :comment, /<!--(.+?)-->/ do |r|
  #       { :comment => r.scanner[1].strip }
  #     end
  #   end
  #
  #   html = HTMLScanner.new "<A HREF='/'>Root!</A><!-- Important link! -->"
  #   html.scan
  #   # => [{:tag=>"a", :innerHTML=>"Root!"}, {:comment=>"Important link!"}]
  #
  #   html.scrub { |r| r.to_s.swapcase unless r.name == :comment }
  #   # => "<a href='/'>rOOT!</a>"
  class Scanner
    @before = nil
    @after = nil
    @rules = {}

    class << self
      attr_reader :before
      attr_reader :after
      attr_reader :rules

      # Scans a string against the rules defined in the class, returning an
      # array of matches processed by those rules.
      #
      # ==== Example
      #
      # The NumberScanner class scans for numbers and returns an array of
      # numbers.
      #
      #   NumberScanner.scan 'One, two, skip a few, 99, 100'
      #   # => [1, 2, 99, 100]
      def scan string
        new(string).scan
      end

      # Scans a string against the rules defined in the class, returning the
      # first match if it coincides with the beginning of the string.
      #
      # For flexibility, whitespace counts, so if you're matching against
      # non-whitespace, make sure to strip your strings before sending them
      # through.
      #
      # ==== Example
      #
      #   NumberScanner.parse 'One, two, three, four...'
      #   # => 1
      #
      #   NumberScanner.parse 'And a five, six, seven eight.'
      #   # => nil
      #
      #   number_scanner = NumberScanner.new '  One with whitespace...'
      #   number_scanner.parse
      #   # => nil
      #
      #   number_scanner.string.lstrip!
      #   number_scanner.parse
      #   # => 1
      def parse string
        new(string).parse
      end

      # Scans and processes a string against the rules defined in the class.
      # Accepts a block that yields to each Result, otherwise scrubbing each
      # match from the string.
      #
      # ==== Example
      #
      # Using the NumberScanner class:
      #
      #   NumberScanner.scrub '99 bottles of beer / take one down'
      #   # => " bottles of beer / take  down"
      #
      #   NumberScanner.scrub 'And one more thing...' do |r|
      #     "<span data-value='#{r.value}'>#{r}</span>"
      #   end
      #   # => "And <span data-value='1'>one</span> more thing..."
      def scrub string, &block
        new(string).scrub &block
      end

      protected

      attr_writer :before
      attr_writer :after
      attr_writer :rules

      def inherited subclass
        subclass.before = before
        subclass.after = after
        subclass.rules = rules.dup
      end

      private

      # A DSL provided to create scanner rules in scanner classes. Provided
      # blocks yield to Scantron::Result instances, evaluated during matches.
      #
      # ==== Example
      #
      #   class TestScanner < Scantron::Scanner
      #     rule :test, /\btest\b/
      #   end
      #   TestScanner.scan "The test went well, didn't it?"
      #   # => ["test"]
      #
      #   >> class PluralScanner < Scantron::Scanner
      #   >>   rule :plural, /\b[\w]+s\b/ do |r|
      #   >>     puts r
      #   >>     r.to_s.capitalize
      #   >>   end
      #   >> end
      #   => ...
      #   >> PluralScanner.scan "No ifs, ands, or buts about it."
      #   ifs
      #   ands
      #   buts
      #   => ["Ifs", "Ands", "Buts"]
      def rule name, regexp, data = {}, &block
        rules[name] = Rule.new regexp, data, block || after
      end

      def before_match &block
        self.before = block
      end

      def after_match &block
        self.after = block
      end
    end

    attr_reader :string

    def initialize string
      super
      @string = string
    end

    # See Scantron::Scanner.scan. The instance method analog.
    def scan
      perform.uniq.map { |result| result.value }
    end

    # See Scantron::Scanner.parse. The instance method analog.
    def parse
      result = perform.find { |result| result.offset == 0 }
      result.value if result
    end

    # See Scantron::Scanner.scrub. The instance method analog.
    def scrub
      str = string.dup

      perform.reverse.each do |result|
        pos = result.pos
        sub = yield result if block_given?
        str[*pos] = sub.to_s if str[*pos] == string[*pos]
      end

      str
    end

    # The heart of the scanner. Returns Result instances to scan, scrub, and
    # parse. Not a class method to discourage direct use outside of a scanner's
    # implementation.
    def perform
      scanner = StringScanner.new string
      results = []

      self.class.rules.each_pair do |name, rule|
        while scanner.skip_until rule.regexp
          results << Result.from(name, rule, scanner, self)
        end

        scanner.pos = 0
      end

      results.sort.delete_if { |r| r.value == false }
    end
  end
end
