# Autoloader.sh
Keep your bashrc clean and simple by splitting it up.
This project is still unde devlopment and some parts will probably be changed in the future.

The directory structure need for this is having:
```.
├── alias       <- Directory
├── functions   <- Directory
├── load.sh     <- Autoloader File
├── post        <- Post script file
├── pre         <- Pre script file
├── prompt      <- Directory
└── vars        <- Directory```

Under alias and vars you need to create files like this:
Filename == Alias/Variable Name
Content  == Alias/Variable Content

Functions will contain also some the some structure, the function name should be the same as the file name
