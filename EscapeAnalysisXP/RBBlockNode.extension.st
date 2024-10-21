Extension { #name : 'RBBlockNode' }

{ #category : '*EscapeAnalysisXP' }
RBBlockNode >> blockNameTracksVarNamed: aVariableName [

	^ self name , aVariableName
]

{ #category : '*EscapeAnalysisXP' }
RBBlockNode >> treatNode: escapeAnalyzer [

	self body children do: [ :child | child treatNode: escapeAnalyzer ]
]

{ #category : '*EscapeAnalysisXP' }
RBBlockNode >> treatNode: escapeAnalyzer given: trackedVariablesTable [
	" treat following cases:
1- when the value returned is tracked you must follow the blockNode as a variable and see where it is assigned 
2- add track to a variable if it is assigned to a tracked variable

then whenever a variable is escaped this must bubble up until the returned variable in the block node
	"

	| catchReturnedVariableName |
	self body children do: [ :child |
		child isReturn
			ifTrue: [
				catchReturnedVariableName := child
					                             treatNode: escapeAnalyzer
					                             given: trackedVariablesTable.

				catchReturnedVariableName ifNotNil: [
					trackedVariablesTable
						at: (self blockNameTracksVarNamed: catchReturnedVariableName)
						put: catchReturnedVariableName ] ]
			ifFalse: [
			child treatNode: escapeAnalyzer given: trackedVariablesTable ] ]
]
