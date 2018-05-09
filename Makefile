TEX=pdflatex -halt-on-error
BIB=bibtex
GIT_STATUS=git_information.tex

MASTER=master
DRAFT=draft
SECTIONS = $(shell ls -1 section/ | sed -e 's/^/section\//g')

ifndef VERBOSE
	REDIRECT=1>/dev/null 2>/dev/null
endif

$(DRAFT).pdf: $(SECTIONS) master.tex
	@echo $@
	make $(GIT_STATUS)
	$(TEX) -jobname=$(DRAFT) master.tex $(REDIRECT)
	$(BIB) $(DRAFT) $(REDIRECT)
	$(TEX) -jobname=$(DRAFT) master.tex $(REDIRECT)
	$(TEX) -jobname=$(DRAFT) master.tex $(REDIRECT)
	make clean_temporary_files

master.pdf: $(SECTIONS) master.tex
	@echo $@
	echo "" > $(GIT_STATUS) $(REDIRECT)
	$(TEX) master.tex $(REDIRECT)
	$(BIB) master $(REDIRECT)
	$(TEX) master.tex $(REDIRECT)
	$(TEX) master.tex $(REDIRECT)
	make clean_temporary_files

.PHONY: $(GIT_STATUS)

$(GIT_STATUS):
	./git_information.sh | tee $(GIT_STATUS)

.PHONY: git-hooks
git-hooks:
	rsync -auv hooks/ .git/hooks/

.PHONY: clean_temporary_files
clean_temporary_files:
	$(RM) git_information.aux section/*.aux
	$(RM) {$(DRAFT),$(MASTER)}.{out,log,aux,synctex.gz,bbl,blg,toc,fls,fdb_latexmk}

.PHONY: clean
clean: clean_temporary_files
	$(RM) $(GIT_STATUS)
	$(RM) {$(DRAFT),$(MASTER)}.pdf

.PHONY: watch
watch:
	watchman-make -p '**/*.tex' '*/*.tex' '*.tex' '*.bib' -t draft.pdf