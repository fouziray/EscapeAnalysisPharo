Class {
	#name : 'InstVarUsageExplorer',
	#superclass : 'Object',
	#instVars : [
		'isAccessed'
	],
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
				escapeStatus ifTrue: [ " does not have accessors "
					m isPrimitive
						ifTrue: [ isAccessed isNil ifTrue: [ isAccessed := true ] ]
						ifFalse: [ isAccessed := false ].
					^ true ] ].
	^ false
]

{ #category : 'accessing' }
InstVarUsageExplorer >> isAccessed [

	^ isAccessed  
]
