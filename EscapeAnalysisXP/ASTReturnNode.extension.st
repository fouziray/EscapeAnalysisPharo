Extension { #name : 'ASTReturnNode' }

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
		node isVariable
			ifTrue: [
				(escapeAnalyzer checkNode: node trackedIn: trackedVariablesTable)
					ifTrue: [
						returnsThisVar := node variable name.
						escapeAnalyzer
							markEscaped: node variable name
							inTable: trackedVariablesTable ] ]
			ifFalse: [
			node treatNode: escapeAnalyzer given: trackedVariablesTable ] ].

	^ returnsThisVar
]
