https://docs.openshift.com/container-platform/3.11/cli_reference/manage_cli_profiles.html


oc get nodes

<As pointed out in the comments, the reason you cannot get information about the nodes is because you do not have permissions to do so. Access to everything is via role based access control.>

oc version

oc describe clusterrole <user>

oc describe clusterrole <user> |grep nodes

oc get quota -n <project>

oc describe quota resource-quota -n <project>


oc get users
oc describe user <user>
oc get rolebindings
