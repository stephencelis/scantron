require 'range_scanner'

# Scans for both numbers and ranges.
class AmountScanner < Scantron::Scanner
  # AmountScanner completely overrides Scantron::Scanner's perform in order to
  # use both NumberScanner's and RangeScanner's perform methods, discarding
  # numbers that occur in ranges.
  def perform
    numbers = NumberScanner.new(string).perform
    ranges  = RangeScanner.new(string).perform
    return numbers if ranges.empty?
    numbers.delete_if { |n| ranges.any? { |r| r.pos[1] >= n.pos[1] } }
    (numbers + ranges).sort
  end
end
