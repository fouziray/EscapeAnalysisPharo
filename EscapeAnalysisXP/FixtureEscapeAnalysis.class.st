Class {
	#name : 'FixtureEscapeAnalysis',
	#superclass : 'Object',
	#instVars : [
		'x',
		'inst',
		'inlined_PointInlined_x',
		'inlined_PointInlined_y'
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

	true ifTrue: [
		| temp |
		temp := Point new.
		^ self returnA: temp ]
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

{ #category : 'accessing' }
FixtureEscapeAnalysis >> objectEscaped [

	| xx y |
	xx := Object new.
	y := xx -> nil.
	^ self tata: y
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
	self methodWithReturn: Object new.
	^ self methodCallsMethodWithReturn: a
]

{ #category : 'recursive' }
FixtureEscapeAnalysis >> repetadFunctionCall [
	| temp |
	temp:= FixtureEscapeAnalysis new .
	temp recursiveFunction.
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

{ #category : 'nested calls' }
FixtureEscapeAnalysis >> singleImplementation: arg [
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
