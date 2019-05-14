Pod::Spec.new do |spec|
  spec.name		= 'PMVPRealm'
  spec.version		= '0.1'
  spec.license		= { :type => 'MIT' }
  spec.homepage		= 'https://github.com/agoodman/pmvp'
  spec.authors		= { 
				'Aubrey Goodman' => 'aubrey.goodman@gmail.com',
				'Antony Chuang' => 'antony.juang@gmail.com',
				'Donny Kuang' => 'jiahekuang@gmail.com',
				'Mimi Chenyao' => 'mimichenyao@gmail.com'
			}
  spec.summary		= 'Reactive data management tooling for iOS'
  spec.description	= <<-DESC
PMVPCoreData delivers Core Data fixture capabilities to enable managed objects to be used with PMVP providers easily.
			DESC
  spec.source		= { :git => 'https://github.com/agoodman/pmvp.git', :tag => spec.version }
  spec.swift_version	= '4.0'
  spec.platform		= :ios
  spec.ios.deployment_target = '9.0'
  spec.ios.source_files	= "PMVPRealm/**/*.{swift}"
  spec.ios.exclude_files= "PMVPRealm/Pods/**"
  spec.dependency	'PMVP'
  spec.dependency	'RxSwift', '~> 4.0'
  spec.dependency	'RealmSwift', '~> 2.0'
end

