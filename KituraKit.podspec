
Pod::Spec.new do |s|
  s.name        = "IBMSwiftKituraKit"
  s.version     = "0.0.20"
  s.summary     = "KituraKit is a library for making Codable HTTP Requests to a Kitura server"
  s.homepage    = "https://github.com/IBM-Swift/KituraKit"
  s.license     = { :type => "Apache License, Version 2.0" }
  s.author     = "IBM"
  s.module_name  = 'KituraKit'
  s.ios.deployment_target = "10.0"
  s.source   = { :git => "https://github.com/IBM-Swift/KituraKit.git", :tag => s.version }
  s.source_files = "Sources/KituraKit/*.swift"
  s.dependency 'IBMSwiftSwiftyRequest', '~> 1.1'
  s.dependency 'IBMSwiftKituraContracts', '~> 1.0'
end
