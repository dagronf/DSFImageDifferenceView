Pod::Spec.new do |s|
  s.name         = "DSFImageDifferenceView"
  s.version      = "1.0"
  s.summary      = "macOS image differencing view"
  s.description  = <<-DESC
    macOS image differencing view
  DESC
  s.homepage     = "https://github.com/dagronf/DSFImageDifferenceView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Darren Ford" => "dford_au-reg@yahoo.com" }
  s.social_media_url   = ""
  s.osx.deployment_target = "10.12"
  s.source       = { :git => ".git", :tag => s.version.to_s }
  s.source_files  = "DSFImageDifferenceView/*.swift"
  s.frameworks  = "Cocoa"
  s.swift_version = "5.0"
end
