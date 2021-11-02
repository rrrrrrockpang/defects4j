WORK_DIR="./work_dir/commons-configuration"

PROJECT_ID="Configuration"
PROJECT_NAME="commons-configuration"
REPOSITORY_URL="https://github.com/apache/commons-configuration.git"

ISSUE_TRACKER_NAME="jira"
ISSUE_TRACKER_PROJECT_ID="CONFIGURATION"
BUG_FIX_REGEX="/(CONFIGURATION-\d+)/mi"

./minimize-patch.pl -p $PROJECT_ID -w $WORK_DIR -b 59