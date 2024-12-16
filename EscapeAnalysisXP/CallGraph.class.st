Class {
	#name : 'CallGraph',
	#superclass : 'Object',
	#instVars : [
		'callGraph',
		'currentCallPosition',
		'trackVariableNameChanges',
		'backTrackCurrentPosition'
	],
	#category : 'EscapeAnalysisXP',
	#package : 'EscapeAnalysisXP'
}

{ #category : 'adding' }
CallGraph >> addCaller: aCaller [

	callGraph add: (Association key: aCaller value: nil).
]

{ #category : 'as yet unclassified' }
CallGraph >> currentCallerCallee [

	^ (callGraph at: currentCallPosition) value
]

{ #category : 'initialization' }
CallGraph >> initialize [

	callGraph := OrderedCollection new.
	 currentCallPosition := 1.
	trackVariableNameChanges := Dictionary new.
]

{ #category : 'testing' }
CallGraph >> isNotEmpty [

	^ callGraph isNotEmpty .
]

{ #category : 'as yet unclassified' }
CallGraph >> nextCall [

	currentCallPosition := currentCallPosition + 1.
	^ [callGraph at: currentCallPosition ] on: SubscriptOutOfBounds  do: [ callGraph last  ]
]

{ #category : 'as yet unclassified' }
CallGraph >> previousCaller [

	| previous |
	backTrackCurrentPosition > 0 ifFalse: [ ^ self ].

	previous := [ (callGraph at: backTrackCurrentPosition) key ]
		            on: SubscriptOutOfBounds
		            do: [ callGraph last key ].
	backTrackCurrentPosition := backTrackCurrentPosition - 1.
	^ previous
]

{ #category : 'as yet unclassified' }
CallGraph >> updateCalledForCaller: aCallerNode with: aCallee [


	callGraph select: [ :edge | edge key = aCallerNode ] thenDo: [ :element | element value ifNil:[ element value: OrderedCollection new  ] ifNotNil: [(element value: element value ) add: aCallee ]] .
]

{ #category : 'as yet unclassified' }
CallGraph >> updateTrackedVariableName: aName with: aNewName [

	trackVariableNameChanges
		at: self currentCallerCallee
		update: [ :v | v add: (Association key: aName value: aNewName) ]
		initial: [
			OrderedCollection newFrom:
				{ (Association key: aName value: aNewName) } ]
]

{ #category : 'as yet unclassified' }
CallGraph >> upperMostDeclarationName: name [

	| upperMostDeclarationOfName continueBackTracking |
	upperMostDeclarationOfName := name.
	backTrackCurrentPosition := currentCallPosition.
	continueBackTracking := true.
	[ continueBackTracking ] whileTrue: [
		(trackVariableNameChanges at: self previousCaller)
			detect: [ :association |
			association key = upperMostDeclarationOfName ]
			ifFound: [ :association |
			upperMostDeclarationOfName := association value ]
			ifNone: [ continueBackTracking := false ].
].

	^ upperMostDeclarationOfName
]
