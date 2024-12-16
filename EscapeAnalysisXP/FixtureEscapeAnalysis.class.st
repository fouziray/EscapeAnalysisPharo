Class {
	#name : 'FixtureEscapeAnalysis',
	#superclass : 'Object',
	#instVars : [
		'x',
		'inst'
	],
	#category : 'EscapeAnalysisXP-Tests',
	#package : 'EscapeAnalysisXP',
	#tag : 'Tests'
}

{ #category : 'class initialization' }
FixtureEscapeAnalysis class >> initialize [

	Smalltalk globals at: #FooGlobalVariable put: nil
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

{ #category : 'accessing' }
FixtureEscapeAnalysis >> callToObjectToInlineMethodEscapes [

	| h |
	"how can i escape and not escape without there being a message send "
	
	h := ObjectToBeInlined new.
	h aMethodThatPassReceiverToAnotherObject.
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

{ #category : 'nested calls' }
FixtureEscapeAnalysis >> receiverMessage [
]

{ #category : 'as yet unclassified' }
FixtureEscapeAnalysis >> recursiveFunction [
	| temp |
	temp := FixtureEscapeAnalysis.
	temp recursiveFunction.
]

{ #category : 'as yet unclassified' }
FixtureEscapeAnalysis >> repeatedFunctionCallWithEscapingVars [

	| temp a col |
	temp := FixtureEscapeAnalysis new.
	col do: [ |tmpInsideBlock | ^ self methodCallsMethodWithReturn: tmpInsideBlock ].
	self methodWithReturn: Object new.
	^ self methodCallsMethodWithReturn: a
]

{ #category : 'as yet unclassified' }
FixtureEscapeAnalysis >> repetadFunctionCall [
	| temp |
	temp:= FixtureEscapeAnalysis new .
	temp recursiveFunction.
]

{ #category : 'tests' }
FixtureEscapeAnalysis >> returnA: a [

	^ a
]

{ #category : 'tests' }
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
FixtureEscapeAnalysis >> totoWithDifferentArgNameTwoLevelIndirection: aName [

	^ self totoWithDifferentArgName: aName
]

{ #category : 'nested calls' }
FixtureEscapeAnalysis >> twoImplementationMethods [

	
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> usedBlockReturnsTemp [

	| h tempo|
	tempo := Object new.
	h := [ ^ tempo ]. "non local return"
	^ self returnBlockValue: h
]
