"
Block analysis is inspired by the liveness analysis done for temp vector construction.
At the entry of the block the tracked variables are checked to see if they are accessed or not.


"
Class {
	#name : 'EscapeAnalyzer',
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
		'next',
		'currentTrackedVars',
		'treatedMethodsEscapeHistory'
	],
	#category : 'EscapeAnalysisXP',
	#package : 'EscapeAnalysisXP'
}

{ #category : 'adding' }
EscapeAnalyzer >> addCurrentMethodReturnStatus: aBoolean [

	workListReturnStatus add: aBoolean .
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> addMethodsToWorkList: aMethodCollection [

	workList addAll: aMethodCollection
]

{ #category : 'adding' }
EscapeAnalyzer >> addTrackingTableForElements: aTrackedVariablesTable [

	trackingTablesList add: aTrackedVariablesTable.
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> analyzeBlockClosure: aBlockNode inAst: anAst [

	| visitor context |
	context := EscapeAnalysisContext new.
	visitor := EscapeAnalysisBlockVisitor new.
	visitor context: context.
	context scope: anAst.
	visitor visitBlockNode: aBlockNode.
	"aBlockNode acceptVisitor: visitor."
	^ context escapedVariables
]

{ #category : 'testing' }
EscapeAnalyzer >> analyzeMethod: aMethod [

	aMethod ast body children do: [ :child | child treatNode: self ]
]

{ #category : 'testing' }
EscapeAnalyzer >> analyzeMethod: aMethod withTrackedVariables: aTrackedVariablesTable [

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
EscapeAnalyzer >> applyEscapeHistoryOf: aMethodName on: aVariablesTable [

	(treatedMethodsEscapeHistory at: aMethodName) associationsDo: [ :var |
		self markEscaped: var key inTable: aVariablesTable ]
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> checkNode: anASTNode trackedIn: aTable [

	anASTNode isVariable ifFalse: [
		anASTNode isBlock ifTrue: [
			^ self checkVariable: anASTNode asString in: aTable ].
		^ false ].
	^ self checkVariable: anASTNode variable name in: aTable
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> checkVariable: anVariableNode in: aTable [

	([(aTable includesKey: anVariableNode )] on: SubscriptOutOfBounds do: [ false ])
		ifTrue: [ ^ true ].
	^ false
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> currentMethod [

	^ next
]

{ #category : 'accessing' }
EscapeAnalyzer >> currentMethodIsReturned [

	^ currentMethodIsReturned ifNil:[ false ]
]

{ #category : 'adding' }
EscapeAnalyzer >> currentMethodReturnStatus [

	^ workListReturnStatus removeFirst
]

{ #category : 'accessing' }
EscapeAnalyzer >> currentTrackedVars [

	^ currentTrackedVars
]

{ #category : 'testing' }
EscapeAnalyzer >> escapeAnalyze: method [

	| tempVariables currentTrackVarsTable treatedMethodsNotToLoopBackTO saveTrackingHistory |
	tempVariables := method ast body temporaryVariables.

	"tempVariables:= tempVariables collect: [ :tempVar | method classBinding name ,'_', method selector, '_', tempVar ]."
	topLevel := true.
	variablesTable := Dictionary
		                  newFromKeys: tempVariables
		                  andValues:
		                  (Array new: tempVariables size withAll: false).
	treatedMethodsNotToLoopBackTO := OrderedCollection new.
	workList := OrderedCollection with: method.
	self addCurrentMethodReturnStatus: true.
	trackingTablesList := OrderedCollection with:
		                      variablesTable shallowCopy.
	currentTrackVarsTable := variablesTable.
	[ workList isNotEmpty ] whileTrue: [ "	topLevel ifTrue:[ self setReturnedFlag: true ]. "
		next := workList removeFirst.
		(treatedMethodsNotToLoopBackTO includes: next name)
			ifFalse: [ " these two conditions are significantly increasing analysis duration"
				treatedMethodsNotToLoopBackTO add: next name.
				trackingTablesList ifNotEmpty: [ " this one too "
					currentTrackVarsTable := trackingTablesList removeFirst ].


				self
					analyzeMethod: next
					withTrackedVariables: currentTrackVarsTable.

				self saveHistoryOfEscapedArgsOf: next from: variablesTable.
				topLevel := false ]
			ifTrue: [ self applyEscapeHistoryOf: next name on: variablesTable ] ].
	variablesTable := currentTrackVarsTable
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> fullnames: namesCol in: aMethod [

	^ namesCol collect: [ :name |
		  aMethod classBinding name , '_' , aMethod selector , '_' , name ]
]

{ #category : 'initialization' }
EscapeAnalyzer >> initialize [

	currentTrackedVars := OrderedCollection new.
	treatedMethodsEscapeHistory := Dictionary new
]

{ #category : 'testing' }
EscapeAnalyzer >> isAtTopLevel [

	^ topLevel
]

{ #category : 'testing' }
EscapeAnalyzer >> isSpecialMethod: aMethodSelector [

	^ { 'new'. 'value' } includes: aMethodSelector
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
	(trackedVariablesTable at: unwrapVariableName ifAbsent: [  ])
		isSymbol
	| (trackedVariablesTable at: unwrapVariableName ifAbsent: [  ])
			isCollection ] whileTrue: [

		(trackedVariablesTable at: unwrapVariableName) isString not ifTrue: [
			(trackedVariablesTable at: unwrapVariableName) do: [ :each |
				self markEscaped: each inTable: trackedVariablesTable.
				^ self ] ].

		unwrapVariableName := trackedVariablesTable at: unwrapVariableName ].

	(trackedVariablesTable at: unwrapVariableName ) ifFalse: [
		trackedVariablesTable at: unwrapVariableName put: true ]
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> markVariableAsEscaped: aVariableNode [

	variablesTable at: aVariableNode name put: true
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> saveHistoryOfEscapedArgsOf: aMethod from: aVarTable [

	treatedMethodsEscapeHistory
		at: aMethod name
		put: (aVarTable associationsSelect: [ :each |
				 (aMethod argumentNames includes: each key) and: [ self unwrapVarPointersOf: each key fromTable: aVarTable ] ])
]

{ #category : 'initialization' }
EscapeAnalyzer >> setReturnedFlag: aBoolean [

	currentMethodIsReturned := aBoolean
]

{ #category : 'adding' }
EscapeAnalyzer >> setWorkListReturnStatus: aCollection [

	workListReturnStatus := aCollection
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> unwrapVarPointersOf: aVariableName fromTable: trackedVariablesTable [

	| unwrapVariableName |
	unwrapVariableName := aVariableName shallowCopy.
	[
	(trackedVariablesTable at: unwrapVariableName ifAbsent: [  ])
		isSymbol
	| (trackedVariablesTable at: unwrapVariableName ifAbsent: [  ])
			isCollection ] whileTrue: [
		(trackedVariablesTable at: unwrapVariableName) isString not ifTrue: [
			(trackedVariablesTable at: unwrapVariableName) do: [ :each |
				(self unwrapVarPointersOf: each fromTable: trackedVariablesTable)
					ifTrue: [ ^ true ] ].
			^ false ].

		unwrapVariableName := trackedVariablesTable at: unwrapVariableName ].

	^ trackedVariablesTable at: unwrapVariableName
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> updateTrackedVariableName: association forMethod: methodName [

trackVariableNameChanges ifNil:[ trackVariableNameChanges:= Dictionary new ].
trackVariableNameChanges at: methodName update: [ :v | v add: association ] initial: [  OrderedCollection newFrom: {association}].
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer >> upperMostDeclarationName: name [

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
EscapeAnalyzer >> variablesTable [
	^ variablesTable
]

{ #category : 'accessing' }
EscapeAnalyzer >> variablesTable: aDictionary [

	variablesTable:= aDictionary .
]

{ #category : 'accessing' }
EscapeAnalyzer >> workList [

	^ workList
]
