    let job = ../Job/job.dhall
    in let artifactStep = ../Step/artifactStep.dhall
    in let defaultSpec = ../Job/defaultSpec.dhall
    in let defaultStep = ../Step/default.dhall
    in let defaultRunStep = ../Step/defaultRunStep.dhall
    in let checkoutStep = ../Step/checkout.dhall
    in let defaultContainer = ../Docker/defaultContainer.dhall
    in let Workflows = ../Workflows.dhall
    in let TopLevel = ../TopLevel.dhall
    in let workflow = ../Workflow/workflow.dhall
    in let workflowJob = ../Workflow/job.dhall
    in let WorkflowJobSpec = ../Workflow/Spec.dhall

    --- actual config

    in let basePythonCommand = "python -O main.py"
    in let dockerImageName = "openalcoholics/regular_dicers_bot:latest-$CIRCLE_BRANCH"
    in let dockerContext = "."
    in let writeVersionStep = (defaultRunStep // { command = "sed -i -e \"s/{{VERSION}}/$CIRCLE_SHA1/\" main.py" })
    in let dockerLoginStep = λ(url : Text) -> (defaultStep (defaultRunStep // { command = "docker login -u $DOCKER_USER -p $DOCKER_PASS ${url}" }))

    in let runJob = (job "run" (defaultSpec // {
        steps = [
            checkoutStep
            , (defaultStep writeVersionStep)
            , (defaultStep (defaultRunStep // { command = "echo \"{\"token\":\"$BOT_TOKEN\"}\" > secrets.json" }))
            , (defaultStep (defaultRunStep // { command = basePythonCommand }))
        ]}))
    in let buildJob = (job "build" (defaultSpec // {
        steps = [
            checkoutStep
            , (dockerLoginStep "hub.docker.com")
            , (defaultStep (defaultRunStep // { command = "docker build -t ${dockerImageName} ${dockerContext}" }))
            , (defaultStep (defaultRunStep // { command = "docker push ${dockerImageName}" }))
        ]
        , docker = Some [ (defaultContainer "docker:18.09-git") ] }
    ))
    in let deployJob = (job "deploy" (defaultSpec // {
        steps = [
            checkoutStep
            , (defaultStep (defaultRunStep // { command = "curl -L \"http://update-bot.openalcolholics.group/?key=$UPDATE_KEY\"" }))
        ]
        , docker = Some [ (defaultContainer "byrnedo/alpine-curl:latest") ] }
    ))
    in let markdownJob = (job "markdown_lint" (defaultSpec // {
        steps = [
            checkoutStep
            , (defaultStep (defaultRunStep // { command = "markdownlint README.md" }))
        ]
        , docker = Some [ (defaultContainer "06kellyjac/markdownlint-cli:0.13.0-alpine") ] }
    ))
    in let pdocJob = (job "pdoc" (defaultSpec // {
        steps = [
            checkoutStep
            , (defaultStep (defaultRunStep // { command = "pip install -r requirements.txt" }))
            , (defaultStep (defaultRunStep // { command = "python setup.py install" }))
            , (defaultStep (defaultRunStep // { command = "pdoc --html dicers_bot" }))
            , (artifactStep { path = "html/dicers_bot" })
        ]
        , docker = Some [ (defaultContainer "python:3.7-slim") ] }
    ))

in {
    version = 2
    , jobs = [ runJob, buildJob, deployJob, markdownJob, pdocJob ]
    , workflows = Some {
        version = 2
        , workflows = [
            (workflow "build_and_deploy" {jobs = [
                --- < Name = "test" | Job : { name : { requires : List Text } } >,
                (workflowJob "build" (Some < Name : Text | Job = { requires = (Some ["run"]), filters = (Some { branches = { only = ["develop", "master"] } }) } >))
                , (workflowJob "deploy" (Some < Name : Text | Job = { requires = (Some ["build"]), filters = None { branches : { only : List Text } } } >))
            ]})
        ]
    }
} : TopLevel
