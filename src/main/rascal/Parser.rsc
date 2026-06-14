module Parser

import Syntax;
import ParseTree;

start[Prompt] parsePrompt(loc l) = parse(#start[Prompt], l);
