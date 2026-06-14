module Syntax

extend lang::std::Layout;   // whitespace + comments for free
extend lang::std::Id;       // standard identifiers

start syntax Prompt
  = prompt: "prompt" Id name "{" Section* sections "}";

syntax Section
  = role:       "role" ":" String text
  | context:    "context" ":" String text
  | task:       "task" ":" String text
  | constraint: "constraint" ":" String text
  | format:     "format" ":" OutputFormat fmt
  ;

syntax OutputFormat
  = jsonFmt: "json"
  | mdFmt: "markdown"
  | textFmt: "text"
  ;

lexical String = "\"" ![\"]* "\"";

