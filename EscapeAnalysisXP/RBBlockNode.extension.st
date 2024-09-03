Extension { #name : 'RBBlockNode' }

{ #category : '*EscapeAnalysisXP' }
RBBlockNode >> treatNode: escapeAnalyzer [

	self body children do: [ :child | child treatNode: escapeAnalyzer ]
]
