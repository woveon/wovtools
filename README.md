# WovTools

> WovTools manages the different staging environments a team working on microservices for a Kubernetes environment will use, moving from a user space, to a production environment. It manages code, secrets and configuration for source code, dev/running environments and Kubernetes. At Woveon, we use WovTools to manage our systems.


## Overview

WovTools tightly integrates git, Docker and Kubernetes, trying to create as little new overhead as possible. It has three data tracks it manages: secrets, env and code. **Secrets** are stored in multiple JSON files and used to compile the **Env** files which are used to configure environment variables, build scripts and Kubernetes yaml configuration files. **Code** is all managed in git repos and we separate out our stages into different branches of git, deployed to our cluster in separate namespaces. WovTools pushes secrets, env and code through three distinct steps: development, archive and deploy. This involves compiling files for archive in git, AWS S3 and Docker repositories, eventually to be deployed. The general operation of WovTools requires you to make use of a set of commands that operate on configurations in WovTools, git, Docker and Kubernets.


### Definitions
* **Project** - a single Aim of a Kubernetes orchestrated system, that can be composed of multiple microservices.

* **Data Track** - the types of data managed in WovTools, compiled for a deployable system in Kubernetes.

  * **Secrets** - a set of json files (merged via a recipe) to create a single file used to compile the Env files
  
  * **Env** - templated files for Kubernetes ConfigMaps and Secrets, environment variables and passwords and Kubernetes configuration
  
  * **Code** - whatever code is used to build your system, inside a git repo.
  
* **Step** - names given to the progress of moving files to a deployable system in Kubernetes.

  * **Development Step** is about building and testing your code.
  
  * **Archive Step** is about moving your code to an archive which you can then depoloy from.
  
  * **Deploy Step** is about running your code.

## Development Step

### Commands
**wov-init** - Turns your existing archive (or creates a new one) into a WovTools project.

**wov-build** - Builds the environment information of a WovTools distribution. Specifically, the environment variables and K8s ConfigMap and Secrets.

**wov-compile** - Readies env files for the Archive.

**wov-context.app** - an Applescript cmd for switching Kubernetes contexts. Give it a keyboard shortcut to really brighten your day.

**wov-env** - converts git, Kubernetes and WovTools config into environment variables (-e to show what it does)

**wov-stage** - Push the WovTools system to a new stage. This involves changing the git branch and Kubernetes context. Fails if either switches do not work. Can leave system in an error state.

**wov-stagecompare** - Check that the git and Kubernetes environments are in sync.

## Archive Step

### Commands
**wov-push-check** - Check that all git files are checked in, regular and secret.

**wov-push-containers** - Runs the recipe scripts and if there is a change, build the containers.

**wov-push-env** - Copies the env files (conf and k8s), into an Archive, from which we can deploy. This works with pushing secrets and containers into the Archive (which is actually several storage mediums).


## Deploy Step

### Commands
**wov-deploy-apply** - Deploys a running kubernetes project from an archive.

**wov-deploy-info** - Shows information of a running project.

## Utility Commands

These are just darn useful...

**wov-ns** - Spews a lot of data in the current Kubernetes namespace.

**wov-p** - Takes a stem and returns the name of the matching pod in a namespace (--ith n, to match *nth* pod).

**wov-plog** - Connects to a running pod (via podstem) and logs its data, with a -f to follow it.
