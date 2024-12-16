Class {
	#name : 'EscapeAnalyzer1',
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
		'workListReturnStatus'
	],
	#category : 'EscapeAnalysisXP-Core',
	#package : 'EscapeAnalysisXP',
	#tag : 'Core'
}

{ #category : 'adding' }
EscapeAnalyzer1 >> addCurrentMethodReturnStatus: aBoolean [

	workListReturnStatus add: aBoolean .
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer1 >> addMethodsToWorkList: aMethodCollection [

	workList addAll: aMethodCollection
]

{ #category : 'adding' }
EscapeAnalyzer1 >> addTrackingTableForElements: aTrackedVariablesTable [

	trackingTablesList add: aTrackedVariablesTable.
]

{ #category : 'testing' }
EscapeAnalyzer1 >> analyze2: method [

	| next tempVariables |
	tempVariables := method ast body temporaryVariables.
	variablesTable := Dictionary
		                  newFromKeys: tempVariables
		                  andValues:
		                  (Array new: tempVariables size withAll: false).

	workList := CallGraph new.
	workList addCaller:  method.
	treatedMethods := OrderedCollection new.
	[ workList isNotEmpty ] whileTrue: [
		treatedMethods add: (next := workList nextCall key).
		(trackVariableNameChanges isNotNil) ifTrue: [   
		( trackVariableNameChanges includesKey: next selector)
			ifTrue: [
				(trackVariableNameChanges at: next selector) do: [ :association |
					variablesTable
						at: association key
						put:
						(variablesTable removeKey: association value ifAbsent: [  ]) ].
				self analyzeMethod2: next.
				trackVariableNameChanges
					at: next selector
					ifPresent: [ :associations |
						associations do: [ :association |
							variablesTable
								at: association value
								put: (variablesTable removeKey: association key) ] ] ]
			ifFalse: [ self analyzeMethod2: next ] ] ifFalse: [
			self analyzeMethod2: next key
			]]
]

{ #category : 'testing' }
EscapeAnalyzer1 >> analyze3: method [

	| next tempVariables |
	tempVariables := method ast body temporaryVariables.
	variablesTable := Dictionary
		                  newFromKeys: tempVariables
		                  andValues:
		                  (Array new: tempVariables size withAll: false).

	workList := OrderedCollection with: method.
	treatedMethods := OrderedCollection new.
	[ workList isNotEmpty ] whileTrue: [
		treatedMethods add: (next := workList removeFirst).
		trackVariableNameChanges isNotNil
			ifTrue: [
				(trackVariableNameChanges includesKey: next selector)
					ifTrue: [
						(trackVariableNameChanges at: next selector) do: [ :association |
							variablesTable
								at: association key
								put:
								(variablesTable removeKey: association value ifAbsent: [  ]) ].
						self analyzeMethod2: next.
						trackVariableNameChanges
							at: next selector
							ifPresent: [ :associations |
								associations do: [ :association |
									variablesTable
										at: association value
										put: (variablesTable removeKey: association key) ] ] ]
					ifFalse: [ self analyzeMethod2: next ] ]
			ifFalse: [ self analyzeMethod2: next ] ]
]

{ #category : 'testing' }
EscapeAnalyzer1 >> analyze: method [

	| next tempVariables |
	tempVariables := method ast body temporaryVariables.
	variablesTable := Dictionary
		                  newFromKeys: tempVariables
		                  andValues:
		                  (Array new: tempVariables size withAll: false).

	workList := OrderedCollection with: method.
	treatedMethods := OrderedCollection new.
	[ workList isNotEmpty ] whileTrue: [
		treatedMethods add: (next := workList removeLast).
		(trackVariableNameChanges isNotNil) ifTrue: [   
		( trackVariableNameChanges includesKey: next selector)
			ifTrue: [
				(trackVariableNameChanges at: next selector) do: [ :association |
					variablesTable
						at: association key
						put:
						(variablesTable removeKey: association value ifAbsent: [  ]) ].
				self analyzeMethod: next.
				trackVariableNameChanges
					at: next selector
					ifPresent: [ :associations |
						associations do: [ :association |
							variablesTable
								at: association value
								put: (variablesTable removeKey: association key) ] ] ]
			ifFalse: [ self analyzeMethod: next ] ] ifFalse: [
			self analyzeMethod: next
			]]
]

{ #category : 'testing' }
EscapeAnalyzer1 >> analyzeMethod2: aMethod [

	aMethod ast body children do: [ :child | child treatNode2: self ]
]

{ #category : 'testing' }
EscapeAnalyzer1 >> analyzeMethod: aMethod [

	aMethod ast body children do: [ :child | child treatNode: self ]
]

{ #category : 'testing' }
EscapeAnalyzer1 >> analyzeMethod: aMethod withTrackedVariables: aTrackedVariablesTable [

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
EscapeAnalyzer1 >> checkNode: anASTNode trackedIn: aTable [

	anASTNode isVariable ifFalse: [ ^ false ].
	^ self checkVariable: anASTNode in: aTable
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer1 >> checkVariable: anVariableNodeName in: aTable [

	([(aTable includesKey: anVariableNodeName)] on: SubscriptOutOfBounds do: [ false ])
		ifTrue: [ ^ true ].
	^ false
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer1 >> checkVariableName: anVariableNodeName in: aTable [

	([ aTable includesKey: anVariableNodeName ]
		 on: SubscriptOutOfBounds
		 do: [ false ]) ifTrue: [ ^ true ].
	^ false
]

{ #category : 'accessing' }
EscapeAnalyzer1 >> currentMethodIsReturned [

	^ currentMethodIsReturned ifNil:[ false ]
]

{ #category : 'adding' }
EscapeAnalyzer1 >> currentMethodReturnStatus [

	^ workListReturnStatus removeFirst
]

{ #category : 'testing' }
EscapeAnalyzer1 >> escapeAnalyze: method [

	| next tempVariables currentTrackVarsTable treatedMethodsNotToLoopBackTO |
	tempVariables := method ast body temporaryVariables.
	
	tempVariables:= tempVariables collect: [ :tempVar | method classBinding name ,'_', method selector, '_', tempVar ].
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
		(treatedMethodsNotToLoopBackTO includes: next name) ifFalse: [ " these two conditions are significantly increasing analysis duration"
			treatedMethodsNotToLoopBackTO add: next name.
			trackingTablesList ifNotEmpty: [ " this one too "
				currentTrackVarsTable := trackingTablesList removeFirst ].

			
			self
				analyzeMethod: next
				withTrackedVariables: currentTrackVarsTable.
			topLevel := false ] ].

	variablesTable := currentTrackVarsTable
]

{ #category : 'initialization' }
EscapeAnalyzer1 >> followReturnedValueFlag [

	^ followReturnedValue
]

{ #category : 'testing' }
EscapeAnalyzer1 >> isSpecialMethod: aMethodSelector [

	^ { 'new' . 'value'} includes: aMethodSelector
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer1 >> isTrackedNode: anASTNode [

	anASTNode isVariable ifFalse: [ ^ false ].
	^ self isTrackedTempVariable: anASTNode
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer1 >> isTrackedTempVariable: anVariableNode [

	(variablesTable includesKey: anVariableNode variable name)
		ifTrue: [ ^ true ].
	^ false
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer1 >> markEscaped: aVariableName inTable: trackedVariablesTable [

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
EscapeAnalyzer1 >> markVariableAsEscaped: aVariableNode [

	variablesTable at: aVariableNode name put: true
]

{ #category : 'testing' }
EscapeAnalyzer1 >> populateWorkList: aMethod [

	aMethod ast body allChildren
		select: [ :node | node isMessage ]
		thenDo: [ :node | node treatNode: self ]
]

{ #category : 'initialization' }
EscapeAnalyzer1 >> setFollowReturnedValueFlag: aBoolean [

	^ followReturnedValue := aBoolean
]

{ #category : 'initialization' }
EscapeAnalyzer1 >> setReturnedFlag: aBoolean [

	currentMethodIsReturned := aBoolean
]

{ #category : 'adding' }
EscapeAnalyzer1 >> setWorkListReturnStatus: aCollection [

	workListReturnStatus := aCollection
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer1 >> updateTrackedVariableName: association forMethod: methodName [

trackVariableNameChanges ifNil:[ trackVariableNameChanges:= Dictionary new ].
trackVariableNameChanges at: methodName update: [ :v | v add: association ] initial: [  OrderedCollection newFrom: {association}].
]

{ #category : 'as yet unclassified' }
EscapeAnalyzer1 >> upperMostDeclarationName: name [

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
EscapeAnalyzer1 >> variablesTable [
	^ variablesTable
]

{ #category : 'accessing' }
EscapeAnalyzer1 >> variablesTable: aDictionary [

	variablesTable:= aDictionary .
]

{ #category : 'accessing' }
EscapeAnalyzer1 >> workList [

	^ workList
]
