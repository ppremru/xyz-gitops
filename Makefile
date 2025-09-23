# Define variables
HELM_RELEASE := xyz-release
CHART_PATH := ./xyz-helm
DEV := peggy-dev
TEST := peggy-test
SLEEP_TIME := 5

.PHONY: login install-dev install-test install-all cleanup test-dev test-test test-all verify-ocp

# The default target that runs if no target is specified
all: cleanup install-all test-all

## Login to OpenShift Cluster
prep:
	@echo "Did you do your oc login?"
	oc new-project $(DEV)
	oc new-project $(TEST)
	@read -p "... press any key to continue"

## Clean up deployments in both namespaces (will not fail if release does not exist)
clean:
	@echo "Cleaning up..."
	helm uninstall $(HELM_RELEASE) --namespace $(DEV) 2>/dev/null || true
	helm uninstall $(HELM_RELEASE) --namespace $(TEST) 2>/dev/null || true

## Install the chart to the DEV namespace
install-dev:
	@echo "Installing to the DEV namespace..."
	helm install $(HELM_RELEASE) $(CHART_PATH) --namespace $(DEV)

## Install the chart to the TEST namespace with a custom message
install-test:
	@echo "Installing to the TEST namespace with a custom message..."
	helm install $(HELM_RELEASE) $(CHART_PATH) --namespace $(TEST) --set-string application.message="value from helm CLI"

## Install the chart to both DEV and TEST namespaces
install-all: install-dev install-test
	@echo "Waiting for deployments to be ready..."
	@sleep $(SLEEP_TIME)
	@read -p "... press any key to continue"

## Test the DEV route
test-dev:
	@echo "Testing the DEV route..."
	@HELLO_DEV=$$(oc get route xyz-app-route -o jsonpath='{.spec.host}' --namespace $(DEV)); \
	curl https://$${HELLO_DEV}/
	@echo

## Test the TEST route
test-test:
	@echo "Testing the TEST route..."
	@HELLO_TEST=$$(oc get route xyz-app-route -o jsonpath='{.spec.host}' --namespace $(TEST)); \
	curl https://$${HELLO_TEST}/
	@echo

## Test the routes in both namespaces
test-all: test-dev test-test

## Verify OpenShift Cluster status
verify-ocp:
	@echo "Verifying cluster state..."
	@echo "-------------------- Events --------------------"
	oc get events --namespace $(DEV)
	oc get events --namespace $(TEST)
	@echo "-------------------- Pods --------------------"
	oc get pods --namespace $(DEV)
	oc get pods --namespace $(TEST)
	@echo "-------------------- Routes --------------------"
	oc get route --namespace $(DEV)
	oc get route --namespace $(TEST)
