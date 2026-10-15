"""Create (if missing) and deploy this app to CapRover via REST API.

Usage:  CAPROVER_PASSWORD=... python deploy.py [app-name]
Password comes from env or app/.env (git-ignored), never from the repo.
"""
import io, json, os, sys, tarfile, time, urllib.error, urllib.request, uuid

CAPTAIN = "https://captain.h.aioblak.com"
APP = sys.argv[1] if len(sys.argv) > 1 else "rba-pfm"
HERE = os.path.dirname(os.path.abspath(__file__))
SKIP = {"build", ".dart_tool", ".idea", ".env", "deploy.py"}


def password():
    if os.environ.get("CAPROVER_PASSWORD"):
        return os.environ["CAPROVER_PASSWORD"]
    env = os.path.join(HERE, ".env")
    if os.path.exists(env):
        for line in open(env, encoding="utf-8"):
            k, _, v = line.strip().partition("=")
            if k == "CAPROVER_PASSWORD":
                return v.strip().strip('"')
    sys.exit("CAPROVER_PASSWORD not set (env or app/.env)")


def call(path, body=None, token=None, raw=None, ctype="application/json"):
    data = raw if raw is not None else (json.dumps(body).encode() if body is not None else None)
    req = urllib.request.Request(CAPTAIN + "/api/v2" + path, data=data, method="POST" if data else "GET")
    req.add_header("Content-Type", ctype)
    req.add_header("x-namespace", "captain")
    if token:
        req.add_header("x-captain-auth", token)
    with urllib.request.urlopen(req, timeout=600) as r:
        res = json.load(r)
    if res.get("status") not in (100, 101):  # 100 ok, 101 ok-partial
        raise RuntimeError(f"{path}: {res.get('status')} {res.get('description')}")
    return res.get("data")


def tarball():
    buf = io.BytesIO()
    with tarfile.open(fileobj=buf, mode="w") as t:
        for name in os.listdir(HERE):
            if name not in SKIP and not name.endswith(".tar"):
                t.add(os.path.join(HERE, name), arcname=name)
    return buf.getvalue()


def main():
    token = call("/login", {"password": password()})["token"]
    apps = call("/user/apps/appDefinitions", token=token)["appDefinitions"]
    app = next((a for a in apps if a["appName"] == APP), None)

    if app is None:
        print(f"Registering {APP}...")
        call("/user/apps/appDefinitions/register", {"appName": APP, "hasPersistentData": False}, token)
        # ponytail: not idempotent, so only on first create
        call("/user/apps/appDefinitions/enablebasedomainssl", {"appName": APP}, token)
        apps = call("/user/apps/appDefinitions", token=token)["appDefinitions"]
        app = next(a for a in apps if a["appName"] == APP)

    if not app.get("forceSsl"):
        # update is a replace: send the fetched definition back with one field changed
        app["forceSsl"] = True
        call("/user/apps/appDefinitions/update", app, token)

    boundary = uuid.uuid4().hex
    body = (f"--{boundary}\r\nContent-Disposition: form-data; name=\"sourceFile\"; filename=\"deploy.tar\"\r\n"
            f"Content-Type: application/x-tar\r\n\r\n").encode() + tarball() + f"\r\n--{boundary}--\r\n".encode()
    print("Uploading source...")
    call(f"/user/apps/appData/{APP}?detached=1", token=token, raw=body,
         ctype=f"multipart/form-data; boundary={boundary}")

    while True:
        time.sleep(5)
        logs = call(f"/user/apps/appData/{APP}/logs", token=token) or {}
        if not logs.get("isAppBuilding"):
            break
        print("  building...")
    if logs.get("isBuildFailed"):
        lines = logs.get("logs", {}).get("lines", [])
        print("\n".join(lines[-40:]) if isinstance(lines, list) else str(lines)[-4000:])
        sys.exit("Build FAILED")
    print(f"Deployed: https://{APP}.h.aioblak.com")


if __name__ == "__main__":
    try:
        main()
    except urllib.error.HTTPError as e:
        sys.exit(f"HTTP {e.code}: {e.read()[:500]}")
