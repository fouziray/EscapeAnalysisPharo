# Escape analysis for Pharo

context-sensitive escape analysis for Pharo. It builds an alias graph that tracks variables referring to newly created objects. It performs intraprocedural analysis to handle aliases involving method arguments. 
Escape analysis helps find heap-allocated objects that are only used temporarily, which enables optimisations like stack allocation, object fusion, or scalar replacement.  


# Installation

```
Metacello new
    baseline: 'EscapeAnalysis';
    repository: 'github://fouziray/EscapeAnalysisPharo:main';
    load.
```

# How it works
### input
It takes a single method, and for the analysis to be meaningful, the method must include at least one explicit allocation. We only consider allocations found at the root method analyzed

### Escape Conditions
The analysis considers a variable as escaping (i.e., outliving its method context) if it or any of its aliases (other references to the same memory location) satisfies one of the following conditions:
- Returned and propagated up to the top level of the call stack.
- Assigned to an instance variable, global variable, or shared variable.
- Passed to or referenced within a lexical closure that may be evaluated later in the call graph, starting from its defining method.
- Stored in a collection, making it difficult for the analyzer to track individual elements.
- Used in reflective or primitive operations, such as `instVarAt:put:`.
- Involved in a serialization process.
\end{enumerate}

### Output

It gives a set of non-escaping variables, along with the analysis summary for statistical insights.

## Contribution

If you'd like to contribute, you are welcome to create an issue or send a pull request. 
Thank you.
