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

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> addMethodsToWorkList: aMethodCollection [

	workList addAll: aMethodCollection
]

{ #category : 'testing' }
EscapeAnalyzer >> analyze: method [

	| next tempVariables |
	workList := OrderedCollection new.
	
	tempVariables := method ast body temporaryVariables.
	variablesTable := (Dictionary
		newFromKeys: tempVariables
		andValues: (Array new: tempVariables size withAll: false)).
		
	method ast body allChildren do: [ :node | node treatNode: self ].
	
	workList add: method.
	[ workList isNotEmpty ] whileTrue: [
		next := workList removeFirst.
		self analyzeNext: next ]
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> analyzeNext: aMethod [

	aMethod ast body children do: [ :child |
		child isMessage ifTrue: [
			(self doesMessageRefersToTrackedVariables: child) ifTrue: [
				workList addAll: child selector implementors ] ].
		child isReturn ifTrue: [
			(self isTheReturnReturningTrackedVariable: child) ifTrue: [
				"self markVariableAsEscaped: child" ] ].
		child isAssignment ifTrue: [
			(self isAssignmentTrackedVariable: child) ifTrue: [
				self markVariableAsEscaped: child variable ] ] ]
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
	point1 := PointInlined new.
	point1 pointX: 1.
	point1 pointY: 12.
	line := LineInlined p1: point1 p2: point2.
	^ line lineLength
]

{ #category : 'testing' }
EscapeAnalyzer >> isAssignmentTrackedVariable: childNode [

	(variablesTable keys includes: childNode variable name)
		ifFalse: [ ^ false ].
	childNode value isLiteral ifTrue: [ ^ false ].
	^ true
]

{ #category : 'testing' }
EscapeAnalyzer >> isTheReturnReturningTrackedVariable: aReturnNode [

	aReturnNode value isMessage ifTrue: [
		^ self doesMessageRefersToTrackedVariables: aReturnNode value ].
	^ (variablesTable includes: aReturnNode value selector) ifTrue: [
		  self markVariableAsEscaped: aReturnNode value  ]
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> isTrackedTempVariable: anVariableNode [

	(variablesTable includesKey: anVariableNode variable name)
		ifTrue: [ ^ true ].
	^ false
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> markVariableAsEscaped: aVariableNode [

	variablesTable at: aVariableNode name put: true
]

{ #category : 'accessing' }
EscapeAnalyzer >> variablesTable: aDictionary [

	variablesTable:= aDictionary .
]
