Extension { #name : 'ASTAssignmentNode' }

{ #category : '*EscapeAnalysisXP' }
ASTAssignmentNode >> treatNode: escapeAnalyzer [

	self variable isTempVariable ifTrue: [ ^ self ].
	self value treatNode: escapeAnalyzer
]
