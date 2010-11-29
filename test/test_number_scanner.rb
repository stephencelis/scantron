require 'minitest/autorun'
require 'scantron'
require 'number_scanner'

class TestNumberScanner < MiniTest::Unit::TestCase
  def test_converts_words_to_numbers
    { <<STR                      => 234_567_890_123_456,
Two hundred and thirty-four trillion five hundred sixty seven billion eight \
hundred ninety million one hundred twenty three thousand four hundred fifty \
six.
STR
      'one and a half'                => Rational(3, 2),
      'three and a half'              => Rational(7, 2),
      'one half'                      => Rational(1, 2),
      'three halves'                  => Rational(3, 2),
      'one half million'              => 500_000,
      'three half millions'           => 1_500_000,
      'one and a half million'        => 1_500_000,
      'three and a half million'      => 3_500_000,
      'one million and a half'        => 1_500_000,
      'three million and a half'      => 3_500_000,
      'thirty-seven and five eighths' => 37 + Rational(5, 8),
    }.each do |string, expectation|
      assert_equal expectation, NumberScanner.human_to_number(string)
    end
  end

  def test_scans_human_numbers
    { 'thirty-two' => [32],
      'thirty two' => [32]
    }.each do |string, expectation|
      assert_equal expectation, NumberScanner.scan(string)
    end
  end

  def test_scans_rationals
    { '1 1/2'  => [Rational(3, 2)],
      '-3/2'   => [Rational(-3, 2)],
      '1 -1/2' => [1, Rational(-1, 2)]
    }.each do |string, expectation|
      assert_equal expectation, NumberScanner.scan(string)
    end
  end

  def test_scans_floats
    { '-.2' => [-0.2],
      '3.2' => [ 3.2]
    }.each do |string, expectation|
      assert_equal expectation, NumberScanner.scan(string)
    end
  end

  def test_scans_integers
    { '-2' => [-2],
      '32' => [32]
    }.each do |string, expectation|
      assert_equal expectation, NumberScanner.scan(string)
    end
  end

  def test_mixed_company
    str, arr = <<STR, [1, 2, 3, 4.5, 6.7, 8.9, 1, 2, 99, 100]
1, 2, 3. 4.5, 6.7, 8.9. one, two, skip a few, ninety-nine-a-hundred
STR
    assert_equal arr, NumberScanner.scan(str)
  end
end
