    let RunStep = ./RunStep.dhall
    let Artifact = ../Artifact.dhall

in let defaultStep = \(run : RunStep) ->
    < Checkout : Text | Run = { run = run } | Artifacts : { store_artifacts : List Artifact } >
in defaultStep
