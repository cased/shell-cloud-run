# Imports the latest release of Cased Shell into a registry
# supported by Google Cloud Run (https://cloud.google.com/run/docs/deploying#other-registries)
FROM ghcr.io/cased/shell:v0.10.3
COPY --from=ghcr.io/cased/jump:latest /bin/app /bin/jump
COPY --from=ghcr.io/cased/ssh-oauth-handlers:pr-6 /bin/app /bin/ssh-oauth-handlers
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-sdk -y
ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]
CMD []
ADD entrypoint.sh jump.yml /