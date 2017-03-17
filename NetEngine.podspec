Pod::Spec.new do |s|
  s.name         = "NetEngine"
  s.version      = "1.1.1"
  s.summary      = "NetEngine : 网络请求封装"
  s.description  = <<-DESC
					 针对AFNetworking进行了封装，判断请求返回成功失败，显示对应状态
                   DESC

  s.homepage     = "https://github.com/Wmileo/NetEngine"
  s.license      = "MIT"
  s.author       = { "leo" => "work.mileo@gmail.com" }

  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/Wmileo/NetEngine.git", :tag => s.version.to_s }
  s.dependency 'AFNetworking'
  s.source_files  = "NetRequestDemo/NetEngine/*.{h,m}"
  s.requires_arc = true

  s.frameworks   = 'CoreTelephony'



end
