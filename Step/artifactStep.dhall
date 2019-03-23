let Artifact = ../Artifact.dhall
in let RunStep = ./RunStep.dhall
in let artifactStep = \(artifact : Artifact) -> 
    < Checkout : Text | Run : { run : RunStep } | Artifacts = { store_artifacts = [artifact] } >
in artifactStep
