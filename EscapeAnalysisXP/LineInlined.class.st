Class {
	#name : 'LineInlined',
	#superclass : 'Object',
	#instVars : [
		'x1',
		'x2',
		'y1',
		'y2'
	],
	#category : 'EscapeAnalysisXP',
	#package : 'EscapeAnalysisXP'
}

{ #category : 'as yet unclassified' }
LineInlined class >> p1: aPoint1 p2: aPoint2 [
	|line|
	line:= self new.
	line x1: aPoint1 x.
	line y1: aPoint1 y.
	line y2: aPoint2 y.
	line x2: aPoint2 x.
^ line
]

{ #category : 'accessing' }
LineInlined >> length [

	^ ((x2 - x1 )squared + (y2 - y1 ) squared )sqrt
]

{ #category : 'as yet unclassified' }
LineInlined >> x1: aNumber [

	x1 := aNumber
]

{ #category : 'accessing' }
LineInlined >> x2: aNumber [

	x2 := aNumber
]

{ #category : 'accessing' }
LineInlined >> y1: aNumber [

	y1 := aNumber
]

{ #category : 'accessing' }
LineInlined >> y2: aNumber [

	y2 := aNumber
]
