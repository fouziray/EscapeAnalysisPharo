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

	| next tempVariables |
	tempVariables := method ast body temporaryVariables.
	self variablesTable: (Dictionary
			 newFromKeys: tempVariables
			 andValues: (Array new: tempVariables size withAll: 'NotEscaped')).
	workList := OrderedCollection new
		            add: method;
		            yourself.

	[ workList isNotEmpty ] whileTrue: [
		next := workList removeFirst.
		self analyzeNext: next ].
	^ self
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> analyzeNext: aMethod [

	aMethod ast body children do: [ :child |
		child isMessage ifTrue: [
			(self doesMessageRefersToTrackedVariables: child) ifTrue: [
				workList addAll: child selector implementors .
				] ].
		child isReturn ifTrue: [
			(self isTheReturnReturningTrackedVariable: child) ifTrue: [
				"self markVariableAsEscaped: child" ] ].
		child isAssignment ifTrue: [
			(self isAssignmentTrackedVariable: child ) ifTrue: [
				self markVariableAsEscaped: child variable ]
			 ] ]
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> doesMessageRefersToTrackedVariables: child [

	(variablesTable includes: child receiver name) ifTrue: [ ^ true ].

	child arguments do: [ :arg |
		arg isMessage
			ifTrue: [ ^ self doesMessageRefersToTrackedVariables: arg ]
			ifFalse: [
				arg isVariable ifTrue: [
					(variablesTable includes: arg name) ifTrue: [
						self markVariableAsEscaped: arg name.
						^ true ] ] ] ].
	^ false
]

{ #category : 'accessing' }
EscapeAnalyzer >> foo: point2 [ 

	| point1 line |
	line:= LineInlined p1: point1 p2: point2.
	^ line length
	
]

{ #category : 'testing' }
EscapeAnalyzer >> isAssignmentTrackedVariable: childNode [
	(variablesTable keys includes: (childNode variable name)) ifFalse: [ ^ false ].
	 childNode value isLiteral ifTrue:[ ^ false  ].
	^ true.
		
]

{ #category : 'testing' }
EscapeAnalyzer >> isTheReturnReturningTrackedVariable: aReturnNode [

	aReturnNode value isMessage ifTrue: [
		^ self doesMessageRefersToTrackedVariables: aReturnNode value ].
	^ (variablesTable includes: aReturnNode value selector) ifTrue: [
		  self markVariableAsEscaped: aReturnNode value  ]
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> markVariableAsEscaped: aVariableNode [

	variablesTable at: aVariableNode name put: 'Escaped'
]

{ #category : 'accessing' }
EscapeAnalyzer >> variablesTable: aDictionary [

	variablesTable:= aDictionary .
]
