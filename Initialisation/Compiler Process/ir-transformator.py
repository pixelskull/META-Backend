#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import os
import argparse
import time


####
# Preparation code
####

# prints basic usage for program
def print_usage():
    print("usage: ir-transformator.py <FILENAME.ll>")

# checks if the file on given path exists
def check_file_exists(path):
    exists = os.path.isfile(path)
    if exists == False:
        file_name = os.path.basename(os.path.normpath(path))
        print("sorry, could not find any IR-File that is called: " + file_name)
        print_usage()

    return exists

# reads contents of file and returns as string
def read_file(path):
    file_object = open(path, 'r')
    file_content = file_object.read()
    file_object.close()

    return file_content

# TODO implement method for creating new file
def write_to_file(file_content):
    output_path = os.path.join(os.getcwd(), "output.ll")
    file_object = open(output_path, 'w+')
    file_object.write(file_content)
    file_object.close()

    return check_file_exists(output_path)

# takes file and generates an array containing the lines
def parse_to_lines(file_content):
    lines = file_content.split('\n')
    return lines

# takes an list and joins the entrys using '\n'
def join_to_string(lines):
    new_file_content = '\n'.join(lines)
    return new_file_content


####
# Transformation code
####

# searches for target datalayout entry and replaces this one
def replace_datalayout_entry(entry):
    if "target datalayout =" in entry:
        print("   > target datalayout found and replaced.")
        return 'target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"'
    else:
        return entry


# searches for target triple entry and replaces this one
def replace_triple_entry(entry):
    if "target triple =" in entry:
        print("   > target triple found and replaced.")
        return 'target triple = "x86_64-apple-macosx10.9"'
    else:
        return entry


# searches for atributes #0 entry and replaces this one
def replace_attribute0_entry(entry):
    if "attributes #0 =" in entry:
        print("   > attributes #0 found and replaced.")
        return 'attributes #0 = { "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "target-cpu"="core2" "target-features"="+ssse3,+cx16,+fxsr,+mmx,+sse,+sse2,+sse3" }'
    else:
        return entry


# searches for atributes #2 entry and replaces this one
def replace_attribute2_entry(entry):
    if "attributes #2 =" in entry:
        print("   > attributes #2 found and replaced.")
        return 'attributes #2 = { noinline "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "target-cpu"="core2" "target-features"="+ssse3,+cx16,+fxsr,+mmx,+sse,+sse2,+sse3" }'
    else:
        return entry

# searches for atributes #3 entry and replaces this one
def replace_attribute3_entry(entry):
    if "attributes #3 =" in entry:
        print("   > attributes #3 found and replaced.")
        return 'attributes #3 = { nounwind readnone "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "target-cpu"="core2" "target-features"="+ssse3,+cx16,+fxsr,+mmx,+sse,+sse2,+sse3" }'
    else:
        return entry

# searches for atributes #6 entry and replaces this one
def replace_attribute6_entry(entry):
    if "attributes #6 =" in entry:
        print("   > attributes #6 found and replaced.")
        return 'attributes #6 = { readonly "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "target-cpu"="core2" "target-features"="+ssse3,+cx16,+fxsr,+mmx,+sse,+sse2,+sse3" }'
    else:
        return entry

####
# Main Method
####
def main(argv):
    # checking arguments otherwise print help message
    if len(argv) == 0:
        print("please give me the name of the file to convert...")
        print_usage()
        print("IR-Transformation aborted...")
        return

    print("### Entering IR-Transformation")
    start_time = time.time()
    # get the given path
    path = os.path.join(os.getcwd(), argv[1])

    # checking if target is file else exit
    if check_file_exists(path) == False:
        return

    # preparing file content
    file_content = read_file(path)
    lines = parse_to_lines(file_content)

    # define transformations to IR
    transformations = [replace_datalayout_entry, replace_triple_entry,
                       replace_attribute0_entry, replace_attribute2_entry,
                       replace_attribute3_entry, replace_attribute6_entry]

    # apply transformations to IR
    tmp_lines = lines
    for transformation in transformations:
        tmp_lines = list( map(transformation, tmp_lines) )


    # joining List to new file content
    new_content = join_to_string(tmp_lines)

    if write_to_file(new_content) == True:
        print("-> safed modified file to disk (lookout for 'output.ll')")
    else:
        print("-> the file was not written to disk, pile of crap...")

    print("-> finished IR-transformation in: %s seconds" % (time.time() - start_time) )
    print("### Leaving IR-transformation")



# starting main method
if __name__ == '__main__':
    main(sys.argv)
