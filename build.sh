git pull
rm -rf build
uv sync
source .venv/bin/activate

make html
systemctl restart caddy
