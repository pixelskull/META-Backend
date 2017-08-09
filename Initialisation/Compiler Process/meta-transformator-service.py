#!/usr/bin/python
# -*- coding: utf-8 -*-
import os
import sys
import time
import json
import logging
import argparse

import pika

####
# Preparation code
####

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
        return 'target triple = "x86_64-apple-macosx10.12"'
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
# RabbitMQ subscriber code
####

def subscriber():
    connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
    logging.info("connection to server established...")
    channel = connection.channel()
    channel.confirm_delivery()
    logging.info("channel successfully created...")
    channel.queue_declare(queue='meta.deployment.irhandled')
    logging.info("queue successfully declared...")
    # tell rabbitMQ to not send more than one message to this worker
    channel.basic_qos(prefetch_count=1)
    channel.basic_consume(callback_subscriber,
                          queue='meta.deployment.irhandled')
    logging.info("start consuming from queue...")
    channel.start_consuming()


def callback_subscriber(ch, method, properties, body):
    logging.info("### Entering IR-Transformation")
    start_time = time.time()

    logging.debug("decoding json from message...")
    json_data = json.loads(body)

    logging.debug("recieved: ", json_data)
    content = json_data["Content"]

    logging.debug("splitting content to lines...")
    lines = parse_to_lines(content)

    # define transformations to IR
    logging.debug("preparing transformations...")
    transformations = [replace_datalayout_entry, replace_triple_entry,
                       replace_attribute0_entry, replace_attribute2_entry,
                       replace_attribute3_entry, replace_attribute6_entry]

    # apply transformations to IR
    logging.debug("applying transformations...")
    tmp_lines = lines
    for transformation in transformations:
        tmp_lines = list( map(lambda x: transformation(x), tmp_lines) )


    # joining List to new file content
    logging.debug("joining lines to string...")
    new_content = join_to_string(tmp_lines)

    logging.debug("alternating json to new content version...")
    json_data["Content"] = new_content

    logging.debug("dumping json to string...")
    json_string = json.dumps(json_data)

    logging.info("starting publishing of new content...")
    publish(json_string)
    ch.basic_ack(delivery_tag=method.delivery_tag)

    logging.info("-> finished IR-transformation in: %s seconds" % (time.time() - start_time) )
    logging.info("### Leaving IR-transformation")


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
        channel.queue_declare(queue='meta.deployment.irtransformed')
        logging.info("queue successfully declared...")
        channel.basic_publish(exchange='meta.deployment',
                              routing_key='irtransformed',
                              body=message)

        logging.info("message successfully published...")
        connection.close()
    except:
        logging.error('could not publish message due to unexpected error')


####
# Main Method
####
def main(argv):
    logging.basicConfig(filename='ir-transformator-service.log', level=logging.DEBUG)

    logging.info("starting subscriber...")
    subscriber()




# starting main method
if __name__ == '__main__':
    main(sys.argv)
