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
EscapeAnalysisTest >> testMethod [

	escapeAnalyzer := EscapeAnalyzer new.
	escapeAnalyzer analyze: FixtureEscapeAnalysis >> #method.
	self assert: (escapeAnalyzer variablesTable at: #a)
]

{ #category : 'tests' }
EscapeAnalysisTest >> testReturnedTempVarEscaped [

	escapeAnalyzer := EscapeAnalyzer new.
	escapeAnalyzer analyze: FixtureEscapeAnalysis >> #foo:.
	self deny: (escapeAnalyzer variablesTable at: #point1).
	self assert: (escapeAnalyzer variablesTable at: #line)
]

{ #category : 'tests' }
EscapeAnalysisTest >> testTempVarAssignedToGlobalEscaped [

	escapeAnalyzer := EscapeAnalyzer new.
	escapeAnalyzer analyze: FixtureEscapeAnalysis >> #foo2.
	self assert: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisTest >> testTempVarPassedAsArgNotEscaped [

	escapeAnalyzer := EscapeAnalyzer new.
	escapeAnalyzer analyze: FixtureEscapeAnalysis >> #foo3.
	self deny: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisTest >> testTempVarsNotEscaped [

	escapeAnalyzer := EscapeAnalyzer new.
	escapeAnalyzer analyze: FixtureEscapeAnalysis >> #fooNotReturn:.
	self deny: (escapeAnalyzer variablesTable at: #point1).
	self deny: (escapeAnalyzer variablesTable at: #line)
]
