Extension { #name : 'RBBlockNode' }

{ #category : '*EscapeAnalysisXP' }
RBBlockNode >> blockNameTracksVarNamed: aVariableName [

	^ self asString , aVariableName
]

{ #category : '*EscapeAnalysisXP' }
RBBlockNode >> escapeAnalyzeNode: escapeAnalyzer [
	" treat following cases:
1- when the value returned is tracked you must follow the blockNode as a variable and see where it is assigned 
2- add track to a variable if it is assigned to a tracked variable

then whenever a variable is escaped this must bubble up until the returned variable in the block node
	"

	| catchReturnedVariableName returnValue referencedTrackedVariables trackedBlockNode |
	"dont analyze the code inside too much just check if a variable is sent to it then assume the block as tracked, if so the value is to""escapeAnalyzer analyzeBlockClosure: self inAst: escapeAnalyzer currentMethod ast body ."
	(referencedTrackedVariables := escapeAnalyzer getTVNames select: [
		                               :variable |
		                               self references: variable ])
		ifNotEmpty: [
			trackedBlockNode := escapeAnalyzer trackVariable:
				                    (self "namePrefixedWithClassAndMethod:
					                     escapeAnalyzer"). " later to be corrected to support all path of the method"
			trackedBlockNode referencesTV: referencedTrackedVariables ]

	"
	returnValue := 'self'.

	self body children do: [ :child |
		child isReturn
			ifTrue: [
				catchReturnedVariableName := child
					                             treatNode: escapeAnalyzer
					                             given: trackedVariablesTable.

				catchReturnedVariableName ifNotNil: [
					trackedVariablesTable
						at: (self blockNameTracksVarNamed: catchReturnedVariableName)
						put: catchReturnedVariableName.
					returnValue := catchReturnedVariableName ] ]
			ifFalse: [
				returnValue := child
					               treatNode: escapeAnalyzer
					               given: trackedVariablesTable.
				child isVariable ifFalse: [ returnValue := 'self' ] ] ].

	^ returnValue"
]

{ #category : '*EscapeAnalysisXP' }
RBBlockNode >> name [

	^ self asString
]

{ #category : '*EscapeAnalysisXP' }
RBBlockNode >> namePrefixedWithClassAndMethod: aMethod [

	^ self asString
]

{ #category : '*EscapeAnalysisXP' }
RBBlockNode >> treatNode2: escapeAnalyzer [

	self body children do: [ :child | child treatNode2: escapeAnalyzer ]
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

	| catchReturnedVariableName returnValue referencedTrackedVariables |
	"dont analyze the code inside too much just check if a variable is sent to it then assume the block as tracked, if so the value is to""escapeAnalyzer analyzeBlockClosure: self inAst: escapeAnalyzer currentMethod ast body ."
	
 (referencedTrackedVariables := trackedVariablesTable keys select:[ :variable| self references: variable  ]) ifNotEmpty: [
	trackedVariablesTable
						at: (self namePrefixedWithClassAndMethod: escapeAnalyzer )
						put: referencedTrackedVariables
	].

"
	returnValue := 'self'.

	self body children do: [ :child |
		child isReturn
			ifTrue: [
				catchReturnedVariableName := child
					                             treatNode: escapeAnalyzer
					                             given: trackedVariablesTable.

				catchReturnedVariableName ifNotNil: [
					trackedVariablesTable
						at: (self blockNameTracksVarNamed: catchReturnedVariableName)
						put: catchReturnedVariableName.
					returnValue := catchReturnedVariableName ] ]
			ifFalse: [
				returnValue := child
					               treatNode: escapeAnalyzer
					               given: trackedVariablesTable.
				child isVariable ifFalse: [ returnValue := 'self' ] ] ].

	^ returnValue"
]
