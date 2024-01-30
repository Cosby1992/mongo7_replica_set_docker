FROM mongo:7

# Create the directory for the keyfile
RUN mkdir -p /data/keyfile

# Copy the keyfile into the container
COPY ./keyfile/keyfile /data/keyfile/

# Set permissions on the keyfile
RUN chmod 600 /data/keyfile/keyfile

RUN chown 999:999 /data/keyfile/keyfile

# Start MongoDB with replica set configuration
CMD ["mongod", "--replSet", "ha_rs", "--bind_ip_all", "--keyFile", "data/keyfile/keyfile"]