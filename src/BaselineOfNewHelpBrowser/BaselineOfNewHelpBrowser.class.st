Class {
	#name : #BaselineOfNewHelpBrowser,
	#superclass : #BaselineOf,
	#category : #BaselineOfNewHelpBrowser
}

{ #category : #baselines }
BaselineOfNewHelpBrowser >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		spec
			package: #'NewTools-NewHelpBrowser'
			with: [ spec requires: #( #'NewTools-HelpTopicBuilder' ) ];
			package: #'NewTools-NewHelpBrowser-Tests' with: [ 
				spec requires:
						#( #'NewTools-NewHelpBrowser' #'NewTools-HelpTopicBuilder' #'NewTools-IconBuilder' ) ];
			package: #'NewTools-HelpTopicBuilder';
			package: #'NewTools-IconBuilder';
			package: #'NewTools-HelpTopicBuilder-Tests'
			with: [ spec requires: #( #'NewTools-HelpTopicBuilder' #'NewTools-IconBuilder') ]].
			
	"spec for: #common do: [ 
		spec
			package: #'NewTools-MDNewHelpBrowser'
			with: [ spec requires: #( #'NewTools-MDHelpTopicBuilder' ) ];
			package: #'NewTools-MDNewHelpBrowser-Tests' with: [ 
				spec requires:
						#( #'NewTools-MDNewHelpBrowser' #'NewTools-MDHelpTopicBuilder' #'NewTools-IconBuilder' ) ];
			package: #'NewTools-MDHelpTopicBuilder';
			package: #'NewTools-IconBuilder';
			package: #'NewTools-MDHelpTopicBuilder-Tests'
			with: [ spec requires: #( #'NewTools-MDHelpTopicBuilder' #'NewTools-IconBuilder' ) ]]"
]
