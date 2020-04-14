# Simple PKS Deployment in AWS

There are many ways to deploy PKS. In order to reduce the noise and illustrate a deployment as simply as possible, this
repo contains the bare minimum number of artifacts to pave an AWS IaaS to allow you to deploy Ops Manager, PKS, and your
first Kubernetes cluster.

This repo is not necessarily meant to be used as code to run in order to deploy PKS for you as much as it is to be used 
as a reference when deploying PKS into an 'odd' environment (defined simply as anything other than the reference 
architecture found on the official site). The code will run successfully in a greenfield environment and can certainly 
be adapted to your custom environment but it is not meant to be an enduring effort.

What you can expect from this repo:
* Paving of IaaS, including creation of VPC, subnets, route tables, security groups, IAM instance profiles and load 
balancers.
* Deploying Ops Manager VM into your public subnet.

What this repo does not do for you:
* Configuration/Deployment of the Bosh Director
* Specific configuration of the PKS tile (though we do provide some general guidance).

# Architecture
A breif overview of _what_ we're deploying can be found below.

![Basic AWS Architecture](images/pks-in-aws-simple-diagram.png)

Your deployment will use three Availability Zones (and thus, three Public subnets ans three Private subnets).
For simplicity, the diagram only shows a single AZ's worth of resources.

# Docs
For a light walkthrough of a successful PKS deployment, see the [Docs](docs/README.md) section.

# Let's Just Go!

For the impatient, simply fill out the [providers.tf](provider.tf) file and create your own terraform.tfvars, then init, plan, and apply.
