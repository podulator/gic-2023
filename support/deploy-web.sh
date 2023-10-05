#!/usr/bin/bash

function usage() {
	echo "usage : $0 [s3 bucket] [cloudfront id]"
}
if [[ $# -ne 2 ]]; then
	usage
	exit 0
fi
bucket=$1
distribution=$2

pushd ../builds/web
aws s3 sync . s3://${bucket} --acl public-read
aws --no-cli-pager  cloudfront create-invalidation --distribution-id ${distribution} --paths "/*"
popd
