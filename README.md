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


### Workflow : Local

1. **Project Creation** - Run *wov-init* to transform your existing project into a WovTools project. This will make changes to your git setup, and create a wovtools directory. 

2. **Create K8s Context** - Make sure you have a context in Kubernetes for your namespace ({PROJECT}\_{STAGE}). 

3. **Set Stage** - By default, *wov-init* will exist in your user's stage, but `wov-stage <stage>` sets the stage for development. So, `wov-stage dev` or `wov-stage prod` are two different stages. However, I use my initials for stages, creating my own Kubernetes namespace and git branch to work in. So, `wov-stage cw` is what I start in.

4. **Secrets** - You need to start moving configuration information into json files in wovtools/secrets. These files are merged together according to the order in wovtools/secrets/config.json. Also, secrets need to be managed in a safe way. They are stored in a git repository, so we can version the secrets, but you need to ensure the repo is hosted in a secure/encryped location. NOTE: GitHub is not encrypted by default.

5. **Env: variables** - Using environment variables is the safe way to run containers and Kubernetes, as you add them at runtime and do not store them in the repo. Create `.wov` files in 'wovtools/conf' which are compiled for use in bash shells, Makefiles, Kubernetes ConfigMaps and Secrets, etc.  Use `.ck8s.wov` for non-secret data and `.sk8s.wov` for data that needs to remain encryped (passwords, keys, etc). See *wov File Format* below.

6. **Env: Kubernetes Yaml** - Move your Kubernetes yaml files into the `wovtools/k8s` directory and append the `wov` extension. Then modify the files to use the secrets you compile from the Env files. NOTE: follows the *wov File Format* as shown below.

7. **Env: Build** - Run the `wov-build -s` command to compile the secrets and then `wov-build -e` to compile the Env's `wov` files with this secret. These files are only built as needed (dependencies on timestamps secret diffs) so `wov-build -v` can print which files are skipped. Also, `wov-build -e` includes the `-s` step so just `wov-build -e` will build the Env in one step.

8. **Services** - Write scripts that emulate the services your code will interact with in the cluster. This includes databases or other microservices. Write scripts in wovtools/services as SERVICE.sh, SERVICE-test.sh, SERVICE-kill.sh, which correspond to `wov-service` switches of -r, -t and -k.

9. **Develop** - Build your code. Whatever you do, create that code. To use environment variables, use the `wov-env` script to set them, and then set them before your command is run. 
```
# To run service myprojectservice1 with environment vars created with wov-build on file 'wovtools/conf/env.ck8s.wov':
env `wov-env --cmd env.ck8s` npm run myprojectservice1

# To use in Makefiles, dump to a file and include 
$(shell wov-env --env env.ck8s > ./.wovtools.mk)
include ./.wovtools.mk

# To get a single WovTools variable:
wov-env --var WOV_PVER

# To get all WovTools variables:
wov-env -e
```

### Workflow : Archive

1. **Git** - Make sure your git archive, and also your wovtools/secret git archive, are checked in and pushed.

2. **Containers** - Build the containers with the `wov-push-containers`. This involves creating scripts to create the content that goes into the container. For each container, created a script.sh file in `wovtools/containers` for that container. Variables passed to the script are CONTAINER (name of the container), SRCDIR (the root of the project) and DESTDIR (the directory the files are dumped). Make sure to include a Dockerfile as well. When your recipes are created, run the `wov-push-containers` command. To list containers this will build, run `wov-push-containers -l`.

### Workflow : Deploy

1. **Deploy** - Run `wov-deploy-apply` to run the latest project. This pulls env files and runs them. These files in turn include the Kubernetes deployments, which pull the containers. To run older versions, do a `wov-deploy-apply --pver X --sver Y` to run different versions. Note that only valid combinations of project and secret versions are allowable.


## Development Step

### Commands
**wov-init** - Turns your existing archive (or creates a new one) into a WovTools project.

**wov-build** - Builds the environment information of a WovTools distribution. Specifically, the environment variables and K8s ConfigMap and Secrets.

**wov-compile** - Readies env files for the Archive. Called by build so largely ignored.

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


## Wov File Format

## Naming Conventions
