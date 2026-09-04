# Dockerfile for running this Odoo source checkout directly (for development).
#
# Builds an image from the repository as-is and runs it against a separate
# PostgreSQL container (see docker-compose.yaml). Not an official Odoo image.

FROM python:3.12-slim-bookworm

ENV LANG=C.UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# System dependencies:
# - build tools + headers needed to compile Python packages (lxml, Pillow,
#   psycopg2, gevent, cryptography, ...)
# - wkhtmltopdf for PDF report generation
# - nodejs/npm + rtlcss for right-to-left CSS generation of web assets
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        fonts-freefont-ttf \
        gnupg \
        libfreetype6-dev \
        libjpeg-dev \
        libldap2-dev \
        libpq-dev \
        libsasl2-dev \
        libssl-dev \
        libxml2-dev \
        libxslt1-dev \
        libzip-dev \
        nodejs \
        npm \
        wkhtmltopdf \
        xfonts-75dpi \
        xfonts-base \
        zlib1g-dev \
    && npm install -g rtlcss \
    && rm -rf /var/lib/apt/lists/*

# Create the odoo user and data directories
RUN adduser --system --home=/var/lib/odoo --group odoo \
    && mkdir -p /var/lib/odoo /mnt/extra-addons \
    && chown -R odoo:odoo /var/lib/odoo /mnt/extra-addons

WORKDIR /opt/odoo

# Install Python dependencies first to make use of Docker layer caching
COPY requirements.txt /opt/odoo/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the Odoo source
COPY . /opt/odoo

RUN chown -R odoo:odoo /opt/odoo

USER odoo

VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

EXPOSE 8069 8071 8072

ENTRYPOINT ["/opt/odoo/odoo-bin"]
CMD ["--config=/etc/odoo/odoo.conf"]
