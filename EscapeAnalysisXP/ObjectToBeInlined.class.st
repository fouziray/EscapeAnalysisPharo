Class {
	#name : 'ObjectToBeInlined',
	#superclass : 'Object',
	#category : 'EscapeAnalysisXP',
	#package : 'EscapeAnalysisXP'
}

{ #category : 'as yet unclassified' }
ObjectToBeInlined >> aMethodThatPassReceiverToAnotherObject [

	Array newFrom: { self } asOrderedCollection
]
