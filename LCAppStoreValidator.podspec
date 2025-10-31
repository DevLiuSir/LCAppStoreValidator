Pod::Spec.new do |spec|

  spec.name           = "LCAppStoreValidator"
  
  spec.version        = "1.0.3"
  
  spec.summary        = "LCAppStoreValidator is a lightweight tool for validating whether a macOS app was installed via the App Store."
  
  spec.description    = <<-DESC
  LCAppStoreValidator is a lightweight tool used to verify whether a macOS or iOS app is installed through the App Store. It supports delaying verification for several days, which is suitable for scenarios such as trial period policies and preventing unofficial distribution.
                   DESC

  spec.homepage       = "https://github.com/DevLiuSir/LCAppStoreValidator"
  
  spec.license        = { :type => "MIT", :file => "LICENSE" }
  
  spec.author         = { "Marvin" => "93428739@qq.com" }
  
  spec.swift_versions = ['5.0']
  
  spec.platform       = :osx

  spec.osx.deployment_target = "10.14"
  
  spec.source         = { :git => "https://github.com/DevLiuSir/LCAppStoreValidator.git", :tag => "#{spec.version}" }

  spec.source_files   = "Sources/LCAppStoreValidator/**/*.{h,m,swift}"
  
  spec.resources      = ['Sources/LCAppStoreValidator/Resources/**/*.{lproj,strings}']
  
end
