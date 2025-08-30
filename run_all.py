import subprocess
import re
import time
import requests


def get_ngrok_url_api():
    """Get ngrok URL using the local API (recommended method)"""
    try:
        # Wait a moment for ngrok to start
        time.sleep(2)

        # Query ngrok's local API
        response = requests.get('http://localhost:4040/api/tunnels')
        data = response.json()

        # Find the HTTP tunnel
        for tunnel in data['tunnels']:
            if tunnel['proto'] == 'https':
                url = tunnel['public_url']
                # Remove https:// prefix
                return url.replace('https://', '')
    except Exception as e:
        print(f"API method failed: {e}")
        return None


def get_ngrok_url_subprocess():
    """Get ngrok URL by parsing subprocess output (alternative method)"""
    # Start ngrok process in HTTP mode on port 8443
    proc = subprocess.Popen(
        ["ngrok", "http", "8443"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        bufsize=1,  # Line buffered
        universal_newlines=True
    )

    url = None
    timeout = 30  # 30 second timeout
    start_time = time.time()

    # Read lines to find forwarding URL
    while True:
        if time.time() - start_time > timeout:
            print("Timeout waiting for ngrok URL")
            break

        line = proc.stdout.readline()
        if not line and proc.poll() is not None:
            break

        if line:
            print(f"Ngrok output: {line.strip()}")  # Debug output

            # Look for the forwarding URL pattern
            if "forwarding" in line.lower() or "https://" in line:
                match = re.search(r'https://[a-z0-9-]+\.ngrok-free\.app', line)
                if match:
                    url = match.group(0)
                    print(f"Found URL: {url}")
                    break

        time.sleep(0.1)  # Small delay to prevent busy waiting

    return url, proc


def get_ngrok_url():
    """Main function that tries API method first, then subprocess method"""

    # First, start ngrok in the background
    print("Starting ngrok...")
    proc = subprocess.Popen(
        ["ngrok", "http", "8443"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    # Wait for ngrok to start
    time.sleep(3)

    # Try API method first (more reliable)
    url = get_ngrok_url_api()
    if url:
        return url, proc

    # If API method fails, terminate the background process and try subprocess method
    proc.terminate()
    print("API method failed, trying subprocess method...")

    return get_ngrok_url_subprocess()


if __name__ == "__main__":
    url, process = get_ngrok_url()
    if url:
        print("Ngrok URL is:", url)

        # Run the command: python start_nifi.py <url>
        result = subprocess.run(["python", "start_nifi.py", url], capture_output=True, text=True)

        # Print the output and errors if any
        print("Output:", result.stdout)
        print("Errors:", result.stderr)

        input("Press Enter to continue...")  # Wait for user input

        print("Running save.sh script...")
        subprocess.call(["sh", "./save.sh"])

        print("Terminating ngrok...")
        process.terminate()
        print("Done.")

    else:
        print("Ngrok URL not found")
        if 'process' in locals():
            process.terminate()
