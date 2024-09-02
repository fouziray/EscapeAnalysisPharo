Extension { #name : 'ASTVariableNode' }

{ #category : '*EscapeAnalysisXP' }
ASTVariableNode >> treatArgument: escapeAnalyzer [

	(escapeAnalyzer isTrackedTempVariable: self) ifTrue: [
		escapeAnalyzer markVariableAsEscaped: self ]
]
