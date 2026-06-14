module Main

import AST;
import Generate;
import Parser;
import ParseTree;

AST::Prompt load(loc l) = implode(#AST::Prompt, parsePrompt(l).top);

str compileFile(loc l) = generate(load(l));
