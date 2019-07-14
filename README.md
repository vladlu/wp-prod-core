# About

[under construction]

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
    CSS: autoprefixer -> cssnano

### Expansions

* `[m]` – dev/wp-prod/wp-prod/webpack/node_modules

### Notes

  - For `uglifyjs` and `webpack` rules:   

    When a single `from` is used: it generates a file 
    with the same name but with `.min` before the extension,
    so `file.css` generates `file.min.css`.

#

Version: 1.11.8

License: [MIT](https://github.com/vladlu/wp-prod/blob/master/LICENSE)
