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

	(escapeAnalyzer
		 checkNode: self value
		 trackedIn: trackedVariablesTable)
		ifFalse: [
			| nameOfReturnedVar |
			nameOfReturnedVar := self value
				                     treatNode: escapeAnalyzer
				                     given: trackedVariablesTable.

			(self value isBlock and: [
				 escapeAnalyzer
					 checkNode: self value
					 trackedIn: trackedVariablesTable ]) ifTrue: [ "(trackedVariablesTable includesKey: self value asString ) ifTrue: [
					trackedVariablesTable
						at: self variable name
						put: nameOfReturnedVar ]"
				(trackedVariablesTable includesKey: self value asString) ifTrue: [
					trackedVariablesTable
						at: self variable name
						put: self value asString ] ] ]
		ifTrue: [
			({ #isClassVariable. #isGlobalVariable. #isInstanceVariable }
				 asOrderedCollection anySatisfy: [ :e | self variable perform: e ])
				ifTrue: [
					escapeAnalyzer
						markEscaped: self value name
						inTable: trackedVariablesTable.
					^ self ] ]
]
