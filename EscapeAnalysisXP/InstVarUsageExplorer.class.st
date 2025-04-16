Class {
	#name : 'InstVarUsageExplorer',
	#superclass : 'Object',
	#category : 'EscapeAnalysisXP-Core',
	#package : 'EscapeAnalysisXP',
	#tag : 'Core'
}

{ #category : 'as yet unclassified' }
InstVarUsageExplorer >> exploreUsersOf: anOCVariableNode startingFrom: anEscapeAnalyzerVisitor [

	| refsToInstVar escVisitor |
	refsToInstVar := RBVariableEnvironment
		                 referencesToInstanceVariable:
		                 anOCVariableNode name asString
		                 in:
		                 anEscapeAnalyzerVisitor context associatedMethod
			                 classBinding value.
	"reuse escape analysis visitor but this time tracking only a single inst var"
	escVisitor := EscapeAnalyzerVisitor new.
	refsToInstVar methods do: [ :m |
			escVisitor escapeAnalyze: m trackingOnly: anOCVariableNode.
			(escVisitor findVariableByNameSymbol: anOCVariableNode name)
				escapeStatus ifTrue: [ ^ true ]. " does not have accessors "  ].
	^ false
]
