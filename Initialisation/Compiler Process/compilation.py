#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import os

import argparse

def prepareParser():
    parser = argparse.ArgumentParser(description="""compilation.py takes an LLVM-IR file and compiles
                                                     this one to executable code""")

    parser.add_argument("IR_File",
                        type=str,
                        help="ir file to compile with compilation.py")

    parser.add_argument("-v", "--verbose",
                        help="increase output verbosity",
                        action="store_true")
    parser.add_argument("-c", "--clean",
                        help="removes all temporary files after build is finished",
                        default=True,
                        action="store_true")
    parser.add_argument("-t", "--target",
                        help="define triple target for llvm compiler",
                        action="store",
                        default="arm64-apple-ios10.0",
                        dest="target_value")
    parser.add_argument("-s", "--sdk",
                        help="define sdk to use with xcrun",
                        action="store",
                        default="iphoneos",
                        dest="sdk_value")
    parser.add_argument("-o", "--output",
                        help="define the output name used for storing file to disc",
                        action="store",
                        default="a.out",
                        dest="output_name")

    return parser


def main(argv):
    # prepare argument parser and parse the argv
    parser = prepareParser()
    args = parser.parse_args()

    print(args.IR_File)

    # sdk = "xcrun -sdk " + args.sdk_value

    # input_file = "hello.swift"
    # output_file = "hello_py.ll"
    # print("-> compiling file for iOS...")
    # os.system(sdk + ' swiftc -emit-ir -target arm64-apple-ios10.0 ' + input_file + ' -o ' + output_file)

    # transformation from iOS based IR to macOS based IR
    ir_file = args.IR_File.replace(' ', '\ ')
    if args.verbose:
        print("-> transforming IR Code for macOS...")
    os.system('./ir-transformator.py ' + ir_file) # TODO: change output path here to custom path or tempDir

    # assambling IR code to bitcode
    transformed_ir_file = "output.bc"
    if args.verbose:
        print("-> transforming to LLVM-Bitcode...")
    os.system('llvm-as output.ll')

    # generating object file from bitcode via llc (low level compiler)
    object_file = "output.o"
    if args.verbose:
        print("-> compiling to linkable object file...")
    os.system('llc -filetype=obj ' + transformed_ir_file)

    # compiling to executable
    if args.verbose:
        print("-> compiling object files to executable...")
    os.system('swiftc -o ' + args.output_name + ' ' + object_file)

    if args.verbose:
        print("-> finished compilation chain!")
        print("")

    if args.clean:
        # Removing temp files
        if args.verbose:
            print("-> removing IR files")
        # os.system('rm ' + output_file + ' ' + ir_file)
        os.system('rm output.ll')

        if args.verbose:
            print("-> removing bitcode file")
        os.system('rm ' + transformed_ir_file)

        if args.verbose:
            print("-> removing object file")
        os.system('rm ' + object_file)


# starting main method
if __name__ == '__main__':
    main(sys.argv)
