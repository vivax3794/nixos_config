/**
 * @file Paradox localisation grammar for tree-sitter
 * @license MIT
 */

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

module.exports = grammar({
	name: "paradox_loc",

	// The game reads localisation line by line, so a value always ends with the
	// line it started on. Comments are deliberately not extras: `#` is ordinary
	// text inside a value and must not start a comment there.
	extras: _ => [/[\s﻿]/],

	rules: {
		source_file: $ => repeat(choice($.language, $.entry, $.comment)),

		language: $ => seq($.language_name, ":"),

		// Outranks `key` so a language header is never read as an entry.
		language_name: _ => token(prec(1, /l_[a-z_]+/)),

		entry: $ => seq(
			field("key", $.key),
			":",
			optional(field("version", $.version)),
			field("value", $.string),
		),

		key: _ => /[A-Za-z0-9_][A-Za-z0-9_.\-]*/,
		version: _ => /\d+/,

		string: $ => seq(
			'"',
			repeat(choice(
				$.variable,
				$.icon,
				$.colour,
				$.command,
				$.escape,
				$.text,
			)),
			'"',
		),

		// `$VALUE|*1$` — a nested key or scope value, with an optional format spec.
		variable: _ => token(seq("$", /[^$\n]*/, "$")),
		// `£energy£`, `£leader_skill|3£` — an icon, with an optional frame.
		icon: _ => token(seq("£", /[^£\n]*/, "£")),
		// `§Y` opens a colour, `§!` closes it.
		colour: _ => token(seq("§", /[^\n]/)),
		// `[Root.GetName]` — a scope command resolved at runtime.
		command: _ => token(seq("[", /[^\]\n]*/, "]")),
		escape: _ => token(seq("\\", /[^\n]/)),
		text: _ => token(/[^"$£§\[\\\n]+/),

		comment: _ => token(seq("#", /[^\n]*/)),
	},
});
