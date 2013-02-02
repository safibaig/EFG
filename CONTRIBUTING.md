# Contributing to EFG

Looking to contribute something to EFG? **Here's how you can help.**


## Reporting issues

We prefer issues that are bug reports or feature requests. Bugs must be isolated and reproducible problems that we can fix within EFG. Please read the following guidelines before opening any issue.

1. **Search for existing issues.** We get a lot of duplicate issues, and you'd help us out a lot by first checking if someone else has reported the same issue. Moreover, the issue may have already been resolved with a fix available.
1. **Create an isolated and reproducible test case.**
1. **Share as much information as possible.** Include operating system and version, browser and version, version of EFG, customized or vanilla build, etc. where appropriate. Also include steps to reproduce the bug.


## Key branches

- `master` is the official work in progress branch for the next release.
- `release` is the latest, deployed version.
- `gh-pages` is the hosted docs (not to be used for pull requests).


## Pull requests

- Try to submit pull requests against the latest `master` branch for easier merging
- Try not to pollute your pull request with unintended changes--keep them simple and small


## Coding standards: HTML

- Two spaces for indentation, never tabs
- Double quotes only, never single quotes
- Always use proper indentation
- Use tags and elements appropriate for an HTML5 doctype (e.g., self-closing tags)


## Coding standards: CSS

- Adhere to the [Recess CSS property order](http://markdotto.com/2011/11/29/css-property-order/)
- Multiple-line approach (one property and value per line)
- Always a space after a property's colon (.e.g, `display: block;` and not `display:block;`)
- End all lines with a semi-colon
- For multiple, comma-separated selectors, place each selector on it's own line
- Attribute selectors, like `input[type="text"]` should always wrap the attribute's value in double quotes, for consistency and safety (see this [blog post on unquoted attribute values](http://mathiasbynens.be/notes/unquoted-attribute-values) that can lead to XSS attacks).



## Coding standards: JS

- No semicolons
- Comma first
- 2 spaces (no tabs)
- strict mode
- "Attractive"



## License

By contributing your code, you agree to license your contribution under the terms of the MIT: https://github.com/alphagov/EFG/blob/master/LICENSE.txt
