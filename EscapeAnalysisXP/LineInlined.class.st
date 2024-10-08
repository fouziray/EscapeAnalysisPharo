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
LineInlined class >> p1: point1 p2: point2 [

	| l |
	l := self new.
	l lineX1: point1 pointX.
	l lineY1: point1 pointY.
	l lineX2: point2 pointX.
	l lineY2: point2 pointY.
	^ l
]

{ #category : 'accessing' }
LineInlined >> lineLength [

	^ ((x2 - x1) squared + (y2 - y1) squared) sqrt
]

{ #category : 'as yet unclassified' }
LineInlined >> lineX1: aNumber [

	x1 := aNumber
]

{ #category : 'accessing' }
LineInlined >> lineX2: aNumber [

	x2 := aNumber
]

{ #category : 'accessing' }
LineInlined >> lineY1: aNumber [

	y1 := aNumber
]

{ #category : 'accessing' }
LineInlined >> lineY2: aNumber [

	y2 := aNumber
]
