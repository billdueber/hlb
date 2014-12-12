require 'nokogiri'
require 'zlib'
require 'lc_callnumber'
require_relative 'hlb_normalizer'

class HLBRange
  attr_accessor :range, :components
  def initialize(range, *comps)
    @range = range
    @comps = comps
  end
end


doc = Nokogiri::XML(Zlib::GzipReader.new(File.open('hlb.xml.gz')).read);
subject_nodes = doc.xpath('/hlb/subject');

# Set up a place to store the ranges
ranges = {}
('A'..'Z').each do |letter|
  ranges[letter] = []
end


subject_nodes.each do |s|
  subject_name = s.attr(:name)
  s.xpath('topic').each do |t|
    topic_name = t.attr(:name)
    t.xpath('call-numbers').each do |cnr|
      begin
        start_of_range = LCCallNumber.parse(cnr.attr(:start))
        end_of_range   = LCCallNumber.parse(cnr.attr(:end))
        letter = start_of_range.letters[0]
        sint = HLBNormalizer.lc_to_hlb_int(start_of_range)
        eint = HLBNormalizer.lc_to_hlb_int(end_of_range)
        ranges[letter] << HLBRange.new(sint..eint, subject_name, topic_name)
      rescue => e
        $stderr.puts "Something wrong with #{cnr}: #{e}"
      end
    end
    break
  end
end

      
      
  
