module Scantron
  module Version
    MAJOR = 0
    MINOR = 0
    PATCH = 1
    BETA  = 'beta'

    VERSION = [MAJOR, MINOR, PATCH, BETA].compact.join('.').freeze
  end
end
