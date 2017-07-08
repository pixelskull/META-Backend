#!/usr/bin/python
# -*- coding: utf-8 -*-
import os
import sys
import time
import logging
import argparse

####
# Preparation code
####

def prepareParser():
    parser = argparse.ArgumentParser(description="""compilation.py takes an LLVM-IR file and compiles
                                                     this one to executable code""")

    parser.add_argument("IR_File",
                        type=str,
                        help="ir file to compile with compilation.py")
    parser.add_argument("-o", "--output",
                        help="define the output name used for storing file to disc",
                        action="store",
                        default="output.ll",
                        dest="output_name")

    return parser


# prints basic usage for program
def print_usage():
    print("usage: ir-transformator.py <FILENAME.ll>")

# checks if the file on given path exists
def check_file_exists(path):
    exists = os.path.isfile(path)
    if exists == False:
        file_name = os.path.basename(os.path.normpath(path))
        logging.error("sorry, could not find any IR-File that is called: " + file_name)
        print_usage()

    return exists

# reads contents of file and returns as string
def read_file(path):
    file_object = open(path, 'r')
    file_content = file_object.read()
    file_object.close()

    return file_content

# TODO implement method for creating new file
def write_to_file(file_content, filename="output.ll"):
    output_path = os.path.join(os.getcwd(), filename)
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
        logging.info("   > target datalayout found and replaced.")
        return 'target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"'
    else:
        return entry


# searches for target triple entry and replaces this one
def replace_triple_entry(entry):
    if "target triple =" in entry:
        logging.info("   > target triple found and replaced.")
        return 'target triple = "x86_64-apple-macosx10.9"'
    else:
        return entry


# searches for atributes #0 entry and replaces this one
def replace_attribute0_entry(entry):
    if "attributes #0 =" in entry:
        logging.info("   > attributes #0 found and replaced.")
        return 'attributes #0 = { "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "target-cpu"="core2" "target-features"="+ssse3,+cx16,+fxsr,+mmx,+sse,+sse2,+sse3" }'
    else:
        return entry


# searches for atributes #2 entry and replaces this one
def replace_attribute2_entry(entry):
    if "attributes #2 =" in entry:
        logging.info("   > attributes #2 found and replaced.")
        return 'attributes #2 = { noinline "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "target-cpu"="core2" "target-features"="+ssse3,+cx16,+fxsr,+mmx,+sse,+sse2,+sse3" }'
    else:
        return entry

# searches for atributes #3 entry and replaces this one
def replace_attribute3_entry(entry):
    if "attributes #3 =" in entry:
        logging.info("   > attributes #3 found and replaced.")
        return 'attributes #3 = { nounwind readnone "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "target-cpu"="core2" "target-features"="+ssse3,+cx16,+fxsr,+mmx,+sse,+sse2,+sse3" }'
    else:
        return entry

# searches for atributes #6 entry and replaces this one
def replace_attribute6_entry(entry):
    if "attributes #6 =" in entry:
        logging.info("   > attributes #6 found and replaced.")
        return 'attributes #6 = { readonly "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "target-cpu"="core2" "target-features"="+ssse3,+cx16,+fxsr,+mmx,+sse,+sse2,+sse3" }'
    else:
        return entry

####
# Main Method
####
def main(argv):
    logging.basicConfig(filename='ir-transformator.log', level=logging.DEBUG)

    parser = prepareParser()
    args = parser.parse_args()

    # checking arguments otherwise print help message
    if len(argv) == 0:
        logging.warning("please give me the name of the file to convert...")
        print_usage()
        logging.error("IR-Transformation aborted...")
        return

    logging.debug("### Entering IR-Transformation")
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
        tmp_lines = list( map(lambda x: transformation(x), tmp_lines) )


    # joining List to new file content
    new_content = join_to_string(tmp_lines)

    if write_to_file(new_content, args.output_name) == True:
        logging.info("-> safed modified file to disk (lookout for '" + args.output_name + "')")

    logging.info("-> the file was not written to disk, pile of crap...")

    logging.info("-> finished IR-transformation in: %s seconds" % (time.time() - start_time) )
    logging.info("### Leaving IR-transformation")



# starting main method
if __name__ == '__main__':
    main(sys.argv)
