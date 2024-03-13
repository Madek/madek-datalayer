# Liquid::Template.error_mode = :strict # Raises a SyntaxError when invalid syntax is used
Liquid::Template.error_mode = :warn # Adds strict errors to template.errors but continues as normal
# Liquid::Template.error_mode = :lax # The default mode, accepts almost anything.
