require 'strscan'
require 'scantron/result'
require 'scantron/rule'

module Scantron
  class Scanner
    @default = nil
    @rules = {}

    class << self
      attr_reader :default
      attr_reader :rules

      def scan string
        new(string).scan
      end

      def scrub string, &block
        new(string).scrub &block
      end

      protected

      attr_writer :default
      attr_writer :rules

      def inherited subclass
        subclass.default = default
        subclass.rules = rules.dup
      end

      private

      def rule name, regexp, &block
        rules[name] = Rule.new regexp, block || default
      end
    end

    attr_reader :string

    def initialize string
      super
      @string = string
    end

    def scan
      perform.map { |result| result.value }
    end

    def scrub
      str = string.dup

      perform.reverse.each do |result|
        pos = result.pos
        sub = yield result if block_given?
        str[*pos] = sub.to_s if str[*pos] == string[*pos]
      end

      str
    end

    private

    def perform
      scanner = StringScanner.new string
      results = []

      self.class.rules.each_pair do |name, rule|
        while scanner.skip_until rule.regexp
          results << Result.new(name, rule.block, scanner)
        end

        scanner.pos = 0
      end

      results.sort_by { |r| r.pos }.delete_if { |r| r.value == false }
    end
  end
end
