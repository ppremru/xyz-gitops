#!/bin/bash

DEV=peggy-dev1
TEST=peggy-dev2

# Just a few hints (experiment with helm charts)
echo "Did you do your oc login?"
read -p "... press any key to continue"

# Will fail first time around ...
echo "Clean up"
helm uninstall xyz-release  --namespace ${DEV}
helm uninstall xyz-release  --namespace ${TEST}
read -p "... press any key to continue"

# echo "Set up"
#oc new-project ${DEV}
#oc new-project ${TEST}
#read -p "... press any key to continue"

# TAG is set in values.yaml
echo "Helm"
helm install xyz-release ./xyz-helm --namespace ${DEV}
helm install xyz-release ./xyz-helm --namespace ${TEST} --set-string application.message="value from helm CLI"
sleep 5
read -p "... press any key to continue"

echo "Test"
HELLO_DEV=$(oc get route xyz-app-route  -o jsonpath='{.spec.host}' --namespace ${DEV})
HELLO_TEST=$(oc get route xyz-app-route  -o jsonpath='{.spec.host}' --namespace ${TEST})
echo Dev
curl https://${HELLO_DEV}/
echo
echo Test
curl https://${HELLO_TEST}/
echo 
read -p "... press any key to continue"

#echo "OCP check"
#oc get events 
#oc get pods
#oc get route
