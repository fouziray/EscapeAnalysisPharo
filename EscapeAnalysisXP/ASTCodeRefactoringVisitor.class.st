Class {
	#name : 'ASTCodeRefactoringVisitor',
	#superclass : 'ASTProgramNodeVisitor',
	#instVars : [
		'trackedVariableNames'
	],
	#category : 'EscapeAnalysisXP-testInlining',
	#package : 'EscapeAnalysisXP',
	#tag : 'testInlining'
}

{ #category : 'visiting' }
ASTCodeRefactoringVisitor >> findEnclosingStatementNodeFor: aNode [

	| statementNode sequenceNode |
	statementNode := aNode.

	[ statementNode parent isSequence not ] whileTrue: [
		statementNode := statementNode parent ].

	^ statementNode
]

{ #category : 'initialization' }
ASTCodeRefactoringVisitor >> initialize [ 
	trackedVariableNames := OrderedCollection new.
]

{ #category : 'visiting' }
ASTCodeRefactoringVisitor >> renameArrayNode: anArrayNode [

	
]

{ #category : 'visiting' }
ASTCodeRefactoringVisitor >> renameAssignmentNode: anAssignmentNode [ 
|aNode|
aNode := ASTVariableNode named: #h.
anAssignmentNode replaceWith: aNode.


]

{ #category : 'visiting' }
ASTCodeRefactoringVisitor >> renameBlockNode: ABlockNode [

	
]

{ #category : 'visiting' }
ASTCodeRefactoringVisitor >> renameCascadeNode: aCascadeNode [

]

{ #category : 'visiting' }
ASTCodeRefactoringVisitor >> renameEnglobingErrorNode: anEnglobingErrorNode [
]

{ #category : 'visiting' }
ASTCodeRefactoringVisitor >> renameLiteralNode: aLiteralNode [
]

{ #category : 'visiting' }
ASTCodeRefactoringVisitor >> renameMessageNode: aMessageNode [

 aMessageNode receiver: (aMessageNode receiver refactorInlinedCallSites: self ).
    aMessageNode arguments: (aMessageNode arguments collect: [:each | each refactorInlinedCallSites: self]).
    
    "Check if this node should be replaced"
    ^ (self shouldReplaceNode: aMessageNode)
        ifTrue: [ self replacementForNode: (self findEnclosingStatementNodeFor: aMessageNode) ]
        ifFalse: [ aMessageNode ]
]

{ #category : 'visiting' }
ASTCodeRefactoringVisitor >> renameMethodNode: aMethodNode [

"Visit the method node and its body and change it to include the modified code"
    aMethodNode body: ( aMethodNode body refactorInlinedCallSites: self).
    ^ aMethodNode
]

{ #category : 'visiting' }
ASTCodeRefactoringVisitor >> renamePragmaNode: aPragmaNode [
]

{ #category : 'visiting' }
ASTCodeRefactoringVisitor >> renameProgramNode: aProgramNode [

]

{ #category : 'visiting' }
ASTCodeRefactoringVisitor >> renameReturnNode: aReturnNode [
]

{ #category : 'visiting' }
ASTCodeRefactoringVisitor >> renameSequenceNode: aSequenceNode [

	aSequenceNode statements:
		(aSequenceNode statements collect: [ :each |
			 each refactorInlinedCallSites: self ]).
	^ aSequenceNode
]

{ #category : 'operations' }
ASTCodeRefactoringVisitor >> renamecallSitesOfAst: astClone withArgument: aTrackedVariableOfInlinedClass inlining: inlinedClass inside: containerClass [


	
]

{ #category : 'operations' }
ASTCodeRefactoringVisitor >> replacementForNode: anASTnode [
]

{ #category : 'asserting' }
ASTCodeRefactoringVisitor >> shouldReplaceNode: aMessageNode [

	| messageArguments |
	messageArguments := OrderedCollection withAll: aMessageNode arguments.
	messageArguments add: aMessageNode receiver.

	^ messageArguments anySatisfy: [ :e |
		  e isVariable and: [ self trackedVariablesNames includes: e name ] ]
]

{ #category : 'accessing' }
ASTCodeRefactoringVisitor >> trackedVariablesNames [

	^ trackedVariableNames
]

{ #category : 'accessing' }
ASTCodeRefactoringVisitor >> trackedVariablesNames: aName [

	trackedVariableNames add: aName
]

{ #category : 'visiting' }
ASTCodeRefactoringVisitor >> visitArrayNode: anArrayNode [

	
]
