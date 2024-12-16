Class {
	#name : 'VariableListerTest',
	#superclass : 'TestCase',
	#category : 'EscapeAnalysisXP-Tests',
	#package : 'EscapeAnalysisXP',
	#tag : 'Tests'
}

{ #category : 'tests' }
VariableListerTest >> testVariables [

	| lister |
	lister := VariableListerVisitor new.
	lister visit: (FixtureEscapeAnalysis >> #callMethodWithDifferentArgName) ast.
	self assert: lister variables size equals: 2. 
]
