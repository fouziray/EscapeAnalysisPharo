Class {
	#name : 'ObjectToBeInlined',
	#superclass : 'Object',
	#category : 'EscapeAnalysisXP-Fixture',
	#package : 'EscapeAnalysisXP',
	#tag : 'Fixture'
}

{ #category : 'as yet unclassified' }
ObjectToBeInlined >> passSelfToArrayConstructor [

	Array newFrom: { self } asOrderedCollection
]
