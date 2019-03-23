    let Workflow = ./Workflow.dhall
    in let WorkflowSpec = ./Spec.dhall

in let workflow  =
  \(name : Text) ->
  \(js : WorkflowSpec) ->
    { mapKey = name, mapValue = js } : Workflow
in workflow
