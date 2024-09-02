Extension { #name : 'RBMessageNode' }

{ #category : '*EscapeAnalysisXP' }
RBMessageNode >> treatNode: escapeAnalyzer [

	| nodesToTreat isRcvrOrArgTracked |
	"Treat only the arguments that are variables and the receiver"
	nodesToTreat := { self receiver } , self arguments.
	isRcvrOrArgTracked := nodesToTreat anySatisfy: [ :e |
		escapeAnalyzer isTrackedNode: e ].
	isRcvrOrArgTracked ifTrue: [
		escapeAnalyzer addMethodsToWorkList: self selector implementors ].

	self arguments
		select: [ :arg | arg isMessage ]
		thenDo: [ :arg | arg treatNode: escapeAnalyzer ]
]
