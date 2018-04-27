TEX=pdflatex -halt-on-error
BIB=bibtex
GIT_STATUS=git_information.tex

MASTER=master
DRAFT=draft
SECTIONS = $(shell ls -1 section/ | sed -e 's/^/section\//g')

$(DRAFT).pdf: $(SECTIONS) master.tex
	make $(GIT_STATUS)
	$(TEX) -jobname=$(DRAFT) master.tex
	$(BIB) $(DRAFT)
	$(TEX) -jobname=$(DRAFT) master.tex
	$(TEX) -jobname=$(DRAFT) master.tex
	make clean_temporary_files

master.pdf: $(SECTIONS) master.tex
	echo "" > $(GIT_STATUS)
	$(TEX) master.tex
	$(BIB) master
	$(TEX) master.tex
	$(TEX) master.tex
	make clean_temporary_files

.PHONY: $(GIT_STATUS)

$(GIT_STATUS): 
	./git_information.sh > $(GIT_STATUS)

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

