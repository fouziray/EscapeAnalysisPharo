Class {
	#name : 'ImplementorWorkingListProducerTest',
	#superclass : 'TestCase',
	#category : 'EscapeAnalysisXP-Tests',
	#package : 'EscapeAnalysisXP',
	#tag : 'Tests'
}

{ #category : 'tests' }
ImplementorWorkingListProducerTest >> testImplementors [

	| v |
	v := ImplementorWorkingListProducer new.
	v visit: (FixtureEscapeAnalysis >> #callNestedMessages2) ast.
	self assert: v unresolved size equals: 3.

]
