# About

This is a dev system for WordPress developers which makes life easier. 

Just create rules and run it.

# How to use

[under construction]  
*((say something about style.dev.css with which webpack rule works differently))*  
*((add examples somewhere below (but try to avoid their downloading))* 

# Rules

### Formatting

- The very first line of the rules file should be either "plugin" or "theme";
- At least one tab between arguments of the rules. You can add additional tabs and spaces to give them beautiful formatting;
- You can use comments in any desired format — only the lines that contain one of the rules in the first argument will be interpreted.

### The list of available rules

    copy
        from  to

    uglifyjs
        from  [to]

    webpack
        from  [to]

    install
        npm_module_name

### What does `webpack` rule do?
 
    JS:  babel (with minification)
    CSS: postcss-preset-env -> autoprefixer -> cssnano
    
    ____________________________
    
    browserslist: cover 95%

### Expansions

* `[m]` – dev/wp-prod/wp-prod-core/webpack/node_modules

### Notes

  - For `uglifyjs` and `webpack` rules:   

    When a single `from` is used: it generates a file 
    with the same name but with `.min` before its extension,
    so `file.css` will generate a `file.min.css` file.
    
  - It uses browserslist with `cover 95%` query. As for now, it can't
    be changed in a convenient way.

#

Version: 1.13.0

License: [MIT](https://github.com/vladlu/wp-prod-core/blob/master/LICENSE)
