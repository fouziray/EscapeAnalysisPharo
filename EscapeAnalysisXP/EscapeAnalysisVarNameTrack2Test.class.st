Class {
	#name : 'EscapeAnalysisVarNameTrack2Test',
	#superclass : 'TestCase',
	#instVars : [
		'escapeAnalyzer',
		'workListReturnStatus'
	],
	#category : 'EscapeAnalysisXP-OldTests',
	#package : 'EscapeAnalysisXP',
	#tag : 'OldTests'
}

{ #category : 'running' }
EscapeAnalysisVarNameTrack2Test >> setUp [

	super setUp.
	escapeAnalyzer := EscapeAnalyzer1 new.
	escapeAnalyzer setWorkListReturnStatus: OrderedCollection new .
	escapeAnalyzer setReturnedFlag: false.
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrack2Test >> testArgBlockReturnsTemp [

	self skip.
	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #usedBlockReturnsTemp.
	self assert: (escapeAnalyzer variablesTable at: #tempo)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrack2Test >> testMethod [

self skip.
	"escapeAnalyzer := EscapeAnalyzer new."
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #method.
	self assert: (escapeAnalyzer variablesTable at: #a)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrack2Test >> testObjectEscaped [

"	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #objectEscaped.
	self assert: (escapeAnalyzer variablesTable at: #xx)"
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrack2Test >> testRecursiveFunction [
	" the analyzer has to hold from pushing the method to the worklist everytime encoutered on a dfs parse "

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #recursiveFunction.
	self deny: (escapeAnalyzer variablesTable at: #FixtureEscapeAnalysis_recursiveFunction_temp)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrack2Test >> testReturnTempInBlock [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #notUsedBlockReturnsTemp.
	self deny: (escapeAnalyzer variablesTable at: #FixtureEscapeAnalysis_notUsedBlockReturnsTemp_tempo)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrack2Test >> testReturnedTempVarEscaped [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #foo:.
	self deny: (escapeAnalyzer variablesTable at: #FixtureEscapeAnalysis_foo:_point1).
	self assert: (escapeAnalyzer variablesTable at: #FixtureEscapeAnalysis_foo:_line)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrack2Test >> testReturnedTempVarEscapedWithDifferentArgName [

	
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #callMethodWithDifferentArgName.
	self assert: (escapeAnalyzer variablesTable at: #h).
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrack2Test >> testReturnedTempVarEscapedWithDifferentArgNameDoesntEscape [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #callMethodWithDifferentArgNameDoesntReturn.
	self deny: (escapeAnalyzer variablesTable at: #h).
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrack2Test >> testReturnedTempVarEscapedWithDifferentArgNameTwoLevelIndirection [

	"escapeAnalyzer := EscapeAnalyzer new."
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #callMethodWithDifferentArgNameTwoLevelIndirection.
	self assert: (escapeAnalyzer variablesTable at: #h).
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrack2Test >> testTempInBlock [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #notUsedBlockTemp.
	self deny: (escapeAnalyzer variablesTable at: #tempo)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrack2Test >> testTempVarAssignedToGlobalEscaped [

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #fooSetToGlobal.
	self assert: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrack2Test >> testTempVarAssignedToGlobalEscapedInScope [

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #fooSetToGlobalInScope.
	self assert: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrack2Test >> testTempVarAssignedToInstEscaped [

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #fooSetToInstance.
	self assert: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrack2Test >> testTempVarAssignedToInstEscapedInScope [

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #fooSetToInstanceInScope.
	self assert: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrack2Test >> testTempVarAssignedToTempNotEscaped [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #fooSetToTemp.
	self deny: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrack2Test >> testTempVarCallingItsMethodEscapes [

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #callToObjectToInlineMethodEscapes.
	self deny: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrack2Test >> testTempVarDoesntEscaped [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #fooDoesNotScape.
	self deny: (escapeAnalyzer variablesTable at: #point1)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrack2Test >> testTempVarPassedAsArgNotEscaped [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #foo3.
	self deny: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrack2Test >> testTempVarsNotEscaped [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #fooNotReturn:.
	self deny: (escapeAnalyzer variablesTable at: #point1).
	self deny: (escapeAnalyzer variablesTable at: #line)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrack2Test >> testVarArgToMessageNotReturned [
	
	"A message call whose direct/indirect parent is not a ReturnNode should not mark its returned variables as ecaping"
"	escapeAnalyzer := EscapeAnalyzer new."
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #noReturnArgumentMessage.
	self deny: (escapeAnalyzer variablesTable at: #p).
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrack2Test >> testVarArgToMessageReturned [
	
	"A message call whose direct/indirect parent is a ReturnNode should mark its returned variables as ecaping"
"	escapeAnalyzer := EscapeAnalyzer new."
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #returnReceiverMessageCallOnSelf.
	self assert: (escapeAnalyzer variablesTable at: #p).
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrack2Test >> testcallTwiceReturnOneDifferentVars [
	
	"A message call whose direct/indirect parent is a ReturnNode should mark its returned variables as ecaping"
	"escapeAnalyzer := EscapeAnalyzer new."
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #callTwiceReturnOneDifferentVars.
	self assert: (escapeAnalyzer variablesTable at: #p).
]
