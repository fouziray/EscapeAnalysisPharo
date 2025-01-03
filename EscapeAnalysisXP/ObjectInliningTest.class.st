Class {
	#name : 'ObjectInliningTest',
	#superclass : 'TestCase',
	#instVars : [
		'objInliner'
	],
	#category : 'EscapeAnalysisXP',
	#package : 'EscapeAnalysisXP'
}

{ #category : 'running' }
ObjectInliningTest >> setUp [

	super setUp.
	objInliner := ObjectInlining new.
	"Put here a common initialization logic for tests"
]

{ #category : 'tests' }
ObjectInliningTest >> testInliningObjectPoint [

	| candidates astt compiler method |
	objInliner allowedDepth: 8.
	method := FixtureEscapeAnalysis >> #foo:.
	candidates := objInliner findCandidatesOf: method.
	objInliner inlineCandidateObjects: candidates in: method.

	self assert: candidates first equals: (ASTAssignmentNode
			 variable: (ASTVariableNode named: 'point1')
			 value: (ASTMessageNode
					  receiver: (ASTVariableNode named: 'PointInlined')
					  selector: 'new'))
]

{ #category : 'tests' }
ObjectInliningTest >> testMultipleAssignments [

	| isAssignedOrNot |
	isAssignedOrNot := objInliner
		                   isAssignedTwice: 'random'
		                   in: HGSimulator class >> #steampaint.

	self assert: isAssignedOrNot
]

{ #category : 'candidates' }
ObjectInliningTest >> testReturnedAssigment [

	| candidates |
	objInliner allowedDepth: 8.
	candidates := objInliner findCandidatesOf:
		              HGSimulator class >> #lint2000 .

	self assert: candidates first equals: (ASTAssignmentNode
			 variable: (ASTVariableNode named: 'random')
			 value: (ASTMessageNode
					  receiver: (ASTVariableNode named: 'Random')
					  selector: 'new'))
]
