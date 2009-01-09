require 'rubygems'
require 'facets/dictionary'
require 'mtg/headers'

class Dataset

  attr_accessor :rows, :header

  def initialize(header, rows)
    @decorators = {}
    @header_orig = header
    @rows_orig = rows
    _rebuild_dataset(header, rows)
  end

  def _rebuild_dataset(header, rows)
    @header = []
    @rows = []

    header.each { |h| @header << Headers.find(h) }

    rows.each do |row|
      myrow = Dictionary.new
      @header.each do |h|
        value = _is_object_row?(h, row) ? _build_object_row(h, row) : _build_struct_row(h, row)
        myrow << [ h[:name], value ]
      end
      @rows << myrow
    end
  end

  def _decorate_dataset
    @rows.each do |row|
      @decorators.each do |header, func_list|
        row[header] = func_list.inject(row[header]) { |r, f| f.call(r, row) }
      end
    end
  end

  def _is_object_row?(header, row)
    row.respond_to?(header[:name])
  end

  def _build_object_row(header, row)
    format_method = header[:format]
    format_method.call(row.send(header[:name]))
  end

  def _build_struct_row(header, row)
    format_method = header[:format]
    format_method.call(row[header[:name]])
  end

  def add_decorator(field, decorate_sub)
    @decorators[field] ||= []
    @decorators[field] << decorate_sub
    _decorate_dataset()
  end
end
