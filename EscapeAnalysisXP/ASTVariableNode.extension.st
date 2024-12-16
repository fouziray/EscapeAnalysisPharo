Extension { #name : 'ASTVariableNode' }

{ #category : '*EscapeAnalysisXP' }
ASTVariableNode >> escapeAnalyzeNode: escapeAnalyzer [

	^ self name
]

{ #category : '*EscapeAnalysisXP' }
ASTVariableNode >> treatNode: escapeAnalyzer given: trackedVariablesTable [

 ^ self name
]
