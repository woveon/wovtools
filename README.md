# WovTools

> WovTools manages the configuration and staging for a Kubernetes development/devOps team; moving from a single dev's environment, to a production environment. This is the tool between writing code on your dev machine and tweaking Kubernetes yaml files on the cluster.

### Guiding Philosophies: 

- Kubernetes is great when it runs but getting there is tricky.
- Keep as much in the existing tools people already use as possible (sit on them and update them, don't overwrite).
- There are multiple developers on a team, that work individually and collaboratively in later stages.
- Toggling local directories breaks you out of your task and really isn't relevant when you're thinking in the cluster.

### Approach to Development

**Step 1: Local Development**
- create/select your stage (i.e. I use my initials to name it)
- write code (like in the olden days!)
- store your configuration and secrets in JSON files (environment variables generated for you)
- update your databases and schemas (i.e. database deltas)
- write Dockerfiles (with Handlebars expressions to insert configuration data)
- write Kubernetes files (with Handlebars expressions to insert configuration data)

**Step 2: Push to Archive**
- push code and configuration/secrets to Git (secure repo for configuration/secrets)
- push generated Kubernetes yaml files (Deployments, ConfigMaps, Secrets, Ingress, Services, etc) to secure repository
- push containers to Docker repository
- push database deltas to repository

**Step 3: Deploy to Cluster**
- Select the version of your system to deploy (defaults to most recent)
- Downloads Kubernetes files and pushes to running cluster
- Use Wovtools CLI to peer into, modify and tinker with running cluster
- Debug a service locally (port forwarding) or on a development pod (Service rerouting) 
- Return to step 1 as needed

**Step 4: Merge to next Stage**
- Change git branch and Kubernetes context to next stage (i.e. 'dev', 'prod', 'security', etc)
- Merge in git repos to this stage (code, configuration, database deltas)
- go to step 1.

> Read the Wiki for more information: [Wiki Home](https://github.com/woveon/wovtools/wiki)

## Overview

WovTools tightly integrates Git, Docker and Kubernetes, trying to create as little new overhead as possible during development. It does this by relying on structures and naming conventions in these tools, and managing data in three tracks: secrets, env and code: 

- **Secrets** are stored in multiple JSON files and used to compile the,

- **Env** files which are used to configure environment variables, build scripts and Kubernetes yaml files; and

- **Code** is all managed in git repo branches.

The data tracts are moved through three distinct steps: development (in Git repos), archive (in AWS S3 and Docker repositories) and deployment (in a running cluster). WovTools provides command line tools to support its development, as well as general tools that probably should exist for Kubernetes anyway.

### Example Usage of our Facebook Plugin

Our Facebook plugin connects to Facebook, listening for updates and pushing content. We run it in our own cluster that we call *wov-aws-va-live*, in its own project *plfb*, which we manage in three Kubernetes namespaces of *plfb-cw* (cw is my private namespace, where 'cw' are my initials), *plfb-dev* and *plfb-prod*. Here's how the naming convetions play out in detail:

The Kubernetes *context* for the production running Facebook plugin is `wov-aws-va-live-plfb-prod`. This means the cluster name is `wov-aws-va-live`, implying this cluster is the main Woveon cluster (sys=wov), on Amazon Web Services (provider=aws) in AWS's region us-east-1 (regioncode=va) (i.e. that is in Virginia (va)), on our main cluster (flavor=live) (We could make another cluster with flavor 'top' or 'brown' if we wanted, to experiment with cluster deployment, but chose 'live' for now). The plugin is one project, plfb (short for plugin Facebook), and follows our internal naming convetion of starting plugins with 'pl' followed by the plugin's short code, 'fb' for Facebook. There is one github repo for this project, and each namespace is its own branch (cw, dev, prod). Inside the project, there are three microservices (i.e. three Kubernetes deployments) that append their microservice code to the project to generate its name (wl - plfbwl - the Facebook plugin WoveonListener, rl - plfbrl - the Facebook plugin RemoteListener, etc.). Each microservice will have its own implementation, either a Helm chart or its own Deployment with its own container (plfbwl, plfbrl, etc.). Our cluster has two nodes, which we use _kube-aws_ to manage and at the moment, because we have not set up roles, one user (admin).

## FAQ

**Q. Where does this fit into my development process?**

A. You develop code. You run it locally and it works. How do you get that into Kubernetes? This helps.

**Q. How do you handle multiple developers on a project and Kubernetes?**

A. Each developer is treated as their own stage of production, and that stage used in Kubernetes namespaces to separate them. So, each developer has their own git branch and runs code in separate namespaces. Merging branches allows you to push to dev and production.

**Q. Doesn't this mean a developer could impact production by too many pods?**

A. Yes, by using too many resources in the cluster, but they can't screw up something in another namespace. If you can't live with that, set your development team to use a different cluster flavor. (How slick was that?)

**Q. What does WovTools do to my development environment?**

A. We create a 'wovtools' directory, where we place our files. We also modify your Git config to have 'dev' and 'prod' branches, with 'prod' being master. For databases, we create a database in the database, named wovtools, where we log versions. You will want to move your Kubernetes files into wovtools/k8s. 

**Q. How do you handle the massive amount of configuration, for local as well as running in the cluster?**

A. Kubernetes is great once it runs. Getting something running locally requires a lot of work before it runs in a development stage of your Kubernetes cluster, and still more configuration changes when it rolls to production. We handle this...
    - ... by placing all your configuration data into json files (organize them as you like, they get merged together later anyway);
    - ... by instrumenting configuration files (environment variables and k8s yaml) with two-pass handlebars expresssions, with the first pass converting expressions to the appropriate stage; 
    - ... by maintaining an up-to-date configuration environment (we rebuild the configuration as necessary with `wov-build`); and
    - ...by versioning the configuration (WOV_SVER) and use it to generate Kubernetes ConfigMaps and Secrets for running pods.

**Q. Wait, how do you manage configuration?**

A. TL;DR: *You don't have separate configuration environments, you just change your Kubernetes context and it changes with you.* 
A. Every script, system, pod, blah... needs some configuration. It's a nightmare. So, json is the source and we generate all configuration with preprocessor statements. Then, in your organization, you restrict who has which json files so only certain people have dev and production stage access. By storing data in json in a hierarchy including the stage, then using a first handlebars pass to direct handlebar expressions to a particular stage, then we have a dynamic configuration environment. Of course, by versioning it and keeping it in the Archive, we can apply it to the running Kubernetes system as well a use locally. 

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



