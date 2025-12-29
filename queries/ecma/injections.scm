(object
  (pair
	key: (property_identifier) @key (#eq? @key "template")
	value: (template_string
			 (string_fragment) @injection.content)
	(#set! injection.language "vue")
	(#set! injection.combined)
	)
  )

(variable_declarator
  name: (identifier) @name (#eq? @name "CSS_STYLE")
  value: (template_string
		   (string_fragment) @injection.content)
  (#set! injection.language "css")
  (#set! injection.combined)
  )

(variable_declarator
  name: (identifier) @name (#eq? @name "HTML_TEMPLATE")
  value: (template_string
		   (string_fragment) @injection.content)
  (#set! injection.language "html")
  (#set! injection.combined)
  )
