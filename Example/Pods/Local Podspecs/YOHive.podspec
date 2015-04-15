#
# Be sure to run `pod lib lint YOHive.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "YOHive"
  s.version          = "0.1.0"
  s.summary          = "A short description of YOHive."
  s.description      = <<-DESC
                       An optional longer description of YOHive

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/<GITHUB_USERNAME>/YOHive"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Brett Hamlin" => "bhamlin@yahoo-inc.com" }
  s.source           = { :path => '/Users/bhamlin/Development/pod/YOHive' }
  #:git => "https://github.com/<GITHUB_USERNAME>/YOHive.git", :tag => s.version.to_s }

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.{h,m,c}'
  s.resources = 'Pod/**/*.{png,xib,fsh,vsh}'
  s.dependency 'BouncerSDK', '~> 0.0.9'
  s.dependency 'Reachability', '~> 3.1.1'
  s.frameworks = ['OpenGLES', 'SystemConfiguration', 'QuartzCore', 'GLKit', 'CoreGraphics']

  # s.public_header_files = 'Pod/Classes/**/*.h'


end
