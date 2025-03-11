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
		'currentTrackedVars',
		'context',
		'ctxList',
		'savedFirstCtxRef',
		'eaHistory',
		'allowedDepth',
		'setWorklistLimitation',
		'escapeLog',
		'workListSizeLimit',
		'analysisStats',
		'ctxCounter'
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
		escapeAnalyzer extendCtxList: newMessageContext ]
]

{ #category : 'visiting' }
EscapeAnalyzerVisitor >> addContext: returnStateOfMessage to: escapeAnalyzer forImplementors: implementors andCallSiteNodes: nodes [

	1 to: implementors size do: [ :i |
		| newMessageContext newMethodArguments newMethodArgumentsNodes |
		newMethodArgumentsNodes := OrderedCollection new.
		newMessageContext := EAMethodContext new escapeAnalysisContext:
			                     escapeAnalyzer context.
		newMessageContext returnStatus: returnStateOfMessage.
		newMessageContext analysisDepth: context analysisDepth + 1.
		newMessageContext associatedMethod: (implementors at: i).

		newMethodArguments := (implementors at: i) argumentNames
			                      asOrderedCollection.
		newMethodArguments addFirst: #self.
		newMethodArguments doWithIndex: [ :argName :index |
			| newTrackedVariable |
			newTrackedVariable := newMessageContext trackVariable: argName.
			(escapeAnalyzer isTrackedNode: (nodes at: index)) ifTrue: [
				newTrackedVariable referencesTV:
					(escapeAnalyzer findVariableByName: (nodes at: index)) ].
			newMethodArgumentsNodes add: newTrackedVariable ].
	
		(self isMethodTreated: (implementors at: i))
			ifTrue: [

				(self
					 retrieveHistoryOf: (implementors at: i)
					 given: newMethodArgumentsNodes) ifTrue: [ ^ self ] ]
			ifFalse: [ escapeAnalyzer extendCtxList: newMessageContext ] ]
]

{ #category : 'adding' }
EscapeAnalyzerVisitor >> addMethodsToWorkList: aMethodCollection [

	workList addAll: aMethodCollection
]

{ #category : 'adding' }
EscapeAnalyzerVisitor >> addStat: anArray of: amethod [

	analysisStats addStat: anArray of: amethod 
]

{ #category : 'accessing' }
EscapeAnalyzerVisitor >> allowedDepth [

	^ allowedDepth
]

{ #category : 'accessing' }
EscapeAnalyzerVisitor >> allowedDepth: aDepth [

	allowedDepth := aDepth
]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitor >> allowedWorklistSize [

	workListSizeLimit
]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitor >> allowedWorklistSize: asize [

	workListSizeLimit := asize
]

{ #category : 'accessing' }
EscapeAnalyzerVisitor >> analysisStats [

	^ analysisStats 
]

{ #category : 'analyse' }
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

{ #category : 'visiting' }
EscapeAnalyzerVisitor >> blockReferencesTVs: aBlockNode [

	^ self getTrackVariableNames select: [ :variable |
		  aBlockNode references: (self unravelLocalName: variable) ]
]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitor >> checkMessageAlreadyAddedToWorkingList: aMessageNode [

| indexOfSimilarContext contextWorklist|
contextWorklist := ctxList collect: #associatedMethod.
indexOfSimilarContext := ( contextWorklist collect: #selector ) indexOf: aMessageNode selector.
( indexOfSimilarContext	 ~= 0 )ifTrue: [ 
		self linkArgumentsOf: aMessageNode.
		^true.
		 ].
	^false.
]

{ #category : 'accessing' }
EscapeAnalyzerVisitor >> context [

	^ context
]

{ #category : 'accessing' }
EscapeAnalyzerVisitor >> context: anEscapeAnalysisContext [

	context := anEscapeAnalysisContext.
]

{ #category : 'analyse' }
EscapeAnalyzerVisitor >> contxtCounterForCurrentMethod [

	^ ctxCounter
]

{ #category : 'analyse' }
EscapeAnalyzerVisitor >> ctxList [

	^ ctxList 
]

{ #category : 'queries' }
EscapeAnalyzerVisitor >> currentMethodIsReturned [

	^ currentMethodIsReturned ifNil:[ false ]
]

{ #category : 'accessing' }
EscapeAnalyzerVisitor >> currentTrackedVars [

	^ context trackedMethodArgs
]

{ #category : 'analyse' }
EscapeAnalyzerVisitor >> escapeAnalyze: method [

	| next tempVariables currentTrackVarsTable |
	tempVariables := method ast body temporaryVariables.
	topLevel := true.
	context associatedMethod: method.
	variablesTable := context trackVariables:
		                  method ast body allTemporaryVariables .
	workList := context extendWorkinglist: method.
	
	"	self addCurrentMethodReturnStatus: true."

	currentTrackVarsTable := variablesTable.
	self context: self removeFirstCtx.
	[
	self context isNotNil and: [
		(next := context currentMethod) isNotNil ] ] whileTrue: [
	self analyzeMethod: next.
		eaHistory addHistory: self context for: next.
		self context: self removeFirstCtx.
		" create a test with two calls for the same method implementeed once , with different tracking statuses for each argument at a time "
		topLevel := false ].
	
 	self resetContxtCounterForCurrentMethod.
	self addStat: ctxCounter copy of: method.
	
	self context: savedFirstCtxRef
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

{ #category : 'testing' }
EscapeAnalyzerVisitor >> getNonEscapingVariables [



	^ savedFirstCtxRef trackedMethodArgs  select: [ :e | e escapeStatus not ].
]

{ #category : 'queries' }
EscapeAnalyzerVisitor >> getTrackVariableNames [

	^ context TVNames
]

{ #category : 'accessing' }
EscapeAnalyzerVisitor >> history [

	^ eaHistory 
]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitor >> implementorsOfAstMessage: aMessageNode [

	| receiverAbstarctVariable |
	receiverAbstarctVariable := self findVariableByName:
		                            aMessageNode receiver.
	receiverAbstarctVariable ifNotNil: [
		receiverAbstarctVariable hasType ifTrue: [
			| aSingleMethod |
			aSingleMethod := receiverAbstarctVariable type lookupSelector:
				                 aMessageNode selector. "consider reassignment of the var to upper type, then we need to treat all implementations of the hierarchy instead of looking up the first one."
			aSingleMethod ifNotNil: [ ^{ aSingleMethod} asOrderedCollection ] ] ]
	ifNil: [ 
		aMessageNode receiver isSelfVariable ifTrue: [
			|aSingleMethod|
			aSingleMethod :=	self context currentMethod classBinding value lookupSelector:
				                 aMessageNode selector.
			aSingleMethod ifNotNil: [ ^{ aSingleMethod} asOrderedCollection].
			]
		
		
		 ]
	
	.

	^ aMessageNode selector implementors
]

{ #category : 'analyse' }
EscapeAnalyzerVisitor >> incrementContxtCounterForCurrentMethod [

	ctxCounter := ctxCounter + 1
]

{ #category : 'initialization' }
EscapeAnalyzerVisitor >> initialize [

	context := EscapeAnalysisContext new.
	context analysisDepth: 1.
	context returnStatus: true.
	setWorklistLimitation := false.
	ctxList := OrderedCollection new.
	savedFirstCtxRef := context.
	self extendCtxList: context.
	escapeLog := Dictionary new.
	trackVariableNameChanges := Dictionary new.
	self setReturnedFlag: false.
	eaHistory := EscapeAnalysisHistory new.
	allowedDepth := 3.
	analysisStats := AnalysisStats new.
	ctxCounter := 0
]

{ #category : 'testing' }
EscapeAnalyzerVisitor >> isAtTopLevel [

	^ topLevel
]

{ #category : 'queries' }
EscapeAnalyzerVisitor >> isMethodTreated: aMethod [

	^ eaHistory isImplementorTreated: aMethod
]

{ #category : 'testing' }
EscapeAnalyzerVisitor >> isSpecialMethod: aMethodSelector [

	^ { #new. #value, #shouldNotImplement, #valueNoContextSwitch } includes: aMethodSelector
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
EscapeAnalyzerVisitor >> isVariableEscaped: aName [

	^ savedFirstCtxRef isVariableEscaped: aName
]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitor >> linkArgumentsOf: aMessageNode [



]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitor >> linkArgumentsOf: aMessageNode toTrackedVarsOfContext: aContext [



]

{ #category : 'analyse' }
EscapeAnalyzerVisitor >> markVariableAsEscaped: aVariableNode [

	| aVariable |
	(aVariable := context findVariableByName: aVariableNode name)
		ifNotNil: [
			escapeLog
				at: (context globallyDistinctName: aVariableNode name)
				put: context.
			" in case the variable is not defined define it"
			aVariable markEscaped.
			^ true ]
]

{ #category : 'analyse' }
EscapeAnalyzerVisitor >> removeFirstCtx [
	self incrementContxtCounterForCurrentMethod.
		ctxList isNotEmpty ifTrue: [ ^ ctxList removeFirst ].

	^ nil
]

{ #category : 'initialization' }
EscapeAnalyzerVisitor >> reset [

	context analysisDepth: context analysisDepth.
	context := EscapeAnalysisContext new.
	context analysisDepth: 1.
	context returnStatus: true.
	"setWorklistLimitation := false."
	ctxList := OrderedCollection new.
	savedFirstCtxRef := context.
	self extendCtxList: context.
	escapeLog := Dictionary new.
	trackVariableNameChanges := Dictionary new.
	self setReturnedFlag: false.
	eaHistory := EscapeAnalysisHistory new.
	"allowedDepth := 3."
	analysisStats := AnalysisStats new.
	ctxCounter := 0
]

{ #category : 'analyse' }
EscapeAnalyzerVisitor >> resetContxtCounterForCurrentMethod [

	 ctxCounter := 0.
]

{ #category : 'testing' }
EscapeAnalyzerVisitor >> resetThenTrackVariable: aVariableNodeName [

	| trackedVar |
	(self isTrackedNode: aVariableNodeName) ifTrue: [
		context unTrackVariable: aVariableNodeName ].
	^ context trackVariable: aVariableNodeName name
]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitor >> retrieveHistoryOf: aCompiledMethod given: argNames [

	^ eaHistory
		  adjudicateHistoryRetrievalOf: aCompiledMethod
		  givenCurrentArguments: argNames
]

{ #category : 'initialization' }
EscapeAnalyzerVisitor >> setReturnedFlag: aBoolean [

	currentMethodIsReturned := aBoolean
]

{ #category : 'initialization' }
EscapeAnalyzerVisitor >> setTypeForPseudoVariable: aVariableNode inRepresentingObject: aTrackedVariable [

	aVariableNode isSelfVariable ifTrue: [ 
		
		self setTypeOf: aTrackedVariable as: (self context currentMethod classBinding value)
		
		 ] ifFalse: [ 
		
		"then it is super"
		self setTypeOf: aTrackedVariable as: (self context currentMethod classBinding value) superclass.
		
		 ]
]

{ #category : 'initialization' }
EscapeAnalyzerVisitor >> setTypeOf: aTV as: aClass [

	aTV type: aClass
]

{ #category : 'accessing' }
EscapeAnalyzerVisitor >> setWorklistLimitation: aSize [
	"comment stating purpose of instance-side method"

	"scope: class-variables  &  instance-variables"

	self allowedWorklistSize: aSize.

	setWorklistLimitation := true
]

{ #category : 'visiting' }
EscapeAnalyzerVisitor >> shouldConsiderImplementors: implementors [

	^ "(self workList size < 3000 ""and: [ implementors size < 5 ]"") and: [
		  context analysisDepth < allowedDepth ]"
 setWorklistLimitation	ifTrue: [ (self workList size < workListSizeLimit ) and: [context analysisDepth < allowedDepth]] ifFalse: [ 
		(context analysisDepth < allowedDepth ) 
		]
]

{ #category : 'asserting' }
EscapeAnalyzerVisitor >> shouldTrackBlock: aBlock [

	^ (self blockReferencesTVs: aBlock ) isNotEmpty 
]

{ #category : 'testing' }
EscapeAnalyzerVisitor >> trackVariable: aVariableNodeName [

	(self isTrackedNode: aVariableNodeName) ifFalse: [
		^ context trackVariable: aVariableNodeName name ].
	^ context findVariableByName: aVariableNodeName name
]

{ #category : 'as yet unclassified' }
EscapeAnalyzerVisitor >> unravelLocalName: agloballyDistinctVariableName [

	^ (agloballyDistinctVariableName splitOn: '_') last
]

{ #category : 'analyse' }
EscapeAnalyzerVisitor >> updateTrackedVariableName: association forMethod: methodName [

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
			( self isTrackedNode: aNode variable ) ifTrue: [
				|abstractVariable|
				abstractVariable := self findVariableByName: aNode variable.
				
				(aNode value isMessage
 and: [ aNode value selector = #new ] ) ifTrue: [ 
		self setTypeOf: abstractVariable as: (Smalltalk at: aNode value receiver name ifAbsent: nil).
		aNode value receiver isSelfOrSuperVariable ifTrue: [ self setTypeForPseudoVariable: aNode value receiver inRepresentingObject: abstractVariable ]
	  ] ifFalse: [
		aNode value isSelfOrSuperVariable ifTrue: [ 
				self setTypeForPseudoVariable: aNode value inRepresentingObject: abstractVariable .
			
			 ]
	].

	].
			(aNode value isBlock and: [ self isTrackedNode: aNode value ])
				ifTrue: [
					| variableNode |
					(variableNode := self findVariableByName: aNode variable) ifNil: [
						variableNode := self trackVariable: aNode variable name ].
					variableNode addReferenceToTrackedVariable:
						(self findVariableByName: aNode value) ] ]
		ifTrue: [
		|abstractVariable abstractValue|
			aNode variable isClassVariable ifTrue: [
				self markVariableAsEscaped: aNode value.
				^ self ].
			aNode variable isInstanceVariable ifTrue: [
				self markVariableAsEscaped: aNode value.
				^ self ].
			aNode variable isGlobalVariable ifTrue: [
				self markVariableAsEscaped: aNode value.
				^ self ]. 
			abstractVariable := 	self resetThenTrackVariable: aNode variable.
				abstractValue := self findVariableByName: aNode value.
				abstractValue hasType ifTrue: [ self setTypeOf: abstractVariable as: (abstractValue) type . ].
 
			 ]
]

{ #category : 'visiting' }
EscapeAnalyzerVisitor >> visitBlockNode: aBlockNode [
	" treat following cases:
1- when the value returned is tracked you must follow the blockNode as a variable and see where it is assigned 
2- add track to a variable if it is assigned to a tracked variable

then whenever a variable is escaped this must bubble up until the returned variable in the block node
	"

	| referencedTrackedVariables trackedBlockNode |
	(referencedTrackedVariables := self blockReferencesTVs: aBlockNode)
		ifNotEmpty: [
			trackedBlockNode := self trackVariable: aBlockNode.

			trackedBlockNode referencesTV:
				(referencedTrackedVariables collect: [ :v |
					 self findVariableByNameSymbol: (self unravelLocalName: v) ]) ]
]

{ #category : 'visiting' }
EscapeAnalyzerVisitor >> visitMessageNode: aMessageNode [

	| implementors nodesToTreat listOfNewTrackedVariableTables followTheseNodes |
	"Treat only the arguments that are variables and the receiver"
	nodesToTreat := { aMessageNode receiver } , aMessageNode arguments.
	
	implementors := self implementorsOfAstMessage: aMessageNode.
	listOfNewTrackedVariableTables := OrderedCollection new.
	followTheseNodes := nodesToTreat select: [ :e |
		(e isBlock and: [ self shouldTrackBlock: e ]) ifTrue: [ 
 				self trackVariable: e.
				true.
			 ] ifFalse: [
			(self findVariableByName: e ) isNotNil
			].
		                     ].
	followTheseNodes isNotEmpty ifTrue: [
		(self isSpecialMethod: aMessageNode selector)
			ifFalse: [
				(self shouldConsiderImplementors: implementors)
					ifTrue: [
						| returnStateOfMessage |
						returnStateOfMessage := false.

						((aMessageNode allParents anySatisfy: #isReturn) and: [
							 self isAtTopLevel ]) ifTrue: [
							self setReturnedFlag: true.
							returnStateOfMessage := context returnStatus ].
						self checkMessageAlreadyAddedToWorkingList: aMessageNode .
			
						self
							addContext: returnStateOfMessage
							to: self
							forImplementors: implementors
							andCallSiteNodes: nodesToTreat.

						self addMethodsToWorkList: implementors ]
					ifFalse: [
						(nodesToTreat select: [ :n |
							 (self findVariableByName: n) isNotNil ]) do: [ :node |
							self markVariableAsEscaped: node ] ] ]
			ifTrue: [
				aMessageNode selector = #value ifTrue: [
					self markVariableAsEscaped: aMessageNode receiver ] ] ].

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

{ #category : 'accessing' }
EscapeAnalyzerVisitor >> workList [

	^ workList
]
