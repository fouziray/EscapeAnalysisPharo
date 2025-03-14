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

{ #category : 'accessing' }
EscapeTest class >> defaultTimeLimit [

	DefaultTimeLimit := 5 minutes.
	^ DefaultTimeLimit
]

{ #category : 'running' }
EscapeTest >> setUp [

	super setUp.
	escapeAnalyzer := EscapeAnalyzerVisitor new.
escapeAnalyzer setWorklistLimitation: 300.
	" the default allowed depth is 6 to avoir loops, but could be extended after"

	escapeAnalyzer allowedDepth: 6
]

{ #category : 'testRealStuff' }
EscapeTest >> test2implShouldTreatOnlySelfRelated [

	escapeAnalyzer allowedDepth: 4.
	escapeAnalyzer allowedWorklistSize: 100.
	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis
		>> #twoImplementationShouldTreatOnlySelfRelated.
	self deny:
		(escapeAnalyzer findVariableByNameSymbol: #o) escapeStatus
]

{ #category : 'testRealStuff' }
EscapeTest >> testAnalysisOfcomplexWeightedGraph4 [

"
When reaching the conditional block that returns the tabs variable.
	- it should be marked as escaped since it is referenced in the block.
	- the block is passed to a common selector ifTrue:IfFalse, and their variants.
	- Should apply escape On the block knowing that no more instructions are following-up the return.
"
"
Uncoherent escape status ! This test should work according to the result of the analysis. done with config: { depth: 1. worklistLimit: 100 } }
"

	escapeAnalyzer allowedDepth: 1.
	escapeAnalyzer allowedWorklistSize: 100.
	escapeAnalyzer escapeAnalyze:
		AICyclicWeightedComplexFixture >> #complexWeightedGraph4.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #graph) escapeStatus


]

{ #category : 'testRealStuff' }
EscapeTest >> testAnalysisOffind [

"
When reaching the conditional block that returns the tabs variable.
	- it should be marked as escaped since it is referenced in the block.
	- the block is passed to a common selector ifTrue:IfFalse, and their variants.
	- Should apply escape On the block knowing that no more instructions are following-up the return.
"
"
Uncoherent escape status ! This test should work according to the result of the analysis. done with config: { depth: 1. worklistLimit: 100 } }
"

	escapeAnalyzer allowedDepth: 1.
	escapeAnalyzer allowedWorklistSize: 100.
	escapeAnalyzer escapeAnalyze:
		AIDisjointSetNode>>#find.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #root) escapeStatus


]

{ #category : 'testRealStuff' }
EscapeTest >> testAnalysisOfqueryResult [


	escapeAnalyzer allowedDepth: 1.
	escapeAnalyzer allowedWorklistSize: 100.
	escapeAnalyzer escapeAnalyze:
		RTNode >> #queryResult:.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #nodesInPoint) escapeStatus


]

{ #category : 'testRealStuff' }
EscapeTest >> testAnalysisOftestGetNewTab [

"
When reaching the conditional block that returns the tabs variable.
	- it should be marked as escaped since it is referenced in the block.
	- the block is passed to a common selector ifTrue:IfFalse, and their variants.
	- Should apply escape On the block knowing that no more instructions are following-up the return.
"
"
Uncoherent escape status ! This test should work according to the result of the analysis. done with config: { depth: 1. worklistLimit: 100 } }
"

	escapeAnalyzer allowedDepth: 1.
	escapeAnalyzer allowedWorklistSize: 100.
	escapeAnalyzer escapeAnalyze:
		AndreasSystemProfilerTest >> #testGetNewTab.
	self deny:
		(escapeAnalyzer findVariableByNameSymbol: #tabs) escapeStatus


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
EscapeTest >> testComplexCycleGraph2 [



	escapeAnalyzer allowedDepth: 1.
	escapeAnalyzer allowedWorklistSize: 100.
	escapeAnalyzer escapeAnalyze:
		AICyclicNonWeightedComplexFixture >> #complexCycleGraph2  .
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #edges) escapeStatus.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #graph) escapeStatus
]

{ #category : 'testRealStuff' }
EscapeTest >> testComplexWeighterGraph [

	self flag: #false.
	self flag: #firstExample.
	self skip.


	escapeAnalyzer allowedDepth: 10000.
	escapeAnalyzer allowedWorklistSize: 10000.
	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #runComplexWeightedGraph2.
	self deny:
		(escapeAnalyzer findVariableByNameSymbol: #astar) escapeStatus.
	self deny:
		(escapeAnalyzer findVariableByNameSymbol: #graph) escapeStatus
]

{ #category : 'False Positive' }
EscapeTest >> testFPsimpleWeightedGraph2 [
"the first analysis configuration d=1 w=100"
	escapeAnalyzer allowedDepth: 1.
	escapeAnalyzer allowedWorklistSize: 100. 
	

	escapeAnalyzer escapeAnalyze:
		AICyclicWeightedSimpleFixture >> #simpleWeightedGraph2.
	self assert:
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

{ #category : 'HIGH PRIORITY test embedded messages' }
EscapeTest >> testNestedMessageAsArg [

	escapeAnalyzer allowedDepth: 10000.
	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #nestedMessageInArgument.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #o) escapeStatus
]

{ #category : 'HIGH PRIORITY test embedded messages' }
EscapeTest >> testNestedMessageAsArgShouldConsiderReturnedVariable [

	escapeAnalyzer allowedDepth: 1000.
	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #nestedMessageInArgument.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #o) escapeStatus
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

{ #category : 'pseudo-variables' }
EscapeTest >> testPseudoVariableSelf [



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

{ #category : 'testRealStuff' }
EscapeTest >> testStaticTypeRestraint [

	escapeAnalyzer allowedDepth: 10000.
	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #staticTypeExample. 
	self deny:
		(escapeAnalyzer findVariableByNameSymbol: #typedObject) escapeStatus
]

{ #category : 'test - blocks' }
EscapeTest >> testTVPassedToBlockPassedEvaluation2 [


escapeAnalyzer allowedDepth: 300.
	escapeAnalyzer escapeAnalyze: AndreasSystemProfiler class >> #spyOn:.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #profiler) escapeStatus
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

{ #category : 'collection operations' }
EscapeTest >> testVariableAddedToCollection [

escapeAnalyzer allowedDepth: 300.
	escapeAnalyzer escapeAnalyze: FixtureEscapeAnalysis >> #objectAddedToCollection.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #tracked) escapeStatus.
		self assert:
		(escapeAnalyzer findVariableByNameSymbol: #addEdges ) escapeStatus


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

{ #category : 'log of treated methods' }
EscapeTest >> testrepeatedFunctionCallWithEscapingVars [

	escapeAnalyzer allowedDepth: 4.
	escapeAnalyzer allowedWorklistSize: 100.
	escapeAnalyzer escapeAnalyze:
		FixtureEscapeAnalysis >> #repeatedFunctionCallWithEscapingVars.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #a) escapeStatus.
	self assert:
		(escapeAnalyzer findVariableByNameSymbol: #col) escapeStatus.
	self deny:
		(escapeAnalyzer findVariableByNameSymbol: #temp) escapeStatus
]
