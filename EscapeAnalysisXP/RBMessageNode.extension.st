Extension { #name : 'RBMessageNode' }

{ #category : '*EscapeAnalysisXP' }
RBMessageNode >> treatNode: escapeAnalyzer [

	self receiver isTempVariable ifTrue: [
		(escapeAnalyzer isTrackedTempVariable: self receiver) ifTrue: [
			escapeAnalyzer addMethodsToWorkList: self selector implementors ] ].

	self isUnary ifTrue: [ ^ self ].

	self arguments do: [ :arg |
		(arg isLiteralNode not and: [ escapeAnalyzer isTrackedTempVariable: arg ]) ifTrue: [
			escapeAnalyzer addMethodsToWorkList: self selector implementors ] ]
]
