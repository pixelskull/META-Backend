#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import os

def main(argv):
    program_name = "python_test.out" #TODO hier noch den namen als parameter einlesen

    sdk = "xcrun -sdk iphoneos" #TODO hier noch anpassungen vornehmen, damit die sdk geãndert werden kann

    input_file = "hello.swift" #TODO hier noch die richtige file angeben
    output_file = "hello_py.ll" #TODO hier noch einen generischen output namen wählen
    print("-> compiling file for iOS...")
    os.system(sdk + ' swiftc -emit-ir -target arm64-apple-ios10.0 ' + input_file + ' -o ' + output_file)

    ir_file = "output.ll" #TODO hier noch einen generischen output namen wählen
    print("-> transforming IR Code for macOS...")
    os.system('./ir-transformator.py ' + output_file)

    transformed_ir_file = "output.bc" #TODO hier noch einen generischen output namen wählen
    print("-> transforming to LLVM-Bitcode...")
    os.system('llvm-as ' + ir_file)

    object_file = "output.o" #TODO hier noch einen generischen output namen wählen
    print("-> compiling to linkable object file...")
    os.system('llc -filetype=obj ' + transformed_ir_file)

    print("-> compiling object files to executable...")
    os.system('swiftc -o ' + program_name + ' ' + object_file)

    print("-> finished compilation chain!")
    print("")

    # Removing temp files
    print("-> removing IR files")
    os.system('rm ' + output_file + ' ' + ir_file)

    print("-> removing bitcode file")
    os.system('rm ' + transformed_ir_file)

    print("-> removing object file")
    os.system('rm ' + object_file)

# starting main method
if __name__ == '__main__':
    main(sys.argv)
