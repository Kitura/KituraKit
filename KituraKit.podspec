
Pod::Spec.new do |s|
  s.name        = "KituraKit"
  s.version     = "0.0.20"
  s.summary     = "Swift client library for using Codable routes with Kitura."
  s.homepage    = "https://github.com/IBM-Swift/KituraKit"
  s.license     = { :type => "Apache License, Version 2.0" }
  s.author     = "IBM"
  s.module_name  = 'KituraKit'
  s.requires_arc = true
  s.osx.deployment_target = "10.11"
  s.ios.deployment_target = "10.0"
  s.tvos.deployment_target = "10.0"
  s.source   = { :git => "https://github.com/IBM-Swift/KituraKit.git", :tag => s.version }
  s.source_files = "Sources/KituraKit/*.swift"
  s.pod_target_xcconfig =  {
        'SWIFT_VERSION' => '4.0.3',
  }
  s.dependency 'SwiftyRequest', '~> 1.0.0'
  s.dependency 'KituraContracts', '~> 0.0.21'
end