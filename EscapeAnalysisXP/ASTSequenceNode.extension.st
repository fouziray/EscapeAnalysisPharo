Extension { #name : 'ASTSequenceNode' }

{ #category : '*EscapeAnalysisXP' }
ASTSequenceNode >> allTemporaryVariablesButOnesInBlocks [
	^(self temporaryNames asOrderedCollection)
		addAll: super allTemporaryVariablesButOnesInBlocks;
		yourself
]
