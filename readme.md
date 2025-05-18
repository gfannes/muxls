&!:muxls

# Multiplexing Language Server

_One language server to control them all_

The [Helix editor](https://helix-editor.com) supports multiple [language servers](https://microsoft.github.io/language-server-protocol/), but some requests are only relayed to the first configured language server for that language, most notably `textDocument/references` and `textDocument/definition`. Since the advent of [champ](https://github.com/gfannes/champ), it is essential to have a language server handling some program language, and another to handle _annotations_.

- [x] Add `rakefile.rb` to handle testing and installation
- [x] Add dependency on [rubr](https://github.com/gfannes/rubr)
- [ ] Support configuration based on [zon](https://ziglang.org/documentation/master/std/#std.zon)
	- Support different languages, each supporting different file extensions and language servers
	- Separate configuration for each language server
		- As such, we can just instantiate and reuse at this level
	- Configure log file
- [ ] Implement request-response loop
- [ ] Instantiate the different language servers
	- Use `std.process.Child.spawn()` to get access to stdio/stdout
