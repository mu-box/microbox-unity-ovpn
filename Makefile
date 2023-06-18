SOURCES = $(wildcard */*)
MD5SUM=$(shell { command -v md5sum || command -v md5; } 2>/dev/null)

.PHONY: all publish

all: publish

%.md5: %.tar.gz
	cat $< | ${MD5SUM} | awk '{print $$1}' > $@

unity-ovpn.tar.gz: ${SOURCES}
	DIR=$$(mktemp -d); \
	mkdir -p $${DIR}/usr/bin; \
	mkdir -p $${DIR}/var/db/ovpn/connections; \
	mkdir -p $${DIR}/var/db/ovpn/zones; \
	cp -r bin/* $${DIR}/usr/bin;\
	tar -czf unity-ovpn.tar.gz -C $${DIR} .
	rm -rf $${DIR}

publish: unity-ovpn.tar.gz unity-ovpn.md5
	aws s3 cp --acl public-read unity-ovpn.tar.gz s3://unity.microbox.cloud/bootstrap/vpn/unity-ovpn.tar.gz; \
	aws s3 cp --acl public-read unity-ovpn.md5 s3://unity.microbox.cloud/bootstrap/vpn/unity-ovpn.md5;
