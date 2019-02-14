use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

# Get current context
do shell script "/usr/local/bin/kubectl config current-context"
set curcontext to result

# Get current cluster
do shell script "/usr/local/bin/kubectl config view -o json | /usr/local/bin/jq -r '.contexts[] | select(.name==\"" & curcontext & "\") | .context.cluster'"
set curcluster to result

# Get current namespace
do shell script "/usr/local/bin/kubectl config view -o json | /usr/local/bin/jq -r '.contexts[] | select(.name==\"" & curcontext & "\") | .context.namespace'"
set curnamespace to result

# Get current project
do shell script "echo \"" & curnamespace & "\" | cut -f1 -d\"-\""
set curproject to result

try
	#	do shell script "/usr/local/bin/kubectl get namespaces"
	
	# get projects in cluster... replaced since it has extra clusters
	# do shell script "/usr/local/bin/kubectl get --cluster " & curcluster & " namespaces | awk '{print $1}' | tail -n+2 | cut -f1 -d\"-\" | sort | uniq" # tail skips headers
	
	# Get projects from config... limits what is returned
	do shell script "/usr/local/bin/kubectl config view -o json | /usr/local/bin/jq -r '.contexts[].context | select( .cluster==\"" & curcluster & "\" ) | select( .namespace != null ) | .namespace' |  cut -f1 -d\"-\" | sort | uniq"
	set projects to paragraphs of result
on error errorMessage number errorNumber
	display dialog "ERROR: Could not connect to cluster. Is VPN and bastion running?"
	return 1
end try






choose from list projects with prompt "In cluster: " & curcluster with title "K8s Project Selector" default items {curproject}
set newproject to result
if newproject is false then
	return
end if

-- build (assuming it exists)
do shell script "echo \"" & curcontext & "\" | sed s/-" & curproject & "-/-" & newproject & "-/g"
set newcontext to result


do shell script "/usr/local/bin/kubectl config use-context " & newcontext

display dialog "Switched to " & newcontext buttons {"ok"} default button 1
