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
