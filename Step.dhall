let RunStep = ./Step/RunStep.dhall

let Artifact = ./Artifact.dhall

in  < Checkout :
        Text
    | Run :
        { run : RunStep }
    | Artifacts :
        { store_artifacts : List Artifact }
    >
