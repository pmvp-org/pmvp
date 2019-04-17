Pod::Spec.new do |spec|
  spec.name		= 'PMVP'
  spec.version		= '0.1'
  spec.license		= { :type => 'MIT' }
  spec.homepage		= 'https://github.com/agoodman/pmvp'
  spec.authors		= { 'Aubrey Goodman' => 'aubrey.goodman@gmail.com' }
  spec.summary		= 'Reactive data management tooling for iOS'
  spec.source		= { :git => 'https://github.com/agoodman/pmvp.git', :tag => '0.1' }
  spec.swift_version	= '4.0'
  spec.platform		= :ios
  spec.ios.deployment_target = '8.0'
  spec.ios.source_files	= "PMVP/**/*.{swift}"
  spec.dependency	'RxSwift'
end

