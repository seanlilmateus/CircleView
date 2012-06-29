class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launch_opts)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds).tap do |win|
	win.rootViewController = BBViewController.alloc.init 
    	win.makeKeyAndVisible
    end
    true
  end
end