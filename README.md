# Laravel Docker Project

This project provides a fully Dockerized development environment for a Laravel 12 application using PHP 8.4 FPM, PostgreSQL, Redis, and Nginx.

## Project Structure

```
project-root/
├── app/                      # Laravel application code
├── ...
├── docker/
│   ├── nginx/                # Nginx configuration files
│   │   └── nginx.conf
│   ├── php/                  # PHP Dockerfile and setup
│   │   └── Dockerfile
│   └── entrypoint.sh         # Entrypoint script for Laravel setup
├── docker-compose.yml        # Docker Compose service definitions
├── .env.example              # Environment variable template
└── README.md
```

## Environment Details

-   **Laravel**: 12.x
-   **PHP**: 8.4 (FPM)
-   **Database**: PostgreSQL 16
-   **Cache**: Redis 7 (Alpine)
-   **Web Server**: Nginx (Alpine)
-   **Orchestration**: Docker Compose

### 📄 Environment File Separation

By default, Laravel uses a `.env` file to load configuration, while Docker Compose also uses `.env` (in the root directory) to interpolate values in `docker-compose.yml`.

To avoid conflict and ensure container-specific configuration, this project uses a separate file:

```bash
.env.docker
```

> This file is mounted as `/var/www/.env` inside the container and contains environment variables **specifically for the application runtime inside Docker**.

#### 🔁 Usage Flow:

1. **Copy the base `.env` from example:**

    ```bash
    cp .env.example .env
    ```

2. **Duplicate it for Docker-specific usage:**

    ```bash
    cp .env .env.docker
    ```

Then, inside `docker-compose.yml`, you’ll find:

```yaml
volumes:
    - ./.env.docker:/var/www/.env
```

This ensures that:

-   Your host Laravel setup (if any) still uses `.env`
-   Your container environment is isolated via `.env.docker`

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
cp .env .env.docker
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

## Technical Notes

-   **Environment Isolation**: The application runs entirely inside containers, ensuring your host machine stays clean.
-   **File Permissions**: UID/GID synchronization is configurable via `.env.example` to avoid permission issues between Windows/WSL and Linux containers.
-   **Database**: A PostgreSQL role and database are automatically created based on the `POSTGRES_USER` and `POSTGRES_DB` environment variables.
-   **Redis Integration**: Laravel is configured to use Redis for cache and sessions. You can choose between `phpredis` or `predis` by updating your `.env` file.

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
