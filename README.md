# Neovim Configuration

This Neovim configuration requires the following external tools for the corresponding extensions
to run correctly (use ':checkhealth' to see state of providers/extensions):

- Telescope

  - [ripgrep](https://github.com/BurntSushi/ripgrep) (alias `rg`)

    - Required for `live_grep` and `grep_string` and is the first priority for `find_files`.

  - [fd](https://github.com/sharkdp/fd) [Optional]

    - Used for file finding.

- Treesitter

  - Any compatible C/C++ compiler (including GCC, Clang, MSVC, etc.)

    - Needed specifically to be able to successfully compile the parser for certain languages.
      In this case, the `yaml` parser does not work without setting one of these compilers for
      Treesitter parser compilation.

      For Windows, quickest install of a known compatible compiler is through [MSYS2](https://www.msys2.org/),
      which will install GCC and other build tooling that is not necessarily needed here. The [Zig](https://ziglang.org/)
      programming language compiler also seems to be compatible, but takes a while to install (at least through its Winget
      package installation on Windows).

- LSP Zero

  - Mason

    Manages a variety of linters, formatters, language servers, and more. Individual servers
    installed through Mason may have additional external tools needed to run properly. The
    following servers in the table are known to require these corresponding tools:
    | Server | Type | Language | Required External Tools |
    | --------- | ---- | -------- | ---------------------------------------------------------------- |
    | `pyright` | LSP | Python | [Node Package Manager [^1] (NPM)](https://www.npmjs.com) |
    | `clang` | LSP | C/C++ | Any compatible C/C++ compiler (including GCC, Clang, MSVC, etc.) |
    [^1]: Recommend installing [NodeJS](https://nodejs.org/) to install NPM.

    Additional external tools or packages can be used by the EFM language server, which for this
    configuration, is needed for formatting certain languages:
    | Server | Type | Language | Required External Tools |
    | ------ | --------- | -------- | -------------------------------------------------------------------- |
    | `efm` | Formatter | Python | [Black](https://black.readthedocs.io/en/stable/getting_started.html) |
    | `efm` | Formatter | Markdown | [Prettier](https://prettier.io/) |

