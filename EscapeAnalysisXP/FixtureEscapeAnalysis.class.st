Class {
	#name : 'FixtureEscapeAnalysis',
	#superclass : 'Object',
	#instVars : [
		'x',
		'inst',
		'inlined_PointInlined_x',
		'inlined_PointInlined_y',
		'instVar'
	],
	#category : 'EscapeAnalysisXP-Tests',
	#package : 'EscapeAnalysisXP',
	#tag : 'Tests'
}

{ #category : 'class initialization' }
FixtureEscapeAnalysis class >> initialize [

	Smalltalk globals at: #FooGlobalVariable put: nil
]

{ #category : 'adding' }
FixtureEscapeAnalysis >> addEscapingVarToTrackedCollection [

	| trackedCollection escapingVar |
	trackedCollection := OrderedCollection new.
	trackedCollection add: escapingVar.
	^ self returnA: escapingVar
]

{ #category : 'instVarAssignedtoNonEscapingObject' }
FixtureEscapeAnalysis >> allocatedReturnInsideBranch [
	| temp |
	true ifTrue: [
	
		temp := Point new.
		^ self returnA: temp ]
]

{ #category : 'recursive' }
FixtureEscapeAnalysis >> alreadyFoundEscapeShouldntTreatOtherMethods [

	| temp a col |
	self fooSetterToInstance: temp . "this marks temps as escp"

	self returnA: temp. " this should not be treated"
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> assignObjectToArrayConstructor [

	| h |
	"how can i escape and not escape without there being a message send "
	
	h := ObjectToBeInlined new.
	h passSelfToArrayConstructor.
]

{ #category : 'instVarAssignedtoNonEscapingObject' }
FixtureEscapeAnalysis >> assignObjectToInstVarOfNonEscapingObject [

	|temp1 temp2|
		

	temp1:= Point new.
	temp1 setX: 1 setY: 1.
	temp2 := Line new.
	temp2 a: temp1.
	
]

{ #category : 'tests - blocks' }
FixtureEscapeAnalysis >> blockValueWithTV [

	| col |
	col do: [ :arg | FooGlobalVariable := arg ].
	
]

{ #category : 'tests - blocks' }
FixtureEscapeAnalysis >> blockValueWithTV2 [

	| col |
	[ :arg | FooGlobalVariable := arg ] value: col.
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> callMethodWithDifferentArgName [

	| h |
	h := nil.
	^ self totoWithDifferentArgName: h
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> callMethodWithDifferentArgNameDoesntReturn [

	| h |
	h := nil.
	self totoWithDifferentArgName: h
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> callMethodWithDifferentArgNameThreeLevelIndirection [

	| h |
	h := nil.
	^ self totoWithDifferentArgNameThreeLevelIndirection: h
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> callMethodWithDifferentArgNameTwoLevelIndirection [

	| h |
	h := nil.
	^ self totoWithDifferentArgNameTwoLevelIndirection: h
]

{ #category : 'nested calls' }
FixtureEscapeAnalysis >> callNestedMessages [

	| o |
	o := super twoImplementationMethods.
	self receiverMessage singleImplementation: (self bar: o)
]

{ #category : 'nested calls' }
FixtureEscapeAnalysis >> callNestedMessages2 [

	| o |
	o := Object twoImplementationMethods.
	self receiverMessage singleImplementation: (self localMessage: o)
]

{ #category : 'nested calls' }
FixtureEscapeAnalysis >> callNestedMessages3 [

	| o |
	o := self foo twoImplementationMethods.
	self receiverMessage singleImplementation: (self bar: o)
]

{ #category : 'as yet unclassified' }
FixtureEscapeAnalysis >> callTwiceDiffrentArgs: unknownOutsideArgument [

	| p second |
	p := Point new.
	self returnA: unknownOutsideArgument.
	self returnA: second.
	^ self returnA: p " the second one which is supposed to mark the p variable as escaped is being ignored"
]

{ #category : 'as yet unclassified' }
FixtureEscapeAnalysis >> callTwiceReturnOneDifferentVars [

	| p |
	p := Point new.
	self returnA: 5.
	^ self returnA: p " the second one which is supposed to mark the p variable as escaped is being ignored"
]

{ #category : 'as yet unclassified' }
FixtureEscapeAnalysis >> consecutiveCallsSecondShouldNotBeTreated [

	| var |
	self fooSetterToInstance: var.
	self returnA: var

	"this one has a argument that is already escaping. We can elagate this branch. But we only get that information on the next iteration of the worklist. how can we anticipate ? we can mark the newly created context relative to returnA as non resolved arguments, after the full pass on the method body the var is resolved. it should also notify its referencers of this change. This should trigger a control process in the context that checks its tracked variables states. in case they all escaped -> deletes itself from the worklist "
]

{ #category : 'tests' }
FixtureEscapeAnalysis >> escArgAfterSetToGlobal [

	| a |
	a := #value.
	FooGlobalVariable:= a.
	^ self returnA: a
]

{ #category : 'analysis summary ' }
FixtureEscapeAnalysis >> firstAgumentEscapes: firstArgument second: secondArgument [
	
	FooGlobalVariable := firstArgument.
]

{ #category : 'analysis summary ' }
FixtureEscapeAnalysis >> firstCallFrequentMethod [

| trackedTemp secondTrackedTemp |
trackedTemp:= Object new.
secondTrackedTemp := Object new.
self firstAgumentEscapes: trackedTemp second: secondTrackedTemp

]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> foo3 [

	| h |
	h := nil.
	^ self toto: h
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> foo: point2 [

	| point1 line |
	point1 := PointInlined new.
	point1 pointX: 1.
	point1 pointY: 12.
	line := LineInlined p1: point1 p2: point2.
	line lineLength.
	^ line
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> fooDoesNotScape [

	| point1 |
	point1 := PointInlined new.
	^ point1 pointX
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> fooDoesNotScapeWithDoMessage [ 
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> fooDoesScapeWithDoMessage [
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> fooNotReturn: point2 [

	| point1 line |
	point1 := PointInlined new.
	point1 pointX: 1.
	point1 pointY: 12.
	line := LineInlined p1: point1 p2: point2.
	^ line lineLength
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> fooSetToGlobal [

	| h |
	h := nil.
	self fooSetterToGlobal: h
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> fooSetToGlobalInScope [
	| h |
	h := nil.
FooGlobalVariable := h.
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> fooSetToInstance [

	| h |
	h := nil.
	self fooSetterToInstance: h
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> fooSetToInstanceInScope [

	| h |
	h := nil.
	inst := h
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> fooSetToTemp [

	| h |
	h := nil.
	self fooSetterToTemp: h
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> fooSetterToGlobal: h [

	FooGlobalVariable := h
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> fooSetterToInstance: h [

	inst := h
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> fooSetterToTemp: h [

	| aTemp |
	aTemp := h.

	^ aTemp
]

{ #category : 'polymorphism' }
FixtureEscapeAnalysis >> guilleTest1 [

	| o1 o2  |
	o1 := FixtureEscapeAnalysis new.
	o2 := FixtureEscapeAnalysisEvilTwin new.
	self x: o1 arg: Object new. 
	self x: o2 arg: Object new.
]

{ #category : 'polymorphism' }
FixtureEscapeAnalysis >> guilleTest2 [

	| o1 o2  |
	o1 := FixtureEscapeAnalysis new.
	o2 := FixtureNiceTriple new.
	self x: o1 arg: Object new. 
	self x: o2 arg: Object new.
]

{ #category : 'polymorphism' }
FixtureEscapeAnalysis >> guilleTest3 [

	| o1 o2  |
	o1 := FixtureEscapeAnalysis new.
	o2 := FixtureEvilQuad new.
	self x: o1 arg: Object new. 
	self x: o2 arg: Object new.
]

{ #category : 'polymorphism' }
FixtureEscapeAnalysis >> guilleTest4 [

	| o1 o2  |
	o1 := FixtureEvilQuad new.
	o2 := FixtureEscapeAnalysisEvilTwin new.
	self x: o1 arg: Object new. 
	self x: o2 arg: Object new.
]

{ #category : 'as yet unclassified' }
FixtureEscapeAnalysis >> inlined_PointInlined_pointX [

	^ inlined_PointInlined_x
]

{ #category : 'as yet unclassified' }
FixtureEscapeAnalysis >> inlined_PointInlined_pointX: anInteger [

	inlined_PointInlined_x := anInteger
]

{ #category : 'as yet unclassified' }
FixtureEscapeAnalysis >> inlined_PointInlined_pointY [

	^ inlined_PointInlined_y
]

{ #category : 'as yet unclassified' }
FixtureEscapeAnalysis >> inlined_PointInlined_pointY: anInteger [

	inlined_PointInlined_y := anInteger
]

{ #category : 'nested calls' }
FixtureEscapeAnalysis >> localMessage: arg [

	self returnA: arg.
]

{ #category : 'tests' }
FixtureEscapeAnalysis >> method [

	| a |
	a := #value.
	^ self returnA: a
]

{ #category : 'as yet unclassified' }
FixtureEscapeAnalysis >> methodCallsMethodWithReturn: anArgg [

	^ self methodWithReturn: anArgg
]

{ #category : 'to test is returned' }
FixtureEscapeAnalysis >> methodThatDoesNotReturnTheMethodWhoseResultShouldBeReturned [

	self methodWhoseResultIsReturned 

]

{ #category : 'to test is returned' }
FixtureEscapeAnalysis >> methodThatDoesNotReturnTheMethodWhoseResultShouldBeReturned2 [

	self methodWhoseResultIsNotReturned 

]

{ #category : 'to test is returned' }
FixtureEscapeAnalysis >> methodThatReturnsTheMethodWhoseResultShouldBeReturned [

	^ self methodWhoseResultIsReturned 

]

{ #category : 'to test is returned' }
FixtureEscapeAnalysis >> methodWhoseResultIsNotReturned [

	^ 666
]

{ #category : 'to test is returned' }
FixtureEscapeAnalysis >> methodWhoseResultIsReturned [

	^ 33
]

{ #category : 'as yet unclassified' }
FixtureEscapeAnalysis >> methodWithReturn: argName [

	^ argName. 
]

{ #category : 'as yet unclassified' }
FixtureEscapeAnalysis >> methodWithReturnSelf [

	^ self. 
]

{ #category : 'nested calls' }
FixtureEscapeAnalysis >> nestedMessageInArgument [

	| o |
	o := Object new.
	 self fooSetterToGlobal: (self returnA: o)
]

{ #category : 'nested calls' }
FixtureEscapeAnalysis >> nestedMessageInArgument2 [

	| o |
	o := Object new.
	self toto: (self fooSetterToGlobal: (self returnA: o))
]

{ #category : 'instance creation' }
FixtureEscapeAnalysis >> newObjectWithoutAssignment [
|a|
	self fooSetterToGlobal: Object new 
]

{ #category : 'as yet unclassified' }
FixtureEscapeAnalysis >> noReturnArgumentMessage [

	| p |
	"p:= Point new."
	p := FixtureEscapeAnalysis new.
	self methodWithReturn: p.
]

{ #category : 'as yet unclassified' }
FixtureEscapeAnalysis >> noReturnArgumentMessageSuccededWithReturnSelf [

	| p |
	"p:= Point new."
	p := FixtureEscapeAnalysis new.
	self methodWithReturn: p.
	^ self
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> notUsedBlockReturnsTemp [

	| h tempo|
	h := [ ^ tempo ].
	^ self toto: h
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> notUsedBlockTemp [

	| h tempo |
	tempo:= Object new.
	h := [ tempo ].
	^ self toto: h
]

{ #category : 'as yet unclassified' }
FixtureEscapeAnalysis >> objectAddedToCollection [

| tracked addEdges eto efrom eval|
tracked := OrderedCollection new.
		tracked add: efrom.
		tracked add: eto.
		tracked add: eval.
		addEdges add: tracked asArray.
		
	 addEdges " escape line of first var, should trigger its contents to escape too" " the reason why now it is marked escaped. is because of add: not because it references tracked"
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> objectEscaped [

	| xx y |
	xx := Object new.
	y := xx -> nil.
	^ self tata: y
]

{ #category : 'polymorphism' }
FixtureEscapeAnalysis >> polyEscapeOrNot: anArg [

	  "do nothing " 
]

{ #category : 'polymorphism' }
FixtureEscapeAnalysis >> receiverMessage [
]

{ #category : 'recursive' }
FixtureEscapeAnalysis >> recursiveFunction [
	| temp |
	temp := FixtureEscapeAnalysis.
	temp recursiveFunction.
]

{ #category : 'instVarAssignedtoNonEscapingObject' }
FixtureEscapeAnalysis >> redeclaringVarInDifferentScope [

	| temp |
	temp := Point new.
	self toto: temp.
	true ifTrue: [
		| temp |
		temp := Point new.
		^ self returnA: temp ]
]

{ #category : 'redefinitionVarScope' }
FixtureEscapeAnalysis >> redefinedTemporary [
	 |tmp|
	 tmp:= Object new.
	 true ifTrue:[ 
tmp:= Object new.
		 ]  
]

{ #category : 'recursive' }
FixtureEscapeAnalysis >> repeatedFunctionCallWithEscapingVars [

	| temp a col |
	temp := FixtureEscapeAnalysis new.
	col do: [ |tmpInsideBlock | ^ self methodCallsMethodWithReturn: tmpInsideBlock ].
	col:= FixtureEscapeAnalysis new.
	self methodWithReturn: Object new.
	col methodWithReturn: 1.
	self methodWithReturn: temp.
	^ self methodCallsMethodWithReturn: a
]

{ #category : 'tests' }
FixtureEscapeAnalysis >> returnA: a [

	^ a
]

{ #category : 'tests - blocks' }
FixtureEscapeAnalysis >> returnBlockPassedAsArgument [

	| h tempo |
	tempo := Object new.

	^ self returnBlockValue: [ ^ tempo ]
]

{ #category : 'tests - blocks' }
FixtureEscapeAnalysis >> returnBlockValue: aBlock [

	^ aBlock value
]

{ #category : 'as yet unclassified' }
FixtureEscapeAnalysis >> returnReceiverMessageCallOnSelf [

	| p |
	"p:= Point new."
	p := FixtureEscapeAnalysis new.
	^ p methodWithReturnSelf
]

{ #category : 'as yet unclassified' }
FixtureEscapeAnalysis >> runComplexWeightedGraph2 [


	|graphType graph astar|
	astar:= AIAstar new.
	graphType := AICyclicWeightedComplexFixture new.
	graph :=graphType complexWeightedGraph2.
	astar nodes: graph nodes.
	astar 
	   edges: graph edges
		from: #first
		to: #second
		weight: #third.

	astar runFrom: 0.
	
]

{ #category : 'analysis summary ' }
FixtureEscapeAnalysis >> secondCallFrequentMethod [

| trackedTemp secondTrackedTemp |

trackedTemp:= Object new.
secondTrackedTemp := Object new.

self firstAgumentEscapes: trackedTemp second: secondTrackedTemp

]

{ #category : 'analysis summary ' }
FixtureEscapeAnalysis >> secondCallFrequentMethodUnmatchingTrackStatus2: anExternalVarArg [

	| trackedTemp2 secondTrackedTemp |
	self firstAgumentEscapes: anExternalVarArg second: trackedTemp2
]

{ #category : 'analysis summary ' }
FixtureEscapeAnalysis >> secondCallFrequentMethodUnmatchingTrackStatus: anExternalVarArg [

| trackedTemp2 secondTrackedTemp |


self firstAgumentEscapes: trackedTemp2 second: anExternalVarArg

]

{ #category : 'nested calls' }
FixtureEscapeAnalysis >> singleImplementation: arg [
]

{ #category : 'static_type' }
FixtureEscapeAnalysis >> staticTypeExample [

	| typedObject |
	typedObject := FixtureEscapeAnalysis new.

	^ typedObject yourself
]

{ #category : 'static_type' }
FixtureEscapeAnalysis >> staticTypeExample2 [
|x y|
	x > 0
		ifTrue: [
			y := Object new.
			y actionMap ]
		ifFalse: [
			y := Morph new.
			y actionMap ]
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> tata: y [

	^ y
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> toto: h [

	^ 5 + 5
]

{ #category : 'as yet unclassified' }
FixtureEscapeAnalysis >> totoWithDifferentArgName: aUniqueName [
	
	^ aUniqueName
]

{ #category : 'as yet unclassified' }
FixtureEscapeAnalysis >> totoWithDifferentArgNameThreeLevelIndirection: aTopLevelName [

	^ self totoWithDifferentArgNameTwoLevelIndirectionNoEscapes: aTopLevelName
]

{ #category : 'as yet unclassified' }
FixtureEscapeAnalysis >> totoWithDifferentArgNameTwoLevelIndirection: aName [

	^ self totoWithDifferentArgName: aName
]

{ #category : 'as yet unclassified' }
FixtureEscapeAnalysis >> totoWithDifferentArgNameTwoLevelIndirectionNoEscapes: aName [

	^ self toto: aName
]

{ #category : 'polymorphism' }
FixtureEscapeAnalysis >> twoImplementationMethods [

	
]

{ #category : 'nested calls' }
FixtureEscapeAnalysis >> twoImplementationShouldTreatOnlySelfRelated [

	| o |
	o := self.

	self localMessage: o.
	self returnA: 1
]

{ #category : 'tests - blocks' }
FixtureEscapeAnalysis >> usedBlockReturnsTemp [

	| h tempo|
	tempo := Object new.
	h := [ ^ tempo ]. "non local return"
	^ self returnBlockValue: h
]

{ #category : 'tests - blocks' }
FixtureEscapeAnalysis >> usedBlockReturnsTemp2 [

	| h tempo|
	tempo := Object new.
	h := [ ^ tempo ]. "non local return"
	 h .
	true.
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> x: anObject arg: arg [

	anObject polyEscapeOrNot: arg.
	
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> yourself [

	^ 4
]
