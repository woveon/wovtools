# WovTools

> WovTools manages the different staging environments a team working on microservices for a Kubernetes environment will use, moving from a user space, to a production environment. It manages code, secrets and configuration for source code, dev/running environments and Kubernetes. At Woveon, we use WovTools to manage our systems.

> Read the Wiki for more information: [Wiki Home](https://github.com/woveon/wovtools/wiki)

## Overview

WovTools tightly integrates git, Docker and Kubernetes, trying to create as little new overhead as possible. It has three data tracks it manages: secrets, env and code. **Secrets** are stored in multiple JSON files and used to compile the **Env** files which are used to configure environment variables, build scripts and Kubernetes yaml configuration files. **Code** is all managed in git repos and we separate out our stages into different branches of git, deployed to our cluster in separate namespaces. WovTools pushes secrets, env and code through three distinct steps: development, archive and deploy. This involves compiling files for archive in git, AWS S3 and Docker repositories, eventually to be deployed. The general operation of WovTools requires you to make use of a set of commands that operate on configurations in WovTools, git, Docker and Kubernets.

### Example Usage of our Facebook Plugin

Our Facebook plugin connects to Facebook, listening for updates and pushing content. We run it in our own cluster that we call *wov-aws-va-live*, in its own project *plfb*, which we manage in three Kubernetes namespaces of *plfb-cw* (cw is my private namespace), *plfb-dev* and *plfb-prod*. Here's how the naming convetions play out in detail:

The Kubernetes *context* for the production running Facebook plugin is `wov-aws-va-live-plfb-prod`. This means the cluster name is `wov-aws-va-live`, implying this cluster is the main Woveon cluster (wov), on Amazon Web Services (aws) in us-east-1 (i.e. that is in Virginia (va)) on our main cluster (live). (NOTE: We could make another cluster with flavor 'top' or 'brown' if we wanted, to test cluster deployment.) The plugin is one project, plfb, and follows our internal naming convetion of starting plugins with 'pl' followed by the plugin's short code, 'fb' for Facebook. There is one github repo for this project, and each namespace is its own branch (cw, dev, prod). Inside the project, there are three microservices (i.e. three Kubernetes deployments) that append their microservice code to the project to generate its name (wl - plfbwl - the Facebook plugin WoveonListener, rl - plfbrl - the Facebook plugin RemoteListener, etc.). Each microservice will have its own implementation, either a Helm chart or its own Deployment with its own container (plfbwl, plfbrl, etc.). Our cluster has two nodes, which we use _kube-aws_ to manage and at the moment, because we have not set up roles, one user (admin).

## FAQ

**Q. Where does this fit into my development process?**

A. You develop code. You run it locally and it works. How do you get that into Kubernetes? This helps.

**Q. How do you handle multiple developers on a project and Kubernetes?**

A. Each developer is treated as their own stage of production, and that stage used in Kubernetes namespaces. So, each developer has their own git branch and runs code in separate namespaces. Merging branches allows you to push to dev and production.

**Q. How do you handle the massive amount of configuration, for local as well as in the cloud running?**

A. Kubernetes is great once it runs. Getting something running locally requires a lot of work before it runs in a development stage of your Kubernetes cluster, and still more configuration changes when it rolls to production. We handle this by...
    - place all your configuration data into json files
    - instrument configuration files (basically bash environment variables and k8s yaml) with two-pass handlebars expresssions 
      - the first pass converts the expression to the appropriate stage of the environment
    - WovTools maintains an up-to-date configuration environment, by rebuilding the configuration as necessary (`wov-build`)
    - version the configuration (WOV_SVER) and use it to generate Kubernetes ConfigMaps and Secrets for running pods

**Q. Wait, how do you manage configuration?**

A. Every script, system, pod, blah... needs some configuration. It's a nightmare. So, json is the source and we generate all configuration with preprocessor statements. Then, you restrict who has which json files so only certain people have dev and production stage access. By storing data in json in a hierarchy including the stage, then using a first handlebars pass to direct handlebar expressions to a particular stage, then we have a dynamic configuration environment. Of course, by versioning it and keeping it in the Archive, we can apply it to the running Kubernetes system as well a use locally. You don't have separate configuration environments, you just change your Kubernetes context and it changes with you. 

**Q. Can you give an example of how configuration works?**
Here we have a mysecret.json file which generates two files, one for code (config.ck8s) and one for secrets (config.sk8s). They are loaded into two different scripts (healthcheck.sh and getdata.sh) with the `wov-env` command. Now, if you need to call 'healthcheck.sh', it never needs to know about your Kubernetes context (and wov-env does a wov-build check so never becomes out of sync). 
```
# NOTE: my initials are 'cw' so I am using 'cw' to represent my personal stage of development (used in Kubernetes namespace and git branch)
<${WOV_BASE}/wovtools/secrets/mysecret.json>
{
	"my": {
		"cw": {"url": "my-cw.site.com", "token": "IO0IExCECXpK"},
  "cw-local": {"url": "localhost:8080", "token": "Y4IIgJZZdYMh"},
		"dev": {"url": "my-dev.site.com", "token": "FvdRWwRLD9Tq"},
		"prod": {"url": "my.site.com"}, "token": "lDLMNXFoUmsuFddX6D" }
}

<${WOV_BASE}/wovtools/conf/config.ck8s>
# regular environment variables go here
MY_SITE_URL=\{{my.{{STAGE}}.url}}

<${WOV_BASE}/wovtools/conf/config.sk8s>
# sensitive environment variables go here
MY_SITE_TOKEN=\{{my.{{STAGE}}.token}}

<healthcheck.sh>
. $(wov-env --env config.ck8s)
curl ${MY_SITE_URL}/api/v1/health

<getdata.sh>
. $(wov-env --conf) # equivalent to $(wov-env --env config.ck8s --env config.sk8s)
curl ${MY_SITE_URL}/api/v1/foo&token=${MY_SITE_TOKEN}
```

**Q. How do you manage secrets?**

A. We use Git to versions secrets. This gives us a SVER number which we pair with the PVER to create a label when pushing content to the Archive.

NOTE: So, PLEASE make sure you trust your repository location (i.e. Github (and likely other free services) are not secure). Also, our preprocessing data is pushed to a `projectroot/wovtools/cache` directory restricted to only the user. You should probably encrypt your harddrive for another layer of secrity if someone goes around this restriction.

**Q. How to you manage databases?**

A. We roughly handle that. Databases are data and schema (SQL at least) so it can be tricky. But, we track changes to schema and loading of snapshots. If we detect changes to a db schema (checksum of database schema dump) when you are pushing, their better be a database delta file to account for that change. These delta files get pushed into the achive. We also have a command to log in to Postgres and MongoDB databases based upon their deployment name (`wov-db-connect <mydatabase>`). All this is managed with the configuration system.  

**Q. What tools does this use?**

A. Kubernetes, Docker and git are the main tools this uses. It was developed while developing with NodeJS for microservices.



