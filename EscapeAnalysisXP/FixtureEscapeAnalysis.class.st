Class {
	#name : 'FixtureEscapeAnalysis',
	#superclass : 'Object',
	#instVars : [
		'x'
	],
	#category : 'EscapeAnalysisXP',
	#package : 'EscapeAnalysisXP'
}

{ #category : 'class initialization' }
FixtureEscapeAnalysis class >> initialize [

	Smalltalk globals at: #FooGlobalVariable put: nil
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> foo2 [

	| h |
	h := nil.
	self fooSetter: h
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
FixtureEscapeAnalysis >> fooSetter: h [

	FooGlobalVariable := h
]

{ #category : 'tests' }
FixtureEscapeAnalysis >> method [

	| a |
	a := #value.
	^ self returnA: a
]

{ #category : 'tests' }
FixtureEscapeAnalysis >> returnA: a [

	^ a
]

{ #category : 'accessing' }
FixtureEscapeAnalysis >> toto: h [

	^ 5 + 5
]
