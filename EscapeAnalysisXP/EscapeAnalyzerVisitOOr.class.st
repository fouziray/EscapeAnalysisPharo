"
Block analysis is inspired by the liveness analysis done for temp vector construction.
At the entry of the block the tracked variables are checked to see if they are accessed or not.


"
Class {
	#name : 'EscapeAnalyzerVisitOOr',
	#superclass : 'Object',
	#instVars : [
		'workList',
		'variablesTable',
		'treatedMethods',
		'trackVariableNameChanges',
		'trackingTablesList',
		'currentMethodIsReturned',
		'topLevel',
		'methodCallerStack',
		'followReturnedValue',
		'workListReturnStatus',
		'currentTrackedVars',
		'context',
		'ctxList',
		'savedFirstCtxRef'
	],
	#category : 'EscapeAnalysisXP',
	#package : 'EscapeAnalysisXP'
}

{ #category : 'adding' }
EscapeAnalyzerVisitOOr >> addCurrentMethodReturnStatus: aBoolean [

	workListReturnStatus add: aBoolean .
]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitOOr >> addMethodsToWorkList: aMethodCollection [

	workList addAll: aMethodCollection
]

{ #category : 'adding' }
EscapeAnalyzerVisitOOr >> addTrackingTableForElements: aTrackedVariablesTable [

	trackingTablesList add: aTrackedVariablesTable.
]

{ #category : 'testing' }
EscapeAnalyzerVisitOOr >> analyzeMethod: aMethod [

	| savedStateOfReturnFlag |
	savedStateOfReturnFlag := self currentMethodIsReturned.

	aMethod ast body children do: [ :child |
		(child isMessage and: [ child parent isReturn ])
			ifTrue: [ child escapeAnalyzeNode: self ]
			ifFalse: [
				self setReturnedFlag: savedStateOfReturnFlag.
				(child isReturn and: [ topLevel ]) ifTrue: [
					self setReturnedFlag: true ].
				child escapeAnalyzeNode: self
				"savedStateOfReturnFlag := self currentMethodIsReturned." ] ]
]

{ #category : 'testing' }
EscapeAnalyzerVisitOOr >> analyzeMethod: aMethod withTrackedVariables: aTrackedVariablesTable [

	| savedStateOfReturnFlag |
	savedStateOfReturnFlag := self currentMethodIsReturned.

	aMethod ast body children do: [ :child |
		(child isMessage and: [ child parent isReturn ])
			ifTrue: [
				child treatNode: self given: aTrackedVariablesTable ]
			ifFalse: [
				self setReturnedFlag: savedStateOfReturnFlag.
				(child isReturn and: [ topLevel ]) ifTrue: [
					self setReturnedFlag: true ].
				child treatNode: self given: aTrackedVariablesTable
				"savedStateOfReturnFlag := self currentMethodIsReturned." ] ]
]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitOOr >> checkEscaped: aName [

	^ context checkEscaped: aName
]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitOOr >> checkNethodIsTreated: aMethod [

	^ ((context workingList indexOf: aMethod) < context workingListIndex)
	not
]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitOOr >> checkNode: anASTNode trackedIn: aTable [

	anASTNode isVariable ifFalse: [
		anASTNode isBlock ifTrue: [
			^ self checkVariable: anASTNode asString in: aTable ].
		^ false ].
	^ self checkVariable: anASTNode variable name in: aTable
]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitOOr >> checkVariable: anVariableNode in: aTable [

	([(aTable includesKey: anVariableNode )] on: SubscriptOutOfBounds do: [ false ])
		ifTrue: [ ^ true ].
	^ false
]

{ #category : 'accessing' }
EscapeAnalyzerVisitOOr >> context [

	^ context
]

{ #category : 'accessing' }
EscapeAnalyzerVisitOOr >> context: anEscapeAnalysisContext [

	context := anEscapeAnalysisContext.

	^ context
]

{ #category : 'accessing' }
EscapeAnalyzerVisitOOr >> currentMethodIsReturned [

	^ currentMethodIsReturned ifNil:[ false ]
]

{ #category : 'adding' }
EscapeAnalyzerVisitOOr >> currentMethodReturnStatus [

	^ workListReturnStatus removeFirst
]

{ #category : 'accessing' }
EscapeAnalyzerVisitOOr >> currentTrackedVars [

	^ currentTrackedVars
]

{ #category : 'testing' }
EscapeAnalyzerVisitOOr >> escapeAnalyze: method [

	| next tempVariables currentTrackVarsTable |
	tempVariables := method ast body temporaryVariables.

	topLevel := true.
	variablesTable := context trackVariables:
		                  method ast body temporaryNames.
	workList := context extendWorkinglist: method.
	self addCurrentMethodReturnStatus: true.
	trackingTablesList := context appendTrackedVariablesTable:
		                      variablesTable shallowCopy.
	currentTrackVarsTable := variablesTable.
	[ (next := context nextMethod) isNotNil ] whileTrue: [ "	topLevel ifTrue:[ self setReturnedFlag: true ]. "
		(self checkNethodIsTreated: next)
			ifTrue: [ " Restitute the history of the analysis, apply the escaping tag to variables corresponding to that"
				 ]
			ifFalse: [ " these two conditions are significantly increasing analysis duration"
				trackingTablesList ifNotEmpty: [ " this one too "
					currentTrackVarsTable := trackingTablesList removeFirst.
					self context: ctxList removeFirst.
					 ].
				self analyzeMethod: next.
				topLevel := false ] ].

	variablesTable := currentTrackVarsTable
]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitOOr >> extendCtxList: aContext [

	ctxList add: aContext
]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitOOr >> findVariableByName: anASTNode [

anASTNode isVariable ifFalse: [
		anASTNode isBlock ifTrue: [
			^ context findVariableByName: anASTNode asString  ].
		^ nil ].
	^ context findVariableByName: anASTNode variable name

]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitOOr >> findVariableByNameSymbol: aVariableName [

	^ context findVariableByName: aVariableName
]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitOOr >> getTVNames [

	^ context TVNames
]

{ #category : 'initialization' }
EscapeAnalyzerVisitOOr >> initialize [

	context := EscapeAnalysisContext new.
	ctxList := OrderedCollection new.
	savedFirstCtxRef := context.
	self extendCtxList: context
]

{ #category : 'testing' }
EscapeAnalyzerVisitOOr >> isAtTopLevel [

	^ topLevel
]

{ #category : 'testing' }
EscapeAnalyzerVisitOOr >> isSpecialMethod: aMethodSelector [

	^ { 'new'. 'value' } includes: aMethodSelector
]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitOOr >> isTrackedNode: anASTNode [

	^ (self findVariableByName: anASTNode) isNotNil
]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitOOr >> isTrackedTempVariable: anVariableNode [

	(variablesTable includesKey: anVariableNode variable name)
		ifTrue: [ ^ true ].
	^ false
]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitOOr >> isTrackedVariable: anVariableNode [

	(variablesTable includesKey: anVariableNode variable name)
		ifTrue: [ ^ true ].
	^ false
]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitOOr >> markEscaped: aVariableName inTable: trackedVariablesTable [

	| unwrapVariableName |
	unwrapVariableName := aVariableName shallowCopy.
	[
	(trackedVariablesTable at: unwrapVariableName ifAbsent: [  ])
		isSymbol
	| (trackedVariablesTable at: unwrapVariableName ifAbsent: [  ])
			isCollection ] whileTrue: [
		(trackedVariablesTable at: unwrapVariableName) isString not ifTrue: [
			(trackedVariablesTable at: unwrapVariableName) do: [ :each |
				self markEscaped: each inTable: trackedVariablesTable.
				^ self ] ].

		unwrapVariableName := trackedVariablesTable at: unwrapVariableName ].

	(trackedVariablesTable at: unwrapVariableName) ifFalse: [
		trackedVariablesTable at: unwrapVariableName put: true ]
]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitOOr >> markVariableAsEscaped: aVariableNode [

	| aVariable |
	(aVariable := context findVariableByName: aVariableNode name)
		ifNotNil: [
			aVariable markEscaped.
			^ true ].
	" in case the variable is not defined define it"
	1 halt
]

{ #category : 'initialization' }
EscapeAnalyzerVisitOOr >> setReturnedFlag: aBoolean [

	currentMethodIsReturned := aBoolean
]

{ #category : 'adding' }
EscapeAnalyzerVisitOOr >> setWorkListReturnStatus: aCollection [

	workListReturnStatus := aCollection
]

{ #category : 'testing' }
EscapeAnalyzerVisitOOr >> trackVariable: aVariableNodeName [

	(self isTrackedNode: aVariableNodeName) ifFalse: [
		^ context trackVariable: aVariableNodeName ].
	^ context findVariableByName: aVariableNodeName
]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitOOr >> updateTrackedVariableName: association forMethod: methodName [

trackVariableNameChanges ifNil:[ trackVariableNameChanges:= Dictionary new ].
trackVariableNameChanges at: methodName update: [ :v | v add: association ] initial: [  OrderedCollection newFrom: {association}].
]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitOOr >> upperMostDeclarationName: name [

	| upperMostDeclarationOfName |
	upperMostDeclarationOfName := name.

	(trackVariableNameChanges isNotNil and: [ treatedMethods isNotEmpty ]) ifTrue: [
		
	[(trackVariableNameChanges at: (treatedMethods  last selector) ifPresent:[ (trackVariableNameChanges at: (treatedMethods  last selector)) detect: [ :association | association key = upperMostDeclarationOfName ] ifNone: [ false ] ]  )  ]
		whileTrue: [
		
			upperMostDeclarationOfName := trackVariableNameChanges at:
				                              upperMostDeclarationOfName ].
	].
	^ upperMostDeclarationOfName
]

{ #category : 'accessing' }
EscapeAnalyzerVisitOOr >> variablesTable [
	^ variablesTable
]

{ #category : 'accessing' }
EscapeAnalyzerVisitOOr >> variablesTable: aDictionary [

	variablesTable:= aDictionary .
]

{ #category : 'accessing' }
EscapeAnalyzerVisitOOr >> workList [

	^ workList
]
