Pod::Spec.new do |s|
  s.name         = "CDCameraImagePicker"
  s.version      = "0.1"
  s.summary      = ""
  s.description  = "Photos picker"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Carlos Duclos" => "darkzeratul64@gmail.com" }
  s.swift_version = '5.0'
  s.ios.deployment_target = "11.0"
  s.tvos.deployment_target = "9.0"
  s.source = { :git => ".git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
end
