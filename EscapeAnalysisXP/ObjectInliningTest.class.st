Class {
	#name : 'ObjectInliningTest',
	#superclass : 'TestCase',
	#instVars : [
		'objInliner'
	],
	#category : 'EscapeAnalysisXP-testInlining',
	#package : 'EscapeAnalysisXP',
	#tag : 'testInlining'
}

{ #category : 'running' }
ObjectInliningTest >> setUp [

	super setUp.
	objInliner := ObjectInlining new.
	"Put here a common initialization logic for tests"
]

{ #category : 'tests' }
ObjectInliningTest >> testHoneyGinger [
 
	| candidates astt compiler method candidatesAssociatedWithTV newMethod|
	objInliner allowedDepth: 8.
	method := HGSimulator class >> #bouncingBalls.
	newMethod :=	objInliner assignObjectCreatedInlineToTmp: method.
		1 halt.
	candidates := objInliner findCandidatesOf: newMethod .
	candidatesAssociatedWithTV := candidates collect: [ :c | c -> (objInliner escapeAnalyzer  findVariableByNameSymbol:  c variable name) ].
	objInliner inlineRefactorCandidateObjects: candidatesAssociatedWithTV in: newMethod.
	self assert: candidatesAssociatedWithTV first key equals: (ASTAssignmentNode
			 variable: (ASTVariableNode named: 'point1')
			 value: (ASTMessageNode
					  receiver: (ASTVariableNode named: 'PointInlined')
					  selector: 'new')).


]

{ #category : 'tests' }
ObjectInliningTest >> testInliningObjectPoint [

	| candidates astt compiler method candidatesAssociatedWithTV|
	objInliner allowedDepth: 8.
	method := FixtureEscapeAnalysis >> #foo:.
	candidates := objInliner findCandidatesOf: method.
	candidatesAssociatedWithTV := candidates collect: [ :c | c -> (objInliner escapeAnalyzer  findVariableByNameSymbol:  c variable name) ].
	1 halt.
	objInliner inlineRefactorCandidateObjects: candidatesAssociatedWithTV in: method.

	self assert: candidatesAssociatedWithTV first key equals: (ASTAssignmentNode
			 variable: (ASTVariableNode named: 'point1')
			 value: (ASTMessageNode
					  receiver: (ASTVariableNode named: 'PointInlined')
					  selector: 'new'))
]

{ #category : 'tests' }
ObjectInliningTest >> testInliningObjectPoint2 [

	| candidates astt compiler method candidatesAssociatedWithTV|
	objInliner allowedDepth: 8.
	method := FixtureEscapeAnalysis >> #fooNotReturn:.
	candidates := objInliner findCandidatesOf: method.
	candidatesAssociatedWithTV := candidates collect: [ :c | c -> (objInliner escapeAnalyzer  findVariableByNameSymbol:  c variable name) ].
	objInliner inlineRefactorCandidateObjects: candidatesAssociatedWithTV in: method.

	self assert: candidatesAssociatedWithTV first key equals: (ASTAssignmentNode
			 variable: (ASTVariableNode named: 'point1')
			 value: (ASTMessageNode
					  receiver: (ASTVariableNode named: 'PointInlined')
					  selector: 'new'))
]

{ #category : 'tests' }
ObjectInliningTest >> testInliningObjectPointUsingVisitor [

	| candidates astt compiler method candidatesAssociatedWithTV|
	objInliner allowedDepth: 8.
	method := FixtureEscapeAnalysis >> #foo:.
	candidates := objInliner findCandidatesOf: method.
	candidatesAssociatedWithTV := candidates collect: [ :c | c -> (objInliner escapeAnalyzer  findVariableByNameSymbol:  c variable name) ].
	objInliner inlineRefactorCandidateObjectsUsingVisitor: candidatesAssociatedWithTV in: method.

	self assert: candidatesAssociatedWithTV first key equals: (ASTAssignmentNode
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
