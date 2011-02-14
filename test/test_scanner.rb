# encoding: utf-8

require 'scantron'
require 'test/unit'

class TestScanner < Test::Unit::TestCase
  class BogusScanner < Scantron::Scanner
    after_match { |r| :default }
    rule(:test, /\btest\b/) { 1 }
    rule(:tests, /\btests\b/) { |r| "#{r}" }
    rule :testing, /,.+$/
    rule(:false, /and/) { |r| false }
  end

  def setup
    @scanner = BogusScanner.new 'and test the tests, k?'
  end

  def test_should_scan
    assert_equal [1, 'tests', :default], @scanner.scan
  end

  def test_should_scrub
    assert_equal "and  the ", @scanner.scrub

  def test_should_scrub_multibyte
    require 'amount_scanner'
    scanner = AmountScanner.new(
      "One or two cafés later, a 3-part, 2 1/2 scored 4.5"
    )
    assert_equal " cafés later, a -part,  scored ", scanner.scrub
  end
end
