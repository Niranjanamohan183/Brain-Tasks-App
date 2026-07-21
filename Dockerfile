# Brain-Tasks-App — production image
# The repo ships only the compiled Vite/React output (dist/), so this is a
# single-stage image: nginx serving static files on port 3000.

FROM nginx:1.27-alpine

# Remove default nginx site config and drop in ours (listens on 3000, SPA-aware)
RUN rm -f /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Ship the pre-built app
COPY dist/ /usr/share/nginx/html/

EXPOSE 3000

# nginx:alpine already runs as non-root (nginx user) for worker processes;
# master needs root to bind <1024, but 3000 is unprivileged so we can drop root entirely.
USER nginx

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:3000/ || exit 1

CMD ["nginx", "-g", "daemon off;"]