# AO Tech Challenge

Welcome to the AO Tech challenge!

This challenge consists of three exercises - Each is representative of a problem we have run across at AO. The first two exercises are technical and the third exercise is theoretical.
Solutions to each exercise will be evaluated on the following criteria:

- Completeness
- Correctness
- Legibility
- Aesthetics

## Pre-requisites

The project provided was built with, and tested against [Docker Desktop](https://www.docker.com/products/docker-desktop) _2.3.0.3_.

## Submission

To submit your work, please fork this repository, and push all commits to your fork upon completion. Once you are happy with your work, send us an email with a link to your repository.

## Exercises

The below exercises involve augmenting an [.NET Core](https://dotnet.microsoft.com/download/dotnet-core/2.2) _2.2_ HTTP web application.

To ensure your focus on the intended challenges, please note that the .NET Core base image and code do not need to be modified.

### Part 1

The application an on-premise service that needs to be migrated to the cloud. It currently run on a Windows Server 2012 R2 server on a VMware ESXi platform that is due to be decommissioned. In the test and production environment the application is load balanced by a pair of Citrix Netscaler's.

The team that owns this app has also recently transitioned to a product aligned team and is expected to take full operational ownership of the infrastructure supporting their application. They would like to avoid having to 'lift and shift' the application to cloud based instances and have asked if you would be able to help them containerise it instead.

The team have already managed to dockerise the application but would like to get a load balancer provisioned with a view of removing the need for the Netscaler when the application is migrated. They also have a desire the begin breaking up the application and believe this will be an important step on that journey.

In order to complete this you must:

- Provision an NGINX container that will route traffic to the application container.
- Ensure the local developer experience is as seamless as possible, using docker compose.

### Part 2

The application is currently built and packaged using an on-premise TeamCity installation and deployed to the virtual servers using Octopus Deploy. The team would like to modernise the deployment pipeline for the application now that it is running in a container. They have also expressed interest in having their infrastructure and pipeline defined as code to serve as a template to avoid repeat work when migrating similar applications.

The company is heavily invested in AWS and the team would like to stay with the companies cloud provider of choice. As this is an experiment so the team can learn more about running the app in the cloud they will only require a single environment to begin with.

In order to complete this you must:

- Produce the Infrastructure as code for the build and deploy pipeline.
- Produce the configuration file(s) for the build and deploy system.
- Produce the Infrastructure as code for the Service that the application will be deploy to.

Note that the infrastructure as code solution *does not* need to be run within a pipeline for this part of the experiment - The team are happy to run the terraform locally, for now.

### Part 3

The team would like you to share your results with other teams who are also on a similar journey. Write a 'less than a page' summary on what you have produced for the team and any recommendations you would like to propose for future improvements.
