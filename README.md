# About

A core for the [wp-prod](https://github.com/vladlu/wp-prod/) system. 

# Rules

### Formatting

- The very first line of the rules file should be either "plugin" or "theme";
- At least one tab between arguments of the rules. You can add additional tabs and spaces to give them beautiful formatting;
- You can use comments in any desired format — only the lines that contain one of the rules in the first argument will be interpreted.

### The list of available rules
```
copy
    from  to

uglifyjs
    from  [to]

webpack
    from  [to]

install
    npm_module_name
```
You can see a sample of rules in [rules.sample](https://github.com/vladlu/wp-prod-core/blob/master/rules.sample) file.

### What does the `webpack` rule do?
```
JS:  babel (with minification)
CSS: postcss-preset-env -> autoprefixer -> cssnano

____________________________

browserslist: cover 95%
```
### Expansions

* `[m]` – dev/wp-prod/wp-prod-core/webpack/node_modules

### Notes

  - For `uglifyjs` and `webpack` rules:   

    When a single `from` is used: it generates a file 
    with the same name but with `.min` before its extension,
    so `file.css` will generate a `file.min.css` file.
    
  - It uses browserslist with a `cover 95%` query. As for now, it can't
    be changed in a convenient way.

#

Version: 1.14.6

License: [MIT](https://github.com/vladlu/wp-prod-core/blob/master/LICENSE)
