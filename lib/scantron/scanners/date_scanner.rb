require 'scantron'
require 'date'

class DateScanner < Scantron::Scanner
  days    = Date::DAYNAMES
  days   += Date::ABBR_DAYNAMES.compact.map { |name| "#{name}.?" }
  days    = days * '|'

  months  = Date::MONTHNAMES.compact
  months += Date::ABBR_MONTHNAMES.compact.map { |name| "#{name}.?" }
  months  = months * '|'

  rule :human, /(?:#{days},? )?(#{months})( \d{1,2}\b,?)?( \d{2,4})?/i do |r|
    Date.parse r.to_s
  end

  rule :iso8601, /\b\d{4}-\d{2}-\d{2}\b/ do |r|
    Date.parse r.to_s
  end
end
