Extension { #name : 'RBMessageNode' }

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

	| nodesToTreat isRcvrOrArgTracked newTrackedVariablesTable |
	"Treat only the arguments that are variables and the receiver"
	nodesToTreat := { self receiver } , self arguments.

	isRcvrOrArgTracked := false.
	newTrackedVariablesTable := (Dictionary new:
		                             nodesToTreat size
		                             + trackedVariablesTable size) addAll:
		                            trackedVariablesTable.
	nodesToTreat do: [ :e |
		(escapeAnalyzer checkNode: e trackedIn: trackedVariablesTable)
			ifTrue: [
				| newMethodArgumentsNames |
				"1 halt."
				newMethodArgumentsNames := OrderedCollection newFrom:
					                           self selector implementors first
						                           argumentNames.
				newMethodArgumentsNames addFirst: #self.
				e name
				~= (newMethodArgumentsNames at: (self children indexOf: e))
					ifTrue: [
						newTrackedVariablesTable
							at: (newMethodArgumentsNames at: (self children indexOf: e))
							put: e name ].

				isRcvrOrArgTracked := true ] ].


	"(escapeAnalyzer isSpecialMethod: self selector) ifFalse: ["
	isRcvrOrArgTracked ifTrue: [ "]"
		(escapeAnalyzer isSpecialMethod: self selector)
			ifFalse: [
				| implementors returnStateOfMessage |
				returnStateOfMessage := false.
				implementors := self selector implementors.
				(self allParents anySatisfy: #isReturn) ifTrue: [
					escapeAnalyzer setReturnedFlag: true.

					returnStateOfMessage := escapeAnalyzer currentMethodReturnStatus ].
				implementors size timesRepeat: [
					escapeAnalyzer addCurrentMethodReturnStatus: returnStateOfMessage ].

				escapeAnalyzer addTrackingTableForElements:
					newTrackedVariablesTable.
				escapeAnalyzer addMethodsToWorkList: implementors ]
			ifTrue: [
				self selector = #value ifTrue: [
					
					escapeAnalyzer
						markEscaped: self receiver name
						inTable: trackedVariablesTable ] ] ].

	self children do: [ :node |
		node treatNode: escapeAnalyzer given: trackedVariablesTable ]
]
