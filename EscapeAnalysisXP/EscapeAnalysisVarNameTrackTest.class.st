Class {
	#name : 'EscapeAnalysisVarNameTrackTest',
	#superclass : 'TestCase',
	#instVars : [
		'escapeAnalyzer'
	],
	#category : 'EscapeAnalysisXP',
	#package : 'EscapeAnalysisXP'
}

{ #category : 'running' }
EscapeAnalysisVarNameTrackTest >> setUp [

	super setUp.
	escapeAnalyzer := EscapeAnalyzer new
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> test2ReturnedTempVarEscapedWithDifferentArgName [

	escapeAnalyzer := EscapeAnalyzer new.
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #callMethodWithDifferentArgName.
	self assert: (escapeAnalyzer variablesTable at: #h).
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testArgBlockReturnsTemp [
 
	escapeAnalyzer := EscapeAnalyzer new.
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #usedBlockReturnsTemp.
	self assert: (escapeAnalyzer variablesTable at: #tempo).
	
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testMethod [

	escapeAnalyzer := EscapeAnalyzer new.
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #method.
	self assert: (escapeAnalyzer variablesTable at: #a)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testObjectEscaped [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #objectEscaped.
	self assert: (escapeAnalyzer variablesTable at: #xx)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testReturnTempInBlock [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #notUsedBlockReturnsTemp.
	self deny: (escapeAnalyzer variablesTable at: #tempo)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testReturnedTempVarEscaped [

	escapeAnalyzer := EscapeAnalyzer new.
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #foo:.
	self deny: (escapeAnalyzer variablesTable at: #point1).
	self assert: (escapeAnalyzer variablesTable at: #line)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testReturnedTempVarEscapedWithDifferentArgName [

	escapeAnalyzer := EscapeAnalyzer new.
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #callMethodWithDifferentArgName.
	self assert: (escapeAnalyzer variablesTable at: #h).
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testReturnedTempVarEscapedWithDifferentArgNameTwoLevelIndirection [

	escapeAnalyzer := EscapeAnalyzer new.
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #callMethodWithDifferentArgNameTwoLevelIndirection.
	self assert: (escapeAnalyzer variablesTable at: #h).
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testTempInBlock [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #notUsedBlockTemp.
	self deny: (escapeAnalyzer variablesTable at: #tempo)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testTempVarAssignedToGlobalEscaped [

	escapeAnalyzer := EscapeAnalyzer new.
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #fooSetToGlobal.
	self assert: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testTempVarAssignedToInstEscaped [

	escapeAnalyzer := EscapeAnalyzer new.
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #fooSetToInstance.
	self assert: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testTempVarAssignedToTempNotEscaped [

	escapeAnalyzer := EscapeAnalyzer new.
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #fooSetToTemp.
	self deny: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testTempVarPassedAsArgNotEscaped [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #foo3.
	self deny: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testTempVarsNotEscaped [

	escapeAnalyzer := EscapeAnalyzer new.
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #fooNotReturn:.
	self deny: (escapeAnalyzer variablesTable at: #point1).
	self deny: (escapeAnalyzer variablesTable at: #line)
]
