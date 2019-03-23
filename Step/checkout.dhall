let Step = ../Step.dhall

in  let RunStep = ./RunStep.dhall
    
    in  let Artifact = ../Artifact.dhall
        
        in    < Checkout =
                  "checkout"
              | Run :
                  { run : RunStep }
              | Artifacts :
                  { store_artifacts : List Artifact }
              >
            : Step
