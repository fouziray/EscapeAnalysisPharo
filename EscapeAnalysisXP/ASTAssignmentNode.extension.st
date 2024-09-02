Extension { #name : 'ASTAssignmentNode' }

{ #category : '*EscapeAnalysisXP' }
ASTAssignmentNode >> treatArgument: escapeAnalyzer [
]

{ #category : '*EscapeAnalysisXP' }
ASTAssignmentNode >> treatNode: escapeAnalyzer [

	(escapeAnalyzer isTrackedNode: self value)
		ifFalse: [ self value treatNode: escapeAnalyzer ]
		ifTrue: [
			self variable isClassVariable ifTrue: [
				escapeAnalyzer markVariableAsEscaped: self value.
				^ self ].
			self variable isInstanceVariable ifTrue: [
				escapeAnalyzer markVariableAsEscaped: self value.
				^ self ].
			self variable isGlobalVariable ifTrue: [
				escapeAnalyzer markVariableAsEscaped: self value.
				^ self ] ]
]
