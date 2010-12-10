require 'scantron'
require 'range_scanner'
require 'test/unit'

class TestRangeScanner < Test::Unit::TestCase
  def test_scans_shared_company
    { 'one and a half to two' => [Rational(3, 2)..2],
      '1-2'                   => [1..2],
      '1.5-2.0'               => [1.5..2.0],
      '1 1/2-2 1/2'           => [Rational(3, 2)..Rational(5, 2)]
    }.each do |string, expectation|
      assert_equal expectation, RangeScanner.scan(string)
    end
  end

  def test_scans_mixed_company
    { 'from one to 100'       => [1..100],
      '1 - 1.5'               => [1..1.5],
      '2 1/2 or 3'            => [Rational(5, 2)..3],
      'between seven and 10'  => [7..10]
    }.each do |string, expectation|
      assert_equal expectation, RangeScanner.scan(string)
    end
  end

  def test_scans_min_to_max
    assert_equal [], RangeScanner.scan("4 or 3 people")
  end
end
