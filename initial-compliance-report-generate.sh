oc get no|grep -v NAME|awk -F. '{print $1}'|xargs -i mkdir -p scan-results/{}
mkdir -p scan-results/cis-report
