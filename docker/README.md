# Running Odoo with Docker Compose

This builds an Odoo image from this repository checkout and runs it
alongside a PostgreSQL database, for local development.

From the repository root:

```bash
docker compose up --build
```

Odoo will be available at http://localhost:8069 once the first build
finishes. On first run, use the "Database Manager" (or the initial setup
screen) to create a database — the master password is set by
`admin_passwd` in `docker/odoo.conf` (default: `admin`, change it before
using this anywhere but your machine).

## Layout

- `../Dockerfile` — builds the Odoo image from this source tree.
- `../docker-compose.yaml` — defines the `odoo` and `db` services.
- `odoo.conf` — Odoo configuration mounted into the container at
  `/etc/odoo/odoo.conf`.

## Adding custom addons

Uncomment the extra volume mount in `docker-compose.yaml`:

```yaml
    volumes:
      - ./extra-addons:/mnt/extra-addons
```

and place your custom modules in `./extra-addons` (already referenced in
`docker/odoo.conf`'s `addons_path`).

## Useful commands

```bash
# Run in the background
docker compose up -d --build

# Follow logs
docker compose logs -f odoo

# Run odoo-bin with extra arguments (e.g. update a module)
docker compose run --rm odoo --update=base --stop-after-init

# Stop and remove containers (keeps the named volumes / data)
docker compose down

# Also wipe the database and filestore
docker compose down -v
```
