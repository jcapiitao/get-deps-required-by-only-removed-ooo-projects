#!/bin/bash

REALPATH=$(realpath "$0")
DIRNAME=$(dirname "$REALPATH")
BASENAME=$(basename "$0")
TMPDIR=/tmp/${BASENAME%.*}

RDOINFO_DIR=$TMPDIR/rdoinfo
DATA_DIR=/workdir/data
TRIPLEO_PROJECTS=$DATA_DIR/tripleo_projects
TRIPLEO_REMOVED_PROJECTS=$DATA_DIR/tripleo_removed_projects
TRIPLEO_REMOVED_PKGS=$DATA_DIR/tripleo_removed_pkgs
REMOVED_PKGS_INSTALLATION=$DATA_DIR/tripleo_removed_pkgs_installation
DEPS_PULLED=$DATA_DIR/deps_pulled
DEPS_DIR=$DATA_DIR/deps
DEPS_SUMMARY=$DATA_DIR/deps_summary
DEPS_AFTER_EXCLUSION=$DATA_DIR/deps_summary_after_excluding_tripleo_projects
DEPS_AFTER=$DATA_DIR/deps_after_excluding_tripleo_projects
DEPS_BEFORE=$DATA_DIR/deps_before_excluding_tripleo_projects
DEPS_TO_REMOVE=$DATA_DIR/deps_to_remove

mkdir -p $TMPDIR
pushd $TMPDIR >/dev/null
echo -e "Working on $TMPDIR directory"

mkdir -p $DATA_DIR >/dev/null 2>&1

#echo "Cloning rdoinfo repo"
#>$TRIPLEO_REMOVED_PROJECTS
#git clone -q https://github.com/redhat-openstack/rdoinfo $RDOINFO_DIR
#pushd $RDOINFO_DIR >/dev/null
## Commit hash from https://review.rdoproject.org/r/c/rdoinfo/+/47883
#tripleo_removal_commit=13065a5ad98caccee9b915af25b6de6859add6fa 
#echo "Writing the removed TripleO projects in $TRIPLEO_REMOVED_PROJECTS"
#git --no-pager show $tripleo_removal_commit | grep -e "-- project:" | awk '{print $3}' >$TRIPLEO_REMOVED_PROJECTS
#popd >/dev/null
#
#echo "Writing the removed TripleO packages in $TRIPLEO_REMOVED_PKGS"
#>$TRIPLEO_REMOVED_PKGS
#while IFS= read -r project; do
#    dnf search -q $project | grep -e ".noarch" | awk '{print $1}' >>$TRIPLEO_REMOVED_PKGS
#done < $TRIPLEO_REMOVED_PROJECTS
#
#echo "Installing the TripleO removed packages"
#>$REMOVED_PKGS_INSTALLATION
#while IFS= read -r pkg; do
#    dnf install $pkg <<< 'N' 2>&1 | grep -v -e "Last metadata.*\|Installed size.*\|Total download size.*" >>$REMOVED_PKGS_INSTALLATION
#done < $TRIPLEO_REMOVED_PKGS
#
#echo "Getting the deps pulled in $DEPS_PULLED"
#grep -e "delorean-master-testing" $REMOVED_PKGS_INSTALLATION | awk '{print $1}' | sort | uniq >$DEPS_PULLED
#
#function rdorepoquery {
#    repoquery -q --whatrequires $1 --disablerepo=* --enablerepo=tmp* --repofrompath=tmp-component-baremetal,https://trunk.rdoproject.org/centos9-master//component/baremetal/current/ --repofrompath=tmp-component-cinder,https://trunk.rdoproject.org/centos9-master//component/cinder/current/ --repofrompath=tmp-component-clients,https://trunk.rdoproject.org/centos9-master//component/clients/current/ --repofrompath=tmp-component-cloudops,https://trunk.rdoproject.org/centos9-master//component/cloudops/current/ --repofrompath=tmp-component-common,https://trunk.rdoproject.org/centos9-master//component/common/current/ --repofrompath=tmp-component-compute,https://trunk.rdoproject.org/centos9-master//component/compute/current/ --repofrompath=tmp-component-glance,https://trunk.rdoproject.org/centos9-master//component/glance/current/ --repofrompath=tmp-component-manila,https://trunk.rdoproject.org/centos9-master//component/manila/current/ --repofrompath=tmp-component-network,https://trunk.rdoproject.org/centos9-master//component/network/current/ --repofrompath=tmp-component-octavia,https://trunk.rdoproject.org/centos9-master//component/octavia/current/ --repofrompath=tmp-component-podified,https://trunk.rdoproject.org/centos9-master//component/podified/current/ --repofrompath=tmp-component-security,https://trunk.rdoproject.org/centos9-master//component/security/current/ --repofrompath=tmp-component-swift,https://trunk.rdoproject.org/centos9-master//component/swift/current/ --repofrompath=tmp-component-tempest,https://trunk.rdoproject.org/centos9-master//component/tempest/current/ --repofrompath=tmp-component-tripleo,https://trunk.rdoproject.org/centos9-master//component/tripleo/current/ --repofrompath=tmp-component-ui,https://trunk.rdoproject.org/centos9-master//component/ui/current/ --repofrompath=tmp-component-validation,https://trunk.rdoproject.org/centos9-master//component/validation/current/  --repofrompath=tmp-delorean-master-testing,https://trunk.rdoproject.org/centos9-master/deps/latest/ --repofrompath=tmp-delorean-master-build-deps,https://trunk.rdoproject.org/centos9-master/build-deps/latest/
#}
#
#echo "Getting the packages that required the deps"
#rm -rf $DEPS_DIR
#mkdir -p $DEPS_DIR
#pushd $DEPS_DIR >/dev/null
#while IFS= read -r dep; do
#    rdorepoquery $dep >$dep
#done < $DEPS_PULLED
#popd >/dev/null
#
#
#echo "Listing the deps summary"
#pushd $DEPS_DIR >/dev/null
#grep -r -e "noarch" | rev | cut -d- -f3- | rev | sort | uniq >$DEPS_SUMMARY
#cut -d: -f1 $DEPS_SUMMARY | sort | uniq | sort >$DEPS_BEFORE
#popd >/dev/null
#
#echo "Listing the deps summary after removing the tripleo projects"
#rdopkg info component:tripleo | grep -e "project:" | awk '{print $2}' | sort >$TRIPLEO_PROJECTS
#grep_regexp=$(cat $TRIPLEO_PROJECTS | head -n 1)
#while IFS= read -r project; do
#    grep_regexp="$grep_regexp\|.*$project.*"
#done < $TRIPLEO_PROJECTS
#grep -v -e "$grep_regexp" $DEPS_SUMMARY | cut -d: -f1- | sort | uniq | sort >$DEPS_AFTER_EXCLUSION
#cut -d: -f1 $DEPS_AFTER_EXCLUSION | sort | uniq | sort >$DEPS_AFTER

echo -e "Deps to remove below:\n"
>$DEPS_TO_REMOVE
comm -3 $DEPS_BEFORE $DEPS_AFTER > ${DEPS_TO_REMOVE}_tmp
while IFS= read -r dep; do
    if ! grep -q -e "$dep" $DEPS_AFTER_EXCLUSION; then
        echo "$dep" >> $DEPS_TO_REMOVE
    fi
done < ${DEPS_TO_REMOVE}_tmp
rm -f ${DEPS_TO_REMOVE}_tmp
cat ${DEPS_TO_REMOVE}
echo -e ""
