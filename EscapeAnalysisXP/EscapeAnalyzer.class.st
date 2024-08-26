Class {
	#name : 'EscapeAnalyzer',
	#superclass : 'Object',
	#instVars : [
		'workList',
		'variablesTable'
	],
	#category : 'EscapeAnalysisXP',
	#package : 'EscapeAnalysisXP'
}

{ #category : 'testing' }
EscapeAnalyzer >> analyze: method [

	| next |
	variablesTable := OrderedCollection newFrom:
		                  method ast body temporaryVariables.
	workList := OrderedCollection new
		            add: method;
		            yourself.
	next := workList removeFirst.
	workList isNotEmpty whileTrue: [ self analyzeNext: next ]
]

{ #category : 'accessing' }
EscapeAnalyzer >> foo: point2 [ 

	| point1 line |
	line:= LineInlined p1: point1 p2: point2.
	^ line length
	
]

{ #category : 'testing' }
EscapeAnalyzer >> isAssignmentTrackedVariable: childNode [
	(variablesTable keys contains: (childNode variable)) ifFalse: [ ^ false ].
	 childNode value isLiteral ifTrue:[ ^ false  ].
	^ true.
		
]
