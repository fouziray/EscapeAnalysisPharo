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
	#category : 'EscapeAnalysisXP-Core',
	#package : 'EscapeAnalysisXP',
	#tag : 'Core'
}

{ #category : 'adding' }
EscapeAnalyzerVisitOOr >> addCurrentMethodReturnStatus: aBoolean [

	workListReturnStatus add: aBoolean .
]

{ #category : 'adding' }
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

{ #category : 'testing' }
EscapeAnalyzerVisitOOr >> checkEscaped: aName [

	^ context checkEscaped: aName
]

{ #category : 'queries' }
EscapeAnalyzerVisitOOr >> checkNethodIsTreated: aMethod [

	^ ((context workingList indexOf: aMethod) < context workingListIndex)
	not
]

{ #category : 'testing' }
EscapeAnalyzerVisitOOr >> checkNode: anASTNode trackedIn: aTable [

	anASTNode isVariable ifFalse: [
		anASTNode isBlock ifTrue: [
			^ self checkVariable: anASTNode asString in: aTable ].
		^ false ].
	^ self checkVariable: anASTNode variable name in: aTable
]

{ #category : 'testing' }
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

{ #category : 'queries' }
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

{ #category : 'analyse' }
EscapeAnalyzerVisitOOr >> extendCtxList: aContext [

	ctxList add: aContext
]

{ #category : 'queries' }
EscapeAnalyzerVisitOOr >> findVariableByName: anASTNode [

anASTNode isVariable ifFalse: [
		anASTNode isBlock ifTrue: [
			^ context findVariableByName: anASTNode asString  ].
		^ nil ].
	^ context findVariableByName: anASTNode variable name

]

{ #category : 'queries' }
EscapeAnalyzerVisitOOr >> findVariableByNameSymbol: aVariableName [

	^ context findVariableByName: aVariableName
]

{ #category : 'queries' }
EscapeAnalyzerVisitOOr >> getTrackVariableNames [

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

{ #category : 'testing' }
EscapeAnalyzerVisitOOr >> isTrackedNode: anASTNode [

	^ (self findVariableByName: anASTNode) isNotNil
]

{ #category : 'testing' }
EscapeAnalyzerVisitOOr >> isTrackedTempVariable: anVariableNode [

	(variablesTable includesKey: anVariableNode variable name)
		ifTrue: [ ^ true ].
	^ false
]

{ #category : 'testing' }
EscapeAnalyzerVisitOOr >> isTrackedVariable: anVariableNode [

	(variablesTable includesKey: anVariableNode variable name)
		ifTrue: [ ^ true ].
	^ false
]

{ #category : 'analyse' }
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

{ #category : 'analyse' }
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

{ #category : 'analyse' }
EscapeAnalyzerVisitOOr >> updateTrackedVariableName: association forMethod: methodName [

trackVariableNameChanges ifNil:[ trackVariableNameChanges:= Dictionary new ].
trackVariableNameChanges at: methodName update: [ :v | v add: association ] initial: [  OrderedCollection newFrom: {association}].
]

{ #category : 'analyse' }
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
