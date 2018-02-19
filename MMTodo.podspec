Pod::Spec.new do |s|
  s.name             = 'MMTodo'
  s.version          = '0.1.0'
  s.summary          = 'MMTodo is a crossplatform Todo Manger.'
  s.description      = <<-DESC
MMTodo is a cross platform Todo Manager. It supports both iOS and macOS and saves to a
MySQL Database ( the user will need to have access to their own ). MMTodo with the rights
will create the DB as needed.
                       DESC

  s.homepage         = 'https://github.com/MatthewMerritt/MMTodo'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'MatthewMerritt' => 'matthew.merritt@yahoo.com' }
  s.source           = { :git => 'https://github.com/MatthewMerritt/MMTodo.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.13'

  s.source_files = 'MMTodo/Classes/Common/**/*', 'MMTodo/Classes/MySQLDriver/**/*'
  s.ios.source_files = 'MMTodo/Classes/MMTodo iOS/**/*'
  s.osx.source_files = 'MMTodo/Classes/MMTodo macOS/**/*'

  s.resource = 'MMTodo/Assets/Assets.xcassets'

  s.ios.resource_bundle = { 'MMTodo' => [ 'MMTodo/Assets/MMTodo iOS/**/*' ] }
  s.ios.resource = 'MMTodo/Assets/MMTodo iOS/Storyboard-iOS.storyboard'

  s.osx.resource_bundle = { 'MMTodo' => [ 'MMTodo/Assets/MMTodo macOS/**/*' ] }
  s.osx.resource = 'MMTodo/Assets/MMTodo macOS/MMTodoWindowController.xib', 'MMTodo/Assets/MMTodo macOS/Bar.png', 'MMTodo/Assets/MMTodo macOS/Save.pdf'
end
