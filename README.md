```
Usage:

    $ .build/debug/jsonutil

Commands:

    + remove -
    + pretty - Reads a Json file, prettyfies it and prints it to the console output.
    + replace - Reads a Json file, and replaces all occurences of specified terms in the values of the file and prints it to the console output.
    + filter -


Usage:

    $ .build/debug/jsonutil remove <removefile> <input>

Arguments:

    removefile - remove map file name. '[remove path]', line separated
    input - Json file input path

Options:
    --prettyPrinted [default: false] - pretty printed output
    
    
Usage:

    $ .build/debug/jsonutil pretty <input>

Arguments:

    input - Json file input path


Usage:

    $ .build/debug/jsonutil replace <replacefile> <input>

Arguments:

    replacefile - replace map file name. '[search term]=[replace term]', line separated
    input - Json file input path

Options:
    --prettyPrinted [default: false] - pretty printed output
    
 
Usage:

    $ .build/debug/jsonutil remove <removefile> <input>

Arguments:

    removefile - remove map file name. '[remove path]', line separated
    input - Json file input path

Options:
    --prettyPrinted [default: false] - pretty printed output
```
