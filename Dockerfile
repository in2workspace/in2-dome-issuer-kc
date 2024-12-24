# Start with the official Keycloak image from Quay.io (https://quay.io/repository/keycloak/keycloak?tab=tags)
# FROM laura:latest
FROM in2workspace/in2-keycloak-extension:v1.1.1-snapshot

# Create non-root user and group manually
USER root
RUN echo "nonroot:x:1000:1000:Non-root user:/home/nonroot:/sbin/nologin" >> /etc/passwd \
    && echo "nonroot:x:1000:" >> /etc/group \
    && mkdir -p /home/nonroot \
    && chown -R 1000:1000 /home/nonroot

# Copy the theme and realm files into the image
COPY /themes /opt/keycloak/themes
COPY /data/import/CredentialIssuer-realm.json /opt/keycloak/data/import/

# Ensure nonroot user has permissions to modify the import directory
RUN chown -R 1000:1000 /opt/keycloak/data/import

USER nonroot


# Command to start Keycloak
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start-dev", "--health-enabled=true", "--metrics-enabled=true", "--log-level=INFO", "--import-realm"]
