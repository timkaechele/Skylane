$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "rack/test"
require "simplecov"

SimpleCov.start do 
  add_filter "/test/"
end

require "flung"
require "pry"


require "minitest/autorun"
