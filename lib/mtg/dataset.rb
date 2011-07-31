require 'rubygems'
require 'mtg/headers'
require 'json'

class Dataset

  attr_accessor :header

  def initialize(header, rows)
    @decorators = {}
    @header_orig = header
    @rows_orig = rows
    _rebuild_dataset(header, rows)
  end

  def rows
    @rows_decorated
  end

  def _rebuild_dataset(header, rows)
    @header = []
    @rows_undecorated = []

    header.each { |h| @header << Headers.find(h) }

    rows.each do |row|
      myrow = {}
      @header.each do |h|
        value = _is_object_row?(h, row) ? _build_object_row(h, row) : _build_struct_row(h, row)
        myrow[ h[:name] ] = value
      end
      @rows_undecorated << myrow
    end
    @rows_decorated = @rows_undecorated
  end

  def _decorate_dataset
    @rows_decorated = []
    @rows_undecorated.each do |row|
      decorated_row = {}
      decorated_row.replace(row)
      @decorators.each do |field, func_list|
        decorated_row[field] = func_list.inject(row[field]) { |r, f| f.call(r, row) }
      end
      @rows_decorated << decorated_row
    end
  end

  def _is_object_row?(header, row)
    row.class != Hash
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

  def to_line_chart(options={})
    options = { :height => 300, :legend => :bottom }.merge(options)
    
    return %Q{
          <div id='#{self.object_id}'></div>
          <script type="text/javascript">
            var data = new google.visualization.DataTable(#{to_data_table()});
            var chart = new google.visualization.LineChart(document.getElementById('#{self.object_id}'));
            chart.draw(data, #{JSON.generate(options)});
          </script>
}
  end

  def to_table(options={})
    options = { :allowHtml => true, :showRowNumber => true }.merge(options)

    return %Q{
<div class="report">
  <div class="ds_header">#{options[:title]}</div>
    <div id='#{self.object_id}'></div>
    <script type="text/javascript">
      var data = new google.visualization.DataTable(#{to_data_table()});
      for(var i = 0; i < data.getNumberOfColumns(); i++) {
        if( data.getColumnLabel(i).match(/_no$/) ) {
          data.removeColumn(i);
        }
      }
      var table = new google.visualization.Table(document.getElementById('#{self.object_id}'));
      table.draw(data, #{JSON.generate(options)});
    </script>
</div>
}
  end

  def to_data_table
    json_format = Hash.new

    json_format = { :cols => [], :rows => [] }
    json_format[:cols] = @header.map do |h|
      { :label => h[:title], :name => h[:name], :type => h[:type] }
    end

    @rows_decorated.each do |row|
      row2 = @header.map { |col| { :v => row[col[:name].to_sym] } }
      json_format[:rows] << { :c => row2 }
    end
    return JSON.generate(json_format)
  end

end
