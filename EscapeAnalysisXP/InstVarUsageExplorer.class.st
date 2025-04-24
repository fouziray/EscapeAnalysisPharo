Class {
	#name : 'InstVarUsageExplorer',
	#superclass : 'Object',
	#instVars : [
		'isAccessed',
		'mainVisitor',
		'sendersOfMessagesAfter',
		'logOfTreatedSenders'
	],
	#category : 'EscapeAnalysisXP-Core',
	#package : 'EscapeAnalysisXP',
	#tag : 'Core'
}

{ #category : 'instance creation' }
InstVarUsageExplorer class >> newWithMainVisitor: aVisitor [

	| newInstVarUsageExplorer |
	newInstVarUsageExplorer := self new.
	newInstVarUsageExplorer initialize.
	^ newInstVarUsageExplorer mainVisitor: aVisitor
]

{ #category : 'as yet unclassified' }
InstVarUsageExplorer >> analyseEscapeOf: aString from: anOCMessageNode [
|accessorVisitor logOfTreatedSelectors|
logOfTreatedSelectors:= Set new.
accessorVisitor := EscapeAnalyzerAccessorVisitor new.
anOCMessageNode do:[ :message |
		
	(mainVisitor isTrackedNode: message receiver) ifTrue:[
		
		].
	logOfTreatedSelectors add: message selector.
	 "message selector implementors do:[ :implm | mainVisitor   ]" "the first idea is to treat each implementor but we don t know the path that lead to the accessor ?? should we keep a log of senders ?"
	aString do:[ :methodThatUsesOrIsAccessor | 
			accessorVisitor escapeAnalyze: methodThatUsesOrIsAccessor. 
		].
	].
]

{ #category : 'as yet unclassified' }
InstVarUsageExplorer >> analyseEscapeOfAccessor: accessorsSenders [ 
	self shouldBeImplemented.
]

{ #category : 'as yet unclassified' }
InstVarUsageExplorer >> analyseEscapeOfAccessor: accessorsSenders of: aSelector [

	| accessorVisitor |
	accessorVisitor := EscapeAnalyzerAccessorVisitor new.
	accessorVisitor accessorSelector: aSelector.
	(accessorsSenders select: [ :e |
			 ((e ast body allChildren select: #isMessage) collect: [ :e |
				  e selector ]) includes: #a ]) do: [ :sender |
			1 halt.
		accessorVisitor escapeAnalyze: sender ]
]

{ #category : 'as yet unclassified' }
InstVarUsageExplorer >> exploreSendersOfAccessor: aString startingFrom: anOCMessageNode [ 
	| senders implementorsOfMessagesAfter lookIntoWithtoutCallGraphConstruction messagesAfter |
	self flag: 'collect classes of all treated methods, then only keep senders whose classes are compatible with them'.
	self flag: 'only treat the methods after the message node
	- one way is collecting messaegs after that msg. We name Mp these messages implementors, and Sn the senders of the accessors, we should restrict Sn to a lower subset whose elemets have at least one element Mp as potential sender'.
		mainVisitor.
		senders := aString senders.
		messagesAfter := anOCMessageNode methodNode sendNodes copyAfter: anOCMessageNode .
		implementorsOfMessagesAfter := ( messagesAfter collect: [:e | e selector implementors] ) flattened.
		
		lookIntoWithtoutCallGraphConstruction := ({senders, aString implementors}  asOrderedCollection ) flattened select: [ :sender | self sendersOf: sender matchAtLeastOneOf:  implementorsOfMessagesAfter  ]. "optim - necessary to directly look at the senders in question"
		 	1 halt.
		
 		"self analyseEscapeOf: lookIntoWithtoutCallGraphConstruction from: messagesAfter."
		self analyseEscapeOfAccessor: senders of: aString. 
self shouldBeImplemented.
]

{ #category : 'as yet unclassified' }
InstVarUsageExplorer >> exploreUsersOf: anOCVariableNode startingFrom: anEscapeAnalyzerVisitor [

	| refsToInstVar escVisitor |
	refsToInstVar := RBVariableEnvironment
		                 referencesToInstanceVariable:
		                 anOCVariableNode name asString
		                 in:
		                 anEscapeAnalyzerVisitor context associatedMethod
			                 classBinding value.
	"reuse escape analysis visitor but this time tracking only a single inst var"
	escVisitor := EscapeAnalyzerVisitor new.
	refsToInstVar methods do: [ :m |
			escVisitor escapeAnalyze: m trackingOnly: anOCVariableNode.
			(escVisitor findVariableByNameSymbol: anOCVariableNode name)
				escapeStatus ifTrue: [ " does not have accessors "
					m isPrimitive
						ifTrue: [ isAccessed isNil ifTrue: [ isAccessed := true ] ]
						ifFalse: [ isAccessed := false ].
					^ true ] ].
	^ false
]

{ #category : 'accessing' }
InstVarUsageExplorer >> initialize [

	logOfTreatedSenders := Set new.
]

{ #category : 'accessing' }
InstVarUsageExplorer >> isAccessed [

	^ isAccessed  
]

{ #category : 'accessing' }
InstVarUsageExplorer >> mainVisitor [

	^ mainVisitor
]

{ #category : 'accessing' }
InstVarUsageExplorer >> mainVisitor: aVisitor [

	mainVisitor := aVisitor
]

{ #category : 'as yet unclassified' }
InstVarUsageExplorer >> sendersOf: senderOfAccessor matchAtLeastOneOf:  implementorsOfMessagesAfter [

	logOfTreatedSenders add: senderOfAccessor.
self haltIf: (senderOfAccessor = (Line>>#a)).
	^ (implementorsOfMessagesAfter includes: senderOfAccessor)
		  ifTrue: [ ^ true ]
		  ifFalse: [
				  (logOfTreatedSenders like: senderOfAccessor) ifNil: [
						  senderOfAccessor selector senders doWithIndex: [
								  :senderOfSenderOfAccessor
								  :index |
								  (self
									   sendersOf: senderOfSenderOfAccessor
									   matchAtLeastOneOf: implementorsOfMessagesAfter) ifTrue: [
										  1 halt.
										  ^ true ].
								  self haltIf: index = 3 ] ].
				  ^ false ]
]
