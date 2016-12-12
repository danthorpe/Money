Pod::Spec.new do |s|
  s.name              = "Money"
  s.version           = "2.0.1"
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
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = [
    'Sources/*.swift'
  ]
  
  s.osx.exclude_files = [ 'Sources/ApplePay.swift' ]
  s.watchos.exclude_files = [ 'Sources/ApplePay.swift' ]
  s.tvos.exclude_files = [ 'Sources/ApplePay.swift' ]  
  
  s.dependency 'ValueCoding', '~> 2'

end

