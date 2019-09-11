Pod::Spec.new do |s|
  s.name         = "CDCameraImagePicker"
  s.version      = "0.3"
  s.summary      = "Photos picker"
  s.description  = "Photos picker"
  s.homepage     = "https://github.com/carlos21/CDCameraImagePicker"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Carlos Duclos" => "darkzeratul64@gmail.com" }
  s.social_media_url   = ""
  s.swift_version    = '5.0'
  s.ios.deployment_target = "11.0"
  s.source       = { :git => "git@github.com:carlos21/CDCameraImagePicker.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
end
