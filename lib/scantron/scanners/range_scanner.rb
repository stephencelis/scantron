require 'number_scanner'

class RangeScanner < Scantron::Scanner
  values = NumberScanner.rules.values_at :human, :rational, :integer, :float
  valued = /#{values.map { |r| r.regexp }.join '|'} ?/
  regexp = /#{NumberScanner.rules[:human].regexp} ?(and|or|to) ?#{valued}/
  rule :range_with_human, regexp do |r|
    range = Range.new *NumberScanner.scan(r.to_s.sub /-/, ' ')
    range.first < range.last ? range : false
  end

  values.delete_at 0
  valued = /(#{values.map { |r| r.regexp }.join '|'} ?)/
  rule :range_without_human, /#{valued} ?(-|and|or|to) ?#{valued}/ do |r|
    range = Range.new *NumberScanner.scan(r.to_s.sub /-/, ' ')
    range.first < range.last ? range : false
  end
end
