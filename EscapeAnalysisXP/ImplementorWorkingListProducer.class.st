Class {
	#name : 'ImplementorWorkingListProducer',
	#superclass : 'ASTProgramNodeVisitor',
	#instVars : [
		'implementors',
		'unresolved'
	],
	#category : 'EscapeAnalysisXP-Core',
	#package : 'EscapeAnalysisXP',
	#tag : 'Core'
}

{ #category : 'accessing' }
ImplementorWorkingListProducer >> implementors [
	^ implementors
]

{ #category : 'initialization' }
ImplementorWorkingListProducer >> initialize [ 
	
	super initialize.
	unresolved := Set new. 

]

{ #category : 'accessing' }
ImplementorWorkingListProducer >> unresolved [
	^ unresolved
]

{ #category : 'visiting' }
ImplementorWorkingListProducer >> visitMessageNode: aMessageNode [

	aMessageNode receiver isGlobalVariable
		ifTrue: [ ^ self ] 
		ifFalse: [ 
			unresolved add: aMessageNode. 
			self visitNode: aMessageNode receiver.
			aMessageNode arguments do: [ :each | each isVariable 
				ifFalse: [ unresolved add: aMessageNode. self visitNode: each. ^ self ]]]
	 
	
]
