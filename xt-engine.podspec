Pod::Spec.new do |s|

  s.name         = "xt-engine"
  s.version      = "0.8.0"
  s.summary      = "xt engine is a light-weight JavaScript bridge."

  s.description  = <<-DESC
                   xt engine is a light-weight JavaScript bridge, helps you export native classes to JavaScriptCore.
                   DESC

  s.homepage     = "https://github.com/xtstudio/engine-ios"

  s.license      = "MIT"
  
  s.author       = { "PonyCui" => "cuis@vip.qq.com" }
  
  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/xtstudio/engine-ios.git", :tag => "#{s.version}" }
  
  s.framework  = "JavaScriptCore"
  
  s.requires_arc = true

  s.dependency "Aspects"

  s.dependency "CocoaLumberjack"

  s.default_subspec = 'core'

  s.subspec 'core' do |c|
    c.source_files  = "Sources", "Sources/*.{h,m}"
  end

  s.subspec 'debugger' do |c|
    c.dependency 'xt-engine/core'
    c.source_files  = "Sources/Debugger Support/*.{h,m}", "Sources/Debugger Support/**/*.{h,m}"
  end

end
