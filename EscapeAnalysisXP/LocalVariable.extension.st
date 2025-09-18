Extension { #name : 'LocalVariable' }

{ #category : '*EscapeAnalysisXP' }
LocalVariable >> isEscaping [
	^escaping = #escapingRead or: [escaping = #escapingWrite]
]
