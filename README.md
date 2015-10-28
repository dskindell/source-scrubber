# source-scrubber

Build:
$ rake build

Install:
$ rake install

Help:
source-scrubber --help
Usage: source-scrubber.rb [OPTIONS]
    -f, --file [FILE]                Scrub ONLY the given file.
                                      Can be repeated for multiple files
                                      (overrides -e & -d)
    -e, --extension [EXT]            Only report files with extension EXT (i.e. cpp).
                                     Can provide multiple times
    -x, --exclude [EXT]              Exclude files with given extension EXT.
                                       Can provide multiple times.
                                       By default the following extensions are ignored:
                                       .o .obj .bin .exe .a .lib .png .jpg .gif .jif .mpeg .docx .json <no extension>
    -d, --directory [PATH]           Search recursively from directory PATH.
                                       (searchs from current directory otherwise)
        --replace [STRING]           DANGEROUS! After reporting invalid characers
                                       replace them in the file with STRING
        --[no-]clean-whitespaces     If enabled: removes trailing whitespaces, 
                                       if disabled: suppresses reporting trailing whitespaces
        --[no-]add-missing-newline   If enabled: adds missing newline to EOF, 
                                       if disabled: suppresses reporting missing EOF newlines
    -h, --help                       Print this dialog
    -v, --version                    Show version

If --[no-]clean-whitespaces is not given, trailing whitespaces will be reported but files will not be changed.
If --[no-]add-missing-newline is not given, missing EOF newlines will be reported but files will not be changed.

Example:
# Remove trailing newlines and add missing EOF newlines in all .cpp and .h files under directory projects/
$ source-scrubber -d projects -e .cpp -e .h --clean-whitespaces --add-missing-newline
