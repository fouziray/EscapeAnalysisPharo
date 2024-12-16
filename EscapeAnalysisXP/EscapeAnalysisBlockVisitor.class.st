"
We need to make a life out analysis of the block itself
two cases occur : 
	- if it is called inside another block it would require to make a recursive case or at least think of the propagation of the result to the first analyzed block.
	- if the block get passed to a variable, then as argument. we need to track the variable and what happens inside the message.
All of this to know if the block gets resolved using value or other messages that run the block.

	
 
"
Class {
	#name : 'EscapeAnalysisBlockVisitor',
	#superclass : 'Object',
	#instVars : [
		'context'
	],
	#category : 'EscapeAnalysisXP',
	#package : 'EscapeAnalysisXP'
}

{ #category : 'accessing' }
EscapeAnalysisBlockVisitor >> context: anAnalysisContext [

	context := anAnalysisContext
]

{ #category : 'as yet unclassified' }
EscapeAnalysisBlockVisitor >> lifeOutAnalysisInScope: anAst [

	| occurences currentBlock |
	currentBlock := context currentBlock.
	occurences := anAst allChildren select: [ :c | c isBlock ].

	occurences do: [ :o |
		| statementsToLookAt |
		statementsToLookAt := o allParents allButFirst: 2.
		statementsToLookAt reversed do: [ :statement |
			statement lifeOutOfBlock: currentBlock ] ]
]

{ #category : 'visiting' }
EscapeAnalysisBlockVisitor >> visitBlockNode: aBlockNode [
	" visits the block to see its return type, but before that, do a life-out analysis"

	context currentBlock: aBlockNode.
	(self lifeOutAnalysisInScope: context scope) ifTrue: [
		self visitNode: aBlockNode body ]
]

{ #category : 'visiting' }
EscapeAnalysisBlockVisitor >> visitNode: anAst [
	"visit the children of the block but with a different "

	anAst children do: [ :child | child treatNode: self given: context trackedVariablesTable ]
]
