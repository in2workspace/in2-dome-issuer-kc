# Start with the official Keycloak image from Quay.io (https://quay.io/repository/keycloak/keycloak?tab=tags)
# FROM laura:latest
FROM in2workspace/issuer-keycloak-plugin:v1.1.0

# Create non-root user and group manually
USER root
RUN echo "nonroot:x:1000:1000:Non-root user:/home/nonroot:/sbin/nologin" >> /etc/passwd \
    && echo "nonroot:x:1000:" >> /etc/group \
    && mkdir -p /home/nonroot \
    && chown -R 1000:1000 /home/nonroot

# Define build argument
ARG ENVIRONMENT

# Copy the theme files into the image
COPY /themes /opt/keycloak/themes

# Copy the realm file into the image according to the environment
RUN if [ "$ENVIROMENT" = "lcl" ]; then \
      cp /data/import/in2-dome-realm-lcl.json /opt/keycloak/data/import/; \
    elif [ "$ENVIROMENT" = "sbx" ]; then \
      cp /data/import/in2-dome-realm-sbx.json /opt/keycloak/data/import/; \
    elif [ "$ENVIROMENT" = "dev" ]; then \
      cp /data/import/in2-dome-realm-dev.json /opt/keycloak/data/import/; \
    elif [ "$ENVIROMENT" = "prd" ]; then \
      cp /data/import/in2-dome-realm-prd.json /opt/keycloak/data/import/; \
    else \
      echo "Unknown environment: $ENVIROMENT"; \
      exit 1; \
    fi


# Ensure nonroot user has permissions to modify the import directory
RUN chown -R 1000:1000 /opt/keycloak/data/import

USER nonroot


# Command to start Keycloak
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start-dev", "--health-enabled=true", "--metrics-enabled=true", "--log-level=INFO", "--import-realm"]
