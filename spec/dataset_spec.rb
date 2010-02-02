require File.dirname(__FILE__) + '/base'
require 'mtg/dataset'

describe Dataset do
  it "renders to google dataTable" do
    data = Dataset.new( [:head1, :header2 ], [ { :head1 => 0, :head2 => 1 }, { :head1 => 2, :head2 => 3} ] )
    as_data_table = data.to_data_table

    as_data_table.should match(/<div id='#{data.object_id}'><\/div>/)
    as_data_table.should match(/new google.visualization.DataTable/)
    as_data_table.should match(/"name":"head1".*"name":"header2"/)
    as_data_table.should match(/"rows":.*"v":0.*"v":2/)
  end
end
