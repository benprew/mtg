require 'mtg/dataset'

describe Dataset do

  before(:each) do
    @data = Dataset.new( [:head1, :header2 ], [ { :head1 => 0, :head2 => 1 }, { :head1 => 2, :head2 => 3} ] )
  end

  it "renders to google dataTable" do
    as_data_table = @data.to_table

    as_data_table.should match(/<div id='#{@data.object_id}'><\/div>/)
    as_data_table.should match(/new google.visualization.DataTable/)
    as_data_table.should match(/table.draw\(data, \{.*"showRowNumber":true/)
    as_data_table.should match(/"name":"head1".*"name":"header2"/)
    as_data_table.should match(/"rows":.*"v":0.*"v":2/)
  end

  it "overrides table defaults correctly" do
    as_data_table = @data.to_table(:showRowNumber => false)

    as_data_table.should match(/table.draw\(data, \{.*"showRowNumber":false/)
  end


  it "renders to google visualization LineChart" do
    line_chart = @data.to_line_chart()

    line_chart.should match(/<div id='#{@data.object_id}'><\/div>/)
    line_chart.should match(/new google.visualization.LineChart/)
    line_chart.should match(/chart.draw\(data, \{.*"height":300/)
    line_chart.should match(/"name":"head1".*"name":"header2"/)
    line_chart.should match(/"rows":.*"v":0.*"v":2/)
  end

  it "overrides chart defaults correctly" do
    line_chart = @data.to_line_chart(:height => 400)

    line_chart.should match(/chart.draw\(data, \{.*"height":400/)
  end
end
