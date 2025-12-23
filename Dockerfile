FROM alpine

# DEPENDENCIES
RUN apk -U upgrade --no-cache \
    && apk add --no-cache \
    inotify-tools jpegoptim exiftool gawk file bash
    
COPY ./monitor.sh /monitor.sh
RUN chmod +x /monitor.sh
ENTRYPOINT ["/bin/bash", "--", "/monitor.sh"]
