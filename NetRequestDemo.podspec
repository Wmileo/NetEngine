Pod::Spec.new do |s|
  s.name         = "NetEngine"
  s.version      = "0.0.5"
  s.summary      = "NetEngine : 网络请求封装"
  s.description  = <<-DESC
					 网络请求封装
                   DESC

  s.homepage     = "https://github.com/Wmileo/NetEngine"
  s.license      = "MIT"
  s.author             = { "leo" => "work.mileo@gmail.com" }

  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/Wmileo/NetEngine.git", :tag => s.version.to_s }
  s.source_files  = "NetRequestDemo/NetEngine/*.{h,m}"
  #s.exclude_files = "Classes/Exclude"
  s.requires_arc = true

  s.dependency 'AFNetworking', '~> 3.0.4'

end
