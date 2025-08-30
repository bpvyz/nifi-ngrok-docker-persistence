CONTAINER_NAME=nifi_container
DEST_DIR=./nifi_data
mkdir -p $DEST_DIR/conf
mkdir -p $DEST_DIR/database_repository
mkdir -p $DEST_DIR/flowfile_repository
mkdir -p $DEST_DIR/content_repository
mkdir -p $DEST_DIR/provenance_repository
mkdir -p $DEST_DIR/certs
mkdir -p $DEST_DIR/lib
docker cp $CONTAINER_NAME:/opt/nifi/nifi-current/conf $DEST_DIR/
docker cp $CONTAINER_NAME:/opt/nifi/nifi-current/database_repository $DEST_DIR/
docker cp $CONTAINER_NAME:/opt/nifi/nifi-current/flowfile_repository $DEST_DIR/
docker cp $CONTAINER_NAME:/opt/nifi/nifi-current/content_repository $DEST_DIR/
docker cp $CONTAINER_NAME:/opt/nifi/nifi-current/provenance_repository $DEST_DIR/
docker cp $CONTAINER_NAME:/opt/nifi/nifi-current/certs $DEST_DIR/
docker cp $CONTAINER_NAME:/opt/nifi/nifi-current/lib $DEST_DIR/
echo "NiFi data copied to $DEST_DIR"