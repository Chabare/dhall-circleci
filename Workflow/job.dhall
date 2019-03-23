    let WorkflowJob = ./Job.dhall
    in let JobSpec = ./JobSpec.dhall

in let job  =
  \(name : Text) ->
  \(js : Optional JobSpec) ->
    { mapKey = name, mapValue = js } : WorkflowJob
in job
