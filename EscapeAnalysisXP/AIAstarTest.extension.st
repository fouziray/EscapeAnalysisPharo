Extension { #name : 'AIAstarTest' }

{ #category : '*EscapeAnalysisXP' }
AIAstarTest >> testComplexWeightedGraph2 [

	| graphType graph astar |
	astar := AIAstar new.
	graphType := AICyclicWeightedComplexFixture new.
	graph := graphType complexWeightedGraph2.
	astar nodes: graph nodes.
	astar
		edges: graph edges
		from: #first
		to: #second
		weight: #third.

	astar runFrom: 0.
	self assert: (astar findNode: 1) pathDistance equals: 4.
	self assert: (astar findNode: 2) pathDistance equals: 1.
	self assert: (astar findNode: 3) pathDistance equals: 7.
	self assert: (astar findNode: 4) pathDistance equals: 9.
	self assert: (astar findNode: 5) pathDistance equals: 10
]
