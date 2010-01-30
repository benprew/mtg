require File.dirname(__FILE__) + '/base'
require 'mtg/dataset'

describe Dataset do
  it "renders to google dataTable" do
    data = Dataset.new( [:head1, :header2 ], [ { :head1 => 0, :head2 => 1 }, { :head1 => 2, :head2 => 3} ] )
    data.to_data_table.should == <<-PART

    <div id='#{data.object_id}'></div>
    <script type="text/javascript">
      data = new google.visualization.DataTable({"cols":[{"type":"string","name":"head1","label":"head1"},{"type":"string","name":"header2","label":"header2"}],"rows":[{"c":[{"v":0},{"v":null}]},{"c":[{"v":2},{"v":null}]}]});
      table = new google.visualization.Table(document.getElementById('#{data.object_id}')) 
      table.draw(data, {allowHtml: true, showRowNumber: true})
    </script>
    PART
  end
end
