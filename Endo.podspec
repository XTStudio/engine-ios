Pod::Spec.new do |s|

  s.name         = "Endo"
  s.version      = "0.1.2"
  s.summary      = "Endo is a light-weight JavaScript bridge."

  s.description  = <<-DESC
                   Endo is a light-weight JavaScript bridge, helps you export native classes to JSCore.
                   DESC

  s.homepage     = "https://github.com/XTStudio/Endo-iOS"

  s.license      = "MIT"
  
  s.author       = { "PonyCui" => "cuis@vip.qq.com" }
  
  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/XTStudio/Endo-iOS.git", :tag => "#{s.version}" }

  s.source_files  = "Sources", "Sources/*.{h,m}", "Sources/**/*.{h,m}"
  
  s.framework  = "JavaScriptCore"
  
  s.requires_arc = true

  s.dependency "Aspects"
  s.dependency "UULog"

end
