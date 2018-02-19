import sys
import fileinput

#
# remove all import statements except "import Foundation"
#
for line in fileinput.input():
    if line.startswith('import'):
        if "import Foundation" in line:
            sys.stdout.write(line)
    else:
        sys.stdout.write(line)
