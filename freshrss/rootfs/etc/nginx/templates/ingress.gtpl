server {
    listen {{ .ingress_host }}:{{ .ingress_port }} default_server;

    include /etc/nginx/includes/server_params.conf;

    allow   172.30.32.2;
    deny    all;

    proxy_hide_header X-Frame-Options;
    proxy_hide_header Content-Security-Policy;
    add_header X-Frame-Options "SAMEORIGIN";
    add_header Content-Security-Policy "frame-ancestors *";

    # Rewrite URLs in responses to include ingress path prefix
    sub_filter_once off;
    sub_filter_types *;
    sub_filter 'href="/' 'href="/{{ .ingress_entry }}/';
    sub_filter 'src="/' 'src="/{{ .ingress_entry }}/';
    sub_filter 'action="/' 'action="/{{ .ingress_entry }}/';

    # this regex is mandatory because of the API
    location ~ ^.+?\.php(/.*)?$ {
        fastcgi_pass 127.0.0.1:9002;
        fastcgi_read_timeout 900;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_index index.php;
        # By default, the variable PATH_INFO is not set under PHP-FPM
        # But FreshRSS API greader.php need it. If you have a "Bad Request" error, double check this var!
        # NOTE: the separate $path_info variable is required. For more details, see:
        # https://trac.nginx.org/nginx/ticket/321
        set $path_info $fastcgi_path_info;
        fastcgi_param PATH_INFO $path_info;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include /etc/nginx/includes/fastcgi_params.conf;
    }
}
