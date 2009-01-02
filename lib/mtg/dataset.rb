class Dataset

  attr_accessor :header, :rows

  def initialize(header, rows)
    @header = header
    @rows = []
    rows.each do |row|
      myrow = []
      @header.each { |h| myrow << row[h.downcase] }
      @rows << myrow
    end
  end
end
