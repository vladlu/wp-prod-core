# About

[under construction]

# How to use

[under construction]  
*((write something about stages also))*  
*((add examples somewhere below (but try to avoid their downloading)))* 

# Rules
  
### Formatting
 
At least one tab between items. You can add additional tabs and spaces to give it beautiful formatting.
You can use comments in any format you like — only lines that contain one of the rules will be interpreted.
 
### List of available rules
 
    substitute
        dev_mode_text  prod_mode_text  file
 
    copy
        from  to
 
    uglifyjs
        from  to  [common_directory]
 
    webpack
        from  to  [common_directory]
 
### What does `webpack` rule do?
 
    
    JS:  babel (with minification)
    CSS: autoprefixer -> cssnano
 
### Additional notes
 
  - Rules are updated only on the prod stage (`to_prod.sh`), so `to_dev.sh` always works with old (previous) rules generated by `to_prod.sh`.

  - for `uglifyjs` and `webpack` rules:   
  
    `from` files are created automatically on the prod stage, by renaming the `to` option files if none of them has `dev/` in the beginning.   
  
    A bit difficult to understand, sorry for that. And sorry for hardcoded `dev/` — I just don't like when the files in `node_modules` can be renamed.  
    *((maybe implement not the hardcoded path? maybe use THIS directory? it depends on the future architecture))*.  

#

Version: 1.3.3

License: [MIT](https://github.com/vladlu/wp-prod/blob/master/LICENSE)