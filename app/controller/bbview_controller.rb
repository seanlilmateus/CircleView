class BBViewController < UIViewController
  attr_accessor :data_source
  
  CELL_ID = "cell_id"
  HORIZONTAL_RADIUS_RATIO = 0.8
  HORIZONTAL_TRANSLATION = -105.0

  def viewDidLoad
    super
    self.view.backgroundColor = UIColor.blackColor
    @data_source = []
    
    @main_title = UILabel.alloc.initWithFrame([[20, 39.0],[14, 422]]).tap do |label|
      label.lineBreakMode = UILineBreakModeWordWrap
      label.backgroundColor = UIColor.clearColor
      label.font = UIFont.boldSystemFontOfSize(16)
      label.layer.shadowColor = UIColor.colorWithRed(0.179, green:0.231, blue:0.780, alpha:1.0).CGColor
      label.layer.shadowOffset = CGSizeMake(0.0, 1.0)
      label.textColor = UIColor.colorWithRed(0.186, green:0.483, blue:0.979, alpha:1.0)
      label.numberOfLines = 39
      label.text = "Macruby \n tweets"
    end
    self.view.addSubview(@main_title)
    
    @table_view = UITableView.alloc.initWithFrame(self.view.bounds, style:UITableViewStylePlain).tap do |table|
      table.showsHorizontalScrollIndicator = true
      table.showsVerticalScrollIndicator = true
      table.canCancelContentTouches = true
      table.delaysContentTouches = true
      table.backgroundColor = UIColor.clearColor
      table.separatorColor = UIColor.whiteColor
      table.separatorStyle = UITableViewCellSeparatorStyleNone
      table.bouncesZoom = false
      table.dataSource = self
      table.rowHeight = 60.0
      table.delegate = self
      table.bounces = false
      table.opaque = false
    end
    self.view.addSubview(@table_view)
    
    self.load_data_source
  end
  
  def viewDidAppear
    super
  end
  
  def didReceiveMemoryWarning
    NSLog("Memory Warning")
    super
  end

  def shouldAutorotateToInterfaceOrientation(interface_orientation)
    interface_orientation != UIInterfaceOrientationPortraitUpsideDown
  end
  
  def viewDidAppear(animated)
    super
    self.setupShapeFormationInVisibleCells
  end
  
  # TableView data source
  def numberOfSectionsInTableView table_view
    1
  end
  
  def tableView(table_view, numberOfRowsInSection:section)
    @data_source.count
  end
  
  
  ### BEGIN TABLE SIZE
  # def tableView(table_view, heightForRowAtIndexPath:index_path)
  #   60.0
  # end
  
  # def tableView(table_view, heightForHeaderInSection:section)
  #   22
  # end
  # 
  # def tableView(table_view, heightForFooterInSection:section)
  #   22
  # end
  ##### END TABLE SIZE
  
  def tableView(table_view, cellForRowAtIndexPath:index_path)
    cell = table_view.dequeueReusableCellWithIdentifier(CELL_ID) || 
           BBCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:CELL_ID)
    info = @data_source[index_path.row]
    cell.title_text = info[:title]
    cell.icon = info[:image]
    cell
  end
  
  def scrollViewDidScroll(scroll_view)
    self.setupShapeFormationInVisibleCells
  end
  
  def setupShapeFormationInVisibleCells
    index_paths = @table_view.indexPathsForVisibleRows
    shift = @table_view.contentOffset.y % @table_view.rowHeight
    radius = (@table_view.frame.size.height / 2.0) # 
    xradius = radius
    
    index_paths.each_with_index do |index_path, index|
      cell = @table_view.cellForRowAtIndexPath(index_path)
      frame = cell.frame
      
      y = radius - (index * @table_view.rowHeight)  # ideal yPoint if the scroll offset is zero
      y += shift  # add the scroll offset

      # We can find the x Point by finding the Angle from the Ellipse Equation of finding y
      angle = Math.asinh(y / radius)
      
      x = (xradius * HORIZONTAL_RADIUS_RATIO * Math.cos(angle))
      x += HORIZONTAL_TRANSLATION
      
      frame.origin.x = x
      cell.frame = frame unless x.nan? 
    end
  end
  
  
  def UIGraphicsContextWithSize(size, &block)
    UIGraphicsBeginImageContext(size)
    block[UIGraphicsGetCurrentContext()]
    UIGraphicsEndImageContext()
  end
  
  def load_data_source
    data = NSMutableArray.alloc.initWithContentsOfFile(NSBundle.mainBundle.pathForResource("data", ofType:"plist"))
    
    queue = Dispatch::Queue.concurrent('de.mateus.CircleView.tableview.load_data_source')
    queue.async do
      data.enumerateObjectsWithOptions(NSEnumerationConcurrent, usingBlock:-> data_info,idx, stop do
        info = data_info.mutableCopy
        image = UIImage.imageNamed(info[:image])

        UIGraphicsContextWithSize(image.size) do |context|
          transform = CGAffineTransformConcat(CGAffineTransformIdentity, CGAffineTransformMakeScale(1.0, -1.0))
          transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(0.0, image.size.height))
          CGContextConcatCTM(context, transform)
          CGContextBeginPath(context)
          CGContextAddEllipseInRect(context, CGRectMake(0.0, 0.0, image.size.width, image.size.height))
          CGContextClip(context)
          CGContextDrawImage(context, CGRectMake(0.0, 0.0, image.size.width, image.size.height), image.CGImage)
          info[:image] = UIGraphicsGetImageFromCurrentImageContext()
        end
        
        @data_source << info   
      end)
      
      Dispatch::Queue.main.async do
        @table_view.reloadData
        self.setupShapeFormationInVisibleCells
      end
    end
  end  
end

