"
Block analysis is inspired by the liveness analysis done for temp vector construction.
At the entry of the block the tracked variables are checked to see if they are accessed or not.


"
Class {
	#name : 'EscapeAnalyzerVisitor',
	#superclass : 'ASTProgramNodeVisitor',
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

{ #category : 'visiting' }
EscapeAnalyzerVisitor >> addContext: returnStateOfMessage to: escapeAnalyzer forImplementors: implementors [

	implementors size timesRepeat: [
		| newMessageContext |
		newMessageContext := EAMethodContext new escapeAnalysisContext:
			                     escapeAnalyzer context.
		newMessageContext returnStatus: returnStateOfMessage.
		escapeAnalyzer extendCtxList: newMessageContext.
		escapeAnalyzer addCurrentMethodReturnStatus: returnStateOfMessage ]
]

{ #category : 'adding' }
EscapeAnalyzerVisitor >> addCurrentMethodReturnStatus: aBoolean [

	workListReturnStatus add: aBoolean .
]

{ #category : 'adding' }
EscapeAnalyzerVisitor >> addMethodsToWorkList: aMethodCollection [

	workList addAll: aMethodCollection
]

{ #category : 'adding' }
EscapeAnalyzerVisitor >> addTrackingTableForElements: aTrackedVariablesTable [

	trackingTablesList add: aTrackedVariablesTable.
]

{ #category : 'testing' }
EscapeAnalyzerVisitor >> analyzeMethod: aMethod [

	| savedStateOfReturnFlag |
	savedStateOfReturnFlag := self currentMethodIsReturned.

	aMethod ast body children do: [ :child |
		(child isMessage and: [ child parent isReturn ])
			ifTrue: [ child acceptVisitor: self ]
			ifFalse: [
				self setReturnedFlag: savedStateOfReturnFlag.
				(child isReturn and: [ topLevel ]) ifTrue: [
					self setReturnedFlag: true ].
				child acceptVisitor: self
				"savedStateOfReturnFlag := self currentMethodIsReturned." ] ]
]

{ #category : 'testing' }
EscapeAnalyzerVisitor >> checkEscaped: aName [

	^ context checkEscaped: aName
]

{ #category : 'queries' }
EscapeAnalyzerVisitor >> checkNethodIsTreated: aMethod [

	^ ((context workingList indexOf: aMethod) < context workingListIndex)
	not
]

{ #category : 'testing' }
EscapeAnalyzerVisitor >> checkNode: anASTNode trackedIn: aTable [

	anASTNode isVariable ifFalse: [
		anASTNode isBlock ifTrue: [
			^ self checkVariable: anASTNode asString in: aTable ].
		^ false ].
	^ self checkVariable: anASTNode variable name in: aTable
]

{ #category : 'testing' }
EscapeAnalyzerVisitor >> checkVariable: anVariableNode in: aTable [

	([(aTable includesKey: anVariableNode )] on: SubscriptOutOfBounds do: [ false ])
		ifTrue: [ ^ true ].
	^ false
]

{ #category : 'accessing' }
EscapeAnalyzerVisitor >> context [

	^ context
]

{ #category : 'accessing' }
EscapeAnalyzerVisitor >> context: anEscapeAnalysisContext [

	context := anEscapeAnalysisContext.

	^ context
]

{ #category : 'queries' }
EscapeAnalyzerVisitor >> currentMethodIsReturned [

	^ currentMethodIsReturned ifNil:[ false ]
]

{ #category : 'adding' }
EscapeAnalyzerVisitor >> currentMethodReturnStatus [

	^ workListReturnStatus removeFirst
]

{ #category : 'accessing' }
EscapeAnalyzerVisitor >> currentTrackedVars [

	^ currentTrackedVars
]

{ #category : 'testing' }
EscapeAnalyzerVisitor >> escapeAnalyze: method [

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
EscapeAnalyzerVisitor >> extendCtxList: aContext [

	ctxList add: aContext
]

{ #category : 'queries' }
EscapeAnalyzerVisitor >> findVariableByName: anASTNode [

anASTNode isVariable ifFalse: [
		anASTNode isBlock ifTrue: [
			^ context findVariableByName: anASTNode asString  ].
		^ nil ].
	^ context findVariableByName: anASTNode variable name

]

{ #category : 'queries' }
EscapeAnalyzerVisitor >> findVariableByNameSymbol: aVariableName [

	^ context findVariableByName: aVariableName
]

{ #category : 'queries' }
EscapeAnalyzerVisitor >> getTrackVariableNames [

	^ context TVNames
]

{ #category : 'initialization' }
EscapeAnalyzerVisitor >> initialize [

	context := EscapeAnalysisContext new.
	ctxList := OrderedCollection new.
	savedFirstCtxRef := context.
	self extendCtxList: context
]

{ #category : 'testing' }
EscapeAnalyzerVisitor >> isAtTopLevel [

	^ topLevel
]

{ #category : 'testing' }
EscapeAnalyzerVisitor >> isSpecialMethod: aMethodSelector [

	^ { 'new'. 'value' } includes: aMethodSelector
]

{ #category : 'testing' }
EscapeAnalyzerVisitor >> isTrackedNode: anASTNode [

	^ (self findVariableByName: anASTNode) isNotNil
]

{ #category : 'testing' }
EscapeAnalyzerVisitor >> isTrackedTempVariable: anVariableNode [

	(variablesTable includesKey: anVariableNode variable name)
		ifTrue: [ ^ true ].
	^ false
]

{ #category : 'testing' }
EscapeAnalyzerVisitor >> isTrackedVariable: anVariableNode [

	(variablesTable includesKey: anVariableNode variable name)
		ifTrue: [ ^ true ].
	^ false
]

{ #category : 'analyse' }
EscapeAnalyzerVisitor >> markEscaped: aVariableName inTable: trackedVariablesTable [

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
EscapeAnalyzerVisitor >> markVariableAsEscaped: aVariableNode [

	| aVariable |
	(aVariable := context findVariableByName: aVariableNode name)
		ifNotNil: [
			aVariable markEscaped.
			^ true ].
	" in case the variable is not defined define it"
	1 halt
]

{ #category : 'initialization' }
EscapeAnalyzerVisitor >> setReturnedFlag: aBoolean [

	currentMethodIsReturned := aBoolean
]

{ #category : 'adding' }
EscapeAnalyzerVisitor >> setWorkListReturnStatus: aCollection [

	workListReturnStatus := aCollection
]

{ #category : 'testing' }
EscapeAnalyzerVisitor >> trackVariable: aVariableNodeName [

	(self isTrackedNode: aVariableNodeName) ifFalse: [
		^ context trackVariable: aVariableNodeName ].
	^ context findVariableByName: aVariableNodeName
]

{ #category : 'analyse' }
EscapeAnalyzerVisitor >> updateTrackedVariableName: association forMethod: methodName [

trackVariableNameChanges ifNil:[ trackVariableNameChanges:= Dictionary new ].
trackVariableNameChanges at: methodName update: [ :v | v add: association ] initial: [  OrderedCollection newFrom: {association}].
]

{ #category : 'analyse' }
EscapeAnalyzerVisitor >> upperMostDeclarationName: name [

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
EscapeAnalyzerVisitor >> variablesTable [
	^ variablesTable
]

{ #category : 'accessing' }
EscapeAnalyzerVisitor >> variablesTable: aDictionary [

	variablesTable:= aDictionary .
]

{ #category : 'visiting' }
EscapeAnalyzerVisitor >> visitAssignmentNode: aNode [

	(self isTrackedNode: aNode value)
		ifFalse: [
			 self visitNode: aNode value.

			(aNode value isBlock and: [
				 self isTrackedNode: aNode value ]) ifTrue: [ 
				| variableNode |
				(variableNode := self findVariableByName: aNode variable)
					ifNil: [
					variableNode := self trackVariable: aNode variable name ].
				variableNode addReferenceToTrackedVariable:
					(self findVariableByName: aNode value) ] ]
		ifTrue: [
			({ #isClassVariable. #isGlobalVariable. #isInstanceVariable }
				 asOrderedCollection anySatisfy: [ :e | aNode variable perform: e ])
				ifTrue: [
					self markVariableAsEscaped: aNode value.
					^ aNode ] ]
]

{ #category : 'visiting' }
EscapeAnalyzerVisitor >> visitBlockNode: aBlockNode [
	" treat following cases:
1- when the value returned is tracked you must follow the blockNode as a variable and see where it is assigned 
2- add track to a variable if it is assigned to a tracked variable

then whenever a variable is escaped this must bubble up until the returned variable in the block node
	"

	| catchReturnedVariableName returnValue referencedTrackedVariables trackedBlockNode |
	"dont analyze the code inside too much just check if a variable is sent to it then assume the block as tracked, if so the value is to""escapeAnalyzer analyzeBlockClosure: self inAst: escapeAnalyzer currentMethod ast body ."
	(referencedTrackedVariables := self getTrackVariableNames
		                               select: [ :variable |
		                               aBlockNode references: variable ])
		ifNotEmpty: [ "
	returnValue := 'self'.

	self body children do: [ :child |
		child isReturn
			ifTrue: [
				catchReturnedVariableName := child
					                             treatNode: escapeAnalyzer
					                             given: trackedVariablesTable.

				catchReturnedVariableName ifNotNil: [
					trackedVariablesTable
						at: (self blockNameTracksVarNamed: catchReturnedVariableName)
						put: catchReturnedVariableName.
					returnValue := catchReturnedVariableName ] ]
			ifFalse: [
				returnValue := child
					               treatNode: escapeAnalyzer
					               given: trackedVariablesTable.
				child isVariable ifFalse: [ returnValue := 'self' ] ] ].

	^ returnValue"
			trackedBlockNode := self  trackVariable: aBlockNode. "namePrefixedWithClassAndMethod:
					                     escapeAnalyzer" " later to be corrected to support all path of the method"
			trackedBlockNode referencesTV: referencedTrackedVariables ]
]

{ #category : 'visiting' }
EscapeAnalyzerVisitor >> visitMessageNode: aMessageNode [

	| implementors nodesToTreat "newTrackedVariablesTable" listOfNewTrackedVariableTables |
	"Treat only the arguments that are variables and the receiver"
	nodesToTreat := { aMessageNode receiver } , aMessageNode arguments.
	implementors := aMessageNode selector implementors.
	listOfNewTrackedVariableTables := OrderedCollection new.

	(nodesToTreat anySatisfy: [ :e |
		 (self findVariableByName: e) isNotNil ]) ifTrue: [
		(self isSpecialMethod: aMessageNode selector)
			ifFalse: [
				(self workList size < 500 and: [ implementors size < 5 ])
					ifTrue: [
						| returnStateOfMessage |
						returnStateOfMessage := false.

						((aMessageNode allParents anySatisfy: #isReturn) and: [
							 self isAtTopLevel ]) ifTrue: [
							self setReturnedFlag: true.
							returnStateOfMessage := self currentMethodReturnStatus ].
						self
							addContext: returnStateOfMessage
							to: self
							forImplementors: implementors.

						listOfNewTrackedVariableTables do: [ :trackedVarTable |
							self addTrackingTableForElements: trackedVarTable ].
						self addMethodsToWorkList: implementors ]
					ifFalse: [
						(nodesToTreat select: [ :n |
							 (self findVariableByName: n) isNotNil ]) do: [ :node |
							self markVariableAsEscaped: node ] ] ]
			ifTrue: [
				aMessageNode selector = #value ifTrue: [
					self markVariableAsEscaped: aMessageNode receiver name ] ] ].

	aMessageNode children do: [ :node | node acceptVisitor: self ]
]

{ #category : 'visiting' }
EscapeAnalyzerVisitor >> visitReturnNode: aNode [

	| returnsThisVar |
	returnsThisVar := nil.
	aNode children do: [ :node |
		(node isVariable and: [
			 (self currentMethodIsReturned or: [
				  aNode allParents anySatisfy: #isBlock ]) and: [
				 self isTrackedNode: node ] ])
			ifTrue: [
				returnsThisVar := node variable name.
				self currentMethodIsReturned ifTrue: [
					self markVariableAsEscaped: node variable
					"Further checks to allow for returned variables in case of local senders." ] ]
			ifFalse: [ self visitNode: node ] ].

	^ returnsThisVar
]

{ #category : 'visiting' }
EscapeAnalyzerVisitor >> visitVariableNode: aNode [

	^ aNode name
]

{ #category : 'accessing' }
EscapeAnalyzerVisitor >> workList [

	^ workList
]
