Extension { #name : 'OCSequenceNode' }

{ #category : '*EscapeAnalysisXP' }
OCSequenceNode >> allTemporaryVariablesButOnesInBlocks [
	^(self temporaryNames asOrderedCollection)
		addAll: super allTemporaryVariablesButOnesInBlocks;
		yourself
]
