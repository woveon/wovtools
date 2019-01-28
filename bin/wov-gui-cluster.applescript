use AppleScript version "2.4" -- Yosemite (10.10) or lateruse scripting additionsdo shell script "/usr/local/bin/kubectl config current-context"set curcontext to result-- do shell script "/usr/local/bin/kubectl config view -o json | /usr/local/bin/jq -r '.contexts[]'"do shell script "/usr/local/bin/kubectl config view -o json | /usr/local/bin/jq -r '.contexts[] | select(.name==\"" & curcontext & "\") | .context.cluster'"set curcluster to result#  do shell script "/usr/local/bin/kubectl config get-contexts -o name"do shell script "/usr/local/bin/kubectl config get-clusters | tail -n+2" # tail skips headersset clusters to paragraphs of result-- display dialog "Select Context:" buttons {"Cancel", "l-app-dev", "l-api-dev"} default button 3choose from list clusters with prompt "Select Cluster:" with title "K8s Cluster Selector" default items {curcluster}set newcluster to resultif newcluster is false then	returnend if-- build context from new cluser (assuming it exists)# do shell script "echo \"${curcontext}/${curcluster}/${newcluster}\""do shell script "echo \"" & curcontext & "\" | sed s/" & curcluster & "/" & newcluster & "/g"set newcontext to result-- set args to result-- set scriptArguments to item 1 of newcontext-- set scriptArguments to button returned of resultdo shell script "/usr/local/bin/kubectl config use-context " & newcontext -- scriptArgumentsdisplay dialog "Switched to " & newcontext buttons {"ok"} default button 1