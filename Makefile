R=R
# -> you can do    R=R-devel  make ....

PACKAGE=tsHydroV2
VERSION=$(shell sed -n '/^Version: /s///p' DESCRIPTION)
TARBALL=${PACKAGE}_${VERSION}.tar.gz
ZIPFILE=${PACKAGE}_${VERSION}.zip

# This Makefile is meant to be run from inside the tsHydroV2/ package
# directory. R CMD build/INSTALL operate on '.' (the package itself),
# and the tarball is produced one level up so the source tree stays clean.

all:
	make doc-update
	make build-package
	make install

doc-update: R/*.R
	echo "library(roxygen2);roxygenize(\".\")" | $(R) --slave
	@touch doc-update

namespace-update :: NAMESPACE
NAMESPACE: R/*.R
	echo "library(roxygen2);roxygenize(\".\")" | $(R) --slave

build-package: ../$(TARBALL)
../$(TARBALL): NAMESPACE DESCRIPTION $(wildcard R/*.R) $(wildcard data/*)
	cd ..; $(R) CMD build --resave-data=no $(PACKAGE)

install: ../$(TARBALL)
	cd ..; $(R) CMD INSTALL --preclean $(TARBALL)
	@touch install

unexport TEXINPUTS
pdf: ../$(PACKAGE).pdf
../$(PACKAGE).pdf: man/*.Rd
	rm -f ../$(PACKAGE).pdf
	cd ..; $(R) CMD Rd2pdf --no-preview $(PACKAGE)

check: ../$(TARBALL)
	cd ..; $(R) CMD check $(TARBALL)

clean:
	\rm -f install doc-update ../$(PACKAGE)_* ../$(PACKAGE).pdf
