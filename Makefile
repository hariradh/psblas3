include Make.inc

all: libd based precd kryld utild
#	(cd opt; $(MAKE) lib)
	@echo "====================================="
	@echo "PSBLAS libraries Compilation Successful."

based: libd
precd utild: based
kryld: precd based

libd:
	(if test ! -d lib ; then mkdir lib; fi)
based:
	cd base && $(MAKE) lib
precd:
	cd prec && $(MAKE) lib
kryld:
	cd krylov && $(MAKE) lib
utild:
	cd util&& $(MAKE) lib 

install: all
	(./mkdir.sh  $(INSTALL_DIR) &&\
	   $(INSTALL_DATA) Make.inc  $(INSTALL_DIR))
	(./mkdir.sh  $(INSTALL_LIBDIR) &&\
	   $(INSTALL_DATA) lib/*.a  $(INSTALL_LIBDIR))
	(./mkdir.sh  $(INSTALL_INCLUDEDIR) && \
	   $(INSTALL_DATA) lib/*$(.mod) $(INSTALL_INCLUDEDIR))
	(./mkdir.sh  $(INSTALL_DOCSDIR) && \
	   /bin/cp -fr docs/*pdf docs/html $(INSTALL_DOCSDIR))
clean: 
	cd base && $(MAKE) clean
	cd prec && $(MAKE) clean 
	cd krylov && $(MAKE) clean
	cd util && $(MAKE) clean
	cd opt && $(MAKE) clean

doxy: 
	doxygen doxypsb
check: all
	make check -C test/serial

cleanlib:
	(cd lib; /bin/rm -f *.a *$(.mod) *$(.fh))
veryclean: cleanlib
	cd base && $(MAKE) veryclean
	cd prec && $(MAKE) veryclean 
	cd krylov && $(MAKE) veryclean
	cd util && $(MAKE) veryclean
	cd test/fileread && $(MAKE) clean
	cd test/pargen && $(MAKE) clean
	cd test/util && $(MAKE) clean

