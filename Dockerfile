FROM nginx:1.25.1
COPY index.html site.css version.txt environment.txt /usr/share/nginx/html