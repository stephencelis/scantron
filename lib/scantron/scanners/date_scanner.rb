require 'scantron'
require 'date'

class DateScanner < Scantron::Scanner
  days    = Date::DAYNAMES * '|'
  days   << "|(?:#{Date::ABBR_DAYNAMES * '|'})\\b\\.?"

  months  = Date::MONTHNAMES.compact * '|'
  months << "|(?:#{Date::ABBR_MONTHNAMES.compact * '|'})\\b\\.?"

  human = /\b(?:(#{days}),? )?\b(#{months})( \d{1,2}\b,?)?( \d{2,4})?/i
  rule :human, human do |r|
    Date.parse r.to_s
  end

  rule :iso8601, /\b\d{4}-\d{2}-\d{2}\b/ do |r|
    Date.parse r.to_s
  end
end
