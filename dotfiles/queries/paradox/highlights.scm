(comment) @comment @spell

(number) @number
(boolean) @boolean
(string) @string
(template_string) @string.special
(identifier) @variable
(variable) @variable.parameter

(assignment
  key: (identifier) @property)

(condition_keyword) @keyword.conditional
(logical_keyword) @keyword.operator
(scope_keyword) @variable.builtin

"=" @operator

[
  "{"
  "}"
] @punctuation.bracket

[
  "[["
  "]"
] @punctuation.special
