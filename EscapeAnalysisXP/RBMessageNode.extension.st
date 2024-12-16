Extension { #name : 'RBMessageNode' }

{ #category : '*EscapeAnalysisXP' }
RBMessageNode >> escapeAnalyzeNode: escapeAnalyzer [

	| implementors nodesToTreat "newTrackedVariablesTable" listOfNewTrackedVariableTables |
	"Treat only the arguments that are variables and the receiver"
	nodesToTreat := { self receiver } , self arguments.
	implementors := self selector implementors.
	listOfNewTrackedVariableTables := OrderedCollection new.
	"newTrackedVariablesTable := (Dictionary new:
		                             nodesToTreat size
		                             + trackedVariablesTable size) addAll:
		                            trackedVariablesTable."
	"
nodesToTreat do:[
	:e |
	e name ~= (argNames at: (self children indexOf: e)) ifTrue: [
						newTrackedVariablesTable
							at: (argNames at: (self children indexOf: e))
							put: (escapeAnalyzer fullName: e name) ]
	]."


	(nodesToTreat anySatisfy: [ :e |
		 (escapeAnalyzer findVariableByName: e) isNotNil ]) ifTrue: [
		(escapeAnalyzer isSpecialMethod: self selector)
			ifFalse: [
				(escapeAnalyzer workList size < 500 and: [ implementors size < 5 ])
					ifTrue: [
						| returnStateOfMessage |
						returnStateOfMessage := false.

						((self allParents anySatisfy: #isReturn) and: [
							 escapeAnalyzer isAtTopLevel ])
							ifTrue: [
								escapeAnalyzer setReturnedFlag: true.
								
							returnStateOfMessage := escapeAnalyzer
								                        currentMethodReturnStatus ].


						implementors size timesRepeat: [
							|newMessageContext|
							
							newMessageContext := EAMethodContext new escapeAnalysisContext: (escapeAnalyzer context).
							newMessageContext returnStatus: returnStateOfMessage .
							escapeAnalyzer extendCtxList: newMessageContext .
							escapeAnalyzer addCurrentMethodReturnStatus:
								returnStateOfMessage .].
						listOfNewTrackedVariableTables do: [ :trackedVarTable |
							escapeAnalyzer addTrackingTableForElements: trackedVarTable ].
						escapeAnalyzer addMethodsToWorkList: implementors ]
					ifFalse: [
						(nodesToTreat select: [ :n |
							 (escapeAnalyzer findVariableByName: n) isNotNil ]) do: [ :node |
							escapeAnalyzer markVariableAsEscaped: node ] ] ]
			ifTrue: [
				self selector = #value ifTrue: [
					escapeAnalyzer markVariableAsEscaped: self receiver name ] ] ].

	self children do: [ :node | node escapeAnalyze: escapeAnalyzer ]
]

{ #category : '*EscapeAnalysisXP' }
RBMessageNode >> escapeAnalyzeNode: escapeAnalyzer given: trackedVariablesTable [

	| implementors nodesToTreat "newTrackedVariablesTable" listOfNewTrackedVariableTables |
	"Treat only the arguments that are variables and the receiver"
	nodesToTreat := { self receiver } , self arguments.
	implementors := self selector implementors.
	listOfNewTrackedVariableTables := OrderedCollection new.
	"newTrackedVariablesTable := (Dictionary new:
		                             nodesToTreat size
		                             + trackedVariablesTable size) addAll:
		                            trackedVariablesTable."

	


	(nodesToTreat anySatisfy: [ :e |
			(escapeAnalyzer checkNode: e trackedIn: trackedVariablesTable) ] )ifTrue: [
		(escapeAnalyzer isSpecialMethod: self selector)
			ifFalse: [
				(escapeAnalyzer workList size < 20 and: [ implementors size < 5 ])
					ifTrue: [
						| returnStateOfMessage |
						returnStateOfMessage := false.

						((self allParents anySatisfy: #isReturn) and: [
							 escapeAnalyzer isAtTopLevel ]) ifTrue: [
							escapeAnalyzer setReturnedFlag: true.

							returnStateOfMessage := escapeAnalyzer
								                        currentMethodReturnStatus ].


						implementors size timesRepeat: [
							escapeAnalyzer addCurrentMethodReturnStatus:
								returnStateOfMessage ].
						listOfNewTrackedVariableTables do: [ :trackedVarTable |
							escapeAnalyzer addTrackingTableForElements: trackedVarTable ].
						escapeAnalyzer addMethodsToWorkList: implementors ]
					ifFalse: [
						(nodesToTreat select: [ :n |
							 escapeAnalyzer checkNode: n trackedIn: trackedVariablesTable ])
							do: [ :node |
								escapeAnalyzer
									markEscaped: node name
									inTable: trackedVariablesTable ] ] ]
			ifTrue: [
				self selector = #value ifTrue: [
					escapeAnalyzer
						markEscaped: self receiver name
						inTable: trackedVariablesTable ] ] ].

	self children do: [ :node |
		node treatNode: escapeAnalyzer given: trackedVariablesTable ]
]

