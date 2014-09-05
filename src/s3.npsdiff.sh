set -e -u

FILE="npsdiff-$(date +%s).zip"

zip -r ${FILE} npsdiff-tasks/

cp ${FILE} npsdiff-latest.zip

s3cmd put --acl-public ${FILE} s3://to-fix/${FILE}
s3cmd put --acl-public npsdiff-latest.zip s3://to-fix/npsdiff-latest.zip

rm -rf npsdiff-*.zip
