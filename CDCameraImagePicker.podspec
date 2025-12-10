Pod::Spec.new do |s|
  s.name         = "CDCameraImagePicker"
  s.version      = "1.8.29"
  s.summary      = "Photos picker"
  s.description  = "This is a Photos picker"
  s.homepage     = "https://github.com/carlos21/CDCameraImagePicker"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Carlos Duclos" => "darkzeratul64@gmail.com" }
  s.swift_version    = '5.0'
  s.ios.deployment_target = "14.0"
  s.source       = { :git => "https://github.com/carlos21/CDCameraImagePicker.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*.{h,m,swift}"
  s.public_header_files = 'Sources/*.h'
  s.resources  = "Sources/images/*"
  s.frameworks  = "Foundation"
end
