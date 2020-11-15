#! /bin/sh

TEMPLATES_DIR="templates"
UPLOAD_DIR="upload"

mkdir -p $UPLOAD_DIR

function mkfileP() { 
  mkdir -p "$(dirname "$1")" || return; touch "$1"; 
}

for f in $(find $TEMPLATES_DIR -name $PARAMETERS_FILE)
do
  new_file="$UPLOAD_DIR/${f#templates/}"
  mkfileP $new_file

  if [[ $(jq '.parameters | select(has("sasToken"))' "$(dirname $f)/$TEMPLATE_FILE") ]]; then
    echo "Adding SAS Token parameter to ${f#templates/}"
    cat $f | jq --arg sasToken $SAS_TOKEN '. * {"parameters": {"sasToken": {"value": $sasToken}}}' > $new_file
  else 
    cp $f $(dirname $new_file)
  fi 
done

for f in $(find $TEMPLATES_DIR -name $TEMPLATE_FILE)
do
  upload_folder="$UPLOAD_DIR/$(dirname ${f#templates/})"
  mkdir -p $upload_folder
  cp $f $upload_folder
done

for f in $(find $UPLOAD_DIR -name "*.json")
do
  echo "Uploading $f file..."
  az storage blob upload \
    --file $f \
    --account-name $TEMPLATE_STORAGE_ACCOUNT \
    --container-name $TEMPATE_STORAGE_CONTAINER \
    --name ${f#upload/}
done

rm -rf $UPLOAD_DIR