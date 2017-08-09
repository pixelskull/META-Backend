#!/usr/bin/python
# -*- coding: utf-8 -*-
import os
import json
import logging
import tempfile

import pika
import shutil


def write_to_file(filename="default.ll", file_content="NULL"):
    output_path = os.path.join(os.getcwd(), filename)
    file_object = open(output_path, 'w+')
    file_object.write(file_content)
    file_object.close()


def find_xcproject_file(rootdir):
    result = ""
    for root, _, files in os.walk(rootdir):
        for f in files:
            if f.endswith('.xcodeproj'):
                result = f
                break
    return result



def compile_file(filename, ir_content):
    logging.info("### Entering Object file Compilation Phase ###")
    logging.info(":::: ir_content -> " + ir_content)

    # create an tempFolder for storing files
    tempFolder = tempfile.gettempdir()
    # switch to tempFolder
    os.chdir(tempFolder)
    logging.debug("changed cwd to: " + os.getcwd())

    write_to_file(filename + ".ll", ir_content)

    # assambling IR code to bitcode
    bc_file = filename + ".bc"
    logging.info("-> transforming to LLVM-Bitcode...")
    os.system('llvm-as ' + filename + '.ll')

    # generating object file from bitcode via llc (low level compiler)
    object_file = filename + ".o"
    logging.info("-> compiling to linkable object file...")
    os.system('llc -filetype=obj ' + bc_file)

    logging.info("-> finished compilation chain!")

    # Removing temp files
    logging.info("-> removing IR files")
    os.system('rm ' + filename + '.ll')

    logging.info("-> removing bitcode file")
    os.system('rm ' + bc_file)

    output_path = tempFolder + "/" + object_file
    logging.debug("-> object file was stored at: " + output_path)
    return output_path

def compile_service(filpath, ident="service"):
    logging.info("### Entering Project Compilation Phase ###")
    # copy object file to project destination
    project_path = "~/.META/template/" # TODO: laod from config?
    basic_output_path = "~/.META/services/" # TODO: load from config

    output_path = basic_output_path + ident
    # copy files to output_path (xc-project and object file)
    shutil.copy2(project_path, output_path)
    logging.info("-> copied project files from: " + project_path + " to path: " + output_path)
    shutil.copy2(filepath, output_path + "/ComputeUnitHandler/ComputeUnitHandler/")
    logging.info("-> copied object file from: " + filepath +
                 " to path: " + output_path + "/ComputeUnitHandler/ComputeUnitHandler/")

    # change cwd to output_path
    os.chdir(output_path + "/ComputeUnitHandler/")
    logging.debug("changed cwd to: " + os.getcwd())
    currend_wd = os.getcwd()
    # finding the needed xcodeproj file
    xcproj = find_xcproject_file(currend_wd)
    logging.info("-> found xcodeproj file: " + xcproj)
    # execute build command
    object_file_path =  output_path + "/ComputeUnitHandler/ComputeUnitHandler/ComputeUnit.o"
    os.system("xcodebuild -project " + xcproj + " OTHER_LDFLAGS=" + object_file_path)
    logging.debug("-> building project via xcodebuild succeded")

    compiled_path = currend_wd + "build/Release/ComputeUnitHandler" #TODO add project name
    logging.info("-> Compiled Service is located at: " + compiled_path)
    return compiled_path


####
# RabbitMQ subscriber code
####

def subscriber():
    connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
    logging.info("connection to server established...")
    channel = connection.channel()
    channel.confirm_delivery()
    logging.info("channel successfully created...")
    channel.queue_declare(queue='meta.deployment.irtransformed')
    logging.info("queue successfully declared...")
    # tell rabbitMQ to not send more than one message to this worker
    channel.basic_qos(prefetch_count=1)
    channel.basic_consume(callback_subscriber,
                          queue='meta.deployment.irtransformed')
    logging.info("start consuming from queue...")
    channel.start_consuming()


def callback_subscriber(ch, method, properties, body):
    json_data = json.loads(body)

    object_path = compile_file(json_data["Id"], json_data["Content"])
    service_path = compile_service(object_path, json_data["Id"])

    json_data["Content"] = service_path
    json_string = json.dumps(json_data)

    publish(json_string)
    ch.basic_ack(delivery_tag=method.delivery_tag)


####
# RabbitMQ publisher code
####

# publishes given message to queue
def publish(message):
    try:
        connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
        logging.info("connection to server established...")
        channel = connection.channel()
        logging.info("channel successfully created...")
        channel.queue_declare(queue='meta.deployment.compiled')
        logging.info("queue successfully declared...")
        channel.basic_publish(exchange='meta.deployment',
                                routing_key='compiled',
                                body=message)

        logging.info("message successfully published...")
        connection.close()
    except:
        logging.error('could not publish message due to unexpected error')


def main():
    logging.basicConfig(filename='ir-compilation-service.log', level=logging.DEBUG)

    logging.info("starting subscriber...")
    subscriber()


# starting main method
if __name__ == '__main__':
    main()
