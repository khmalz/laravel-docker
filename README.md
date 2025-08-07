# Laravel Docker Project

This project provides a fully Dockerized development environment for a Laravel 12 application using **FrankenPHP** (Caddy-based server), PHP 8.4, PostgreSQL, and Redis.

## Project Structure

```
project-root/
├── app/                      # Laravel application code
├── ...
├── docker/
│   ├── php/                  # PHP Dockerfile and setup (FrankenPHP)
│   │   └── Dockerfile
│   ├── etc/
│   │   └── supervisor.d/
│   │       └── supervisord.conf
│   └── entrypoint.sh         # Entrypoint script for Laravel setup
├── docker-compose.yml        # Docker Compose service definitions
├── .env.example              # Environment variable template
└── README.md
```

## Environment Details

-   **Laravel**: 12.x
-   **PHP**: 8.4 (via FrankenPHP)
-   **Database**: PostgreSQL 16
-   **Cache**: Redis 7 (Alpine)
-   **Web Server**: [FrankenPHP](https://frankenphp.dev) (Caddy-based PHP server)
-   **Orchestration**: Docker Compose

### ⚙️ Environment Flexibility

By default, the application looks for a `.env.docker` file **inside the container**.

To support multiple workflows:

-   If `.env.docker` exists → it will be used and copied as `.env`
-   If not → `.env` or `.env.example` will be used instead

This logic is handled inside `entrypoint.sh` automatically, so developers can work with whichever they prefer.

## Getting Started

### Prerequisites

Ensure Docker and Docker Compose are installed:

```bash
docker --version
docker compose version
```

### Setting Up the Environment

1. Copy the .env.example file to .env and adjust any necessary environment variables:

```bash
cp .env.example .env
```

2. Start the Docker Compose Services:

```bash
docker-compose up -d --build
```

3. Access the Application:

Visit: [http://localhost:8000](http://localhost:8000)

### Accessing inside the Container

### Rebuild Containers:

```bash
docker-compose up -d --build
```

### Stop Containers:

```bash
docker-compose down
```

### View Logs:

```bash
docker-compose logs -f
```

For specific services, you can use:

```bash
docker-compose logs -f php
```

## Laravel Setup (Inside the Container)

After container startup, the `entrypoint.sh` automatically:

-   Installs dependencies via Composer
-   Copies the `.env.docker` file (if exists)
-   Generates application key
-   Waits for PostgreSQL to be ready
-   Runs database migrations and seeds
-   Caches Laravel config, routes, and views
-   Fixes storage & cache directory permissions

You can manually access the PHP container with:

```bash
docker-compose exec php bash
```

Or run artisan commands directly:

```bash
docker-compose exec php php artisan migrate
```

Laravel is served via:

-   `php artisan octane:frankenphp --host=0.0.0.0 --port=80`
-   Managed using `supervisord` in production-like mode

## Technical Notes

-   **Web Server**: FrankenPHP is a modern, high-performance PHP server built on Caddy with Octane and Fiber integration.
-   **Environment Isolation**: The application runs entirely inside containers, keeping your host machine clean.
-   **Permissions**: UID/GID can be adjusted in `.env.example` for compatibility with your OS (Linux/WSL/Windows).
-   **PostgreSQL**: Role/database are created via Docker Compose environment.
-   **Redis**: Laravel uses Redis (via `phpredis`) for cache, queue, and sessions.

## 💡 Troubleshooting

### `FATAL: role "postgres" does not exist`

Make sure you are using the correct `POSTGRES_USER` and healthcheck in your `docker-compose.yml`. The default is:

```yaml
POSTGRES_USER=laravel
POSTGRES_DB=laravel-docker
```

And the healthcheck should be:

```yaml
test: ["CMD-SHELL", "pg_isready -U laravel -d laravel-docker"]
```

## 🐘 Database & Redis Access

To access PostgreSQL CLI:

```bash
docker compose exec postgres psql -U laravel -d laravel-docker
```

To access Redis CLI:

```bash
docker compose exec redis redis-cli
```
