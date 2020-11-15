#! /bin/bash

SETTINGS_PATH="deploy.parameters.sh"

if [[ -f $SETTINGS_PATH ]]; then
    source $SETTINGS_PATH
else
    echo -e "$ERROR File $SETTINGS_PATH not found. Exiting."
    exit 1
fi

./upload_templates.sh

az deployment create \
  --location $REGION \
  --template-file $TEMPLATE_FILE \
  --parameters \
      $PARAMETERS_FILE \
      sasToken=$SAS_TOKEN