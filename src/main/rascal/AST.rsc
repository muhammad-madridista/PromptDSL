module AST

data Prompt = prompt(str name, list[Section] sections);

data Section
  = role(str text)
  | context(str text)
  | task(str text)
  | constraint(str text)
  | format(OutputFormat fmt)
  ;

data OutputFormat = jsonFmt() | mdFmt() | textFmt();


