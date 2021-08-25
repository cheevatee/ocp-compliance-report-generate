
oc_cmd=/usr/bin/oc
ocp_cluster_id=cluster-kp9vq
ocp_base_domain=kp9vq.sandbox1891.opentlc.com
ocp_resource_name=compliance-report
ocp_compliance_project=openshift-compliance
ocp_compliancesuites_worker_currentIndex=$($oc_cmd get compliancesuites -o=jsonpath="{.items[*]['status.scanStatuses'][0].currentIndex}")
ocp_compliancesuites_master_currentIndex=$($oc_cmd get compliancesuites -o=jsonpath="{.items[*]['status.scanStatuses'][1].currentIndex}")
ocp_compliancesuites_cis_currentIndex=$($oc_cmd get compliancesuites -o=jsonpath="{.items[*]['status.scanStatuses'][2].currentIndex}")
scan_results_path=./scan-results


for i in deployment is bc svc route
do
	$oc_cmd delete $i $ocp_resource_name
done

/usr/bin/rm -rf *.html

$oc_cmd create -f ./compliance-raw-master-result-extract.yaml
$oc_cmd create -f ./compliance-raw-worker-result-extract.yaml
$oc_cmd create -f ./compliance-raw-cis-result-extract.yaml
#sleep 120
sleep 60

for i in $($oc_cmd get no|/usr/bin/grep -v NAME|/usr/bin/awk -F. '{print $1}')
do
	echo $i
        for j in $($oc_cmd get po -n $ocp_compliance_project -o wide|/usr/bin/grep -i openscap-pod|/usr/bin/grep -i $i|/usr/bin/awk '{print $1}')
        do
		echo $j
		$oc_cmd cp worker-compliance-extract:/workers-scan-results/$ocp_compliancesuites_worker_currentIndex/$j.xml.bzip2 ./scan-results/$i/$i-$(date +"%Y%m%d%H%M").xml.bzip2
		$oc_cmd cp master-compliance-extract:/masters-scan-results/$ocp_compliancesuites_master_currentIndex/$j.xml.bzip2 ./scan-results/$i/$i-$(date +"%Y%m%d%H%M").xml.bzip2
	done
done

$oc_cmd cp cis-compliance-extract:/cis-scan-results/$ocp_compliancesuites_cis_currentIndex/ocp4-cis-api-checks-pod.xml.bzip2 ./scan-results/cis-report/ocp4-cis-api-checks-pod-$(date +"%Y%m%d%H%M").xml.bzip2

$oc_cmd delete -f ./compliance-raw-worker-result-extract.yaml
$oc_cmd delete -f ./compliance-raw-master-result-extract.yaml
$oc_cmd delete -f ./compliance-raw-cis-result-extract.yaml

for i in $($oc_cmd get no|/usr/bin/grep -v NAME|/usr/bin/awk -F. '{print $1}')
do
	/usr/bin/oscap xccdf generate report $scan_results_path/$i/$(/usr/bin/ls -lart $scan_results_path/$i/|/usr/bin/tail -1|/usr/bin/awk '{print $9}') >> $i.html
done

/usr/bin/oscap xccdf generate report $scan_results_path/cis-report/$(/usr/bin/ls -lart $scan_results_path/cis-report/|/usr/bin/tail -1|/usr/bin/awk '{print $9}') >> cis-report.html


echo "<h1>CIS Red Hat OpenShift Container Platform 4 Benchmark Report</h1>" >> index.html
echo "cis-report: <a href=\"https://compliance-report-openshift-compliance.apps.$ocp_cluster_id.$ocp_base_domain/cis-report.html\">compliance-report-openshift-compliance.apps.$ocp_cluster_id.$ocp_base_domain/cis-report.html</a><br>" >> index.html
oc get no|grep -v NAME|awk -F. '{print $1}'|xargs -i echo "{}: <a href=\"https://compliance-report-openshift-compliance.apps.$ocp_cluster_id.$ocp_base_domain/{}.html\">compliance-report-openshift-compliance.apps.$ocp_cluster_id.$ocp_base_domain/{}.html</a><br>" >> index.html


$oc_cmd new-build --name compliance-report --binary
$oc_cmd start-build compliance-report --from-dir=. --follow --wait
$oc_cmd new-app compliance-report
$oc_cmd create route edge --service=compliance-report
$oc_cmd get route compliance-report

##### DEBUG #####

#$oc_cmd get compliancesuites -o=jsonpath="{.items[*]['status.scanStatuses']}"|jq
#echo $ocp_compliancesuites_worker_currentIndex
#echo $ocp_compliancesuites_master_currentIndex
#echo $ocp_compliancesuites_cis_currentIndex

