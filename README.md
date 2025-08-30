# nifi-ngrok-docker-persistence
Lightweight setup for running Apache NiFi inside a Docker container with data persistence and public access via ngrok. Includes helper scripts for automatic startup, live saving, and manual control.
-----

# Requirements

Before running, make sure you have the following installed:

* **Docker** → [Install guide](https://docs.docker.com/get-docker/)
* **Python 3.x** → [Download](https://www.python.org/downloads/)
* **Ngrok** → [Setup guide](https://dashboard.ngrok.com/get-started/setup)

---

# Building the Docker Image

```bash
docker build -t test-nifi .
```

> You can replace `test-nifi` with another image name.
> If you do, make sure to also update the `image_name` variable inside the `main()` function of `start_nifi.py`.

---

# Running the Easy Way

1. **Run everything with one command**

   ```bash
   python run_all.py
   ```

   > This script will:
   >
   > * Start ngrok and fetch the public URL.
   > * Pass that URL to `start_nifi.py`.
   > * Launch NiFi with persistence enabled.

---

# Running Manually

1. **Expose NiFi with ngrok**

   ```bash
   ngrok http https://localhost:8443 --host-header=localhost
   ```

   > This starts ngrok on port `8443` and returns a unique public URL (changes every run).

2. **Start NiFi with persistence**

   ```bash
   python start_nifi.py <ngrok_url>
   ```

   > The script will:
   >
   > * Create a directory called `nifi_data` in the project root.
   > * If `nifi_data` already exists, NiFi will start with that data mounted as volumes (persistence).

   > You can also rename container-related variables directly in the `main()` function if needed.

---

# Saving and Stopping

* **Save without stopping the container**

  ```bash
  ./livesave.sh
  ```

  > Runs `docker cp` to back up data while the container is still running.

* **Save and stop the container**

  ```bash
  ./save.sh
  ```

  > Runs `docker cp` to back up data and then stops the container.
