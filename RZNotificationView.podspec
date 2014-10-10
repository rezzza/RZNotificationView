Pod::Spec.new do |s|
  s.name         = "RZNotificationView"
  s.version      = "1.1.1"
  s.summary      = "Notifications done right"
  s.description  = "This notification class will allow you to show notification within a context without any effort. You can also just ask to display the notification on controller displayed, all automatically!."
  s.homepage     = "https://github.com/rezzza/RZNotificationView"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Rezzza" => "contact@verylastroom.com" }
  s.source       = { :git => "https://github.com/rezzza/RZNotificationView.git", :tag => "1.1.1" }
  s.platform     = :ios, '7.0'
  s.resource = 'RZNotificationView/Icons/*'
  s.dependency 'MOOMaskedIconView', '>= 0.1.0'
  s.dependency 'PPHelpMe', '>= 1.0.0'

  s.requires_arc = true
  s.source_files = 'RZNotificationView/RZNotificationView/*.{h,m}'
  s.frameworks  = 'QuartzCore', 'AudioToolbox'

end
