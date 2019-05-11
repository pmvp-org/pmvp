Pod::Spec.new do |spec|
  spec.name		= 'PMVP'
  spec.version		= '0.4.2'
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
PMVP offers a comprehensive set of components for interacting with collections of 
objects within any arbitrary domain object model. Built on industry standards and
best practices for data persistence, the data layer tools published here represent
a standard API for reading, updating, and deleting data. Moreover, the Provider
architecture aims to define a uniform mechanism for synchronizing data between
local and remote persistent stores, all without sacrificing extensibility.

Beyond the data layer, PMVP aims to wrangle the often complex dance between data
model objects and the UI components displaying information to the user. By adopting
the Reactive Extensions (Rx) design methodology, PMVP enables a unidirectional data
flow all the way from database to UI, ready to react to any user intent.

This project would not be possible without the tireless dedication of the iOS team
at Motiv in 2018. Antony Zhuang, Donny Kuang, and Mimi Chenyao played critical roles
in the success of this effort. In the face of unfamiliar design patterns, with little 
to no exposure to Rx, they were able to adapt, refine, and champion the architecture. 

We are proud of our 4.5 star rating, and we believe it demonstrates the awesome power 
of PMVP.
			DESC
  spec.source		= { :git => 'https://github.com/agoodman/pmvp.git', :tag => spec.version }
  spec.swift_version	= '4.0'
  spec.platform		= :ios
  spec.ios.deployment_target = '8.0'
  spec.ios.source_files	= "PMVP/**/*.{swift}"
  spec.dependency	'RxSwift', '~> 4.0'
end

