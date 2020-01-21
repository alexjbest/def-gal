.PHONY:	clean clean-html all check deploy debug

XSLTPROC = xsltproc --timing --stringparam debug.datedfiles no --stringparam html.google-classic UA-48250536-1 # -v

docs:	docs/def-gal.pdf def-gal-pretty.xml def-gal.xsl filter.xsl
	mkdir -p docs
	cd docs/; \
	$(XSLTPROC) ../def-gal.xsl ../def-gal-pretty.xml

def-gal.tex:	def-gal-pretty.xml def-gal-latex.xsl filter.xsl
	$(XSLTPROC) -o def-gal.tex def-gal-latex.xsl def-gal-pretty.xml

docs/def-gal.pdf:	def-gal.tex
	mkdir -p docs
	cd docs && latexmk -pdf -shell-escape -pdflatex="pdflatex -shell-escape -interaction=batchmode"  ../def-gal.tex

docs/images/:	docs def-gal-wrapper.xml
	mkdir -p docs/images
	../mathbook/script/mbx -vv -c latex-image -f svg -d ~/def-gal/docs/images ~/def-gal/def-gal-wrapper.xml

def-gal-wrapper.xml:	*.pug pug-plugin.json
	pug -O pug-plugin.json --extension xml def-gal-wrapper.pug
	sed -i.bak -e 's/proofcase/case/g' def-gal-wrapper.xml # Fix proofcase->case !! UGLY HACK, SAD
	rm def-gal-wrapper.xml.bak

def-gal-pretty.xml: def-gal-wrapper.xml
	xmllint --pretty 2 def-gal-wrapper.xml > def-gal-pretty.xml

all:	docs docs/def-gal.pdf

deploy: clean-html def-gal-wrapper.xml docs
	cp def-gal-wrapper.xml docs/def-gal.xml
	./deploy.sh

debug:	*.pug pug-plugin.json
	pug -O pug-plugin.json --pretty --extension xml def-gal-wrapper.pug

check:	def-gal-pretty.xml
	jing ../mathbook/schema/pretext.rng def-gal-pretty.xml
	#xmllint --xinclude --postvalid --noout --dtdvalid ../mathbook/schema/dtd/mathbook.dtd def-gal-pretty.xml
	$(XSLTPROC) ../mathbook/schema/pretext-schematron.xsl def-gal-pretty.xml

clean-html:
	rm -rf docs

clean:	clean-html
	rm -f def-gal*.tex
	rm -f def-gal*.xml
