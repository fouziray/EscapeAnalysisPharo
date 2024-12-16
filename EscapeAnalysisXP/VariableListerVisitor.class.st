Class {
	#name : 'VariableListerVisitor',
	#superclass : 'ASTProgramNodeVisitor',
	#instVars : [
		'variables'
	],
	#category : 'EscapeAnalysisXP-Core',
	#package : 'EscapeAnalysisXP',
	#tag : 'Core'
}

{ #category : 'initialization' }
VariableListerVisitor >> initialize [ 

	super initialize. 
	variables := Set new. 
]

{ #category : 'initialization' }
VariableListerVisitor >> variables [

	^ variables
]

{ #category : 'initialization' }
VariableListerVisitor >> visitVariableNode: aNode [

	variables add: aNode.
]
