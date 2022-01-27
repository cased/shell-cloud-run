# Imports the latest release of Cased Shell into a registry
# supported by Google Cloud Run (https://cloud.google.com/run/docs/deploying#other-registries)
FROM ghcr.io/cased/shell:v0.10.3
COPY --from=ghcr.io/cased/jump:latest /bin/app /bin/jump
COPY --from=ghcr.io/cased/ssh-oauth-handlers:pr-6 /bin/app /bin/ssh-oauth-handlers
ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]
CMD []
ADD entrypoint.sh jump.yml /