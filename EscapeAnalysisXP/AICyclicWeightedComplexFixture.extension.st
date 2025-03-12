Extension { #name : 'AICyclicWeightedComplexFixture' }

{ #category : '*EscapeAnalysisXP' }
AICyclicWeightedComplexFixture >> complexWeightedGraph2 [

	"https://i.imgur.com/Syyd7YI.png"

	| nodes edges graph |
	nodes := 0 to: 5.
	edges := #( #( 0 1 5 ) #( 0 2 1 ) #( 1 2 2 ) #( 1 4 20 ) #( 1 3 3 )
	            #( 2 1 3 ) #( 2 4 12 ) #( 3 2 3 ) #( 3 4 2 ) #( 3 5 6 )
	            #( 4 5 1 ) ).
	graph := AIGraphWeightedFixtureStructure new.
	graph nodes: nodes.
	graph edges: edges.
	^graph
]
