# ocp-compliance-report-generate
This project used with openshift Compliance Operator for generate the CIS Red Hat OpenShift Container Platform 4 Benchmark Report

Install the Compliance Operator through the web console.

https://docs.openshift.com/container-platform/4.8/security/compliance_operator/compliance-operator-installation.html#installing-compliance-operator-web-console_compliance-operator-installation


On helper node. Install OpenSCAP packages.

```
# yum install -y openscap openscap-utils scap-security-guide
```

Initial by run script initial-compliance-report-generate.sh will create scan-results folder.

```
./initial-compliance-report-generate.sh
```

Setup variables below in compliance-report-create.sh

```
oc_cmd=/usr/bin/oc
ocp_cluster_id=cluster-kp9vq
ocp_base_domain=kp9vq.sandbox1891.opentlc.com
ocp_resource_name=compliance-report
ocp_compliance_project=openshift-compliance
ocp_compliance_report_path=/root/compliance/compliance-report
scan_results_path=./scan-results
```

Run the script compliance-report-create.sh to generate compliance report. Will deploy pod compliance-report and provide a route for access compliance report each node. 

```
./compliance-report-generate.sh
```

```
# oc get po -n openshift-compliance|grep -i compliance-report
compliance-report-1-build                               0/1     Completed   0          3m49s
compliance-report-6dd8c87679-bh44z                      1/1     Running     0          2m53s
#
# oc get route -n openshift-compliance
NAME                HOST/PORT                                                                                 PATH   SERVICES            PORT       TERMINATION   WILDCARD
compliance-report   compliance-report-openshift-compliance.apps.<cluster-id>.<base-domain>          compliance-report   8080-tcp   edge          None
#
```

Setup crontab for generate compliance report.

```
*/5 * * * * /usr/bin/bash /root/compliance/compliance-report/compliance-report-generate.sh
```
