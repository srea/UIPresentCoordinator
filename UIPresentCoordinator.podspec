Pod::Spec.new do |s|
  
    s.name             = 'UIPresentCoordinator'
    s.version          = '0.1'
    s.summary          = 'UIPresentCoordinator'
    s.description      = <<-DESC
    This library manages items that are about to be presented in a queue and displays them on a first-in, first-out basis.
                         DESC
  
    s.homepage         = 'https://github.com/srea/UIPresentCoordinator'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Scalefocus' => 'y@minipro.co' }
    s.source           = { :git => 'https://github.com/srea/UIPresentCoordinator.git', :tag => s.version.to_s }
  
    s.platform     = :ios, "13.0"
    s.swift_version = '5.0'
    s.source_files = 'Sources/**/*'
    
  end