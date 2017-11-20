Pod::Spec.new do |s|

  s.name         = "KituraKit"
  s.version      = "0.0.1"
  s.summary      = "Allows developers to use Codable protocols in their front and back end applications and use the same code on the front and backend."
  s.homepage     = "https://github.com/IBM-Swift/KituraKit"
  s.license      = { :type => "APACHE 2.0", :file => "LICENSE" }
  s.authors      = { "David Dunn" => "davdunn2@uk.ibm.com" }
  s.platform     = :ios, "11.0"
  s.source       = { :git => "https://github.com/IBM-Swift/KituraKit", :branch => "pod", :submodules => true }
  s.subspec 'KituraContracts' do |kituracontracts|
    kituracontracts.source_files = 'Sources/KituraKit/KituraContracts/*.swift'
  end
  s.subspec 'CircuitBreaker' do |circuitbreaker|
    circuitbreaker.source_files = 'Sources/KituraKit/CircuitBreaker/*.swift'
    circuitbreaker.subspec 'LoggerAPI' do |loggerapi|
       loggerapi.source_files = 'Sources/KituraKit/LoggerAPI/*.swift'
    end
  end
  s.subspec 'SwiftyRequest' do |swiftyrequest|
    swiftyrequest.source_files = 'Sources/KituraKit/SwiftyRequest/*.swift'
    swiftyrequest.subspec 'CircuitBreaker' do |circuitbreaker|
       circuitbreaker.source_files = 'Sources/KituraKit/CircuitBreaker/*.swift'
       circuitbreaker.subspec 'LoggerAPI' do |loggerapi|
          loggerapi.source_files = 'Sources/KituraKit/LoggerAPI/*.swift'
       end
    end
  end
  s.source_files  = "Sources/KituraKit/*.swift"
end
