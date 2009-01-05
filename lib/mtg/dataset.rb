require 'mtg/headers'

class Dataset

  attr_accessor :rows, :header

  def initialize(header, rows)
    @header = []
    @decorators = {}
    @header_orig = header
    @rows_orig = rows
    _build_dataset()
  end

  def _build_dataset
    @header = []
    @rows = []
    @header_orig.each { |h| @header << Headers.find(h) }

    @rows = []
    @rows_orig.each do |row|
      myrow = []
      @header.each do |h|
        format_method = h[:format]
        value = format_method.call(row[h[:name]])
        if @decorators.has_key?(h[:name])
          value = @decorators[h[:name]].inject(value) { |r, d| d.call(r, row) }
        end
        myrow << value
      end
      @rows << myrow
    end
  end

  def add_decorator(field, decorate_sub)
    @decorators[field] ||= []
    @decorators[field] << decorate_sub
    warn "building dataset"
    _build_dataset()
  end
end
