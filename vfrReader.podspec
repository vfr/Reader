Pod::Spec.new do |s|
 s.name = "vfrReader"
 s.version = "2.8.7"
 s.license = "MIT"
 s.summary = "PDF Reader Core for iOS"
 s.homepage = "http://www.vfr.org/"
 s.authors = { "Julius Oklamcak" => "joklamcak@gmail.com" }
 s.source = { :git => "https://github.com/vfr/Reader.git", :tag => "#{s.version}" }
 s.platform = :ios
 s.ios.deployment_target = "6.0"
 s.source_files = "Sources/**/*.{h,m}"
 s.resources = "Graphics/Reader-*.png"
 s.frameworks = "UIKit", "Foundation", "CoreGraphics", "QuartzCore", "ImageIO", "MessageUI"
 s.requires_arc = true
end
