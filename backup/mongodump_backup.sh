#!/bin/bash

current_date=$(date +%Y-%m-%d)

# Create out dir if not exists
mkdir -p "$MONGO_BACKUP_DIR/$current_date"

# Run mongodump
mongodump \
    --host "$MONGO_REPLICA_SET_NAME/$MONGO_REPLICA_SET_HOSTS" \
    --username "$MONGO_BACKUP_USER" \
    --password "$MONGO_BACKUP_PASSWORD" \
    --authenticationDatabase "$MONGO_AUTHENTICATION_DATABASE" \
    --readPreference "$MONGO_BACKUP_FROM" \
    --out "$MONGO_BACKUP_DIR/$current_date" \
    --oplog

# Exit with the appropriate status
exit 0