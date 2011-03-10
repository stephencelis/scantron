class NumberScanner < Scantron::Scanner
  WORD_MAP = {
    'trillions' => 1_000_000_000_000,
    'trillion'  => 1_000_000_000_000,
    'billions'  => 1_000_000_000,
    'billion'   => 1_000_000_000,
    'millions'  => 1_000_000,
    'million'   => 1_000_000,
    'thousands' => 1_000,
    'thousand'  => 1_000,
    'hundreds'  => 100,
    'hundred'   => 100,
    'ninety'    => 90,
    'eighty'    => 80,
    'seventy'   => 70,
    'sixty'     => 60,
    'fifty'     => 50,
    'forty'     => 40,
    'thirty'    => 30,
    'twenty'    => 20,
    'nineteen'  => 19,
    'eighteen'  => 18,
    'seventeen' => 17,
    'sixteen'   => 16,
    'fifteen'   => 15,
    'fourteen'  => 14,
    'thirteen'  => 13,
    'dozen'     => 12,
    'twelve'    => 12,
    'eleven'    => 11,
    'ten'       => 10,
    'nine'      => 9,
    'eight'     => 8,
    'seven'     => 7,
    'six'       => 6,
    'five'      => 5,
    'four'      => 4,
    'three'     => 3,
    'couple'    => 2,
    'two'       => 2,
    'one'       => 1,
    'halves'    => Rational(1, 2),
    'half'      => Rational(1, 2),
    'thirds'    => Rational(1, 3),
    'third'     => Rational(1, 3),
    'fourths'   => Rational(1, 4),
    'fourth'    => Rational(1, 4),
    'fifths'    => Rational(1, 5),
    'fifth'     => Rational(1, 5),
    'sixths'    => Rational(1, 6),
    'sixth'     => Rational(1, 6),
    'sevenths'  => Rational(1, 7),
    'seventh'   => Rational(1, 7),
    'eighths'   => Rational(1, 8),
    'eighth'    => Rational(1, 8),
    'zero'      => 0
  }

  words = WORD_MAP.keys.map { |v| v.sub(/y$/, 'y-?') } * '|'
  human = %r{(?:a )?(?:\b(?:#{words}))(?: ?\b(?:#{words}|an?d?)\b)*}i
  rule :human, human do |r|
    human_to_number r.to_s
  end

  #-
  # This catches, perhaps, too many edge cases. Simplify.
  #+
  def self.human_to_number input
    input   = input.split(/\W+/)
    numbers = input.map { |w| WORD_MAP[w.downcase] || w }

    case numbers.count { |n| n.is_a? Numeric }
      when 0 then false
      when 1 then numbers.find { |n| n.is_a? Numeric }
    else
      array = []
      total = 0
      limit = 1
      words = []
      reset = true

      numbers.each.with_index do |n, i|
        words << n and next if n.is_a?(String)

        if n == 1 && limit == 1
          reset = false
          next
        end

        if n >= 1_000
          total += n * limit
          limit = 1
          reset = true
        else
          if n < 1
            if words.join(' ') =~ /\band\b/
              if total > 0 && total % 1_000
                if total % (factor = 10 ** (total.to_i.to_s.size - 1)) == 0
                  limit = n * factor
                else
                  limit = n
                end
              else
                limit += n
              end
            else
              limit *= n
            end
          elsif words.join(' ') =~ /\band\b/ && numbers[i + 1].to_i < 1
            total += limit
            limit = n
          elsif !reset && limit >= 1 &&
            m1 = (n > (m2 = numbers[i + 1].to_i) ? n + m2 : n) and
            m = [limit, m1].sort and
            !m[1].to_s[-(m0 = m[0].to_i.to_s.size), m0].to_i.zero?

            if limit == 2 && input[i] == 'dozen'
              limit *= n
            else
              array << total + limit
              total = 0
              limit = n
            end
          elsif !reset && limit == 1 && n > numbers[i + 1].to_i &&
            m = [limit, n + numbers[i + 1].to_i].sort and
              !m[1].to_s[-(m[0].to_i.to_s.size), m[0].to_i.to_s.size].to_i.zero?

            array << total + limit
            total = 0
            limit = n
          else
            n > limit ? limit *= n : limit += n
          end

          total += limit if numbers[i + 1].nil?
          reset = false
        end

        words.clear
      end

      array.empty? ? total : array << total
    end
  end

  # Only covers whole numbers from "zero" to "ninety-nine".
  def self.number_to_human number
    return number unless number >= 0 && number < 100
    inverted_word_map = WORD_MAP.invert
    return inverted_word_map[number].dup if number < 20 || (number % 10).zero?

    human = []
    human.unshift inverted_word_map[remainder = number % 10]
    human.unshift inverted_word_map[number - remainder]
    human.join '-'
  end

  rule :rational, %r{([-+])?(\d+ )?(\d*\.?\d+/\d*\.?\d+)} do |r|
    if r.length != r.scanner.matched_size
      parse r.to_s
    else
      "#{r.scanner[1]}#{r.scanner[3]}".to_r + r.scanner[2].to_i
    end
  end

  int = /\d+(?:,?\d+)*/ # Could be stricter with delimiter matching...
  pre = %r{(?<![,.]|\d|\d/|/\d)[-+]?}
  rule :float, %r{#{pre}#{int}?\.\d+(?![,./]\d)} do |r|
    r.to_s.gsub(/,/, '').to_f
  end

  rule :integer, %r{#{pre}#{int}(?!#{int}?[,./]\d| ?\d+/\d+)} do |r|
    r.to_s.gsub(/,/, '').to_i
  end
end
