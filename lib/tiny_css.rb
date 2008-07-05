Dir.glob(File.join(File.dirname(__FILE__), 'tiny_css/**/*.rb')).sort.
  each { |lib| require lib }

module TinyCss
  class Error < StandardError; end

  def self.new
    TinyCss::Base.new
  end
end
