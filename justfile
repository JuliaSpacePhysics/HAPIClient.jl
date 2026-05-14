update-servers:
    curl -fsSL https://raw.githubusercontent.com/hapi-server/servers/refs/heads/master/abouts.json \
        -o src/abouts.json
