Class {
	#name : 'TrackedVariable',
	#superclass : 'TrackedVariablesAsSet',
	#instVars : [
		'type',
		'name',
		'escapeStatus',
		'referencedTrackedVariables',
		'trackedVarsReferencingSelf',
		'associatedMethod'
	],
	#category : 'EscapeAnalysisXP-Core',
	#package : 'EscapeAnalysisXP',
	#tag : 'Core'
}

{ #category : 'accessing' }
TrackedVariable >> addReferenceToTrackedVariable: aReferencedTrackedVariable [

	referencedTrackedVariables add: aReferencedTrackedVariable
]

{ #category : 'accessing' }
TrackedVariable >> associatedMethod [

	^ associatedMethod
]

{ #category : 'accessing' }
TrackedVariable >> associatedMethod: aMethod [

	associatedMethod := aMethod
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
	referencedTrackedVariables := OrderedCollection new.
	trackedVarsReferencingSelf := OrderedCollection new
]

{ #category : 'accessing' }
TrackedVariable >> markEscaped [

	escapeStatus ifFalse: [
		self escapeStatus: true.
		referencedTrackedVariables do: [ :each | each markEscaped ].
		trackedVarsReferencingSelf do: [ :each | each markEscaped ] ].
	
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
TrackedVariable >> referencedByTV: aTV [

	trackedVarsReferencingSelf add: aTV
]

{ #category : 'as yet unclassified' }
TrackedVariable >> referencesTV: aColOfTv [

	aColOfTv isCollection
		ifTrue: [
			
			referencedTrackedVariables addAll: aColOfTv.
			self type: ((aColOfTv select: #hasType) ifNotEmpty:  [ :e | e first type] ifEmpty: nil) .
			aColOfTv do: [ :each | each referencedByTV: self ] ]
		ifFalse: [
			referencedTrackedVariables add: aColOfTv.
			aColOfTv referencedByTV: self ]
]

{ #category : 'accessing' }
TrackedVariable >> referencesTrackedVariable: aTrackedVariable [

	| doesReference |
	doesReference := referencedTrackedVariables includes:
		                 aTrackedVariable.
	doesReference
		ifTrue: [ ^ true ]
		ifFalse: [
			referencedTrackedVariables do: [ :trackedVar |
				doesReference ifFalse: [
					doesReference := trackedVar referencesTrackedVariable:
						                 aTrackedVariable ] ] ].

	^ doesReference
]

{ #category : 'as yet unclassified' }
TrackedVariable >> trackedVarsReferencingSelf [

	^ trackedVarsReferencingSelf
]

{ #category : 'testing' }
TrackedVariable >> type [

	^ type
]

{ #category : 'testing' }
TrackedVariable >> type: aClass [

	type := aClass
]
