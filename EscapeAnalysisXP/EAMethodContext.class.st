Class {
	#name : 'EAMethodContext',
	#superclass : 'EscapeAnalysisContext',
	#category : 'EscapeAnalysisXP-Core',
	#package : 'EscapeAnalysisXP',
	#tag : 'Core'
}

{ #category : 'as yet unclassified' }
EAMethodContext >> TVNames [

	| col |
	col := super TVNames addAll: eaContext TVNames.

	^ col
]

{ #category : 'as yet unclassified' }
EAMethodContext >> escapeAnalysisContext: anEscapeAnalysisContext [

	eaContext := anEscapeAnalysisContext
]

{ #category : 'as yet unclassified' }
EAMethodContext >> extendWorkinglist: aMethod [

	^ eaContext extendWorkinglist: aMethod
]

{ #category : 'as yet unclassified' }
EAMethodContext >> findVariableByName: aName [

	| node |
	node := super findVariableByName: aName.
	node ifNil: [ ^ eaContext findVariableByName: aName ].
	^ node
]

{ #category : 'as yet unclassified' }
EAMethodContext >> nextMethod [

	^ eaContext nextMethod
]

{ #category : 'accessing' }
EAMethodContext >> workingList [

	^ eaContext workingList
]

{ #category : 'accessing' }
EAMethodContext >> workingListIndex [

	^ eaContext workingListIndex
]
