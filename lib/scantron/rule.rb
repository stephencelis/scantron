module Scantron
  class Rule < Struct.new :regexp, :block
    def to_s
      regexp.to_s
    end
  end
end
