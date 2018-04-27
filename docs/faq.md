

# FAQ



## VH : Private Repos

### Q: How do I checkout my repos on 'vh'? 

* Easiest approach is to create a machine user on GitHub (non-user account) and give it read access to your private repo. Then, give that account all the keys of your different 'vh' machines (look in secrets).

### Q: I have a private repo. How do I edit on 'vh' pod and push?

* Edit all code on vh, then in your local git branch for that repo, copy it all over from the vh and manage with regular git operations.
```
wov-pull-dir - Copies from the vh as vh:$1 which is the working dir on pod, to local directory
```

* Alternatively, set your machine user account on Github to have write access. But, than all commits are from that user and not you, which is odd for development teams.



