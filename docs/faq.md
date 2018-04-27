

# FAQ

## VH: Develop on Your Cluster

## Q: How do I develop microservices with WovTools?
* The 'vh' pod can be created to run commands and develop in your cluster.

## Q: How do I set up a development environment in my cluster?
- Start the 'vh' pod: `wov-vh -s`
- Put your git code repos on it. 
  - whole topic, invluives often machine users on Github (adding your vh's key to that user).
- Develop and run your microservice.
- Route the service through to vh instead of your pod: `wov-vh --route-service [service] vh`
  - NOTE: a deploy with overwrite this, or `wov-vh --route-service [service] [originalpodname]` to undo.
- Pull your code back into your local repos:
  - cd to your local git repo
  - `wov-pull-dir`, assumes directory is on vh is /usr/src/app/
  - commit and push
  - if needed, pull vh's git repo again to update 


## VH : Private Repos

### Q: How do I checkout my repos on 'vh'? 

* Easiest approach is to create a machine user on GitHub (non-user account) and give it read access to your private repo. Then, give that account all the keys of your different 'vh' machines (look in secrets).

### Q: I have a private repo. How do I edit on 'vh' pod and push?

* Edit all code on vh, then in your local git branch for that repo, copy it all over from the vh and manage with regular git operations.
```
wov-pull-dir - Copies from the vh as vh:$1 which is the working dir on pod, to local directory
```

* Alternatively, set your machine user account on Github to have write access. But, than all commits are from that user and not you, which is odd for development teams.


## NodeJS Specific

## Q: I have repos my main repo depends on, that I am developing for. Any easy way to manage this?
Yes, just use npm's link so it symlinks directly to the file, then do development on the private repo just as you would any other.
- Checkout the private repo, next to your main repo on vh.
- cd into that private repo and `npm link`.
- cd into your main repo and `npm link [privatereponame]`.



