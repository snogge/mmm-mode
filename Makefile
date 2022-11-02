# Using srcdir, builddir, and VPATH enables separate build dir with
# $ make -f $srcdir
srcdir := $(dir $(MAKEFILE_LIST))
VPATH = $(srcdir)
builddir = .

EMACS ?= emacs
MAKEINFO = makeinfo
MAKEINFOFLAGS =
INSTALL ?= install

ELFILES = mmm-auto.el mmm-class.el mmm-cmds.el mmm-compat.el mmm-cweb.el \
          mmm-defaults.el mmm-erb.el mmm-mason.el mmm-mode.el mmm-myghty.el \
          mmm-noweb.el mmm-region.el mmm-rpm.el mmm-sample.el mmm-univ.el \
          mmm-utils.el mmm-vars.el
ELCFILES = $(ELFILES:.el=.elc)
TESTS = highlighting.el html-erb.el variables.el

all: mmm.info $(ELCFILES)

mmm.info: mmm.texi
	$(MAKEINFO) $(MAKEINFOFLAGS) -o $@ $^

mmm.html: mmm.texi
	$(MAKEINFO) --html $(MAKEINFOFLAGS) -o $@ $^

docs: html info
html: mmm.html
info: mmm.info

%.elc: %.el
	$(EMACS) --batch -Q -L $(builddir) -L $(srcdir) \
	  --eval '(setq byte-compile-dest-file-function (lambda (_) "$@"))' \
	  -f batch-byte-compile '$<'

check: all
	$(EMACS) --batch -Q -L $(builddir) -L $(srcdir) -L $(srcdir)/tests \
	  $(addprefix -l ,$(TESTS)) -f ert-run-tests-batch-and-exit

clean-lisp:
	$(RM) -f $(ELCFILES)

clean-info:
	$(RM) -f mmm.info

clean-html:
	$(RM) -rf mmm.html

clean: clean-lisp clean-info clean-html

.PHONY: check clean clean-html clean-info clean-lisp docs html info
.PHONY: install uninstall

# Installation and uninstallation targets for completeness

prefix = /usr/local
datarootdir = ${prefix}/share
datadir = ${datarootdir}
infodir = ${datarootdir}/info
lispdir = ${datadir}/emacs/site-lisp

install: install-info install-elc install-el

install-elc: $(ELCFILES)
	$(INSTALL) -d $(DESTDIR)$(lispdir)
	$(INSTALL) -m 0644 $(ELCFILES) $(DESTDIR)$(lispdir)

install-el:
	$(INSTALL) -d $(DESTDIR)$(lispdir)
	$(INSTALL) -m 0644 $(ELFILES) $(DESTDIR)$(lispdir)

uninstall: uninstall-info uninstall-elc uninstall-el

uninstall-elc:
	$(RM) -f $(addprefix $(DESTDIR)$(lispdir)/,$(ELCFILES))

uninstall-el:
	$(RM) -f $(addprefix $(DESTDIR)$(lispdir)/,$(ELFILES))

install-info: mmm.info
	$(INSTALL) -d $(DESTDIR)$(infodir)
	$(INSTALL) -m 0644 $^ $(DESTDIR)$(infodir)
	for ifile in $^; do \
		install-info --info-dir=$(DESTDIR)$(infodir) $(DESTDIR)$(infodir)/$$ifile ;\
	done

uninstall-info:
	for ifile in $^; do \
		install-info --info-dir=$(DESTDIR)$(infodir) --remove $(DESTDIR)$(infodir)/$$ifile ;\
		$(RM) $(DESTDIR)$(infodir)/$$ifile ;\
	done
