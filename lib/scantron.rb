relative_path = File.join File.dirname(__FILE__), 'scantron', 'scanners'
$LOAD_PATH << File.expand_path(relative_path)
require 'scantron/version'
require 'scantron/scanner'

module Scantron
end
