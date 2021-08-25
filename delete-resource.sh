rm -rf *.html
oc delete deployment compliance-report
oc delete is compliance-report
oc delete bc compliance-report
oc delete svc compliance-report
oc delete route compliance-report
