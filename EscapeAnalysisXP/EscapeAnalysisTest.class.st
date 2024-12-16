Class {
	#name : 'EscapeAnalysisTest',
	#superclass : 'TestCase',
	#instVars : [
		'escapeAnalyzer'
	],
	#category : 'EscapeAnalysisXP-OldTests',
	#package : 'EscapeAnalysisXP',
	#tag : 'OldTests'
}

{ #category : 'running' }
EscapeAnalysisTest >> setUp [

	super setUp.
	escapeAnalyzer := EscapeAnalyzer1 new
]

{ #category : 'tests' }
EscapeAnalysisTest >> test2ReturnedTempVarEscapedWithDifferentArgName [

	escapeAnalyzer := EscapeAnalyzer1 new.
	escapeAnalyzer analyze: FixtureEscapeAnalysis >> #callMethodWithDifferentArgName.
	self assert: (escapeAnalyzer variablesTable at: #h).
]

{ #category : 'tests' }
EscapeAnalysisTest >> testArgBlockReturnsTemp [
 
	escapeAnalyzer := EscapeAnalyzer1 new.
	escapeAnalyzer analyze: FixtureEscapeAnalysis >> #usedBlockReturnsTemp.
	self assert: (escapeAnalyzer variablesTable at: #tempo).
	
]

{ #category : 'tests' }
EscapeAnalysisTest >> testMethod [

	escapeAnalyzer := EscapeAnalyzer1 new.
	escapeAnalyzer analyze: FixtureEscapeAnalysis >> #method.
	self assert: (escapeAnalyzer variablesTable at: #a)
]

{ #category : 'tests' }
EscapeAnalysisTest >> testObjectEscaped [

	escapeAnalyzer analyze: FixtureEscapeAnalysis >> #objectEscaped.
	self assert: (escapeAnalyzer variablesTable at: #xx)
]

{ #category : 'tests' }
EscapeAnalysisTest >> testReturnTempInBlock [

	escapeAnalyzer analyze: FixtureEscapeAnalysis >> #notUsedBlockReturnsTemp.
	self deny: (escapeAnalyzer variablesTable at: #tempo)
]

{ #category : 'tests' }
EscapeAnalysisTest >> testReturnedTempVarEscaped [

	escapeAnalyzer := EscapeAnalyzer1 new.
	escapeAnalyzer analyze: FixtureEscapeAnalysis >> #foo:.
	self deny: (escapeAnalyzer variablesTable at: #point1).
	self assert: (escapeAnalyzer variablesTable at: #line)
]

{ #category : 'tests' }
EscapeAnalysisTest >> testReturnedTempVarEscapedWithDifferentArgName [

	escapeAnalyzer := EscapeAnalyzer1 new.
	escapeAnalyzer analyze: FixtureEscapeAnalysis >> #callMethodWithDifferentArgName.
	self assert: (escapeAnalyzer variablesTable at: #h).
]

{ #category : 'tests' }
EscapeAnalysisTest >> testReturnedTempVarEscapedWithDifferentArgNameTwoLevelIndirection [

	escapeAnalyzer := EscapeAnalyzer1 new.
	escapeAnalyzer analyze: FixtureEscapeAnalysis >> #callMethodWithDifferentArgNameTwoLevelIndirection.
	self assert: (escapeAnalyzer variablesTable at: #h).
]

{ #category : 'tests' }
EscapeAnalysisTest >> testTempInBlock [

	escapeAnalyzer analyze: FixtureEscapeAnalysis >> #notUsedBlockTemp.
	self deny: (escapeAnalyzer variablesTable at: #tempo)
]

{ #category : 'tests' }
EscapeAnalysisTest >> testTempVarAssignedToGlobalEscaped [

	escapeAnalyzer := EscapeAnalyzer1 new.
	escapeAnalyzer analyze: FixtureEscapeAnalysis >> #fooSetToGlobal.
	self assert: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisTest >> testTempVarAssignedToInstEscaped [

	escapeAnalyzer := EscapeAnalyzer1 new.
	escapeAnalyzer analyze: FixtureEscapeAnalysis >> #fooSetToInstance.
	self assert: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisTest >> testTempVarAssignedToTempNotEscaped [

	escapeAnalyzer := EscapeAnalyzer1 new.
	escapeAnalyzer analyze: FixtureEscapeAnalysis >> #fooSetToTemp.
	self deny: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisTest >> testTempVarPassedAsArgNotEscaped [

	escapeAnalyzer analyze: FixtureEscapeAnalysis >> #foo3.
	self deny: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisTest >> testTempVarsNotEscaped [

	escapeAnalyzer := EscapeAnalyzer1 new.
	escapeAnalyzer analyze: FixtureEscapeAnalysis >> #fooNotReturn:.
	self deny: (escapeAnalyzer variablesTable at: #point1).
	self deny: (escapeAnalyzer variablesTable at: #line)
]

{ #category : 'tests' }
EscapeAnalysisTest >> testUpperMostDeclarationName [


]
