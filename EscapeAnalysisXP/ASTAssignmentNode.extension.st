Extension { #name : 'ASTAssignmentNode' }

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

{ #category : '*EscapeAnalysisXP' }
ASTAssignmentNode >> treatNode: escapeAnalyzer given: trackedVariablesTable [

	(escapeAnalyzer checkNode: self value trackedIn: trackedVariablesTable )
		ifFalse: [ self value treatNode: escapeAnalyzer given: trackedVariablesTable ]
		ifTrue: [
			self variable isClassVariable ifTrue: [
				escapeAnalyzer markEscaped: self value name inTable: trackedVariablesTable .
				^ self ].
			self variable isInstanceVariable ifTrue: [
				escapeAnalyzer markEscaped: self value name inTable: trackedVariablesTable.
				^ self ].
			self variable isGlobalVariable ifTrue: [
				escapeAnalyzer markEscaped: self value name inTable: trackedVariablesTable.
				^ self ] ]
]
