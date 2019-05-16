Pod::Spec.new do |spec|
  spec.name		= 'PMVPCoreData'
  spec.version		= '0.5.1'
  spec.license		= { :type => 'MIT' }
  spec.homepage		= 'https://github.com/agoodman/pmvp'
  spec.authors		= { 
				'Aubrey Goodman' => 'aubrey.goodman@gmail.com',
			}
  spec.summary		= 'Core Data fixtures for the PMVP framework'
  spec.description	= <<-DESC
PMVPCoreData delivers Core Data fixture capabilities to enable managed objects to be used with PMVP providers easily.
			DESC
  spec.source		= { :git => 'https://github.com/agoodman/pmvp.git', :tag => spec.version }
  spec.swift_version	= '4.0'
  spec.platform		= :ios
  spec.ios.deployment_target = '9.0'
  spec.ios.source_files	= "PMVPCoreData/**/*.{swift}"
  spec.ios.framework	= 'CoreData'
  spec.dependency	'PMVP'
end

