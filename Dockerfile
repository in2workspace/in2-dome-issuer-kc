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

# Copy all realm files into a temporary location
COPY /data/import/in2-dome-realm-lcl.json /tmp/
COPY /data/import/in2-dome-realm-sbx.json /tmp/
COPY /data/import/in2-dome-realm-dev.json /tmp/
COPY /data/import/in2-dome-realm-prd.json /tmp/

# Ensure the target directory exists and has the correct permissions
RUN mkdir -p /opt/keycloak/data/import && chown -R 1000:1000 /opt/keycloak/data/import

# Conditionally copy the correct realm file based on the environment
RUN if [ "$ENVIRONMENT" = "lcl" ]; then \
      cp /tmp/in2-dome-realm-lcl.json /opt/keycloak/data/import/in2-dome-realm-lcl.json; \
    elif [ "$ENVIRONMENT" = "sbx" ]; then \
      cp /tmp/in2-dome-realm-sbx.json /opt/keycloak/data/import/in2-dome-realm-sbx.json; \
    elif [ "$ENVIRONMENT" = "dev" ]; then \
      cp /tmp/in2-dome-realm-dev.json /opt/keycloak/data/import/in2-dome-realm-dev.json; \
    elif [ "$ENVIRONMENT" = "prd" ]; then \
      cp /tmp/in2-dome-realm-prd.json /opt/keycloak/data/import/in2-dome-realm-prd.json; \
    else \
      echo "Unknown environment: $ENVIRONMENT"; \
      exit 1; \
    fi

# Clean up temporary files
RUN rm /tmp/in2-dome-realm-*.json

USER nonroot

# Command to start Keycloak
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start-dev", "--health-enabled=true", "--metrics-enabled=true", "--log-level=INFO", "--import-realm"]
