Class {
	#name : 'EscapeAnalysisVarNameTrackTest',
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
EscapeAnalysisVarNameTrackTest >> setUp [

	super setUp.
	escapeAnalyzer := EscapeAnalyzer new.
	escapeAnalyzer setWorkListReturnStatus: OrderedCollection new .
	escapeAnalyzer setReturnedFlag: false.
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> test2ReturnedTempVarEscapedWithDifferentArgName [

	escapeAnalyzer := EscapeAnalyzer new.
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #callMethodWithDifferentArgName.
	self assert: (escapeAnalyzer variablesTable at: #h).
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testArgBlockReturnsTemp [

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #usedBlockReturnsTemp.
	self assert: (escapeAnalyzer variablesTable at: #tempo)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testMethod [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #method.
	self assert: (escapeAnalyzer variablesTable at: #a)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testObjectEscaped [

"	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #objectEscaped.
	self assert: (escapeAnalyzer variablesTable at: #xx)"
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testRecursiveFunction [
	" the analyzer has to hold from pushing the method to the worklist everytime encoutered on a dfs parse "

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #recursiveFunction.
	self deny: (escapeAnalyzer variablesTable at: #temp)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testRepeatedFunctionCall [
	" the analyzer has to hold from pushing the method to the worklist everytime encoutered on a dfs parse "

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #repeatedFunctionCallWithEscapingVars.
	self deny: (escapeAnalyzer variablesTable at: #a)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testRepeatedFunctionCallEscaping [
	" the analyzer has to hold from pushing the method to the worklist everytime encoutered on a dfs parse "

	"However needs to treat the method separately from the context, it must suppose that all arguments are tracked, which may be wrong but that eases the implementation, maybe ?  
"

	self skip.
	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #repeatedFunctionCallWithEscapingVars.
	self assert: (escapeAnalyzer variablesTable at: #a)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testRepeatedFunctionCallNonEscaping [
	" the analyzer has to hold from pushing the method to the worklist everytime encoutered on a dfs parse "

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #repeatedFunctionCallWithEscapingVars.
	self deny: (escapeAnalyzer variablesTable at: #a)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testReturnInDoBlock [

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #repeatedFunctionCallWithEscapingVars.
	self deny: (escapeAnalyzer variablesTable at: #a)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testReturnTempInBlock [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #notUsedBlockReturnsTemp.
	self deny: (escapeAnalyzer variablesTable at: #tempo)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testReturnedTempVarEscaped [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #foo:.
	self deny: (escapeAnalyzer variablesTable at: #point1).
	self assert: (escapeAnalyzer variablesTable at: #line)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testReturnedTempVarEscapedWithDifferentArgName [

	
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #callMethodWithDifferentArgName.
	self assert: (escapeAnalyzer variablesTable at: #h).
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testReturnedTempVarEscapedWithDifferentArgNameDoesntEscape [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #callMethodWithDifferentArgNameDoesntReturn.
	self deny: (escapeAnalyzer variablesTable at: #h).
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testReturnedTempVarEscapedWithDifferentArgNameTwoLevelIndirection [

	"escapeAnalyzer := EscapeAnalyzer new."
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

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #fooSetToGlobal.
	self assert: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testTempVarAssignedToGlobalEscapedInScope [

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #fooSetToGlobalInScope.
	self assert: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testTempVarAssignedToInstEscaped [

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #fooSetToInstance.
	self assert: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testTempVarAssignedToInstEscapedInScope [

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #fooSetToInstanceInScope.
	self assert: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testTempVarAssignedToTempNotEscaped [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #fooSetToTemp.
	self deny: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testTempVarCallingItsMethodEscapes [

	self skip.
	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #callToObjectToInlineMethodEscapes.
	self assert: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testTempVarDoesntEscaped [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #fooDoesNotScape.
	self deny: (escapeAnalyzer variablesTable at: #point1)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testTempVarPassedAsArgNotEscaped [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #foo3.
	self deny: (escapeAnalyzer variablesTable at: #h)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testTempVarsNotEscaped [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #fooNotReturn:.
	self deny: (escapeAnalyzer variablesTable at: #point1).
	self deny: (escapeAnalyzer variablesTable at: #line)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testVarArgToMessageNotReturned [
	
	"A message call whose direct/indirect parent is not a ReturnNode should not mark its returned variables as ecaping"
"	escapeAnalyzer := EscapeAnalyzer new."
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #noReturnArgumentMessage.
	self deny: (escapeAnalyzer variablesTable at: #p).
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testVarArgToMessageReturned [
	"A message call whose direct/indirect parent is a ReturnNode should mark its returned variables as ecaping"

	"	escapeAnalyzer := EscapeAnalyzer new."

	" the called method has two implementations, one that returns the arg, one that doesn't. the expected result should assume the worst."

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #returnReceiverMessageCallOnSelf.
	self assert: (escapeAnalyzer variablesTable at: #p)
]

{ #category : 'tests' }
EscapeAnalysisVarNameTrackTest >> testcallTwiceReturnOneDifferentVars [
	
	"A message call whose direct/indirect parent is a ReturnNode should mark its returned variables as ecaping"
	"escapeAnalyzer := EscapeAnalyzer new."
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #callTwiceReturnOneDifferentVars.
	self assert: (escapeAnalyzer variablesTable at: #p).
]
