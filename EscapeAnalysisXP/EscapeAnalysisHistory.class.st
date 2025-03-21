Class {
	#name : 'EscapeAnalysisHistory',
	#superclass : 'Object',
	#instVars : [
		'history'
	],
	#category : 'EscapeAnalysisXP-Core',
	#package : 'EscapeAnalysisXP',
	#tag : 'Core'
}

{ #category : 'adding' }
EscapeAnalysisHistory >> addHistory: aContext for: aCompiledMethod [

	history at: aCompiledMethod ifPresent: [ :value | OrderedCollection new add: value; add: aContext ] ifAbsentPut: aContext .
	

]

{ #category : 'adding' }
EscapeAnalysisHistory >> adjudicateHistoryRetrievalOf: aCompiledMethod givenCurrentArguments: aCollectionOfVarNodes [

	| historyContext varNodesNames historyVarNames varIntersection |

	varNodesNames := aCollectionOfVarNodes collect: [ :varNode |
		                 varNode name ].

	historyContext := self restituteContextOf: aCompiledMethod.

	historyVarNames :=  historyContext trackedMethodArgs collect: [ :var | var name ].
	varIntersection := varNodesNames intersection: historyVarNames.
		                 varIntersection size = historyVarNames size ifFalse: [ ^ false ].
	^ self applyHistoryResults: historyContext trackedMethodArgs on: aCollectionOfVarNodes 
]

{ #category : 'adding' }
EscapeAnalysisHistory >> applyHistoryResults: historyTrackedArgs on: aCollectionOfVarNodes [

	aCollectionOfVarNodes do: [ :varNode |
		( (historyTrackedArgs select:
				 [ :oldNode | oldNode name = varNode name ]) first escapeStatus) ifTrue:[ varNode markEscaped ].].

	^ true
]

{ #category : 'accessing' }
EscapeAnalysisHistory >> history [

	^ history
]

{ #category : 'initialization' }
EscapeAnalysisHistory >> initialize [

	history := Dictionary new
]

{ #category : 'adding' }
EscapeAnalysisHistory >> isImplementorTreated: aCompiledMethod [

	^ history includesKey: aCompiledMethod
]

{ #category : 'adding' }
EscapeAnalysisHistory >> restituteContextOf: aCompiledMethod [

	^ history at: aCompiledMethod ifAbsent: [ ^ nil ]
]
