require 'mtg/headers'

class Dataset

  attr_accessor :header, :rows, :header_titles

  def initialize(header, rows)
    @header = header
    @header_titles = []
    @header.each do |h|
      hrd = Headers.find(h)
      @header_titles << hrd[:title]
    end
    @rows = []
    p rows
    rows.each do |row|
      myrow = []
      @header.each do |h|
        format_method = Headers.find(h)[:format]
        myrow << format_method.call(row[h.downcase])
      end
      @rows << myrow
    end
  end
end
