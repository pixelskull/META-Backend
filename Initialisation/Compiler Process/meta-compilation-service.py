#!/usr/bin/python
# -*- coding: utf-8 -*-
import os
import json
import logging
import tempfile

import pika


def write_to_file(filename="default.ll", file_content="NULL"):
    output_path = os.path.join(os.getcwd(), filename)
    file_object = open(output_path, 'w+')
    file_object.write(file_content)
    file_object.close()


def compile(filename, ir_content):
    logging.info("### Entering Compilation Process ###")
    logging.info(":::: ir_content -> " + ir_content)

    # create an tempFolder for storing files
    tempFolder = tempfile.gettempdir()
    # switch to tempFolder
    os.chdir(tempFolder)
    logging.debug("changed cwd to: " + os.getcwd())

    write_to_file(filename + ".ll", ir_content)

    # TODO: save file with content

    # assambling IR code to bitcode
    bc_file = filename + ".bc"
    logging.info("-> transforming to LLVM-Bitcode...")
    os.system('llvm-as ' + filename + '.ll')

    # generating object file from bitcode via llc (low level compiler)
    object_file = filename + ".o"
    logging.info("-> compiling to linkable object file...")
    os.system('llc -filetype=obj ' + bc_file)

    # compiling to executable
    logging.info("-> compiling object files to executable...")
    os.system('swiftc -o ' + filename + ' ' + object_file)

    logging.info("-> finished compilation chain!")

    # Removing temp files
    logging.info("-> removing IR files")
    os.system('rm ' + filename + '.ll')

    logging.info("-> removing bitcode file")
    os.system('rm ' + bc_file)

    logging.info("-> removing object file")
    os.system('rm ' + object_file)

    final_path = tempFolder + "/" + filename
    return final_path

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
    channel.basic_consume(callback_subscriber,
                          queue='meta.deployment.irtransformed')
    logging.info("start consuming from queue...")
    channel.start_consuming()


def callback_subscriber(ch, method, properties, body):
    json_data = json.loads(body)

    filepath = compile(json_data["id"], json_data["content"])

    json_data["content"] = filepath
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
