CELL_ID = "cell id"
describe BBCell do
  before do
    @cell = BBCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:CELL_ID)
  end

  it "has a image layer" do
    @cell.image_layer.class.should.equal CALayer
  end

  it "image layer has a corner raius of 16.0" do
  	@cell.image_layer.cornerRadius.should.equal 16.0
  end

  it "has a title label" do
    @cell.title_label.class.should.equal UILabel
  end

  it "Helvetica-bold is the title label font" do
  	@cell.title_label.font.should.equal UIFont.fontWithName("Helvetica-Bold", size:14.0)
  end

  it "should raise an RuntimeError unrecognized selector sent to instance" do
    lambda { @cell.title_text = 1 }
      .should.raise(RuntimeError)
      .message.should.match(/unrecognized selector sent/)
  end

  it "after layoutSubviews the cell title label width should not be the same" do
    first_frame = @cell.title_label.frame.size.width
    @cell.performSelector("layoutSubviews", withObject:nil, afterDelay:0.1)
     wait 0.2 do
      @cell.title_label.frame.size.width.should.not.be.same_as first_frame
    end
  end
end
