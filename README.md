# PromptDSL — A Domain-Specific Language for Prompt Engineering (in Rascal)

An experiment in **metaprogramming** and **DSL implementation**, built with
[Rascal MPL](https://www.rascal-mpl.org/). PromptDSL lets you write a structured,
reusable prompt definition in a `.prompt` file and **generates a ready-to-paste LLM
prompt string** from it.

> Course assignment — *Metaprogramming & DSL Implementation*
> Domain: **Prompt Engineering** · Approach: **Rascal**
> Author: **Muhammad Noor Sheikh** · University of Koblenz

---

## Why a DSL for prompts?

Prompts written as free text are inconsistent, copy-pasted and re-edited every time, and
impossible to validate. The idea — following the *model-driven prompt engineering* line of
work (see [References](#references)) — is to treat prompts as **software artifacts**:
give them a grammar, an abstract syntax, and a generation pipeline so they become
structured, reusable and checkable.

**You write this:**

```
prompt SummarizeEmail {
  role: "You are a professional executive assistant."
  context: "The user receives long business emails in German."
  task: "Summarize the email in 3 bullet points."
  constraint: "Do not exceed 50 words."
  constraint: "Keep the original language."
  format: markdown
}
```

**PromptDSL generates this:**

```
ROLE: You are a professional executive assistant.
CONTEXT: The user receives long business emails in German.
TASK: Summarize the email in 3 bullet points.
CONSTRAINT: Do not exceed 50 words.
CONSTRAINT: Keep the original language.
RESPOND IN: Markdown
```

The prompt-engineering method being formalised is **structured (template-based) prompting
with role assignment** — the Role · Task · Format (RTF) / CO-STAR template family. It is
*not* a reasoning technique such as few-shot or chain-of-thought; the contribution is
making an existing, recognised prompt structure **formal, reusable and checkable**.

---

## The pipeline

Every language implementation is the same assembly line. Each stage maps to one module:

```
.prompt file  →  parse()  →  Parse Tree  →  implode()  →  AST  →  generate()  →  prompt string
   (text)       Parser.rsc                  Main.rsc            Generate.rsc       (text)
                 Syntax.rsc                  AST.rsc
```

- **Concrete syntax** — the text with all its punctuation (`Syntax.rsc`).
- **Abstract syntax (AST)** — the clean data we actually compute with (`AST.rsc`).
- **Semantics** — walking the AST to produce output (`Generate.rsc`).

---

## Project structure

```
rascalexperiment/
├── META-INF/
│   └── RASCAL.MF              # project manifest (Project-Name must match folder)
├── pom.xml                    # Maven dependencies (Rascal runtime)
├── src/
│   └── main/
│       └── rascal/
│           ├── Syntax.rsc     # the grammar (concrete syntax)
│           ├── AST.rsc        # the data types (abstract syntax / metamodel)
│           ├── Parser.rsc     # parses text → parse tree
│           ├── Generate.rsc   # walks the AST → prompt string (semantics)
│           └── Main.rsc       # glues the pipeline together
├── examples/
│   └── summarize.prompt       # an example program written in PromptDSL
└── README.md
```

---

## The metamodel

The abstract syntax (`AST.rsc`) **is** the metamodel — it defines every legal shape a
prompt can take:

```
Prompt ──contains──> Section*           (a prompt has a name and many sections)

Section = role(str)                     (a section is one of five kinds)
        | context(str)
        | task(str)
        | constraint(str)
        | format(OutputFormat)

OutputFormat = json | markdown | text   (an enumeration)
```

---

## Requirements

- **Java JDK 11 or 17** (Rascal runs on the JVM)
- **Visual Studio Code**
- The **Rascal Metaprogramming Language** extension (publisher: *usethesource*)

> Eclipse support for Rascal is archived; this project targets the VS Code extension.

---

## Setup & running (Windows)

1. **Install Java 17**
   ```powershell
   winget install EclipseAdoptium.Temurin.17.JDK
   ```
   Verify in a fresh terminal: `java -version`

2. **Install the Rascal extension** in VS Code (Extensions panel → search "Rascal").

3. **Open the project folder** in VS Code (`File → Open Folder` → `rascalexperiment`).
   The folder name must match `Project-Name` in `META-INF/RASCAL.MF`.

4. **Reload the window** once (`Ctrl+Shift+P → Developer: Reload Window`) so the
   extension reads the manifest and `pom.xml`. The first load downloads the Rascal runtime.

5. **Open `Main.rsc`** and click **"Import in new Rascal terminal"** above the module line.
   Wait for the `rascal>` prompt.

6. **Run it** (note the semicolon):
   ```
   compileFile(|project://rascalexperiment/examples/summarize.prompt|);
   ```

You should see the generated prompt string printed in the terminal.

> **Tip:** after editing a `.rsc` file, type `:reload` in the terminal to pick up changes.
> A Rascal terminal does **not** survive a window reload — always start a fresh one after reloading.

---

## How it works (in brief)

**`Syntax.rsc` — the grammar.** Defines what a valid `.prompt` file looks like. Each
alternative carries a label (`role:`, `task:`, `format:` …) that matches an AST constructor.

```rascal
start syntax Prompt
  = prompt: "prompt" Id name "{" Section* sections "}";

syntax Section
  = role:       "role" ":" String text
  | task:       "task" ":" String text
  | constraint: "constraint" ":" String text
  | format:     "format" ":" OutputFormat fmt
  ;
```

**`AST.rsc` — the clean data shape.** The constructor names match the grammar labels,
which is what makes `implode` work automatically.

```rascal
data Prompt  = prompt(str name, list[Section] sections);
data Section = role(str text) | context(str text) | task(str text)
             | constraint(str text) | format(OutputFormat fmt);
```

**`Generate.rsc` — the semantics.** Pattern matching walks the AST and builds the output.

```rascal
switch (s) {
  case role(str t): out += "ROLE: <unquote(t)>\n";
  case task(str t): out += "TASK: <unquote(t)>\n";
  // ...
}
```

**`Main.rsc` — the glue.** `parse` → `implode` → `generate`.

```rascal
AST::Prompt load(loc l) = implode(#AST::Prompt, parsePrompt(l).top);
str compileFile(loc l)  = generate(load(l));
```

---

## Limitations & future work

This is intentionally a *very* small experiment. Natural next steps:

- **`{placeholder}` variables** with a static check for undeclared names.
- **Validation rules** — e.g. every prompt must have exactly one `task`.
- **Multiple generation targets** — JSON, an OpenAI message array, a plain system prompt.
- **IDE registration** — syntax highlighting + error markers for `.prompt` files via Rascal's LSP support.

---

## References

- Model-Driven Prompt Engineering — https://modeling-languages.com/model-driven-prompt-engineering/
- *Impromptu* (DSL for prompt engineering) — https://github.com/som-Research/impromptu
- DSLs & Prompt Engineering — https://medium.com/@jallenswrx2016/dsl-prompt-engineering-f6edc89f4729
- Rascal Metaprogramming Language — https://www.rascal-mpl.org/

---

## License

Released for educational purposes as part of a university assignment.
