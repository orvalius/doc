DCBOOK_FILES	=	book.xml										\
						$(wildcard chapters/intro/*xml)		\
						$(wildcard chapters/hisio/*xml)

UML_FILES		= $(wildcard chapters/hisio/uml/*.uml)

PNG_FILES += $(notdir $(patsubst %.uml,%.png,$(UML_FILES)))

PNG_OUT	=	out/png

vpath %.png $(PNG_OUT)
vpath %.uml chapters/hisio/uml

png: $(PNG_FILES)

clean:
	rm -rf out/html/*
	rm -rf out/pdf/*

out/forvalidation.xml: $(DCBOOK_FILES)
	xmllint --noent book.xml > out/forvalidation.xml

validate: out/forvalidation.xml
	xmllint --noout --schema schema/docbook.xsd out/forvalidation.xml

doc: out/forvalidation.xml
	xsltproc ./styles/params.xsl book.xml > out/pdf/book.fo
	fop -c fop/fop.xml -fo out/pdf/book.fo -pdf out/pdf/book.pdf
#	xsltproc ./style/docbook-xsl-1.78.1/fo/docbook.xsl book.xml > out/book.fo

html: out/forvalidation.xml out/html/style.css
	xsltproc -o out/html/ styles/params_html.xsl book.xml


out/html/style.css: styles/css/style.css
	cp styles/css/style.css out/html/style.css

epub: out/forvalidation.xml
	xsltproc -o out/epub/book.epub ./styles/params_epub.xsl book.xml

cp:
	cp out/pdf/book.pdf /var/www/soix/download/book_mace.pdf

spell:
	aspell --mode=sgml --lang=es check book.xml
	aspell --mode=sgml --lang=es check chapters/osek.xml


%.png : %.uml
	@echo ""
	@echo ==================================================
	@echo Converting $< to $@
	@echo ""
	java -jar plantuml.jar $< -o ../../$(PNG_OUT)

help:
	@echo validate................: validates the docbook xml agianst the schema
	@echo html....................: generates html output
	@echo doc.....................: generates pdf output
	@echo clean...................: cleans the project
	@echo spell...................: check spelling