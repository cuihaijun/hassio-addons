server {
  listen {{ .ingress_host }}:{{ .ingress_port }} default_server;
  server_name _;

  allow 172.30.32.2;
  deny all;

  client_max_body_size 4G;

  proxy_hide_header X-Frame-Options;
  proxy_hide_header Content-Security-Policy;
  add_header X-Frame-Options "SAMEORIGIN";
  add_header Content-Security-Policy "frame-ancestors *";

  location / {
    proxy_pass http://rsshub_backend/;
    proxy_http_version 1.1;
    proxy_set_header Connection $connection_upgrade;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Host $http_host;
    proxy_set_header X-Forwarded-Host $http_host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-NginX-Proxy true;
    proxy_set_header Accept-Encoding "";

    sub_filter_once off;
    sub_filter_types *;
    sub_filter href="/ href="/{{ .ingress_entry }}/;
    sub_filter src="/ src="/{{ .ingress_entry }}/;
    sub_filter action="/ action="/{{ .ingress_entry }}/;
  }
}

server {
  listen {{ .bind_host }}:{{ .bind_port }}{{ if .direct_ssl }} ssl{{ end }};
  server_name _;

  {{ if .direct_ssl }}
  ssl_certificate /ssl/{{ .certfile }};
  ssl_certificate_key /ssl/{{ .keyfile }};
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_prefer_server_ciphers on;
  {{ end }}

  client_max_body_size 4G;

  location / {
    proxy_pass http://rsshub_backend/;
    proxy_http_version 1.1;
    proxy_set_header Connection $connection_upgrade;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Host $http_host;
    proxy_set_header X-Forwarded-Host $http_host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-NginX-Proxy true;
  }
}
