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
	
	self populateWorkList: method.
	1h.

	"workList add: method."
	[ workList isNotEmpty ] whileTrue: [
		next := workList removeFirst.
		self analyzeMethod: next ]
]

{ #category : 'testing' }
EscapeAnalyzer >> analyzeMethod: aMethod [

	aMethod ast body children do: [ :child | child treatNode: self ]
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

{ #category : 'testing' }
EscapeAnalyzer >> isTheReturnReturningTrackedVariable: aReturnNode [

	aReturnNode value isMessage ifTrue: [
		^ self doesMessageRefersToTrackedVariables: aReturnNode value ].
	^ (variablesTable includes: aReturnNode value selector) ifTrue: [
		  self markVariableAsEscaped: aReturnNode value  ]
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> isTrackedNode: anASTNode [

	anASTNode isVariable ifFalse: [ ^ self ].
	^ self isTrackedTempVariable: anASTNode
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

{ #category : 'testing' }
EscapeAnalyzer >> populateWorkList: aMethod [

	aMethod ast body allChildren
		select: [ :node | node isMessage ]
		thenDo: [ :node | node treatNode: self ]
]

{ #category : 'accessing' }
EscapeAnalyzer >> variablesTable [
	^ variablesTable
]

{ #category : 'accessing' }
EscapeAnalyzer >> variablesTable: aDictionary [

	variablesTable:= aDictionary .
]