{ #category : '*EscapeAnalysisXP' }
RBMessageNode >> treatNode2: escapeAnalyzer [

	| nodesToTreat isRcvrOrArgTracked |
	"Treat only the arguments that are variables and the receiver"
	nodesToTreat := { self receiver } , self arguments.
	isRcvrOrArgTracked := false.
	nodesToTreat do: [ :e |
		(escapeAnalyzer isTrackedNode: e) ifTrue: [
			isRcvrOrArgTracked := true.
			(self children indexOf: e) > 0 ifTrue: [
				escapeAnalyzer
					updateTrackedVariableName: (Association
							 key: ({
									  #self.
									  ((self selector implementors first argumentNames
										    collect: [ :arg |
										    escapeAnalyzer workList upperMostDeclarationName: arg ])
										   joinUsing: '.') } at: (self children indexOf: e))
							 value: e variable name)
					forMethod: self selector ] ] ].
	isRcvrOrArgTracked ifTrue: [
		escapeAnalyzer addMethodsToWorkList: self selector implementors ].

	self children do: [ :node | node treatNode: escapeAnalyzer ]
]

{ #category : '*EscapeAnalysisXP' }
RBMessageNode >> treatNode2: escapeAnalyzer given: trackedVariablesTable [

	| nodesToTreat isRcvrOrArgTracked |
	"Treat only the arguments that are variables and the receiver"
	nodesToTreat := { self receiver } , self arguments.
	isRcvrOrArgTracked := false.
	nodesToTreat do: [ :e |
		(escapeAnalyzer checkNode: e trackedIn: trackedVariablesTable)
			ifTrue: [
			escapeAnalyzer addMethodsToWorkList: self selector implementors ] ].




	self children do: [ :node | node treatNode: escapeAnalyzer ]
]

{ #category : '*EscapeAnalysisXP' }
RBMessageNode >> treatNode: escapeAnalyzer [

	| nodesToTreat isRcvrOrArgTracked |
	"Treat only the arguments that are variables and the receiver"
	nodesToTreat := { self receiver } , self arguments.
	isRcvrOrArgTracked := false.
	nodesToTreat do: [ :e |
		(escapeAnalyzer isTrackedNode: e) ifTrue: [
			isRcvrOrArgTracked := true.
			(e parent children indexOf: e) > 0 ifTrue: [
				escapeAnalyzer
					updateTrackedVariableName: (Association
							 key: ({
									  #self.
									  ((e parent selector implementors first argumentNames
										    collect: [ :arg |
										    escapeAnalyzer upperMostDeclarationName: arg ])
										   joinUsing: '.') } at: (e parent children indexOf: e))
							 value: e variable name)
					forMethod: e parent selector ] ] ].
	isRcvrOrArgTracked ifTrue: [
		escapeAnalyzer addMethodsToWorkList: self selector implementors ].

	self children do: [ :node | node treatNode: escapeAnalyzer ]
]

{ #category : '*EscapeAnalysisXP' }
RBMessageNode >> treatNode: escapeAnalyzer given: trackedVariablesTable [

	| newMethodArgumentsNames implementors nodesToTreat isRcvrOrArgTracked newTrackedVariablesTable listOfNewTrackedVariableTables |
	"Treat only the arguments that are variables and the receiver"
	nodesToTreat := { self receiver } , self arguments.
	implementors := self selector implementors.
	isRcvrOrArgTracked := false.
	listOfNewTrackedVariableTables := OrderedCollection new.
	newTrackedVariablesTable := (Dictionary new:
		                             nodesToTreat size
		                             + trackedVariablesTable size) addAll:
		                            trackedVariablesTable.
	newMethodArgumentsNames := OrderedCollection newFrom:
		                           (self selector implementors collect: [
			                            :each |
			                            | c |
			                            c := OrderedCollection newFrom:
				                                 each argumentNames.
			                            c addFirst: #self.
			                            c ]).
	newMethodArgumentsNames do: [ :argNames |
		newTrackedVariablesTable := (Dictionary new:
			                             nodesToTreat size
			                             + trackedVariablesTable size) addAll:
			                            trackedVariablesTable.

		nodesToTreat do: [ :e |
			(escapeAnalyzer checkNode: e trackedIn: trackedVariablesTable)
				ifTrue: [ "| newMethodArgumentsNames |""newMethodArgumentsNames addFirst: #self."
					e name ~= (argNames at: (self children indexOf: e)) ifTrue: [
						newTrackedVariablesTable
							at: (argNames at: (self children indexOf: e))
							put: e name ].

					isRcvrOrArgTracked := true ] ].

		listOfNewTrackedVariableTables add: newTrackedVariablesTable ].


	isRcvrOrArgTracked ifTrue: [
		(escapeAnalyzer isSpecialMethod: self selector)
			ifFalse: [
				(escapeAnalyzer workList size < 20 and: [ implementors size < 5 ])
					ifTrue: [
						| returnStateOfMessage |
						returnStateOfMessage := false.

						((self allParents anySatisfy: #isReturn) and: [
							 escapeAnalyzer isAtTopLevel ]) ifTrue: [
							escapeAnalyzer setReturnedFlag: true.

							returnStateOfMessage := escapeAnalyzer
								                        currentMethodReturnStatus ].


						implementors size timesRepeat: [
							escapeAnalyzer addCurrentMethodReturnStatus:
								returnStateOfMessage ].
						listOfNewTrackedVariableTables do: [ :trackedVarTable |
							escapeAnalyzer addTrackingTableForElements: trackedVarTable ].
						escapeAnalyzer addMethodsToWorkList: implementors ]
					ifFalse: [
						(nodesToTreat select: [ :n |
							 escapeAnalyzer checkNode: n trackedIn: trackedVariablesTable ])
							do: [ :node |
								escapeAnalyzer
									markEscaped: node name
									inTable: trackedVariablesTable ] ] ]
			ifTrue: [
				self selector = #value ifTrue: [
					escapeAnalyzer
						markEscaped: self receiver name
						inTable: trackedVariablesTable ] ] ].

	self children do: [ :node |
		node treatNode: escapeAnalyzer given: trackedVariablesTable ]
]
