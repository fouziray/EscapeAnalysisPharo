Class {
	#name : 'EscapeTest',
	#superclass : 'TestCase',
	#instVars : [
		'escapeAnalyzer',
		'workListReturnStatus'
	],
	#category : 'EscapeAnalysisXP-Tests',
	#package : 'EscapeAnalysisXP',
	#tag : 'Tests'
}

{ #category : 'running' }
EscapeTest >> setUp [

	super setUp.
	escapeAnalyzer := EscapeAnalyzerVisitor new.
escapeAnalyzer setWorklistLimitation.
	" the default allowed depth is 6 to avoir loops, but could be extended after"

	escapeAnalyzer allowedDepth: 6
]

{ #category : 'tests' }
EscapeTest >> testAppendEscapingVarToCollection [

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #addEscapingVarToTrackedCollection.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #trackedCollection)
			escapeStatus.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #escapingVar) escapeStatus
]

{ #category : 'tests' }
EscapeTest >> testArgBlockReturnsTemp [

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #usedBlockReturnsTemp.
	self assert: (escapeAnalyzer isVariableEscaped: #tempo)
]

{ #category : 'tests' }
EscapeTest >> testAssignObjectToArrayConstructor [

	self flag: #PassingVarToObjectCreation.
	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #assignObjectToArrayConstructor.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #h) escapeStatus
]

{ #category : 'tests' }
EscapeTest >> testCollectionNonEscapingInAIAstar [
	"escapeAnalyzer := EscapeAnalyzer new."

	escapeAnalyzer allowedDepth: 300.
	escapeAnalyzer escapeAnalyze: AIAstar >> #heuristicFrom:to:.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #use) escapeStatus
]

{ #category : 'testRealStuff' }
EscapeTest >> testComplexWeighterGraph [

	self flag: #false.
	self flag: #firstExample.
	escapeAnalyzer allowedDepth: 10000.
	escapeAnalyzer allowedWorklistSize: 100000.
	escapeAnalyzer escapeAnalyze:
		AIAstarTest >> #testComplexWeightedGraph2.
	self deny:
		(escapeAnalyzer findVariableByNameSymbol: #astar) escapeStatus.
			self deny:
		(escapeAnalyzer findVariableByNameSymbol: #graph) escapeStatus
]

{ #category : 'tests - find variable' }
EscapeTest >> testFindVariableNameShouldFindTheVariable [

	| variable |
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #fooSetToGlobal.
	"fooSetToGlobal
		| h |
		h := nil.
		self fooSetterToGlobal: h"
		
	variable := (escapeAnalyzer findVariableByNameSymbol: #h).
	self assert: variable class equals: TrackedVariable.
	self assert: variable escapeStatus.
	
]

{ #category : 'tests - find variable' }
EscapeTest >> testFindVariableNameShouldNotFindTheVariable [

	| variable |
	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #fooSetToGlobal.
	"fooSetToGlobal
		| h |
		h := nil.
		self fooSetterToGlobal: h"

	variable := escapeAnalyzer findVariableByNameSymbol: #hGHHGHH.
	self assert: variable isNil
	"Horrible we should have a NullObject in the future."
]

{ #category : 'tests' }
EscapeTest >> testHGSteamPaint [

	escapeAnalyzer allowedDepth: 6.
	escapeAnalyzer escapeAnalyze: HGSimulator class >> #steampaint.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #simulator) escapeStatus
]

{ #category : 'testRealStuff' }
EscapeTest >> testInsideBranchEscape [

	escapeAnalyzer allowedDepth: 10000.
	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #allocatedReturnInsideBranch.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #temp) escapeStatus
]

{ #category : 'testRealStuff' }
EscapeTest >> testInterScopeIdenticalVarNameConfusion [

	escapeAnalyzer allowedDepth: 10000.
	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #redeclaringVarInDifferentScope. 
	self deny:
		(escapeAnalyzer findVariableByNameSymbol: #temp) escapeStatus.
		
	
]

{ #category : 'tests' }
EscapeTest >> testMethod [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #method.
	self assert: (escapeAnalyzer findVariableByNameSymbol: #a) escapeStatus 
]

{ #category : 'tests' }
EscapeTest >> testNonReturnedTempVarEscapedThreeLevelIndirectionWithHigherDepth [
	"escapeAnalyzer := EscapeAnalyzer new."

	escapeAnalyzer allowedDepth: 6. " one level deeper "
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis
		>> #callMethodWithDifferentArgNameThreeLevelIndirection.
	self deny: (escapeAnalyzer findVariableByNameSymbol: #h) escapeStatus
]

{ #category : 'tests' }
EscapeTest >> testNonReturnedTempVarEscapedWithDifferentArgNameThreeLevelIndirection [
	"escapeAnalyzer := EscapeAnalyzer new."

	escapeAnalyzer allowedDepth: 3.
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis
		>> #callMethodWithDifferentArgNameThreeLevelIndirection.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #h) escapeStatus
]

{ #category : 'testRealStuff' }
EscapeTest >> testObjectEmbeddedInNonEscapingObject [

	escapeAnalyzer allowedDepth: 10000.
	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #assignObjectToInstVarOfNonEscapingObject. 
	self deny:
		(escapeAnalyzer findVariableByNameSymbol: #temp2) escapeStatus.
		
	self deny:
		(escapeAnalyzer findVariableByNameSymbol: #temp1) escapeStatus 
		
	
]

{ #category : 'tests' }
EscapeTest >> testObjectEscaped [

"	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #objectEscaped.
	self assert: (escapeAnalyzer variablesTable at: #xx)"
]

{ #category : 'tests' }
EscapeTest >> testRecursiveFunction [
	" the analyzer has to hold from pushing the method to the worklist everytime encoutered on a dfs parse "

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #recursiveFunction.
	self deny:
		(escapeAnalyzer findVariableByNameSymbol: #temp) escapeStatus
]

{ #category : 'tests' }
EscapeTest >> testReturnTempInBlock [

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #notUsedBlockReturnsTemp.
	self deny:( (escapeAnalyzer findVariableByNameSymbol: #tempo) escapeStatus) 
]

{ #category : 'tests' }
EscapeTest >> testReturnedTempVarEscaped [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #foo:.
	self deny:
		(escapeAnalyzer findVariableByNameSymbol: #point1) escapeStatus.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #line) escapeStatus
]

{ #category : 'tests' }
EscapeTest >> testReturnedTempVarEscapedWithDifferentArgName [

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #callMethodWithDifferentArgName.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #h) escapeStatus
]

{ #category : 'tests' }
EscapeTest >> testReturnedTempVarEscapedWithDifferentArgNameDoesntEscape [

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #callMethodWithDifferentArgNameDoesntReturn.
	self deny: (escapeAnalyzer findVariableByNameSymbol: #h) escapeStatus
]

{ #category : 'tests' }
EscapeTest >> testReturnedTempVarEscapedWithDifferentArgNameTwoLevelIndirection [
	"escapeAnalyzer := EscapeAnalyzer new."

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis
		>> #callMethodWithDifferentArgNameTwoLevelIndirection.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #h) escapeStatus
]

{ #category : 'testRealStuff' }
EscapeTest >> testScopeDefinitionDistinction [

	escapeAnalyzer allowedDepth: 10000.
	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #redefinedTemporary. 
	self deny:
		(escapeAnalyzer findVariableByNameSymbol: #tmp) escapeStatus
]

{ #category : 'test - blocks' }
EscapeTest >> testTVPassedToBlockPassedToMethodsValue [


escapeAnalyzer allowedDepth: 300.
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #returnBlockPassedAsArgument.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #tempo) escapeStatus
]

{ #category : 'tests' }
EscapeTest >> testTempInBlock [

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #notUsedBlockTemp.
	self deny:
		(escapeAnalyzer findVariableByNameSymbol: #tempo) escapeStatus
]

{ #category : 'tests' }
EscapeTest >> testTempVarAssignedToGlobalEscaped [

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #fooSetToGlobal.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #h) escapeStatus
]

{ #category : 'tests' }
EscapeTest >> testTempVarAssignedToGlobalEscapedInScope [

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #fooSetToGlobalInScope.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #h) escapeStatus
]

{ #category : 'tests' }
EscapeTest >> testTempVarAssignedToInstEscaped [

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #fooSetToInstance.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #h) escapeStatus
]

{ #category : 'tests' }
EscapeTest >> testTempVarAssignedToInstEscapedInScope [

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #fooSetToInstanceInScope.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #h) escapeStatus
]

{ #category : 'tests' }
EscapeTest >> testTempVarAssignedToTempNotEscaped [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #fooSetToTemp.
	self deny: (escapeAnalyzer findVariableByNameSymbol: #h) escapeStatus
]

{ #category : 'tests' }
EscapeTest >> testTempVarDoesntEscaped [

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #fooDoesNotScape.
	self deny:
		(escapeAnalyzer findVariableByNameSymbol: #point1) escapeStatus
]

{ #category : 'tests' }
EscapeTest >> testTempVarPassedAsArgNotEscaped [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #foo3.
	self deny: (escapeAnalyzer findVariableByNameSymbol: #h) escapeStatus
]

{ #category : 'tests' }
EscapeTest >> testTempVarsNotEscaped [

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #fooNotReturn:.
	self deny:
		(escapeAnalyzer findVariableByNameSymbol: #point1) escapeStatus.
	self deny:
		(escapeAnalyzer findVariableByNameSymbol: #line) escapeStatus
]

{ #category : 'tests' }
EscapeTest >> testVarArgToMessageNotReturned [
	"A message call whose direct/indirect parent is not a ReturnNode should not mark its returned variables as ecaping"

	"	escapeAnalyzer := EscapeAnalyzer new."
	escapeAnalyzer allowedDepth: 20.
	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #noReturnArgumentMessage.
	self deny: (escapeAnalyzer findVariableByNameSymbol: #p) escapeStatus
]

{ #category : 'tests' }
EscapeTest >> testVarArgToMessageReturned [
	"A message call whose direct/indirect parent is a ReturnNode should mark its returned variables as ecaping"

	"	escapeAnalyzer := EscapeAnalyzer new."

	" the called method has two implementations, one that returns the arg, one that doesn't. the expected result should assume the worst."

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #returnReceiverMessageCallOnSelf.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #p) escapeStatus
]

{ #category : 'tests' }
EscapeTest >> testVarEscapedThreeLevelIndirectionNoDepthRestraint [
	"escapeAnalyzer := EscapeAnalyzer new."

	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis
		>> #callMethodWithDifferentArgNameThreeLevelIndirection.
	self deny: (escapeAnalyzer findVariableByNameSymbol: #h) escapeStatus
]

{ #category : 'tests' }
EscapeTest >> testcallTwiceReturnOneDifferentVars [
	"A message call whose direct/indirect parent is a ReturnNode should mark its returned variables as ecaping"

	"escapeAnalyzer := EscapeAnalyzer new."

	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #callTwiceReturnOneDifferentVars.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #p) escapeStatus
]

{ #category : 'tests' }
EscapeTest >> testcallTwiceWithDifferentArgStatus [
	"A message call whose direct/indirect parent is a ReturnNode should mark its returned variables as ecaping"

	"escapeAnalyzer := EscapeAnalyzer new."

	escapeAnalyzer escapeAnalyze:	FixtureEscapeAnalysis >> #callTwiceDiffrentArgs:.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #p) escapeStatus
]
