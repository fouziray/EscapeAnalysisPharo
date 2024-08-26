Class {
	#name : 'EscapeAnalysisTest',
	#superclass : 'TestCase',
	#category : 'EscapeAnalysisXP',
	#package : 'EscapeAnalysisXP'
}

{ #category : 'tests' }
EscapeAnalysisTest >> testAssignmentNodeContainsTempVar [

	| variablesTable escAnalyzer |
	variablesTable := (EscapeAnalyzer >> #foo:) ast body
		                  temporaryVariables.
	escAnalyzer := EscapeAnalyzer new variablesTable: variablesTable.
	self assert: (escAnalyzer isTheReturnReturningTrackedVariable: 
			 (RBParser parseExpression: ' line := line y2: aPoint2 y'))
]

{ #category : 'tests' }
EscapeAnalysisTest >> testMessageNodeContainsTempVar [

	| variablesTable escAnalyzer |
	variablesTable := (EscapeAnalyzer >> #foo:) ast body
		                  temporaryVariables.
	escAnalyzer := EscapeAnalyzer new variablesTable: variablesTable.
	self assert: (escAnalyzer doesMessageRefersToTrackedVariables:
			 (RBParser parseExpression: 'line y2: aPoint2 y'))
]

{ #category : 'tests' }
EscapeAnalysisTest >> testReturnNodeContainsTempVar [

	| variablesTable escAnalyzer |
	variablesTable := (EscapeAnalyzer >> #foo:) ast body
		                  temporaryVariables.
	escAnalyzer := EscapeAnalyzer new variablesTable: variablesTable.
	self assert: (escAnalyzer isTheReturnReturningTrackedVariable: 
			 (RBParser parseExpression: '^ line y2: aPoint2 y'))
]
