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

{ #category : 'to remove as soon as possible' }
EAMethodContext >> nextMethod [

	^ eaContext nextMethod
]

{ #category : 'to remove as soon as possible' }
EAMethodContext >> workingList [

	^ eaContext workingList
]

{ #category : 'to remove as soon as possible' }
EAMethodContext >> workingListIndex [

	^ eaContext workingListIndex
]
