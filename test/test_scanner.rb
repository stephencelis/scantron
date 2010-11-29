require 'minitest/autorun'
require 'scantron'

class TestScanner < MiniTest::Unit::TestCase
  class BogusScanner < Scantron::Scanner
    @default = lambda { |r| :default }
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

    assert_equal %(and <i id="1">test</i> the <i id="tests">tests</i>),
      @scanner.scrub { |r|
        %(<i id="#{r.value}">#{r}</i>) unless r.value == :default
      }
    assert_equal 'and', BogusScanner.scrub('and')
  end
end
