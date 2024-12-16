Extension { #name : 'ASTReturnNode' }

{ #category : '*EscapeAnalysisXP' }
ASTReturnNode >> escapeAnalyzeNode: escapeAnalyzer [

	| returnsThisVar |
	returnsThisVar := nil.
	self children do: [ :node |
		(node isVariable and: [
			 (escapeAnalyzer currentMethodIsReturned or: [
				  self allParents anySatisfy: #isBlock ]) and: [
				 escapeAnalyzer isTrackedNode: node ] ])
			ifTrue: [
				returnsThisVar := node variable name.
				escapeAnalyzer currentMethodIsReturned ifTrue: [
					escapeAnalyzer markVariableAsEscaped: node variable
					"Further checks to allow for returned variables in case of local senders." ] ]
			ifFalse: [ node escapeAnalyzeNode: escapeAnalyzer ] ].

	^ returnsThisVar
]

{ #category : '*EscapeAnalysisXP' }
ASTReturnNode >> treatNode2: escapeAnalyzer [

	self children do: [ :node |
		node isVariable
			ifTrue: [
				(escapeAnalyzer isTrackedNode: node) ifTrue: [
					escapeAnalyzer markVariableAsEscaped: node ] ]
			ifFalse: [ node treatNode2: escapeAnalyzer ] ]
]

{ #category : '*EscapeAnalysisXP' }
ASTReturnNode >> treatNode: escapeAnalyzer [

	self children do: [ :node |
		node isVariable
			ifTrue: [
				(escapeAnalyzer isTrackedNode: node) ifTrue: [
					escapeAnalyzer markVariableAsEscaped: node ] ]
			ifFalse: [ node treatNode: escapeAnalyzer ] ]
]

{ #category : '*EscapeAnalysisXP' }
ASTReturnNode >> treatNode: escapeAnalyzer given: trackedVariablesTable [

	| returnsThisVar |
	returnsThisVar := nil.
	self children do: [ :node |
		(node isVariable and: [
			 (escapeAnalyzer currentMethodIsReturned or: [
				  self allParents anySatisfy: #isBlock ]) and: [
				  escapeAnalyzer checkNode: node trackedIn: trackedVariablesTable ] ])
			ifTrue: [
				returnsThisVar := node variable name.
				(escapeAnalyzer currentMethodIsReturned ) ifTrue: [
					escapeAnalyzer
						markEscaped: node variable name
						inTable: trackedVariablesTable "Further checks to allow for returned variables in case of local senders." ] ]
			ifFalse: [
			node treatNode: escapeAnalyzer given: trackedVariablesTable ] ].

	^ returnsThisVar
]
