Class {
	#name : 'TrackedVariable',
	#superclass : 'TrackedVariablesAsSet',
	#instVars : [
		'type',
		'name',
		'escapeStatus',
		'referencedTrackedVariables'
	],
	#category : 'EscapeAnalysisXP',
	#package : 'EscapeAnalysisXP'
}

{ #category : 'accessing' }
TrackedVariable >> addReferenceToTrackedVariable: aReferencedTrackedVariable [

	referencedTrackedVariables add: aReferencedTrackedVariable
]

{ #category : 'accessing' }
TrackedVariable >> escapeStatus [

	^ escapeStatus
]

{ #category : 'accessing' }
TrackedVariable >> escapeStatus: aBoolean [

	escapeStatus := aBoolean
]

{ #category : 'testing' }
TrackedVariable >> hasType [

	^ type isNotNil
]

{ #category : 'initialization' }
TrackedVariable >> initialize [

	escapeStatus := false.
	referencedTrackedVariables := OrderedCollection new
]

{ #category : 'accessing' }
TrackedVariable >> markEscaped [

	self escapeStatus: true.
	referencedTrackedVariables do: [ :each | each markEscaped ]
]

{ #category : 'accessing' }
TrackedVariable >> name [

	^ name
]

{ #category : 'accessing' }
TrackedVariable >> name: aName [

	name := aName
]

{ #category : 'as yet unclassified' }
TrackedVariable >> referencesTV: aColOfTv [

	aColOfTv isCollection
		ifTrue: [ referencedTrackedVariables addAll: aColOfTv ]
		ifFalse: [ referencedTrackedVariables add: aColOfTv ]
]

{ #category : 'testing' }
TrackedVariable >> type [

	^ type
]
