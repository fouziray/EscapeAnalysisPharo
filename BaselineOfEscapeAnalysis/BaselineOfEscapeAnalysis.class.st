Class {
	#name : 'BaselineOfEscapeAnalysis',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfEscapeAnalysis',
	#package : 'BaselineOfEscapeAnalysis'
}

{ #category : 'baselines' }
BaselineOfEscapeAnalysis >> baseline: spec [

	<baseline>
	spec for: #pharo do: [
		spec package: 'EscapeAnalysisXP'.
		spec
			group: 'core' with: #( 'EscapeAnalysisXP' );
			group: 'default' with: #( 'core' ) ]
]
