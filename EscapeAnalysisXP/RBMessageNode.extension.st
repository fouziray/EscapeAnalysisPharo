Extension { #name : 'RBMessageNode' }

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
	newTrackedVariablesTable := trackedVariablesTable shallowCopy.
	nodesToTreat do: [ :e |
		(escapeAnalyzer checkNode: e trackedIn: trackedVariablesTable)
			ifTrue: [
				| newMethodArgumentsNames | 
				"1 halt."
				newMethodArgumentsNames:= OrderedCollection newFrom: self selector implementors first argumentNames.
				newMethodArgumentsNames addFirst: #self.
				e variable name ~= ( newMethodArgumentsNames 
					 at: (self children indexOf: e)) ifTrue: [
					newTrackedVariablesTable
						at: (newMethodArgumentsNames at: (self children indexOf: e))
						put: e variable name ].

				isRcvrOrArgTracked := true ] ].
	isRcvrOrArgTracked ifTrue: [
		
		(escapeAnalyzer isSpecialMethod: self selector) ifFalse:[
			escapeAnalyzer addTrackingTableForElements: newTrackedVariablesTable.
			escapeAnalyzer addMethodsToWorkList: self selector implementors
			]
		 ].

	self children do: [ :node |
		node treatNode: escapeAnalyzer given: trackedVariablesTable ]
]
