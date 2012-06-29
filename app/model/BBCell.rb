class BBCell < UITableViewCell
  attr_reader :title_label, :image_layer

  def initWithStyle(style, reuseIdentifier:reuse_identifier)
    super.tap do |cell|
      cell.selectionStyle = UITableViewCellSelectionStyleNone
      cell.contentView.backgroundColor = UIColor.clearColor
      
      # add the image layer
      @image_layer = CALayer.layer.tap do |new_layer|
        new_layer.cornerRadius = 16.0
        new_layer.borderWidth = 4.0
        new_layer.borderColor = UIColor.whiteColor.CGColor
      end
      cell.contentView.layer.addSublayer(@image_layer)
      
      # the title label
      label_frame = [[40.0, 10.0], [self.contentView.bounds.size.width - 44.0, 21.0]]
      @title_label = UILabel.alloc.initWithFrame(label_frame).tap do |label|
        label.backgroundColor = UIColor.clearColor
        label.textColor = UIColor.whiteColor
        label.font = UIFont.fontWithName("Helvetica-Bold", size:14.0)
      end
      cell.contentView.addSubview(@title_label)
    end
  end
  

  def layoutSubviews
    super
    image_y = 4.0
    img_layer_height = (self.bounds.size.height  - 4.0 ).floor
    @image_layer.cornerRadius =  img_layer_height / 2.0
    @image_layer.frame =  [[4.0, image_y], [img_layer_height, img_layer_height]]
    label_frame = [
      [img_layer_height + 10.0, (img_layer_height/2.0 - (21/2.0)).floor + 4.0], 
      [self.contentView.bounds.size.width - img_layer_height + 10.0, 21.0]
    ]
    @title_label.frame = label_frame
  end
  

  def title_text=(new_title)
    @title_label.text = new_title
  end
  

  def icon=(image)
    @image_layer.contents = image.CGImage #unless image.nil?
  end
  

  def setSelected(selected)
    super
  end
  

  def setSelected(selected, animated:animated)
    super
    @image_layer.borderColor = selected ? UIColor.orangeColor.CGColor : UIColor.whiteColor.CGColor
    @title_label.textColor = selected ? UIColor.orangeColor : UIColor.whiteColor
  end
end