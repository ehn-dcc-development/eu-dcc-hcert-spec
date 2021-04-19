GENERATED=	hcert_spec.html \
		hcert_spec.docx


all: $(GENERATED)

hcert_spec.html: hcert_spec.md
	grip --export $<

hcert_spec.docx: hcert_spec.md
	pandoc -o $@ $<

clean:
	rm -f $(GENERATED)
