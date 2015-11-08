Pod::Spec.new do |s|
  s.name              = "Money"
  s.version           = "1.2.0"
  s.summary           = "Swift types for working with Money."
  s.description       = <<-DESC
  
  Money is a Swift cross platform framework for iOS, watchOS, tvOS and OS X. 
  
  It provides types and functionality to help represent and manipulate money 
  and currency related information.

                       DESC
  s.homepage          = "https://github.com/danthorpe/Money"
  s.license           = 'MIT'
  s.author            = { "Daniel Thorpe" => "@danthorpe" }
  s.source            = { :git => "https://github.com/danthorpe/Money.git", :tag => s.version.to_s }
  s.module_name       = 'Money'
  s.social_media_url  = 'https://twitter.com/danthorpe'
  s.requires_arc      = true
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
  s.source_files      = ['Money/*.swift', 'Money/Decimal/*.swift', 'Money/FX/*.swift']
  
  s.dependency 'ValueCoding'
  s.dependency 'Result', '0.6.0-beta.6'
  s.dependency 'SwiftyJSON'    
end

