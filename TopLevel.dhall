let Job = ./Job.dhall

in  let Workflows = ./Workflows.dhall
    
    in  { version : Natural, jobs : List Job }
