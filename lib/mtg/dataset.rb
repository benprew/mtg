require 'rubygems'
require 'facets/dictionary'
require 'mtg/headers'
require 'json'

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

  def to_data_table
    json_format = Hash.new

    json_format = { :cols => [], :rows => [] }
    json_format[:cols] = @header.map do |h|
      { :label => h[:title], :name => h[:name], :type => :string }
    end

    @rows.each do |row|
      row2 = @header.map { |col| { :v => row[col[:name].to_sym] } }
      json_format[:rows] << { :c => row2 }
    end
    
    return %Q{
    <div id='#{self.object_id}'></div>
    <script type="text/javascript">
      data = new google.visualization.DataTable(#{JSON.generate(json_format)});
      table = new google.visualization.Table(document.getElementById('#{self.object_id}')) 
      table.draw(data, {allowHtml: true, showRowNumber: true})
    </script>
}
  end
end
