Class {
	#name : 'ReferencingTest',
	#superclass : 'TestCase',
	#instVars : [
		'escapeAnalyzer'
	],
	#category : 'EscapeAnalysisXP',
	#package : 'EscapeAnalysisXP'
}

{ #category : 'running' }
ReferencingTest >> setUp [

	super setUp.
	escapeAnalyzer := EscapeAnalyzerVisitor new.

	" the default allowed depth is 6 to avoir loops, but could be extended after"

	escapeAnalyzer allowedDepth: 6
]

{ #category : 'tests' }
ReferencingTest >> testInlinedCandidateReferences [
	"escapeAnalyzer := EscapeAnalyzer new."

	| objInliner method candidates |
	objInliner := ObjectInlining new.
	objInliner allowedDepth: 8.
	method := FixtureEscapeAnalysis >> #foo:.
	candidates := objInliner findCandidatesOf: method.
	1 halt.
	objInliner escapeAnalyzer
]
