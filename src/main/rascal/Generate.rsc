module Generate

import AST;

str unquote(str s) = s[1..-1];  // strip surrounding quotes

str generate(AST::Prompt p) {
  str out = "";
  for (AST::Section s <- p.sections) {
    switch (s) {
      case role(str t):       out += "ROLE: <unquote(t)>\n";
      case context(str t):    out += "CONTEXT: <unquote(t)>\n";
      case task(str t):       out += "TASK: <unquote(t)>\n";
      case constraint(str t): out += "CONSTRAINT: <unquote(t)>\n";
      case format(AST::OutputFormat f): out += "RESPOND IN: <fmtName(f)>\n";
    }
  }
  return out;
}

str fmtName(jsonFmt())  = "JSON";
str fmtName(mdFmt())    = "Markdown";
str fmtName(textFmt())  = "plain text";