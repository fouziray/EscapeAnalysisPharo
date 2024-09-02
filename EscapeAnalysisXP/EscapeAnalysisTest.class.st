Class {
	#name : 'EscapeAnalysisTest',
	#superclass : 'TestCase',
	#instVars : [
		'escapeAnalyzer'
	],
	#category : 'EscapeAnalysisXP',
	#package : 'EscapeAnalysisXP'
}

{ #category : 'tests' }
EscapeAnalysisTest >> testAssignmentNodeContainsTempVar [

	| variablesTable escAnalyzer |
	self skip.
	variablesTable := (EscapeAnalyzer >> #foo:) ast body temporaryVariables.
	escAnalyzer := EscapeAnalyzer new variablesTable: variablesTable.
	self assert: (escAnalyzer isTheReturnReturningTrackedVariable: 
			 (RBParser parseExpression: ' line := line y2: aPoint2 y'))
]

{ #category : 'tests' }
EscapeAnalysisTest >> testFoo [

	escapeAnalyzer := EscapeAnalyzer new.
	escapeAnalyzer analyze: FixtureEscapeAnalysis >> #foo:.
	self deny: (escapeAnalyzer variablesTable at: #point1).
	self assert: (escapeAnalyzer variablesTable at: #line)
]

{ #category : 'tests' }
EscapeAnalysisTest >> testFoo2 [

	escapeAnalyzer := EscapeAnalyzer new.
	escapeAnalyzer analyze: FixtureEscapeAnalysis >> #foo2.
	self assert: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisTest >> testFoo3 [

	escapeAnalyzer := EscapeAnalyzer new.
	escapeAnalyzer analyze: FixtureEscapeAnalysis >> #foo3.
	self deny: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisTest >> testMessageNodeContainsTempVar [

	| variablesTable escAnalyzer |
	self skip.
	variablesTable := (EscapeAnalyzer >> #foo:) ast body
		                  temporaryVariables.
	escAnalyzer := EscapeAnalyzer new variablesTable: variablesTable.
	self assert: (escAnalyzer doesMessageRefersToTrackedVariables:
			 (RBParser parseExpression: 'line y2: aPoint2 y'))
]

{ #category : 'tests' }
EscapeAnalysisTest >> testMethod [

	escapeAnalyzer := EscapeAnalyzer new.
	escapeAnalyzer analyze: FixtureEscapeAnalysis >> #method.
	self assert: (escapeAnalyzer variablesTable at: #a)
]

{ #category : 'tests' }
EscapeAnalysisTest >> testReturnNodeContainsTempVar [

	| variablesTable escAnalyzer |
	self skip.
	variablesTable := (EscapeAnalyzer >> #foo:) ast body
		                  temporaryVariables.
	escAnalyzer := EscapeAnalyzer new variablesTable: variablesTable.
	self assert: (escAnalyzer isTheReturnReturningTrackedVariable: 
			 (RBParser parseExpression: '^ line y2: aPoint2 y'))
]
