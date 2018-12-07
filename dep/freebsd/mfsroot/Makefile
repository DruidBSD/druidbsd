# -*- tab-width:  4 -*- ;; Emacs
# vi: set tabstop=4     :: Vi/ViM

MDUNIT = 5
SUDO   = sudo

all:
	@echo "	open:		Open mfsroot.gz"
	@echo "	copy:		Copy in src to opened image"
	@echo "	close:		Close mfsroot.gz"
	@echo "	remake:		Open, re-copy src, and close"
	@echo "	from_dep:	Re-make from stored dependencies"

stage1:
	cp -i dep/mfsroot.gz mfsroot.gz

stage2:
	gunzip mfsroot.gz
	mkdir -p mnt
	$(SUDO) mdconfig -f mfsroot -u $(MDUNIT)
	$(SUDO) mount /dev/md$(MDUNIT)a mnt

stage3:
	( cd src && \
	  find . -type d -mindepth 1 ! -name CVS -exec \
	  	$(SUDO) mkdir -pv '../mnt/{}' \; \
	)
	( cd src && \
	  find . -type f ! -path '*/CVS/*' -a ! -name '.keep' -exec \
	  	$(SUDO) cp -pfv '{}' '../mnt/{}' \; \
	)
	( cd src && \
	  find . -type l -exec $(SUDO) cp -RPpfv '{}' '../mnt/{}' \; )
	( cd mnt && \
	  $(SUDO) pwd_mkdb -i -d etc etc/master.passwd )

stage4:
	$(SUDO) umount mnt
	rmdir mnt
	$(SUDO) mdconfig -d -u $(MDUNIT)
	gzip mfsroot

from_dep: stage1 stage2 stage3 stage4

remake: stage2 stage3 stage4

open: stage2

copy: stage3

close: stage4

################################################################################
#
# $Header: /cvsroot/druidbsd/druidbsd/druidbsd/dep/freebsd/mfsroot/Makefile,v 1.1.1.1 2010/09/15 20:36:23 devinteske Exp $
#
# $Copyright: 2010 Devin Teske. All rights reserved. $
#
# $Log: Makefile,v $
# Revision 1.1.1.1  2010/09/15 20:36:23  devinteske
# Initial import of project.
#
#
################################################################################
