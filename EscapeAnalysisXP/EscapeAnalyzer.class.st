Class {
	#name : 'EscapeAnalyzer',
	#superclass : 'Object',
	#instVars : [
		'workList',
		'variablesTable',
		'treatedMethods',
		'trackVariableNameChanges',
		'trackingTablesList'
	],
	#category : 'EscapeAnalysisXP',
	#package : 'EscapeAnalysisXP'
}

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> addMethodsToWorkList: aMethodCollection [

	workList addAll: aMethodCollection
]

{ #category : 'adding' }
EscapeAnalyzer >> addTrackingTableForElements: aTrackedVariablesTable [

	trackingTablesList add: aTrackedVariablesTable.
]

{ #category : 'testing' }
EscapeAnalyzer >> analyze: method [

	| next tempVariables |
	tempVariables := method ast body temporaryVariables.
	variablesTable := Dictionary
		newFromKeys: tempVariables
		andValues: (Array new: tempVariables size withAll: false).

	workList := OrderedCollection with: method.
	[ workList isNotEmpty ] whileTrue: [
		next := workList removeLast.
		self analyzeMethod: next ]
]

{ #category : 'testing' }
EscapeAnalyzer >> analyzeMethod: aMethod [

	aMethod ast body children do: [ :child | child treatNode: self ]
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> checkNode: anASTNode trackedIn: aTable [

	anASTNode isVariable ifFalse: [ ^ false ].
	^ self checkVariable: anASTNode in: aTable
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> checkVariable: anVariableNode in: aTable [

	(aTable includesKey: anVariableNode variable name)
		ifTrue: [ ^ true ].
	^ false
]

{ #category : 'testing' }
EscapeAnalyzer >> escapeAnalyze: method [

	| next tempVariables currentTrackVarsTable|
	tempVariables := method ast body temporaryVariables.
	variablesTable := Dictionary
		                  newFromKeys: tempVariables
		                  andValues:
		                  (Array new: tempVariables size withAll: false).

	workList := OrderedCollection with: method.
	trackingTablesList := OrderedCollection with: variablesTable shallowCopy .
	currentTrackVarsTable:= variablesTable.
	[ workList isNotEmpty ] whileTrue: [
		next := workList removeFirst.
		currentTrackVarsTable:= trackingTablesList removeFirst .
"		1halt."
		self analyzeMethod: next withTrackedVariables:  currentTrackVarsTable  ].
	
	variablesTable := currentTrackVarsTable.
]

{ #category : 'testing' }
EscapeAnalyzer >> isSpecialMethod: aMethodSelector [

	^ { 'new' } includes: aMethodSelector
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> isTrackedNode: anASTNode [

	anASTNode isVariable ifFalse: [ ^ false ].
	^ self isTrackedTempVariable: anASTNode
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> isTrackedTempVariable: anVariableNode [

	(variablesTable includesKey: anVariableNode variable name)
		ifTrue: [ ^ true ].
	^ false
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> markEscaped: aVariableName inTable: trackedVariablesTable [

	| unwrapVariableName |
	unwrapVariableName := aVariableName shallowCopy.
	[
	(trackedVariablesTable at: unwrapVariableName ifAbsent: [ "1 halt" ])
		isSymbol ] whileTrue: [ 
		unwrapVariableName := trackedVariablesTable at: unwrapVariableName ].
	(trackedVariablesTable at: unwrapVariableName) ifFalse: [
		trackedVariablesTable at: unwrapVariableName put: true ]
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
